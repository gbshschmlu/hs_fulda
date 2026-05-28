"""
Case 1 – Lücken in der Laufzeit-Prozesssupervision

Hypothese:
  - main_sim.py erkennt den Ausfall des PipelineManagers innerhalb von ~1s
  - main_sim.py erkennt den Ausfall von LoggerProcess, FrameGrabberProcess und
    InspectionDataHandlerProcess NICHT (kein Neustart, kein Alarm)

Methodik:
  - Starte main_sim.py als Subprocess, capture stdout
  - Parse Log-Output um PIDs der Hauptprozesse zu extrahieren
  - Warte auf "READY_AFTER" (System läuft vollständig)
  - Sende SIGKILL an Zielprozess
  - Miss: Zeit bis main_sim.py sich beendet (detektiert) oder nicht (Timeout)

PID-Extraktion aus Log-Format:
  "11:22:22.308 |    DEBUG | [PID] Inspection Data Handler initialized"
  "11:22:22.541 |    DEBUG | [PID] Frame Grabber Simulator initialized"
  "11:22:22.753 |     INFO | [PID] Pipeline Manager process started"
  Logger-PID: nicht direkt im Log → wird über psutil als child gefunden
"""

import os
import re
import select
import signal
import subprocess
import sys
import time
from pathlib import Path

import psutil

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent
TIMEOUT_DETECT_S = 20.0  # Wartezeit nach SIGKILL (Shutdown kann 15s dauern)


def extract_pid_from_log(line: str, pattern: str) -> int | None:
    """Extrahiert PID aus einer Log-Zeile wenn pattern vorkommt."""
    if pattern not in line:
        return None
    m = re.search(r"\[(\d+)\]", line)
    return int(m.group(1)) if m else None


def find_logger_pid(main_pid: int, known_pids: set[int]) -> int | None:
    """Findet Logger-PID als unbekannter child von main_pid."""
    try:
        parent = psutil.Process(main_pid)
        for child in parent.children(recursive=True):
            if child.pid not in known_pids:
                return child.pid
    except psutil.NoSuchProcess:
        pass
    return None


def read_output_until_ready(proc, timeout_s: float = 30) -> tuple[list[str], dict[str, int]]:
    """Liest subprocess-output bis 'READY_AFTER' gefunden, extrahiert PIDs."""
    lines = []
    pids = {}
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

        # InspectionDataHandler PID
        pid = extract_pid_from_log(line, "Inspection Data Handler")
        if pid and "InspDataHandler" not in pids:
            pids["InspDataHandler"] = pid

        # FrameGrabber PID
        pid = extract_pid_from_log(line, "Frame Grabber")
        if pid and "FrameGrabber" not in pids:
            pids["FrameGrabber"] = pid

        # PipelineManager PID
        pid = extract_pid_from_log(line, "Pipeline Manager process")
        if pid and "PipelineManager" not in pids:
            pids["PipelineManager"] = pid

        # System bereit
        if "READY_AFTER" in line:
            # Logger-PID über psutil
            known = set(pids.values())
            logger_pid = find_logger_pid(proc.pid, known)
            if logger_pid:
                pids["Logger"] = logger_pid
            break

    return lines, pids


def run_case(target_label: str) -> dict:
    """
    Startet ROSI-Simulator, wartet bis bereit, killt Zielprozess,
    misst ob/wie schnell main_sim.py das bemerkt.
    """
    print(f"\n{'='*60}", flush=True)
    print(f"  SIGKILL an: {target_label}", flush=True)
    print(f"{'='*60}", flush=True)

    proc = subprocess.Popen(
        [str(REPO / ".venv/bin/python"), "main_sim.py"],
        cwd=str(REPO),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    # Startup abwarten und PIDs extrahieren
    startup_lines, pids = read_output_until_ready(proc, timeout_s=35)

    ready = any("READY_AFTER" in l for l in startup_lines)
    if not ready:
        proc.kill()
        proc.wait(timeout=5)
        return {
            "target": target_label,
            "success": False,
            "error": f"System wurde nicht bereit (gefundene PIDs: {pids})",
        }

    print(f"  System bereit. PIDs: {pids}", flush=True)

    target_pid = pids.get(target_label)
    if target_pid is None:
        proc.kill()
        proc.wait(timeout=5)
        return {
            "target": target_label,
            "success": False,
            "error": f"Ziel-PID nicht gefunden. Bekannte PIDs: {pids}",
        }

    print(f"  Sende SIGKILL → {target_label} (PID={target_pid})", flush=True)
    kill_time = time.time()

    try:
        os.kill(target_pid, signal.SIGKILL)
    except ProcessLookupError:
        proc.kill()
        proc.wait(timeout=5)
        return {"target": target_label, "success": False, "error": "Prozess bereits beendet"}

    # Phase 2: Beobachtungsfenster
    all_lines = startup_lines.copy()
    detected = False
    detection_time = None
    detection_trigger = None
    deadline = kill_time + TIMEOUT_DETECT_S

    while time.time() < deadline:
        # Prozess beendet?
        ret = proc.poll()
        if ret is not None:
            detected = True
            detection_time = time.time()
            detection_trigger = f"Prozess beendet (returncode={ret})"
            break

        # Output überwachen
        readable, _, _ = select.select([proc.stdout], [], [], 0.1)
        if readable:
            line = proc.stdout.readline()
            if line:
                all_lines.append(line)
                stripped = line.strip()
                if any(kw in stripped for kw in ["Shutting down", "CRASHED", "crashed", "OperationalError"]):
                    detected = True
                    detection_time = time.time()
                    detection_trigger = f"Keyword in Output: {stripped[:80]}"
                    break

    # Weiterlaufende Prozesse nach dem Fenster
    still_running = proc.poll() is None

    # Aufräumen – stdout NICHT lesen (child-Prozesse halten Pipe offen)
    proc.stdout.close()
    if proc.poll() is None:
        proc.kill()
    proc.wait(timeout=8)

    ttd = round(detection_time - kill_time, 3) if detection_time else None
    result = {
        "target": target_label,
        "target_pid": target_pid,
        "detected": detected,
        "time_to_detection_s": ttd,
        "still_running_after_timeout": still_running,
        "detection_trigger": detection_trigger,
        "success": True,
    }

    status = "DETEKTIERT" if detected else "NICHT DETEKTIERT"
    print(f"  → {status} | TTD={ttd}s | weitergelaufen={still_running}", flush=True)
    if detection_trigger:
        print(f"  → Trigger: {detection_trigger}", flush=True)

    # Log speichern
    log_path = RESULTS_DIR / f"case1_{target_label.lower()}_kill.log"
    log_path.write_text("".join(all_lines))

    return result


def run_all() -> list[dict]:
    results = []
    # Wichtig: PipelineManager zuerst – bei ihm wird Detektion erwartet
    targets = ["PipelineManager", "FrameGrabber", "InspDataHandler", "Logger"]
    for t in targets:
        r = run_case(t)
        results.append(r)
        time.sleep(3)  # Kurze Pause – Ports / SharedMemory freigeben
    return results


if __name__ == "__main__":
    print("\n=== Case 1: Laufzeit-Prozesssupervision ===")
    print("Hypothese: Nur PipelineManager-Crash wird in main_sim.py erkannt\n")
    results = run_all()

    print("\n" + "="*60)
    print("ZUSAMMENFASSUNG Case 1")
    print("="*60)
    for r in results:
        if not r.get("success"):
            print(f"  {r['target']:20s}: FEHLER – {r.get('error', '?')}")
        else:
            status = "✓ DETEKTIERT" if r["detected"] else "✗ NICHT DETEKTIERT"
            print(f"  {r['target']:20s}: {status:20s} TTD={r['time_to_detection_s']}s")
