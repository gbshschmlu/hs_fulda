# ROSI Fallstudie – Übersicht der Cases

**Kurs:** AI3955 Fallstudie
**Bearbeiter:** Luca Michael Schmidt
**Hochschule Fulda, 2026**
**System:** ROSI – Realtime Optical Surface Inspection (Baustoffproduktion, 24/7)

---

## Systemarchitektur (Kurzübersicht)

ROSI ist ein Python-Multiprocessing-System mit 4 Service-Prozessen und 12 Worker-Prozessen:

```
main.py
├── FrameGrabber         – Kamera-Interface (Hardware-gebunden)
├── InspectionDataHandler – Frame-Verteilung an Pipeline
├── PipelineManager       – Orchestriert 6-Step-Pipeline (← überwacht von main.py)
│   ├── MPWorkerPool (12 Worker)
│   └── Steps 1–6 sequentiell, Steps 4+5 parallel
└── LoggerProcess         – Log-Queue → Django ORM → PostgreSQL
```

**Supervision:** `main.py` überwacht ausschließlich den `PipelineManager` via 1s-Poll.

---

## Cases im Überblick

| Case                                          | Titel                                | Block                    | Status               | Risiko          |
| --------------------------------------------- | ------------------------------------ | ------------------------ | -------------------- | --------------- |
| [Baseline](baseline/README.md)                | Normalbetrieb-Messung                | —                        | BESTÄTIGT            | —               |
| [Case 1](case1_prozess_supervision/README.md) | Lücken in der Prozesssupervision     | B – Beobachtbarkeit      | BESTÄTIGT            | **Kritisch**    |
| [Case 2](case2_ram_disk_spof/README.md)       | RAM Disk als Single Point of Failure | A – Ressourcenverwaltung | BESTÄTIGT            | **Hoch**        |
| [Case 3](case3_log_queue_cascade/README.md)   | Log-Queue-Stau als Pipeline-Blocker  | C – Datenpersistenz      | BESTÄTIGT            | **Hoch**        |
| [Case 4](case4_stale_db_connection/README.md) | Stale Django Connection nach Pause   | D – Fehlertoleranz       | ANALYTISCH BESTÄTIGT | **Mittel-Hoch** |
| [Case 5](case5_gc_race_condition/README.md)   | GC Race Condition im Worker-Pool     | A – Ressourcenverwaltung | HYPOTHESE WIDERLEGT  | **Niedrig**     |

---

## Kurzbeschreibung der Cases

### Baseline

Normalbetrieb-Messung ohne injizierte Fehler. Referenzwerte für alle weiteren Messungen.

- **Durchsatz:** ~1.74 Insp/s (17 Pipelines in 5s gemessen)
- **Step-Laufzeiten:** Step 4 (37ms), Step 5 (45–107ms), gesamt ~168–350ms
- **Prozess-PIDs:** 4 Service-Prozesse + 12 Worker

### Case 1 – Prozesssupervision

`main.py` überwacht nur den PipelineManager. FrameGrabber-, Logger- und IDH-Abstürze sind unsichtbar.

| Zielprozess     | Detektiert | TTD    | Verhalten                   |
| --------------- | ---------- | ------ | --------------------------- |
| PipelineManager | ✓ JA       | 0.992s | Sauberer Shutdown           |
| FrameGrabber    | ✗ NEIN     | —      | Deadlock in Step 1          |
| InspDataHandler | ✗ NEIN     | —      | Stiller Ausfall             |
| Logger          | ✗ NEIN     | —      | Silent failure, Log-Verlust |

### Case 2 – RAM Disk SPOF

`store_images_to_disk` enthält kein `try/except`. Volle RAM-Disk → `OSError(28)` → Worker-Crash → 35s Stall → PM-Crash → Shutdown. Bei 38 MB/s Schreibrate kann die RAM-Disk in einer Schicht voll sein.

| Messgröße               | Wert                                             |
| ----------------------- | ------------------------------------------------ |
| Zeit OSError → PM-Crash | 35.2s                                            |
| Graceful Degradation    | NEIN                                             |
| Images/Out Wachstum     | ~21.8 MB/Insp = **~38 MB/s** bei Produktionslast |

### Case 3 – Log-Queue-Stau

`log_queue.put()` in `collector.py` blockiert ohne Timeout. Logger-Freeze → Queue voll in ~6s → alle 11 Worker + PM blockieren synchron → 27s Freeze, kein Alarm, kein Shutdown.

| Messgröße              | Wert               |
| ---------------------- | ------------------ |
| Baseline Durchsatz     | 17 Pipelines/5s    |
| In-Flight nach SIGSTOP | 5                  |
| Freeze-Dauer           | 27.7s (kein Alarm) |
| qsize nach SIGCONT     | 6 → 0 in <300ms    |

### Case 4 – Stale DB Connection

`convert_inspection_to_model` hat kein `try/except` für `OperationalError`. Klassischer Dev/Prod-Parity-Bruch: `CONN_MAX_AGE=0` in Entwicklung maskiert die Schwachstelle. In Produktion (`CONN_MAX_AGE=60`) deterministisch reproduzierbar nach jeder Produktionspause.

| Konfiguration                | Verhalten nach pg_terminate_backend                                   |
| ---------------------------- | --------------------------------------------------------------------- |
| Development (CONN_MAX_AGE=0) | Kein Crash – erwartetes Ergebnis (frische Verbindung pro Aufruf)      |
| Produktion (CONN_MAX_AGE=60) | OperationalError → Shutdown – analytisch bestätigt durch Code-Analyse |

### Case 5 – GC Race Condition

Hypothese widerlegt. GC-Mechanismus ist aktiv und korrekt. Zwei unabhängige Schutzebenen verhindern einen Race: ~100-facher Zeitpuffer (Step 5: ~100ms vs. GC-Threshold: 10s) und idempotentes `destroy()`. Step 6 greift zudem nicht auf SM-Blöcke zu.

| Befund                            | Wert                       |
| --------------------------------- | -------------------------- |
| GC aktiv                          | JA                         |
| Zeitpuffer Step5 vs. GC-Threshold | ~100× (100ms vs. 10s)      |
| `destroy()` idempotent            | JA                         |
| Race reproduziert                 | NEIN – Hypothese widerlegt |

---

## Empfehlungen (Kurzübersicht)

| Case   | Fix                                                          | Aufwand |
| ------ | ------------------------------------------------------------ | ------- |
| Case 1 | Supervision aller 4 Prozesse in main.py                      | Gering  |
| Case 2 | `try/except OSError` in store_images_to_disk + Disk-Monitor  | Gering  |
| Case 3 | `put(timeout=0.1)` + Drop-on-Full in collector.py            | Minimal |
| Case 4 | `close_old_connections()` in convert_inspection_to_model     | Minimal |
| Case 5 | Kein unmittelbarer Handlungsbedarf (Referenzzähler optional) | —       |

---

## Verzeichnisstruktur

```
.luca/cases/
├── OVERVIEW.md                           ← diese Datei
├── baseline/
│   ├── README.md
│   └── results/
│       ├── test_baseline.py
│       └── baseline_run.log
├── case1_prozess_supervision/
│   ├── README.md
│   └── results/
│       ├── test_case1_process_supervision.py
│       ├── pipelinemanager_kill.log
│       ├── framegrabber_kill.log
│       ├── inspdatahandler_kill.log
│       └── logger_kill.log
├── case2_ram_disk_spof/
│   ├── README.md
│   └── results/
│       ├── test_case2_disk_usage.py
│       ├── test_case2_disk_full.py
│       ├── case2_disk_usage_timeseries.csv
│       └── disk_full.log
├── case3_log_queue_cascade/
│   ├── README.md
│   └── results/
│       ├── test_case3_log_queue_cascade.py
│       ├── queue_depth_timeseries.csv
│       └── cascade.log
├── case4_stale_db_connection/
│   ├── README.md
│   └── results/
│       ├── test_case4_stale_db_connection.py
│       └── case4_stale_db.log
└── case5_gc_race_condition/
    ├── README.md
    └── results/
        ├── test_case5_gc_race.py
        └── case5_gc_race.log
```
