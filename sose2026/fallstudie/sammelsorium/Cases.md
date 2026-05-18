# ROSI – Fallstudie: Ausgewählte Failure Cases

> Kontext: Praxisorientierte Fallstudie – AI3955, 4. Semester SoSe26
> Student: Schmidt, Luca Michael | Betreuer: Manuel Pilz (Grenzebach BSH GmbH)
> Fokus: Inter-Prozess- und Betriebssystem-Ebene | Keine Hardware | Keine Sabotage
> Ziel: 5 empirisch messbare/simulierbare Cases für das Exposé

---

## Methodischer Rahmen

### Was wurde ausgefiltert

| Kategorie                                    | Grund                                                             |
| -------------------------------------------- | ----------------------------------------------------------------- |
| Hardware-Fehler (Kamera, LED, Encoder, etc.) | Explizit vom Betreuer ausgeschlossen                              |
| Sabotage / mutwillige Zerstörung             | Explizit vom Betreuer ausgeschlossen                              |
| Deployment-Prozess (ISO, Ansible, Transport) | Außerhalb des Referenzsystems                                     |
| KI-Modell-Integrität (falsches .aiaddon)     | Empirisch kaum messbar ohne Zugang zum Trainingsprozess           |
| Systemstart / Boot-Integrität (LUKS/TPM)     | Vom Betreuer ausgeschlossen                                       |
| Framegrabber DMA-Buffer                      | Hardware-adjacent (C++ SDK, Kernel-DMA) – außerhalb Scope         |
| Race Condition bei Konfigurationsänderung    | Architektonisch ausgeschlossen – System ist hier korrekt designed |
| /dev/shm-Erschöpfung durch externe Prozesse  | Wird sauber abgefangen (graceful shutdown), kein Failure Case     |

### Was bleibt

Fokus liegt auf dem **laufenden Betrieb** des ROSI-Systems auf **Prozess- und OS-Ebene**:

- Python-Multiprocessing (Worker-Pool, Hauptprozesse, Shared Memory)
- Dateisystem / Speicherverwaltung (RAM Disk, Logs)
- Datenbankverbindung und Persistenz
- Beobachtbarkeit und Fehlertoleranz im Betrieb

---

## Case 1 – Lücken in der Laufzeit-Prozesssupervision

### Systemkontext

ROSI läuft als Multiprocessing-System mit mehreren langlebigen Hauptprozessen:

- `InspectionDataHandlerProcess`
- `FrameGrabberProcess`
- `PipelineManagerProcess`
- `LoggerProcess`

Der `MPWorkerPool` besitzt einen `HealthMonitor`-Thread der Sub-Worker per Heartbeat überwacht und bei Ausfall via `restart_worker()` neustartet. Die `heartbeat_queue` aus `main.py` wird ausschließlich von Sub-Workern genutzt – die Hauptprozesse melden ihren Status darüber nicht.

### Das Problem

**Befund aus `main.py` (Code vorliegend):**

Der gesamte Runtime-Check für die Hauptprozesse beschränkt sich auf:

```python
while pipeline_manager_proc.is_running():
    time.sleep(1)
```

Sobald dieser Loop endet (natürliches Ende oder Crash), führt der `finally`-Block einen **geordneten Shutdown aller Prozesse** aus – aber keinen Neustart. Kein Alarm, kein externes Signal.

**Noch gravierender:** `LoggerProcess`, `InspectionDataHandlerProcess` und `FrameGrabberProcess` werden nach erfolgreichem Start **überhaupt nicht mehr überwacht**. Nur beim Startup gibt es State-Checks. Im laufenden Betrieb bemerkt `main.py` deren Ausfall nicht.

**Bekannte Crash-Trigger für den PipelineManager:**

- DB-Ausfall: `convert_inspection_to_model` hat keinen `try/except` → Exception propagiert → PipelineManager crasht hart
- FrameGrabber-Crash (SIGKILL): PipelineManager läuft in endloser Leerschleife (jede Sekunde `queue.Empty` → `continue`), ohne dass `main.py` das bemerkt

**Bei hartem PipelineManager-Crash (SIGKILL/OOM):** Shared-Memory-Blöcke des aktiven Frames bleiben verwaist in `/dev/shm` – weder `finally`-Block noch `atexit`-Hook greifen.

### Messbarkeit / Simulation

- Einzelne Hauptprozesse gezielt abschießen (`kill -9`)
- DB-Verbindung trennen → PipelineManager-Crash provozieren
- Messen: Time-to-Detection pro Prozess
- Verhalten der anderen Prozesse nach Ausfall beobachten (blockieren, weiterlaufen, Leerschleife?)
- Messgröße: Time-to-Detection pro Prozess, Folgeverhalten, verwaiste /dev/shm-Blöcke

---

## Case 2 – Ausfalltoleranz des flüchtigen Bildspeicher-Subsystems

### Systemkontext

Die RAM Disk ist ein **separat gemountetes Verzeichnis** (eigenes tmpfs, **nicht** `/dev/shm`) und wird von einem Django-Prozess als Bildbuffer genutzt. Zweck:

1. **SSD-Schonung:** Bilder landen zuerst im RAM-Buffer, von dort auf die HDD – die SSD bleibt von unnötigem Schreibverkehr entlastet
2. **Schnelles Serving:** Die letzten N Stunden an Inspektionsbildern liegen im RAM und können direkt served werden ohne HDD-Zugriff

Die RAM Disk ist damit ein **Single Point of Failure für zwei unabhängige Funktionen** gleichzeitig. Ein Ausfall beeinflusst `/dev/shm` (Pipeline-Shared-Memory) nicht, da separate Mounts.

### Das Problem

**Szenario A – Mount-Failure:** RAM Disk nicht gemountet beim Start → Django kann weder Bilder buffern noch serven. Produktion läuft weiter, Bilddaten gehen verloren, UI zeigt keine Bilder – ohne direkten Fehlerhinweis in der Pipeline.

**Szenario B – Overflow:** RAM Disk läuft voll → Django-Prozess erhält `OSError: No space left on device`. Neue Inspektionsbilder können nicht gepuffert werden; laufende Frame-Writes schlagen fehl. Entsteht schleichend wenn Bilder schneller geschrieben als rotiert werden (Retention-Logik).

Kein proaktives Monitoring der Füllstandsüberwachung im Code vorhanden.

### Messbarkeit / Simulation

- Mount-Failure: tmpfs nicht mounten, Systemverhalten nach Start beobachten
- Overflow: tmpfs auf kleinen Wert begrenzen, unter Last vollschreiben
- Messgrößen: Zeit bis Fehler sichtbar wird, welche Funktionen ausfallen, ob Fehler aktiv gemeldet wird
- Verifizieren: Kein Einfluss auf `/dev/shm` (getrennte Mounts)

---

## Case 3 – Speichererschöpfung durch unkontrolliertes Log-Wachstum

### Systemkontext

ROSI loggt auf mehreren Ebenen:

- **Systemd-Journal:** OS-Level, Größe via `SystemMaxUse=1G` begrenzt
- **ROSI-eigene Logs:** Werden vom `LoggerProcess` gebatcht (100er-Chunks) in die Django-Datenbank geschrieben
- **Kein externes Alerting:** Monitoring nur über Marimo Notebooks, kein automatisches Alert-System

Die zentrale Log-Queue ist **bounded** (`maxsize=1000`) und **blocking** – `LogCollector.put()` übergibt ohne `timeout`-Parameter, d.h. bei voller Queue frieren alle schreibenden Prozesse ein.

### Das Problem

**Szenario A – Systemd-Journal:** Wenn die Rotation nicht greift (z.B. ein Prozess loggt exzessiv), läuft die `root`-Partition voll → OS-Instabilität, Schreiboperationen scheitern systemweit. (Realer Vorfall bei anderem Grenzebach-Produkt dokumentiert.)

**Szenario B – DB-Logs wachsen unkontrolliert:** Bei aktivem DEBUG-Level wächst die `StatusLog`-Tabelle in PostgreSQL schneller als die Inspektionsdaten (Dutzende bis Hunderte Log-Einträge pro Frame). Kein automatisches Archivieren oder Rotieren vorhanden.

**Szenario C – Kaskadeneffekt (Log-Queue als Backpressure-Ventil):**
DB-Writes verlangsamen LoggerProcess → Log-Queue (max. 1000, blocking) füllt sich → **alle anderen Prozesse (Worker, FrameGrabber, PipelineManager) frieren beim nächsten Log-Aufruf ein**. Das Logging wirkt unbeabsichtigt als systemweites Backpressure-Ventil.

### Messbarkeit / Simulation

- Systemd-Journal: `SystemMaxUse` temporär auf kleinen Wert setzen, Log-Flut erzeugen
- DB-Log-Wachstum: DEBUG-Level aktivieren, DB-Größe over time tracken
- Kaskadeneffekt: DB künstlich verlangsamen, Log-Queue-Füllstand und Prozess-Freezes messen
- Messgröße: Disk-Fullness over time, Queue-Tiefe, Zeit bis erster Prozess einfriert

---

## Case 4 – Stale Django Connection nach Produktionspause

### Systemkontext

Der `PipelineManagerProcess` ist ein langlaufender Daemon-Prozess. Das Django ORM wird einmalig via `django.setup()` initialisiert und hält danach eine persistente TCP-Verbindung zur PostgreSQL-Datenbank offen (`CONN_MAX_AGE`). Die Funktion `convert_inspection_to_model` nutzt diese Verbindung für jeden Frame.

### Das Problem

Wenn die Produktionsanlage pausiert (Schichtwechsel, Wartung, Nacht), trennt PostgreSQL oder eine dazwischenliegende Firewall inaktive TCP-Verbindungen nach einem Idle-Timeout. Im ROSI-Code wird `django.db.close_old_connections()` **nicht aufgerufen**.

**Ablauf:**

1. Anlage pausiert für mehrere Stunden
2. PostgreSQL/Firewall trennt idle Verbindung serverseitig
3. Erstes Brett läuft wieder über das Band
4. `convert_inspection_to_model` versucht zu schreiben
5. Django-ORM merkt nicht dass die Verbindung tot ist → wirft `OperationalError: server closed the connection unexpectedly`
6. Kein `try/except` in der Funktion → Exception propagiert → PipelineManager crasht hart

**Kritisch:** Das System stirbt genau beim **ersten Brett nach jeder Pause** – also täglich reproduzierbar bei Schichtwechseln.

### Messbarkeit / Simulation

- PostgreSQL-Verbindung nach einer Pause manuell trennen (`pg_terminate_backend`)
- Oder: `tcp_keepalive`-Timeout auf OS-Ebene kurz setzen
- Ersten Frame danach triggern, Crash beobachten
- Messgröße: Time-to-Crash nach Verbindungstrennung, ob Fehler nach außen sichtbar wird

---

## Case 5 – GC Race Condition im Worker-Pool unter Last

### Systemkontext

Worker-Prozesse im `MPWorkerPool` allozieren eigene Shared-Memory-Blöcke (z.B. WebP-encoded Images via `SharedMemoryEncodedImage`). In der Hauptschleife des Workers (`handle_jobs`) wird die Funktion `cleanup_old_sm_blocks(..., remove_after_seconds=10)` aufgerufen, sobald die Job-Queue für ≥ 0,5 Sekunden leer ist.

Diese Funktion zerstört **autonom alle Shared-Memory-Blöcke die älter als 10 Sekunden sind** – unabhängig davon, ob der PipelineManager sie noch benötigt.

### Das Problem

Unter hoher Last (z.B. langsame DB-Writes durch Case 3-Kaskade, oder viele parallele Jobs) kann die Verarbeitung eines Frames die 10-Sekunden-Grenze überschreiten. Der Worker bekommt kurz eine leere Queue (0,5s Idle), triggert den GC, und zerstört Blöcke die der PipelineManager in einem späteren Step noch lesen will.

**Folge:** Wenn der PipelineManager danach `enc_img.get_data()` aufruft, fehlt der Speicherblock im OS → `FileNotFoundError` oder Segfault im C-Backend.

**Verbindung zu anderen Cases:** Dieser Case wird durch Case 3 (langsame DB → langsamer Logger → Backpressure → gesamtes System verlangsamt) als Auslöser begünstigt – d.h. er tritt bevorzugt als Teil einer Kaskade auf.

### Messbarkeit / Simulation

- `remove_after_seconds` temporär auf einen kleinen Wert setzen (z.B. 2s)
- Künstliche Verzögerung in einem späteren Pipeline-Step einbauen
- Prüfen ob `FileNotFoundError`/Segfault reproduzierbar auftritt
- Messgröße: Crash-Rate gegen simulierte Frame-Verarbeitungsdauer

---

## Zusammenfassung

| #   | Case                                                    | Typ                                    | Realer Vorfall?               | Code-Eingriff möglich? |
| --- | ------------------------------------------------------- | -------------------------------------- | ----------------------------- | ---------------------- |
| 1   | Lücken in der Laufzeit-Prozesssupervision               | Harter Ausfall unbemerkt               | Ja (ähnliche Vorfälle)        | Ja                     |
| 2   | Ausfalltoleranz des flüchtigen Bildspeicher-Subsystems  | Harter Ausfall + schleichend           | Ja (RAM Disk nicht geladen)   | Ja                     |
| 3   | Speichererschöpfung durch unkontrolliertes Log-Wachstum | Schleichend + Kaskade                  | Ja (Speicher voll durch Logs) | Ja                     |
| 4   | Stale Django Connection nach Produktionspause           | Harter Ausfall, täglich reproduzierbar | Nein (neu identifiziert)      | Ja                     |
| 5   | GC Race Condition im Worker-Pool unter Last             | Harter Ausfall unter Lastkombination   | Nein (neu identifiziert)      | Ja                     |

---

## Offene Punkte

- **Case 5:** Tritt bevorzugt als Konsequenz von Case 3 auf – in der Ausarbeitung als Kaskadeneffekt darstellen.
- **Case 4:** `CONN_MAX_AGE`-Wert aus Django-Settings unbekannt – beeinflusst wie schnell der Idle-Timeout greift.
- **Case 1/5:** Verwaiste `/dev/shm`-Blöcke bei hartem PipelineManager-Crash (SIGKILL) – Überschneidung beider Cases, in der Ausarbeitung klar abgrenzen.
