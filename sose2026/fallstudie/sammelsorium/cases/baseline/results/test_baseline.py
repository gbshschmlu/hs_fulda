"""
Baseline-Messung des ROSI-Simulators.

Misst:
- Startup-Zeit bis READY_AFTER
- Durchsatz (Inspektionen/s)
- Pipeline-Laufzeit pro Inspektion (min/avg/max)
- Gesamtlaufzeit
"""

import re
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).parent.parent.parent
LOG_OUT = Path(__file__).parent / "baseline_run.log"


def run_baseline() -> dict:
    start_wall = time.time()

    proc = subprocess.Popen(
        [str(REPO / ".venv/bin/python"), "main_sim.py"],
        cwd=str(REPO),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    lines = []
    ready_after_s = None
    pipeline_times_ms = []
    t_first_pipeline = None
    t_last_pipeline = None

    try:
        for line in proc.stdout:
            lines.append(line)
            stripped = line.strip()

            # Startup complete
            m = re.search(r"READY_AFTER=(\d+)\s*s", stripped)
            if m:
                ready_after_s = int(m.group(1))

            # Pipeline timing
            m = re.search(r"Pipeline finished.*TOOK=(\d+)\s*ms", stripped)
            if m:
                ms = int(m.group(1))
                pipeline_times_ms.append(ms)
                now = time.time()
                if t_first_pipeline is None:
                    t_first_pipeline = now
                t_last_pipeline = now

            if "Shutting down all subsystems" in stripped:
                break

    finally:
        proc.wait(timeout=10)

    total_wall = time.time() - start_wall
    run_duration = (t_last_pipeline - t_first_pipeline) if (t_first_pipeline and t_last_pipeline) else 0.0
    n = len(pipeline_times_ms)
    throughput = n / run_duration if run_duration > 0 else 0.0

    result = {
        "startup_s": ready_after_s,
        "total_wall_s": round(total_wall, 2),
        "run_duration_s": round(run_duration, 2),
        "inspections": n,
        "throughput_per_s": round(throughput, 2),
        "pipeline_ms_min": min(pipeline_times_ms) if pipeline_times_ms else None,
        "pipeline_ms_avg": round(sum(pipeline_times_ms) / n, 1) if n else None,
        "pipeline_ms_max": max(pipeline_times_ms) if pipeline_times_ms else None,
    }

    LOG_OUT.write_text("".join(lines))
    return result


if __name__ == "__main__":
    print("Starte Baseline-Messung ...", flush=True)
    r = run_baseline()
    print("\n=== BASELINE ERGEBNIS ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
    print(f"\nLog gespeichert: {LOG_OUT}")
