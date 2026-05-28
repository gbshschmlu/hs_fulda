"""
Case 2 – Speicherfüllstand über die Zeit (Monitoring-Messung)

Ergänzungsmessung zu test_case2_disk_full.py.
Kein Fehler wird injiziert – stattdessen wird gemessen, wie schnell
/dev/shm und IMAGE_OUT_PATH im Normalbetrieb anwachsen.

Messgröße:
  - /dev/shm: belegter Speicher (MB) alle 1s
  - ~/ROSI/Images/Out: Gesamtgröße (MB) alle 5s
  - Anzahl SM-Blöcke in /dev/shm (ls /dev/shm | wc -l) alle 1s

Keine Code-Änderungen, keine Patches.
"""

import csv
import select
import shutil
import subprocess
import time
from pathlib import Path

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent

SHM_PATH = Path("/dev/shm")
IMAGE_OUT_PATH = Path.home() / "ROSI/Images/Out"
MONITOR_DURATION_S = 60


def get_shm_usage():
    usage = shutil.disk_usage(str(SHM_PATH))
    sm_block_count = len(list(SHM_PATH.glob("*")))
    return usage.used / 1024**2, sm_block_count


def get_image_out_size():
    if not IMAGE_OUT_PATH.exists():
        return 0.0
    total = sum(f.stat().st_size for f in IMAGE_OUT_PATH.rglob("*") if f.is_file())
    return total / 1024**2


def run_case() -> dict:
    print("\n=== Case 2 Speicherfüllstand – Monitoring-Messung ===\n")

    # Basislinie vor dem Start
    shm_before, sm_count_before = get_shm_usage()
    img_before = get_image_out_size()
    print(f"  Vor Start: /dev/shm {shm_before:.1f} MB, SM-Blöcke={sm_count_before}, Images/Out={img_before:.1f} MB", flush=True)

    series: list[dict] = []

    proc = subprocess.Popen(
        [str(REPO / ".venv/bin/python"), "main_sim.py"],
        cwd=str(REPO),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    t_start = time.time()
    deadline = t_start + MONITOR_DURATION_S
    pipeline_count = 0
    last_img_check = t_start
    img_size_mb = img_before
    ready = False

    print("  Monitoring läuft (60s)...", flush=True)

    while time.time() < deadline:
        if proc.poll() is not None:
            remaining = proc.stdout.read()
            break

        readable, _, _ = select.select([proc.stdout], [], [], 0.5)
        now = time.time()
        t_rel = round(now - t_start, 1)

        shm_mb, sm_count = get_shm_usage()

        if now - last_img_check >= 5:
            img_size_mb = get_image_out_size()
            last_img_check = now

        entry = {
            "t_rel_s": t_rel,
            "shm_used_mb": round(shm_mb, 2),
            "shm_sm_block_count": sm_count,
            "images_out_mb": round(img_size_mb, 2),
            "pipelines": pipeline_count,
        }
        series.append(entry)

        if readable:
            line = proc.stdout.readline()
            if line:
                if "READY_AFTER" in line:
                    ready = True
                    print(f"  T+{t_rel:.0f}s: System bereit", flush=True)
                if "Pipeline finished" in line and "TOOK=" in line:
                    pipeline_count += 1
                    if pipeline_count % 10 == 0:
                        print(f"  T+{t_rel:.0f}s: {pipeline_count} Pipelines, /dev/shm={shm_mb:.1f}MB, SM-Blöcke={sm_count}", flush=True)

    proc.stdout.close()
    if proc.poll() is None:
        proc.kill()
    proc.wait(timeout=5)

    shm_after, sm_count_after = get_shm_usage()
    img_after = get_image_out_size()

    # CSV speichern
    csv_path = RESULTS_DIR / "case2_disk_usage_timeseries.csv"
    if series:
        with open(csv_path, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=series[0].keys())
            w.writeheader()
            w.writerows(series)
        print(f"\n  CSV gespeichert: {csv_path} ({len(series)} Einträge)")

    delta_shm = shm_after - shm_before
    delta_img = img_after - img_before

    result = {
        "duration_s": MONITOR_DURATION_S,
        "pipelines_completed": pipeline_count,
        "shm_start_mb": round(shm_before, 1),
        "shm_end_mb": round(shm_after, 1),
        "shm_delta_mb": round(delta_shm, 1),
        "shm_delta_mb_per_inspection": round(delta_shm / max(pipeline_count, 1), 3),
        "images_out_start_mb": round(img_before, 1),
        "images_out_end_mb": round(img_after, 1),
        "images_out_delta_mb": round(delta_img, 1),
        "images_out_mb_per_inspection": round(delta_img / max(pipeline_count, 1), 3),
        "sm_blocks_before": sm_count_before,
        "sm_blocks_after": sm_count_after,
    }

    return result


if __name__ == "__main__":
    r = run_case()
    print("\n=== ERGEBNIS Case 2 – Speicherfüllstand ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
