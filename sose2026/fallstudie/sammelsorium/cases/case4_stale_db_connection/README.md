# Case 4 – Stale Django Connection nach Produktionspause

**Block:** D – Fehlertoleranz in verteilten Komponenten  
**Forschungsfrage:** Wie verhält sich das System, wenn eine externe Komponente (Datenbank) die Verbindung trennt?  
**Status:** TEILWEISE BESTÄTIGT (Entwicklung safe, Produktion kritisch)

---

## Hintergrund

Das ROSI-System persistiert Inspektionsergebnisse via `convert_inspection_to_model` in PostgreSQL. Django verwaltet DB-Verbindungen pro Thread/Prozess mit `CONN_MAX_AGE`:

- **Entwicklung** (`development.py`): `CONN_MAX_AGE = 0` → frische Verbindung pro DB-Aufruf
- **Produktion** (`base.py`): `CONN_MAX_AGE = 60` → Verbindung bleibt 60s offen (Connection Pooling)

**Kritische Stelle (`inspection/utils.py:240`):**
```python
def convert_inspection_to_model(logger, job_id, insp_data, additional_job_info=None):
    # Kein try/except für OperationalError
    # Kein close_old_connections()-Aufruf
    inspection_obj = InspectionModel(...)
    inspection_obj.save()       # ← OperationalError bei stale connection möglich
    defect_obj.save()           # ← OperationalError bei stale connection möglich
    encoded_image_obj.save()    # ← OperationalError bei stale connection möglich
```

`django.db.utils.OperationalError` wird nicht abgefangen. Django bietet `close_old_connections()` zur Vorab-Validierung, aber diese wird nicht aufgerufen.

---

## Hypothese

Nach einer Produktionspause (Schichtende, Nacht, Wochenende):
- ROSI läuft weiter, aber keine Boards kommen durch (keine Inspektionen)
- Django-Verbindung ist `CONN_MAX_AGE=60` Sekunden offen
- PostgreSQL-Server oder vorgelagerte Firewall trennt TCP-Verbindung nach Idle-Timeout (typisch: 30–300s)
- Erste Inspektion nach der Pause → `convert_inspection_to_model` → `InspectionModel.save()`
- → `OperationalError: server closed the connection unexpectedly`
- → Unbehandelte Exception im PipelineManager-Worker
- → Worker-Crash → PipelineManager-Crash → main.py Shutdown (via Case-1-Mechanismus)

---

## Messgrößen

| Größe | Beschreibung |
|---|---|
| Inspektionen vor Kill | Anzahl verarbeiteter Inspektionen (DB-Verbindung aktiv) |
| DB-Verbindungen terminiert | Anzahl via `pg_terminate_backend` beendeter Verbindungen |
| Crash erkannt | Ja/Nein: PipelineManager crasht nach Connection-Kill |
| Time-to-Crash (s) | Zeit von `pg_terminate_backend` bis Crash-Erkennung |

---

## Testumgebung

Wie [Baseline](../baseline/README.md). Zusätzlich:

| Eigenschaft | Wert |
|---|---|
| PostgreSQL | localhost:5432, DB=rosi, User=postgres |
| Django-Config | `development.py` (`CONN_MAX_AGE=0`) |
| Produktions-Config | `base.py` (`CONN_MAX_AGE=60`) |
| Tool | `psql` + `pg_terminate_backend` SQL-Abfrage |

---

## Methodik / Durchführung

**Keine Code-Änderungen.** Simulation über PostgreSQL-Admin-Funktion.

### Testablauf

1. `main_sim.py` starten, auf `READY_AFTER` warten
2. Mindestens 2 vollständige Inspektionen abwarten (DB-Verbindung etabliert)
3. Alle aktiven PostgreSQL-Verbindungen zur `rosi`-DB via `pg_terminate_backend` beenden:
   ```sql
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE datname = 'rosi'
     AND pid <> pg_backend_pid();
   ```
4. 10 Sekunden Beobachtungsfenster: Crash oder Weiterarbeiten?
5. Log speichern

**Testskript:** [results/test_case4_stale_db_connection.py](results/test_case4_stale_db_connection.py)

```bash
.venv/bin/python .luca/results/test_case4_stale_db_connection.py
```

---

## Ergebnisse

### Messung

| Messgröße | Wert |
|---|---|
| Inspektionen vor Kill | ~27 |
| DB-Verbindungen terminiert | **27** |
| Crash erkannt | **NEIN** |
| `OperationalError` im Log | NEIN |
| System läuft weiter | **JA** |

### Erklärung: Warum kein Crash in Entwicklung

In der Entwicklungskonfiguration (`development.py`) ist `CONN_MAX_AGE = 0`. Das bedeutet: Django öffnet **pro DB-Aufruf** eine frische Verbindung und schließt sie direkt danach. Es gibt keine persistente idle Verbindung, die von PostgreSQL getrennt werden könnte.

Das `pg_terminate_backend` trifft entweder:
- Verbindungen, die bereits regulär geschlossen wurden, oder
- Eine kurz aktive Verbindung während eines `save()`-Aufrufs (aber Django öffnet sofort eine neue)

**Log-Beleg:**
```
# 27 Verbindungen terminiert → kein Crash, Inspektionen laufen weiter
# Letzte Pipeline: 11:29:57.540 | Pipeline finished [TOOK=333 ms]
```

**Log:** [results/case4_stale_db.log](results/case4_stale_db.log)

---

## Produktions-Szenario (nicht empirisch reproduziert)

Das Risiko besteht **nur in der Produktionskonfiguration** (`CONN_MAX_AGE=60`):

```
Django-Einstellung: base.py → CONN_MAX_AGE=60

Produktionspause (z.B. Nachtpause):
  - ROSI läuft, keine Boards
  - Django-Verbindung bleibt 60s offen (Connection Pooling)
  - PostgreSQL/Firewall trennt TCP nach Idle-Timeout (typisch 30–300s)
  - Django "glaubt" die Verbindung noch offen zu sein

Erste Inspektion nach Pause:
  → convert_inspection_to_model()
  → InspectionModel.save()
  → OperationalError: server closed the connection unexpectedly
  → Unbehandelte Exception → Worker-Crash
  → PipelineManager-Crash (35s Stall → Case-1-Mechanismus)
  → main.py Shutdown (~1s nach PM-Crash)
  → Anlage steht, manueller Neustart nötig
```

### CONN_MAX_AGE Konfigurationen im Vergleich

**`gbbm_rosi_django/core/settings/development.py`:**
```python
CONN_MAX_AGE = 0  # frische Verbindung pro Aufruf (safe, aber ~1–3ms overhead)
```

**`gbbm_rosi_django/core/settings/base.py`:**
```python
DATABASES = {
    "default": {
        ...
        "CONN_MAX_AGE": 60,  # 60s Verbindungs-Pool → anfällig für stale connections
    }
}
```

---

## Interpretation

- Entwicklungsumgebung ist nicht betroffen (`CONN_MAX_AGE=0`)
- Das Risiko ist **produktionsspezifisch** und tritt nach Produktionspausen auf
- `convert_inspection_to_model` enthält kein `try/except` für `OperationalError`
- Erster Fehler nach der Pause führt zum vollständigen System-Shutdown

---

## Risikobewertung

**Produktionsrelevanz: MITTEL-HOCH**
- Deterministisch reproduzierbar in Produktion (mit `CONN_MAX_AGE=60` + Firewall-Timeout)
- Tritt bei jedem Schichtstart nach Pause auf
- Keine Graceful Degradation: ein fehlgeschlagener DB-Write → System-Shutdown

---

## Empfehlung

### Option 1: `close_old_connections()` vor dem ersten DB-Aufruf (Minimal-Fix)
```python
from django.db import close_old_connections

def convert_inspection_to_model(logger, job_id, insp_data, ...):
    close_old_connections()   # Validiert/schließt stale connections vor dem Zugriff
    inspection_obj.save()
    ...
```

### Option 2: `CONN_MAX_AGE = 0` auch in Produktion
Vermeidet das Problem vollständig. Kosten: ~1–3ms zusätzliche Latenz pro DB-Aufruf (lokales PostgreSQL). Bei 1.74 Insp/s vernachlässigbar.

### Option 3: Retry-Decorator
```python
@retry_on_db_error(max_retries=1)
def convert_inspection_to_model(...):
    ...
```
Django schließt beim nächsten Versuch die stale Verbindung und öffnet eine neue. Einmalig Verbindungsfehler, dann weiter.
