"""
Case 2 – RAM Disk als Single Point of Failure

Hypothese:
  - store_images_to_disk hat kein try/except für OSError (ENOSPC)
  - Bei voller RAM-Disk crasht der Worker-Prozess unbehandelt
  - MPWorkerPool hat keinen Worker-Restart → Step 5 blockiert dauerhaft
  - PipelineManager-Prozess läuft weiter (kein Crash!) → main.py erkennt nichts
  → stiller Ausfall

Test-Methodik (nicht-invasiv, vollständig reversibel):
  1. Patch store_images_to_disk in der venv:
     Nach der Warmup-Pipeline wird für alle echten Inspektionen
     OSError(28, "No space left on device") geworfen – simuliert volle RAM-Disk
  2. main_sim.py starten, Verhalten beobachten
  3. Messen:
     - Wie viele Pipelines schließen ab (erwartet: Warmup + 0)
     - Friert Step 5 ein oder crasht der PipelineManager?
     - Erkennt main.py das Problem?

Modifizierte Datei (automatisch zurückgesetzt):
  - .venv/.../common/functions/load_store_imgs.py
    (OSError-Injection nach Warmup-Check)
"""

import re
import select
import subprocess
import time
from pathlib import Path

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent

LOAD_STORE = (
    REPO
    / ".venv/lib/python3.13/site-packages/gbbm_rosi_dependencies/common/functions/load_store_imgs.py"
)

# Marker innerhalb store_images_to_disk – nach dem Warmup-Check,
# kurz bevor die eigentliche Disk-Schreiboperation beginnt
INJECT_AFTER = "    raw_count = 0\n    for sm in additional_job_info:"


def patch_store_images(inject_after: str) -> str:
    """Injiziert OSError nach dem ersten Schreibversuch (nicht in Warmup)."""
    text = LOAD_STORE.read_text()
    if "# CASE2_ENOSPC" in text:
        print("  [Patch] Patch bereits vorhanden", flush=True)
        return text

    original = text
    injection = (
        "    if not insp_data.is_warmup:\n"
        "        raise OSError(28, 'No space left on device')  # CASE2_ENOSPC\n"
    )
    patched = text.replace(inject_after, injection + inject_after, 1)
    if "# CASE2_ENOSPC" not in patched:
        print(f"  [WARN] Patch-Marker nicht gefunden in {LOAD_STORE.name}", flush=True)
        return original
    LOAD_STORE.write_text(patched)
    print(
        f"  [Patch] OSError(ENOSPC) nach Warmup in store_images_to_disk eingefügt",
        flush=True,
    )
    return original


def unpatch_store_images(original: str) -> None:
    LOAD_STORE.write_text(original)
    print("  [Unpatch] load_store_imgs.py wiederhergestellt", flush=True)


def run_case() -> dict:
    print("\n=== Case 2: RAM-Disk SPOF – OSError(ENOSPC) Simulation ===\n")

    original_text = LOAD_STORE.read_text()
    patch_store_images(INJECT_AFTER)

    log_lines = []
    pipelines_completed = 0
    warmup_done = False
    step5_freeze_detected = False
    pm_crash_detected = False
    main_shutdown_detected = False
    oserror_seen = False
    freeze_time = None

    try:
        proc = subprocess.Popen(
            [str(REPO / ".venv/bin/python"), "main_sim.py"],
            cwd=str(REPO),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        deadline = time.time() + 90
        last_pipeline_time = None
        ready = False

        while time.time() < deadline:
            if proc.poll() is not None:
                remaining = proc.stdout.read()
                if remaining:
                    log_lines.extend(remaining.splitlines(keepends=True))
                main_shutdown_detected = True
                pm_crash_detected = True
                print(
                    f"  [!] main_sim.py beendet (returncode={proc.returncode})", flush=True
                )
                break

            readable, _, _ = select.select([proc.stdout], [], [], 0.3)
            if not readable:
                if ready and last_pipeline_time and not step5_freeze_detected:
                    idle = time.time() - last_pipeline_time
                    if idle > 20:
                        step5_freeze_detected = True
                        freeze_time = time.time()
                        print(
                            f"  [!] Step-5-Freeze erkannt: kein Pipeline-Abschluss für {idle:.1f}s",
                            flush=True,
                        )
                        deadline = min(deadline, freeze_time + 15)
                continue

            line = proc.stdout.readline()
            if not line:
                break
            log_lines.append(line)

            if "READY_AFTER" in line:
                ready = True
                last_pipeline_time = time.time()
                print("  System bereit.", flush=True)

            if "Warming up complete" in line:
                warmup_done = True
                print("  Warmup abgeschlossen – erste echte Inspektion beginnt.", flush=True)

            if "Pipeline finished" in line and "TOOK=" in line:
                pipelines_completed += 1
                last_pipeline_time = time.time()
                m = re.search(r"TOOK=(\d+)\s*ms", line)
                ms = int(m.group(1)) if m else "?"
                print(f"  Pipeline {pipelines_completed} abgeschlossen (TOOK={ms}ms)", flush=True)

            # Fehler-Indikatoren
            for kw in ["OSError", "ENOSPC", "No space left", "space left on device",
                       "E_IMAGE_PATH", "SharedException"]:
                if kw.lower() in line.lower():
                    oserror_seen = True
                    print(f"  [!] Disk-Fehler im Log: {line.strip()[:120]}", flush=True)

            if any(kw in line for kw in ["CRASHED", "crashed", "Traceback", "Exception"]):
                pm_crash_detected = True
                print(f"  [!] Exception/Crash: {line.strip()[:120]}", flush=True)

            if "Shutting down" in line:
                main_shutdown_detected = True
                print(f"  [!] Shutdown: {line.strip()[:80]}", flush=True)

        if proc.poll() is None:
            proc.stdout.close()
            proc.kill()
        proc.wait(timeout=5)

    finally:
        unpatch_store_images(original_text)

    result = {
        "warmup_completed": warmup_done,
        "pipelines_after_warmup": max(0, pipelines_completed - 1),
        "oserror_in_log": oserror_seen,
        "step5_freeze_detected": step5_freeze_detected,
        "pm_crash_detected": pm_crash_detected,
        "main_shutdown_detected": main_shutdown_detected,
        "patch": "OSError(28) in store_images_to_disk nach Warmup",
    }

    log_path = RESULTS_DIR / "case2_disk_full.log"
    log_path.write_text("".join(log_lines))
    print(f"\n  Log gespeichert: {log_path}")

    return result


if __name__ == "__main__":
    r = run_case()
    print("\n=== ERGEBNIS Case 2 ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
