"""
Case 3 – Log-Queue-Stau als Pipeline-Blocker

Hypothese:
  - Queue(maxsize=1000) in logger_process.py
  - log_queue.put() in collector.py ist BLOCKING (kein Timeout, kein put_nowait)
  - Wenn der Logger-Prozess einfriert (z.B. hängender Django-DB-Call),
    füllt sich die Queue; alle Worker-Prozesse und der PipelineManager
    blockieren synchron → Pipeline friert ein ohne Alarm

Test-Methodik (KEINE Code-Patches – nur POSIX-Signale + qsize-Monitoring):
  1. logger_process.py wird um einen Monitoring-Thread erweitert (CASE3_QMON)
     → druckt alle 200ms: "[QMON] <timestamp> <qsize>" auf stdout
  2. main_sim.py starten, PIDs extrahieren
  3. Auf READY_AFTER warten (System läuft normal)
  4. 5s Baseline – qsize-Werte bei normaler Last
  5. SIGSTOP an Logger-Prozess → Logger pausiert (simuliert hängenden Django-Call)
  6. Beobachten: Pipeline-Durchsatz bricht ein (Worker blockieren auf put())
  7. Messen: Zeit bis kein "Pipeline finished" mehr erscheint
  8. Prüfen: main.py reagiert NICHT (kein "Shutting down")
  9. SIGCONT an Logger → Queue drainiert; qsize-Kurve zeigt Abbau
  10. Beide Patches werden rückgängig gemacht

Modifizierte Dateien:
  - gbbm_rosi_main/logger_process.py  (CASE3_QMON Monitoring-Thread, ~5 Zeilen)
"""

import csv
import os
import re
import select
import signal
import subprocess
import time
from pathlib import Path

import psutil

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent

LOGGER_PROC = REPO / "gbbm_rosi_main/logger_process.py"
SIGSTOP_DURATION_S = 30


# ──────────────────────────────────────────────────────────────────────────────
# Patch-Logik
# ──────────────────────────────────────────────────────────────────────────────

QMON_MARKER = "        state.value = LoggerProcessState.RUNNING.value\n"
QMON_CODE = (
    "        state.value = LoggerProcessState.RUNNING.value\n"
    "        import threading as _t; import time as _ti  # CASE3_QMON\n"
    "        def _qmon():\n"
    "            while not stop_event.is_set():\n"
    "                try:\n"
    "                    print(f'[QMON] {_ti.time():.3f} {log_queue.qsize()}', flush=True)\n"
    "                except Exception:\n"
    "                    pass\n"
    "                _ti.sleep(0.2)\n"
    "        _t.Thread(target=_qmon, daemon=True).start()  # CASE3_QMON\n"
)


def patch_logger_qmon() -> str:
    text = LOGGER_PROC.read_text()
    if "CASE3_QMON" in text:
        print("  [Patch] QMON bereits vorhanden", flush=True)
        return text
    if QMON_MARKER not in text:
        raise RuntimeError(f"Marker nicht gefunden in {LOGGER_PROC}")
    patched = text.replace(QMON_MARKER, QMON_CODE, 1)
    LOGGER_PROC.write_text(patched)
    print("  [Patch] logger_process.py: qsize-Monitor-Thread eingefügt", flush=True)
    return text


def unpatch_logger_qmon(original: str) -> None:
    LOGGER_PROC.write_text(original)
    print("  [Unpatch] logger_process.py wiederhergestellt", flush=True)


# ──────────────────────────────────────────────────────────────────────────────
# PID-Extraktion
# ──────────────────────────────────────────────────────────────────────────────

def find_logger_pid(main_pid: int, known_pids: set[int]) -> int | None:
    try:
        parent = psutil.Process(main_pid)
        for child in parent.children(recursive=False):
            if child.pid not in known_pids:
                return child.pid
    except psutil.NoSuchProcess:
        pass
    return None


def read_until_ready(proc, timeout_s: float = 90) -> tuple[list[str], dict, list[tuple]]:
    lines = []
    pids = {}
    qmon_entries: list[tuple[float, int]] = []
    deadline = time.time() + timeout_s

    while time.time() < deadline:
        if proc.poll() is not None:
            break
        readable, _, _ = select.select([proc.stdout], [], [], 0.3)
        if not readable:
            continue
        line = proc.stdout.readline()
        if not line:
            break
        lines.append(line)

        if "[QMON]" in line:
            parts = line.strip().split()
            try:
                qmon_entries.append((float(parts[1]), int(parts[2])))
            except (IndexError, ValueError):
                pass
            continue

        if "Pipeline Manager process" in line:
            m = re.search(r"\[(\d+)\]", line)
            if m:
                pids["PipelineManager"] = int(m.group(1))

        if "Inspection Data Handler" in line and "InspDataHandler" not in pids:
            m = re.search(r"\[(\d+)\]", line)
            if m:
                pids["InspDataHandler"] = int(m.group(1))

        if "Frame Grabber" in line and "FrameGrabber" not in pids:
            m = re.search(r"\[(\d+)\]", line)
            if m:
                pids["FrameGrabber"] = int(m.group(1))

        if "READY_AFTER" in line:
            known = set(pids.values())
            logger_pid = find_logger_pid(proc.pid, known)
            if logger_pid:
                pids["Logger"] = logger_pid
            break

    return lines, pids, qmon_entries


# ──────────────────────────────────────────────────────────────────────────────
# Haupttest
# ──────────────────────────────────────────────────────────────────────────────

def run_case() -> dict:
    print("\n=== Case 3: Log-Queue-Stau (SIGSTOP + qsize-Monitoring) ===\n")

    original_logger = LOGGER_PROC.read_text()
    patch_logger_qmon()

    qmon_series: list[tuple[float, int, str]] = []  # (t_abs, qsize, phase)
    all_lines = []
    pipeline_timestamps = []
    freeze_detected = False
    freeze_time = None
    main_shutdown_detected = False

    try:
        proc = subprocess.Popen(
            [str(REPO / ".venv/bin/python"), "main_sim.py"],
            cwd=str(REPO),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        # Phase 1: Startup + READY_AFTER
        startup_lines, pids, startup_qmon = read_until_ready(proc, timeout_s=90)
        all_lines.extend(startup_lines)
        for t, sz in startup_qmon:
            qmon_series.append((t, sz, "startup"))

        ready = any("READY_AFTER" in l for l in startup_lines)
        if not ready or "Logger" not in pids:
            proc.stdout.close(); proc.kill(); proc.wait(timeout=5)
            return {"success": False, "error": "READY_AFTER oder Logger-PID fehlt", "pids": pids}

        logger_pid = pids["Logger"]
        print(f"  System bereit. PIDs: {pids}", flush=True)

        # Phase 2: Baseline 5s
        baseline_deadline = time.time() + 5
        pipelines_baseline = 0
        while time.time() < baseline_deadline:
            readable, _, _ = select.select([proc.stdout], [], [], 0.2)
            if readable:
                line = proc.stdout.readline()
                if line:
                    all_lines.append(line)
                    if "[QMON]" in line:
                        parts = line.strip().split()
                        try:
                            qmon_series.append((float(parts[1]), int(parts[2]), "baseline"))
                        except (IndexError, ValueError):
                            pass
                    elif "Pipeline finished" in line and "TOOK=" in line:
                        pipelines_baseline += 1

        print(f"  Baseline: {pipelines_baseline} Pipelines in 5s", flush=True)

        # Phase 3: SIGSTOP
        stop_time = time.time()
        os.kill(logger_pid, signal.SIGSTOP)
        print(f"  SIGSTOP → Logger (PID={logger_pid})", flush=True)

        last_pipeline_t = stop_time
        pipelines_after_stop = 0
        observe_deadline = stop_time + SIGSTOP_DURATION_S

        while time.time() < observe_deadline:
            if proc.poll() is not None:
                main_shutdown_detected = True
                remaining = proc.stdout.read()
                if remaining:
                    all_lines.extend(remaining.splitlines(keepends=True))
                break

            readable, _, _ = select.select([proc.stdout], [], [], 0.2)
            if readable:
                line = proc.stdout.readline()
                if line:
                    all_lines.append(line)
                    if "Pipeline finished" in line and "TOOK=" in line:
                        pipelines_after_stop += 1
                        last_pipeline_t = time.time()
                        m = re.search(r"TOOK=(\d+)\s*ms", line)
                        ms = int(m.group(1)) if m else "?"
                        print(f"  In-flight Pipeline (TOOK={ms}ms, +{time.time()-stop_time:.1f}s)", flush=True)
                    if any(kw in line for kw in ["Shutting down", "CRASHED"]):
                        main_shutdown_detected = True
            else:
                idle = time.time() - last_pipeline_t
                if idle > 8 and not freeze_detected:
                    freeze_detected = True
                    freeze_time = time.time()
                    print(f"  [!] FREEZE: kein Pipeline-Event für {idle:.1f}s", flush=True)

        # Phase 4: SIGCONT – Queue drainiert, qsize sichtbar
        print(f"\n  SIGCONT → Logger (PID={logger_pid})", flush=True)
        cont_time = time.time()
        os.kill(logger_pid, signal.SIGCONT)

        drain_deadline = cont_time + 15
        while time.time() < drain_deadline:
            if proc.poll() is not None:
                break
            readable, _, _ = select.select([proc.stdout], [], [], 0.2)
            if readable:
                line = proc.stdout.readline()
                if line:
                    all_lines.append(line)
                    if "[QMON]" in line:
                        parts = line.strip().split()
                        try:
                            t_abs = float(parts[1])
                            sz = int(parts[2])
                            phase = "drain"
                            qmon_series.append((t_abs, sz, phase))
                            if sz % 100 == 0 or sz < 10:
                                print(f"  [QMON] qsize={sz} (T+{t_abs-stop_time:.1f}s)", flush=True)
                        except (IndexError, ValueError):
                            pass
                    if "Pipeline finished" in line and "TOOK=" in line:
                        pipeline_timestamps.append(time.time())

    finally:
        try:
            proc.stdout.close()
        except Exception:
            pass
        if proc.poll() is None:
            proc.kill()
        proc.wait(timeout=5)
        unpatch_logger_qmon(original_logger)

    # CSV speichern
    if qmon_series:
        t0 = qmon_series[0][0]
        csv_path = RESULTS_DIR / "case3_queue_depth_timeseries.csv"
        with open(csv_path, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["t_rel_s", "t_abs", "qsize", "phase"])
            for t_abs, sz, phase in qmon_series:
                w.writerow([round(t_abs - t0, 3), round(t_abs, 3), sz, phase])
        print(f"  Queue-Tiefe CSV: {csv_path} ({len(qmon_series)} Einträge)")

    freeze_latency = round(freeze_time - stop_time, 2) if freeze_detected else None

    result = {
        "success": True,
        "pids": pids,
        "pipelines_baseline_5s": pipelines_baseline,
        "pipelines_after_sigstop": pipelines_after_stop,
        "freeze_detected": freeze_detected,
        "time_to_freeze_s": freeze_latency,
        "qmon_entries_total": len(qmon_series),
        "main_shutdown_detected": main_shutdown_detected,
        "sigstop_duration_s": SIGSTOP_DURATION_S,
    }

    log_path = RESULTS_DIR / "case3_log_queue_cascade.log"
    log_path.write_text("".join(all_lines))
    print(f"  Log gespeichert: {log_path}")

    return result


if __name__ == "__main__":
    r = run_case()
    print("\n=== ERGEBNIS Case 3 ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
