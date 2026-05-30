# Baseline – Referenzmessung

**Block:** –
**Zweck:** Referenzwerte für normalen Betrieb unter Simulatorbedingungen

---

## Was wird gemessen?

Reproduzierbare Messung des ROSI-Systems ohne injizierte Fehler. Die Ergebnisse dienen als Vergleichsbasis für alle 5 Failure Cases.

### Messgrößen

| Größe                         | Beschreibung                                              |
| ----------------------------- | --------------------------------------------------------- |
| Startup-Zeit (s)              | Zeit von Programmstart bis `READY_AFTER`                  |
| Durchsatz (Insp/s)            | Inspektionen pro Sekunde im Steady State                  |
| Pipeline-Dauer ∅/min/max (ms) | Zeit von Pipeline-Start bis -Ende                         |
| Prozessanzahl                 | Anzahl der gestarteten Prozesse (Main + Service + Worker) |

---

## Testumgebung

| Eigenschaft        | Wert                                                        |
| ------------------ | ----------------------------------------------------------- |
| Hardware           | Entwicklungs-VM, Bad Hersfeld                               |
| OS                 | Linux 6.17.0-20-generic (x86_64)                            |
| RAM                | 64 GB                                                       |
| GPU                | NVIDIA GeForce RTX 5090 (31.3 GB VRAM)                      |
| Python             | 3.13 (.venv)                                                |
| ROSI-Startskript   | `main_sim.py` (Simulator-Wrapper)                           |
| ROSI-Konfiguration | `DUMMY_CONFIG_SET_SIMULATOR_TESTSTAND_GROSS_TRIPLE_TRIGGER` |
| Bilddatenquelle    | `~/ROSI/Images/Simulation/` (462 Bilder = 154 Inspektionen) |
| Django-Settings    | `gbbm_rosi_django.core.settings.development`                |
| CONN_MAX_AGE       | 0 (frische DB-Verbindung pro Aufruf)                        |

---

## Durchführung

```bash
cd /home/rosipc/git/gbbm_rosi_main
.venv/bin/python .luca/results/test_baseline.py
```

Keine Patches, keine Signale. Das Skript startet `main_sim.py` als Subprocess, liest den Output, extrahiert Zeitstempel und beendet den Prozess nach ~25s.

**Testskript:** [../../results/test_baseline.py](../../results/test_baseline.py)

---

## Ergebnisse

| Messgröße                           | Wert                                                                                         |
| ----------------------------------- | -------------------------------------------------------------------------------------------- |
| Startup-Zeit                        | **8s**                                                                                       |
| Durchsatz                           | **1.74 Inspektionen/s**                                                                      |
| Pipeline-Dauer ∅                    | **383 ms**                                                                                   |
| Pipeline-Dauer min                  | 185 ms                                                                                       |
| Pipeline-Dauer max                  | 545 ms                                                                                       |
| Inspektionen gesamt (Messzeit ~22s) | 39                                                                                           |
| Prozesse: Service                   | 4 (Main, LoggerProcess, FrameGrabberProcess, InspDataHandlerProcess, PipelineManagerProcess) |
| Prozesse: Worker                    | 12 (MPWorkerPool)                                                                            |

### Prozessarchitektur

```
main_sim.py (Main Process)
├── LoggerProcess          ← log_queue.get() → Django + Console
├── FrameGrabberProcess    ← Simulator: lädt JPEGs aus ~/ROSI/Images/Simulation
├── InspectionDataHandlerProcess  ← verwaltete InspectionData-Objekte
└── PipelineManagerProcess
    ├── Worker 0–1:  get_classic_defects / get_ai_defects (Defect Detection)
    ├── Worker 2–5:  encode_frames (JPEG→WebP Encoding, parallel)
    ├── Worker 6:    extract_features
    ├── Worker 7–9:  encode_frames (weitere Kamerakanäle)
    └── Worker 10–11: store_images_to_disk / encoded_images_to_cache
```

### Pipeline-Schritte (sequenziell)

| Step | Funktion                                                              | Ø Dauer                  |
| ---- | --------------------------------------------------------------------- | ------------------------ |
| 1    | `wait_for_new_inspection`                                             | ~10–20 ms (steady state) |
| 2    | `GeoMeas.get_geometrics`                                              | ~25–70 ms                |
| 3    | `RoiTrimming.trim`                                                    | ~5–15 ms                 |
| 4    | `[get_classic_defects + get_ai_defects + encode_frames]`              | ~170–220 ms (parallel)   |
| 5    | `[extract_features + store_images_to_disk + encoded_images_to_cache]` | ~50–110 ms (parallel)    |
| 6    | `convert_inspection_to_model`                                         | ~5–110 ms                |

**Log:** [results/baseline_run.log](results/baseline_run.log)
