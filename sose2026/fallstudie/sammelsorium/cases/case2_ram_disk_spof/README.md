# Case 2 – RAM Disk als Single Point of Failure

**Block:** A – Speicher- und Ressourcenverwaltung  
**Forschungsfrage:** Wie verhält sich das System, wenn Subsysteme überlaufen oder Prozesse unkontrolliert enden?  
**Status:** EMPIRISCH BESTÄTIGT

---

## Hintergrund

Das ROSI-System speichert verarbeitete Bilder (WebP/JPEG) auf dem Dateisystem unter `~/ROSI/Images/Out`. Auf der Produktionshardware wird dieser Pfad als tmpfs-RAM-Disk gemountet, um schnelle I/O-Zugriffe zu gewährleisten. `/dev/shm` (Standard-Linux-tmpfs) wird von `multiprocessing.shared_memory` für die Shared-Memory-Blöcke genutzt.

Beide Pfade teilen sich physischen RAM. `store_images_to_disk` enthält kein `try/except` für `OSError`. Es gibt kein Monitoring des Füllstands.

---

## Hypothese

Wenn der Speicher voll ist (RAM-Disk oder `/dev/shm`):
- `store_images_to_disk` wirft `OSError(28, 'No space left on device')`
- Worker-Prozess bricht ab (unbehandelte Exception)
- PipelineManager deadlockt (~35s) und crasht dann
- `main.py` erkennt PM-Crash (Case-1-Mechanismus) → Shutdown
- Kein graceful degradation; gesamte Anlage fährt herunter

---

## Messgrößen

| Größe | Beschreibung |
|---|---|
| Speicherwachstum /dev/shm (MB/Insp) | Zuwachs in `/dev/shm` pro Inspektion |
| Speicherwachstum Images/Out (MB/Insp) | Zuwachs in `~/ROSI/Images/Out` pro Inspektion |
| Zeit bis Worker-Fehler (s) | Verzögerung zwischen OSError und PM-Crash |
| TTD Gesamt (s) | Zeit von OSError bis `main.py` Shutdown |
| Graceful Degradation | Ja/Nein |

---

## Testumgebung

| Eigenschaft | Wert |
|---|---|
| Hardware | Entwicklungs-VM, Bad Hersfeld |
| /dev/shm | tmpfs, 50 GB (77% belegt im Test = 39 GB) |
| ~/ROSI/Images/Out | reguläres Filesystem (Entwicklung), tmpfs in Produktion |
| Sonstige | wie [Baseline](../baseline/README.md) |

---

## Methodik / Durchführung

### Teil A: Speicherfüllstand über die Zeit (Monitoring)

Kein Fehler wird injiziert. `main_sim.py` läuft 60s im Normalbetrieb. Das Monitoring-Skript misst jede Sekunde `/dev/shm`-Nutzung und alle 5s die Größe von `Images/Out`.

**Testskript:** [../../results/test_case2_disk_usage.py](../../results/test_case2_disk_usage.py)

### Teil B: ENOSPC-Simulation (Crash-Test)

**Code-Modifikation (temporär, automatisch rückgängig gemacht):**

**Datei:** `.venv/lib/python3.13/site-packages/gbbm_rosi_dependencies/common/functions/load_store_imgs.py`

```python
# Eingefügt am Anfang von store_images_to_disk(), nach dem Warmup-Check:
if not insp_data.is_warmup:
    raise OSError(28, 'No space left on device')  # CASE2_ENOSPC
```

Dies simuliert exakt den Fehler einer vollen RAM-Disk. Der Patch ist auf `not is_warmup` beschränkt, damit das System vollständig hochfahren kann.

**Testskript:** [../../results/test_case2_disk_full.py](../../results/test_case2_disk_full.py)

```bash
.venv/bin/python .luca/results/test_case2_disk_usage.py   # Teil A
.venv/bin/python .luca/results/test_case2_disk_full.py    # Teil B
```

---

## Ergebnisse

### Teil A: Speicherwachstum im Normalbetrieb

| Messgröße | Wert |
|---|---|
| Messdauer | 60s |
| Pipelines abgeschlossen | ~2 (Testlauf mit Monitoring-Overhead) |
| /dev/shm Delta | +1038 MB in 60s |
| /dev/shm pro Inspektion | ~519 MB (Warmup + SM-Block-Allokation) |
| Images/Out Delta | +43.6 MB in 60s |
| Images/Out pro Inspektion | ~21.8 MB (WebP + Raw-Bilder) |
| SM-Blöcke Δ | +317 Blöcke (5461 → 5778) |

**Hochrechnung für Produktionsbetrieb (1.74 Insp/s):**
- Images/Out: ~21.8 MB × 1.74/s = **~38 MB/s** Schreibrate
- Bei 12 GB freier RAM-Disk: voll nach **~5 Minuten**
- SM-Blöcke werden durch GC nach 10s bereinigt – kein unbegrenztes Wachstum

**Hinweis:** SM-Blöcke in /dev/shm werden durch den Worker-GC (`remove_after_seconds=10`) regelmäßig freigegeben (Case 5). Der Wachstumswert für /dev/shm ist daher bei längeren Läufen geringer als im 60s-Snapshot.

### Teil B: ENOSPC-Crash

| Messgröße | Wert |
|---|---|
| Warmup abgeschlossen | JA |
| Pipelines nach Warmup | **0** |
| OSError im Log | **JA** – `[Errno 28] No space left on device` |
| Worker betroffen | Worker 10 (`store_images_to_disk`) |
| Zeit OSError → PM-Crash | **35.2s** |
| PM-Crash → Shutdown | 2.1s |
| Gesamt-TTD (OSError→Shutdown) | **~37s** |
| Graceful Degradation | **NEIN** |

### Zeitlinie (Teil B)

```
15:26:52.942  Warmup-Pipeline fertig [TOOK=798ms]
15:26:53.024  READY_AFTER=8s

15:26:53.272  Step 4 abgeschlossen
15:26:53.335  ► OSError(28): No space left on device [Worker 10]
              Job execution failed [JOB_ID=16, WORKER_ID=10]

15:26:53.375  PM: Exception occurred [store_images_to_disk]
15:26:53.383  PM: Unknown error (Exception-Kaskade)

──── 35.1 Sekunden Stille ──────────────────────────────────────────
  Kein Pipeline-Abschluss, kein Alarm, kein Operator-Hinweis

15:27:28.511  ► Pipeline manager process crashed
15:27:30.599  Main Process stopped [Shutting down all subsystems...]
```

### Warum 35 Sekunden?

PM versucht, Ergebnis von JOB_ID=16 abzurufen. Worker 10 ist im Error-Zustand und hat das Result nie gespeichert. PM bleibt in der Result-Collector-Schleife gefangen:
```
Job not found. Cannot get work result. JOB_ID=16
```

---

## Interpretation

- Kein stiller Ausfall: PM crasht nach 35s, main.py reagiert (Case-1-Mechanismus)
- Das eigentliche Problem: **35 Sekunden unkontrollierter Stall** – keine Inspektion, kein Alarm
- Keine graceful degradation: Ein fehlgeschlagenes Image-Save fährt das **gesamte System** herunter
- In Produktion bei 38 MB/s: volle RAM-Disk nach wenigen Minuten ohne Monitoring

---

## Risikobewertung

**Hoch.** Deterministisch reproduzierbar bei vollem Speicher. Bei Produktionsdurchsatz (38 MB/s) kann die RAM-Disk innerhalb einer Schicht voll sein.

---

## Empfehlung

1. `try/except OSError` in `store_images_to_disk` – Inspektion fortsetzen, Bildarchivierung überspringen
2. Disk-Space-Monitor: Alarm bei < 20% freier RAM-Disk
3. `/dev/shm` und `IMAGE_OUT_PATH` auf separate Mounts → kein gemeinsamer RAM-Pool

**Log (Teil B):** [results/disk_full.log](results/disk_full.log)  
**CSV (Teil A):** [results/disk_usage_timeseries.csv](results/disk_usage_timeseries.csv)
