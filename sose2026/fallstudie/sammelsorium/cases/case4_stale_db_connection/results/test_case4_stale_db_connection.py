"""
Case 4 – Stale Django Connection nach Produktionspause

Hypothese:
  - PostgreSQL/Firewall trennt idle TCP-Verbindung nach Timeout
  - Beim nächsten convert_inspection_to_model-Aufruf crasht der PipelineManager
    mit OperationalError (kein try/except in convert_inspection_to_model)
  - main.py bemerkt den PipelineManager-Crash → Shutdown

Test-Methodik:
  - Starte ROSI-Simulator
  - Warte bis erste Inspektion verarbeitet wurde (Verbindung offen)
  - Terminiere alle DB-Verbindungen via pg_terminate_backend
  - Beobachte ob PipelineManager crasht
  - Messe Time-to-Crash

Hinweis:
  In development settings ist CONN_MAX_AGE=0 (jeder DB-Aufruf öffnet neue Verbindung).
  Dieser Test prüft ob das close_old_connections() dennoch fehlt und ob ein
  aktiver Verbindungsabbruch während eines laufenden DB-Writes crasht.
"""

import os
import re
import select
import subprocess
import sys
import time
from pathlib import Path

import psutil

REPO = Path(__file__).parent.parent.parent
RESULTS_DIR = Path(__file__).parent

# PostgreSQL connection info (aus Django development settings)
PG_HOST = "127.0.0.1"
PG_PORT = 5432
PG_DB = "rosi"
PG_USER = "postgres"
PG_PASS = "postgres"


def terminate_db_connections() -> int:
    """Terminiert alle aktiven PostgreSQL-Verbindungen zur rosi-DB."""
    import subprocess

    sql = f"""
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = '{PG_DB}'
      AND pid <> pg_backend_pid();
    """
    result = subprocess.run(
        [
            "psql",
            "-h", PG_HOST,
            "-p", str(PG_PORT),
            "-U", PG_USER,
            "-d", PG_DB,
            "-c", sql,
            "-t",
        ],
        capture_output=True,
        text=True,
        env={**os.environ, "PGPASSWORD": PG_PASS},
    )
    # Zähle wie viele Verbindungen terminiert wurden
    count = result.stdout.count("t")
    print(f"  pg_terminate_backend: {count} Verbindungen beendet", flush=True)
    print(f"  psql stdout: {result.stdout.strip()[:200]}", flush=True)
    if result.stderr:
        print(f"  psql stderr: {result.stderr.strip()[:200]}", flush=True)
    return count


def get_active_db_connections() -> list:
    """Gibt aktive DB-Verbindungen zurück."""
    sql = f"""
    SELECT pid, application_name, state, query_start
    FROM pg_stat_activity
    WHERE datname = '{PG_DB}'
      AND pid <> pg_backend_pid();
    """
    result = subprocess.run(
        [
            "psql",
            "-h", PG_HOST,
            "-p", str(PG_PORT),
            "-U", PG_USER,
            "-d", PG_DB,
            "-c", sql,
            "-t",
        ],
        capture_output=True,
        text=True,
        env={**os.environ, "PGPASSWORD": PG_PASS},
    )
    lines = [l.strip() for l in result.stdout.splitlines() if l.strip()]
    return lines


def run_case() -> dict:
    print("\n=== Case 4: Stale Django Connection ===\n")

    log_lines = []
    proc = subprocess.Popen(
        [str(REPO / ".venv/bin/python"), "main_sim.py"],
        cwd=str(REPO),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    # Schritt 1: Warte auf mindestens eine vollständige Inspektion (DB-Write)
    first_inspection_done = False
    ready = False
    deadline = time.time() + 30
    inspection_count = 0

    print("  Warte auf System-Start und erste DB-Schreiboperationen...", flush=True)

    while time.time() < deadline:
        readable, _, _ = select.select([proc.stdout], [], [], 0.5)
        if not readable:
            if proc.poll() is not None:
                break
            continue

        line = proc.stdout.readline()
        if not line:
            break
        log_lines.append(line)

        if "READY_AFTER" in line:
            ready = True
            print(f"  System bereit.", flush=True)

        if ready and "Pipeline finished" in line and "TOOK=" in line:
            inspection_count += 1
            if inspection_count >= 2 and not first_inspection_done:
                first_inspection_done = True
                print(f"  {inspection_count} Inspektionen verarbeitet. DB-Verbindungen vorhanden.", flush=True)

                # Zeige aktive Verbindungen vor dem Abbruch
                conns_before = get_active_db_connections()
                print(f"  Aktive DB-Verbindungen vor Abbruch: {len(conns_before)}")

                # Schritt 2: Terminiere alle DB-Verbindungen
                time.sleep(0.1)
                kill_time = time.time()
                print(f"  Terminiere alle rosi-DB-Verbindungen via pg_terminate_backend...", flush=True)
                terminated = terminate_db_connections()

    # Schritt 3: Beobachte ob PipelineManager crasht (innerhalb 10s)
    crash_detected = False
    crash_time = None
    crash_reason = None
    deadline2 = (kill_time if first_inspection_done else time.time()) + 10

    while time.time() < deadline2:
        ret = proc.poll()
        if ret is not None:
            crash_detected = True
            crash_time = time.time()
            crash_reason = "main.py beendet (returncode={})".format(ret)
            break

        readable, _, _ = select.select([proc.stdout], [], [], 0.2)
        if readable:
            line = proc.stdout.readline()
            if line:
                log_lines.append(line)
                if any(kw in line for kw in ["CRASHED", "crashed", "OperationalError", "Shutting down"]):
                    crash_detected = True
                    crash_time = time.time()
                    crash_reason = f"Erkannt durch Output: {line.strip()[:100]}"

    # Aufräumen
    if proc.poll() is None:
        # Restliche Output lesen
        try:
            remaining, _ = proc.communicate(timeout=3)
            if remaining:
                log_lines.append(remaining)
        except Exception:
            pass
        proc.kill()
        proc.wait(timeout=3)

    ttc = round(crash_time - kill_time, 3) if (crash_detected and crash_time and first_inspection_done) else None

    result = {
        "inspections_before_kill": inspection_count,
        "db_connections_terminated": terminated if first_inspection_done else 0,
        "crash_detected": crash_detected,
        "time_to_crash_s": ttc,
        "crash_reason": crash_reason,
        "conn_max_age_note": "development settings: CONN_MAX_AGE=0 (frische Verbindung pro DB-Aufruf)",
    }

    # Log speichern
    log_path = RESULTS_DIR / "case4_stale_db.log"
    log_path.write_text("".join(log_lines))
    print(f"\n  Log gespeichert: {log_path}")

    return result


if __name__ == "__main__":
    r = run_case()
    print("\n=== ERGEBNIS Case 4 ===")
    for k, v in r.items():
        print(f"  {k}: {v}")
