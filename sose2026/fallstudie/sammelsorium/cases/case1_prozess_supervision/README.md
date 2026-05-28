# Case 1 – Lücken in der Laufzeit-Prozesssupervision

**Block:** B – Systembeobachtbarkeit und Fehlertoleranz  
**Forschungsfrage:** In welchem Zeitraum erkennt das System eigene Prozessausfälle, und welche Reaktion erfolgt?  
**Status:** EMPIRISCH BESTÄTIGT

---

## Hintergrund

`main.py` überwacht im Steady State ausschließlich den `PipelineManagerProcess` via `is_running()`-Poll im 1-Sekunden-Takt. Die drei weiteren Service-Prozesse (FrameGrabber, InspectionDataHandler, Logger) laufen ohne jede Supervision. Ein Absturz dieser Prozesse führt entweder zu einem stillen Ausfall oder zu einem Deadlock, ohne dass ein Alarm ausgelöst wird.

**Root Cause (Quellcode):**
```python
# main.py ~Zeile 62–65
while pipeline_manager_proc.is_running():
    time.sleep(1)
# → nur PipelineManager wird überwacht
```

---

## Hypothese

- SIGKILL auf PipelineManager → `main.py` erkennt Ausfall innerhalb ~1s (TTD ≈ 1s)
- SIGKILL auf FrameGrabber → System läuft weiter, bleibt in Step 1 hängen (Deadlock)
- SIGKILL auf InspDataHandler → System läuft weiter (stiller Ausfall)
- SIGKILL auf Logger → System läuft weiter, keine Log-Ausgaben mehr (stiller Ausfall)

---

## Messgrößen

| Größe | Beschreibung |
|---|---|
| TTD (s) | Time-to-Detection: Zeit von SIGKILL bis `main.py` sich beendet oder Shutdown-Keyword erscheint |
| Verhalten nach Kill | Beschreibung des Systemverhaltens im Beobachtungsfenster (20s) |
| Detektion | Ja/Nein |

---

## Testumgebung

Wie [Baseline](../baseline/README.md). Zusätzlich: `psutil` für PID-Ermittlung via Prozesskindbaum.

---

## Methodik / Durchführung

**Keine Code-Änderungen. Nur POSIX-Signale.**

1. `main_sim.py` als Subprocess starten (stdout=PIPE)
2. PIDs der vier Service-Prozesse aus dem Log-Output extrahieren
   - Format: `[PID] Pipeline Manager process started`
   - Logger: kein `[PID]` im Log → via `psutil.children()` ermittelt
3. Warten auf `READY_AFTER` (vollständiger Hochlauf)
4. `SIGKILL` an Zielprozess senden
5. Beobachtungsfenster: 20s
   - Detektion wenn: Subprocess beendet ODER Keyword `Shutting down` / `CRASHED` im Output
6. Aufräumen: `proc.stdout.close()` → `proc.kill()` → `proc.wait()`
   - **Wichtig:** `stdout.close()` VOR `kill()`, da Child-Prozesse den Pipe-FD halten und `stdout.read()` sonst blockiert

**Testskript:** [../../results/test_case1_process_supervision.py](../../results/test_case1_process_supervision.py)

```bash
.venv/bin/python .luca/results/test_case1_process_supervision.py
```

---

## Ergebnisse

### Messung

| Zielprozess | Detektiert | TTD (s) | Verhalten |
|---|---|---|---|
| **PipelineManager** | ✓ **JA** | **0.992s** | Sauberer Shutdown aller Subsysteme |
| FrameGrabber | ✗ NEIN | – | System hängt in Step 1 (`wait_for_new_inspection`), Deadlock |
| InspDataHandler | ✗ NEIN | – | System läuft weiter, bestehende Inspektionen abgeschlossen |
| Logger | ✗ NEIN | – | System läuft weiter, keine Log-Ausgaben mehr (silent failure) |

### Zeitlinie (PipelineManager-Kill)

```
11:27:28.477  READY_AFTER=9s
              SIGKILL → PipelineManager (PID=2926659)
11:27:29.478  Main Process stopped [Pipeline Manager finished automatically.]
11:27:29.478  Main Process stopped [Shutting down all subsystems...]
              TTD = 29.478 − 28.477 = 0.992s
```

### Zeitlinie (FrameGrabber-Kill)

```
11:27:41.701  READY_AFTER=9s
              SIGKILL → FrameGrabber
11:27:42.150  [2929023] Waiting for frame grabber result [JOB_ID=-1]
              → kein weiterer Output
              → System wartet unbegrenzt auf nächstes Frame
              → nach 20s Timeout: kein Shutdown beobachtet
```

### Log-Belege

- PM-Kill: [results/pipelinemanager_kill.log](results/pipelinemanager_kill.log)
- FG-Kill: [results/framegrabber_kill.log](results/framegrabber_kill.log)
- IDH-Kill: [results/inspdatahandler_kill.log](results/inspdatahandler_kill.log)
- Logger-Kill: [results/logger_kill.log](results/logger_kill.log)

---

## Interpretation

Der PipelineManager-Absturz wird korrekt erkannt (TTD ≈ 1s = Sleep-Intervall des Poll-Loops). Alle anderen Prozessausfälle bleiben vollständig unbemerkt:

- **FrameGrabber-Crash** → Pipeline blockiert in Step 1, kein Timeout, kein Alarm. Anlage steht still, Operator sieht nichts.
- **Logger-Crash** → Silent failure. Alle Log-Einträge gehen verloren; kein Monitoring-Alarm möglich.
- **IDH-Crash** → Keine neuen Inspektionen starttbar; aktive Inspektionen laufen noch zu Ende.

---

## Risikobewertung

**Kritisch.** FrameGrabber läuft direkt an der Kamerahardware. Ein Kamera-Disconnect, OOM-Kill oder Treiberfehler hält die gesamte Anlage an – ohne Alarm, ohne Restart, ohne Log.

---

## Empfehlung

```python
# main.py: Supervision aller Service-Prozesse
supervised = [pipeline_manager_proc, fg_proc, idh_proc, logger_proc]
while all(p.is_running() for p in supervised):
    time.sleep(1)
crashed = [p.name for p in supervised if not p.is_running()]
# → Alarm + Neustart-Logik
```

Alternativ: systemd-Unit mit `Restart=on-failure` für den gesamten ROSI-Prozessbaum.
