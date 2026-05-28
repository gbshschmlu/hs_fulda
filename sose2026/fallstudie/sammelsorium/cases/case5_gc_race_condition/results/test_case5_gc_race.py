"""
Case 5 – GC Race Condition im Worker-Pool unter Last

Hypothese:
  - Worker-GC zerstört SharedMemory-Blöcke nach remove_after_seconds=10
  - Wenn Verarbeitungszeit eines Frames >10s dauert (durch künstliche Last/Delay),
    können Blöcke destroyed werden bevor der PipelineManager sie noch braucht
  - Folge: FileNotFoundError oder BrokenPipeError beim nächsten .get_data()-Aufruf

Test-Methodik (nicht-invasiv):
  1. Reduziere remove_after_seconds temporär von 10 auf 2
  2. Füge künstliche Verzögerung in convert_inspection_to_model ein (4s sleep)
     → Worker von Step 4 (encode_frames) werden idle für >2s während Step 6 läuft
     → GC triggert und zerstört ggf. noch referenzierte Blöcke
  3. Beobachte ob FileNotFoundError oder ähnliche Fehler auftreten

Hinweis: Modifiziert temporär:
  - .venv/.../worker/types/base.py  (remove_after_seconds: 10 → 2)
  - gbbm_rosi_django/.../inspection/utils.py  (sleep in convert_inspection_to_model)

Beide Änderungen werden nach dem Test rückgängig gemacht.
"""

import re
import select
import subprocess
import time
from pathlib import Path

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent

WORKER_BASE = REPO / ".venv/lib/python3.13/site-packages/gbbm_rosi_dependencies/worker/types/base.py"
CONVERT_UTILS = REPO / "../gbbm_rosi_django/gbbm_rosi_django/inspection/utils.py"


def patch_remove_after_seconds(value: int) -> None:
    """Ändert remove_after_seconds im Worker-Base."""
    text = WORKER_BASE.read_text()
    import re
    patched = re.sub(
        r"(cleanup_old_sm_blocks\(\s*blocks=sm_blocks_in_use,\s*remove_after_seconds=)\d+",
        rf"\g<1>{value}",
        text,
    )
    WORKER_BASE.write_text(patched)
    print(f"  [Patch] remove_after_seconds={value} in {WORKER_BASE.name}", flush=True)


def patch_convert_inspection_delay(delay_s: float) -> None:
    """Fügt einen sleep in convert_inspection_to_model ein."""
    text = CONVERT_UTILS.read_text()
    marker = "    if not inspection_data or not isinstance(inspection_data, InspectionData):"
    if "# CASE5_DELAY" in text:
        print(f"  [Patch] convert delay bereits vorhanden", flush=True)
        return
    sleep_code = f"    import time; time.sleep({delay_s})  # CASE5_DELAY\n"
    patched = text.replace(marker, sleep_code + marker)
    CONVERT_UTILS.write_text(patched)
    print(f"  [Patch] time.sleep({delay_s}) in convert_inspection_to_model", flush=True)


def unpatch_convert_inspection_delay() -> None:
    """Entfernt den sleep aus convert_inspection_to_model."""
    text = CONVERT_UTILS.read_text()
    import re
    patched = re.sub(r"    import time; time\.sleep\(\d+\.?\d*\)  # CASE5_DELAY\n", "", text)
    CONVERT_UTILS.write_text(patched)
    print("  [Unpatch] convert delay entfernt", flush=True)


def run_case() -> dict:
    print("\n=== Case 5: GC Race Condition ===\n")

    # --- Patches anwenden ---
    original_worker = WORKER_BASE.read_text()
    patch_remove_after_seconds(2)
    patch_convert_inspection_delay(4.0)

    log_lines = []
    errors_found = []
    crash_detected = False
    inspections_completed = 0

    try:
        proc = subprocess.Popen(
            [str(REPO / ".venv/bin/python"), "main_sim.py"],
            cwd=str(REPO),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )

        deadline = time.time() + 120  # Genug Zeit für mehrere Inspektionen mit Delay

        while time.time() < deadline:
            readable, _, _ = select.select([proc.stdout], [], [], 0.5)

            if proc.poll() is not None:
                # Prozess beendet – restlichen Output lesen
                remaining = proc.stdout.read()
                if remaining:
                    log_lines.extend(remaining.splitlines(keepends=True))
                break

            if not readable:
                continue

            line = proc.stdout.readline()
            if not line:
                break
            log_lines.append(line)

            # Nach Fehlerindikatoren suchen
            for keyword in ["FileNotFoundError", "BrokenPipeError", "CRASHED", "OperationalError",
                            "No such file", "shared_memory", "Segfault", "segfault"]:
                if keyword.lower() in line.lower():
                    errors_found.append(line.strip())
                    print(f"  [!] Fehler gefunden: {line.strip()[:120]}", flush=True)

            if "Pipeline finished" in line and "TOOK=" in line:
                inspections_completed += 1
                m = re.search(r"TOOK=(\d+)\s*ms", line)
                ms = int(m.group(1)) if m else "?"
                print(f"  Inspektion {inspections_completed} fertig (TOOK={ms}ms)", flush=True)

            if "CRASHED" in line or "crashed" in line:
                crash_detected = True
                print(f"  [!] CRASH: {line.strip()[:120]}", flush=True)

            if "Shutting down" in line:
                # Warte noch etwas für abschließende Fehler
                time.sleep(1)
                remaining = proc.stdout.read()
                if remaining:
                    log_lines.extend(remaining.splitlines(keepends=True))
                break

        if proc.poll() is None:
            proc.kill()
        proc.wait(timeout=5)

    finally:
        # --- Patches rückgängig machen ---
        WORKER_BASE.write_text(original_worker)
        print("  [Unpatch] remove_after_seconds=10 wiederhergestellt", flush=True)
        unpatch_convert_inspection_delay()

    result = {
        "inspections_completed": inspections_completed,
        "errors_found": len(errors_found),
        "error_samples": errors_found[:5],
        "crash_detected": crash_detected,
        "gc_triggered_note": "remove_after_seconds=2, convert delay=4s",
    }

    log_path = RESULTS_DIR / "case5_gc_race.log"
    log_path.write_text("".join(log_lines))
    print(f"\n  Log gespeichert: {log_path}")

    return result


if __name__ == "__main__":
    r = run_case()
    print("\n=== ERGEBNIS Case 5 ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
