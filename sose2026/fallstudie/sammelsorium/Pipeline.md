# Systemarchitektur & Pipeline-Dokumentation: ROSI (Deep Dive)

## Meta-Kontext

Dieses Dokument beschreibt die Softwarearchitektur, die Orchestrierung, den Datenfluss und das Speichermanagement des "ROSI"-Systems (ein industrielles Bildverarbeitungs- und Defekterkennungssystem). Es existiert kein Quellcode in diesem Dokument; stattdessen werden die konzeptionellen und mechanischen Paradigmen detailliert erklärt. Nutze dieses Wissen, um Fragen zur Skalierung, zum Multiprocessing, zur Pipeline-Hierarchie oder zur Speicherverwaltung des Systems zu beantworten.

---

## 1. Systemübersicht & Kernphilosophie

ROSI ist auf extrem hohen Durchsatz und parallele Bildverarbeitung ausgelegt. Um den "Global Interpreter Lock" (GIL) von Python zu umgehen und große Bilddatenmengen (Gigabytes pro Sekunde) nicht durch teure Inter-Process-Communication (IPC) zu blockieren, basiert das System auf drei Säulen:

1. **Striktes Multiprocessing:** Trennung von Datenproduktion, Bildakquise, Orchestrierung und Logging in dedizierte Haupt-Prozesse.
2. **Zero-Copy durch Shared Memory:** Große Daten (Bilder, Tensoren) wandern _niemals_ durch Queues. Queues transportieren ausschließlich Referenzen (Metadaten) auf vom Betriebssystem verwaltete C-Level RAM-Blöcke.
3. **Map-Reduce über dynamische Worker-Pools:** Schwere Rechenaufgaben werden dynamisch auf einen Pool von Hintergrund-Prozessen (Workern) verteilt und deren Ergebnisse asynchron wieder zusammengeführt.

---

## 2. Prozess-Topologie (Die Hauptakteure)

Das System wird beim Start in mehrere unabhängige Prozesse aufgeteilt, die über threadsichere `multiprocessing.Queue` und `Event`-Primitive kommunizieren.

### 2.1 InspectionDataHandlerProcess (Der Daten-Factory-Prozess)

- **Aufgabe:** Produziert fortlaufend leere `InspectionData`-Objekte (die zentralen Daten-Container des Systems) und versieht sie mit fortlaufenden IDs sowie der aktuellen Systemkonfiguration.
- **Mechanik (Backpressure):** Er schiebt diese Objekte in eine limitierte Queue. Ist die Queue voll, wartet der Prozess. Dies fungiert als systemweites Backpressure-Ventil, das verhindert, dass das System bei Verarbeitungsstaus unendlich viel Speicher allokiert (Out-Of-Memory-Schutz).

### 2.2 FrameGrabberProcess (Der Hardware-/Simulations-Prozess)

- **Aufgabe:** Konsumiert leere `InspectionData`-Objekte. Er kommuniziert mit der echten Kamera-Hardware (oder simuliert diese), akquiriert die Bilder und speichert die rohen Pixeldaten direkt in neu allozierten Shared-Memory-Blöcken.
- **Output:** Erzeugt ein `FrameGrabberResult` (enthält Referenzen auf die Speicherblöcke) und schiebt dieses in die Result-Queue für den Pipeline Manager.

### 2.3 PipelineManagerProcess (Der Orchestrator)

- **Aufgabe:** Das "Gehirn" der Datenverarbeitung. Er entnimmt die Ergebnisse des FrameGrabbers, erzeugt einen sogenannten `MPWorkerPool` (siehe Abschnitt 5) und leitet die Referenzdaten chronologisch durch die definierte Pipeline-Hierarchie.
- **Besonderheit:** Er ist synchron in der Steuerung der Pipeline-Schritte, lagert die tatsächliche CPU-Last aber asynchron in den Worker-Pool aus.

### 2.4 LoggerProcess (Der asynchrone Beobachter)

- **Aufgabe:** Alle anderen Prozesse (und Sub-Worker) schieben ihre Lognachrichten in eine zentrale Queue. Dieser Prozess liest sie im Batch und schreibt sie asynchron auf die Festplatte, Konsole oder in eine Datenbank (Django). Das verhindert, dass I/O-Latenzen die Bildverarbeitung blockieren.

---

## 3. Die Pipeline-Hierarchie (Orchestrierung)

Die Datenverarbeitung im `PipelineManagerProcess` folgt einer strengen, hierarchischen Topologie:

1. **Pipeline:** Die oberste Ebene. Sie besteht aus einer geordneten Liste von _Steps_. Die Ausführung erfolgt streng **sequenziell** (Schritt 1 muss abgeschlossen sein, bevor Schritt 2 beginnt). Die Datenstruktur (`PipelineData`) wird durchgereicht.
2. **Step:** Ein einzelner Verarbeitungsschritt. Ein Step kann aus einem oder mehreren _Branches_ (Zweigen) bestehen. Alle Branches innerhalb eines Steps werden **parallel (concurrent)** gestartet. Wenn ein Step mehrere Branches hat, muss er zwingend eine `post_step_function` (Reduce) definieren, um die Ergebnisse der verschiedenen Branches am Ende des Steps wieder zu konsolidieren.
3. **Branch:** Ein logischer Zweig, der aus einer geordneten Liste von _Functions_ besteht. Die Funktionen in einem Branch laufen streng **sequenziell** nacheinander ab.
4. **Function:** Die atomare Einheit (die eigentliche Arbeit, z. B. "Fehler per KI suchen" oder "Bilder komprimieren"). Eine Funktion entscheidet anhand ihrer Konfiguration (`run_in_worker_pool`), ob sie im lokalen Thread ausgeführt wird, oder ob sie die Arbeit in den Worker-Pool auslagert.

---

## 4. Das Map-Reduce-Muster (Worker-Pool)

Wenn eine _Function_ rechenintensiv ist und parallelisiert werden soll (z. B. das Encodieren von 5 Bildern in WebP), nutzt das System einen zentralen `MPWorkerPool`.

### Architektur des MPWorkerPools

- **MPWorker (Subprozesse):** Der Pool startet beim Systemstart _N_ Subprozesse. Jeder Worker hat eine eigene Job-Queue und eine eigene Result-Queue. Jeder Worker kann spezifische Funktionalitäten (Job-Klassen) beinhalten, die beim Start initialisiert werden, um Initialisierungs-Overhead bei Laufzeit zu vermeiden.
- **Scheduler:** Wenn die _Function_ der Pipeline einen Job einreicht, sucht der Scheduler den Worker, der (a) für diese Aufgabe qualifiziert ist und (b) die kürzeste Job-Queue hat (Min-Queue-Depth-Routing).
- **ResultCollector (Hintergrund-Thread):** Anstatt den PipelineManager blockierend warten zu lassen, sammelt ein dedizierter Thread im Hintergrund kontinuierlich (non-blocking) alle Results aus allen Workern ein und speichert sie in einem Dictionary. Erst wenn alle benötigten Teil-Jobs abgeschlossen sind, wird die Pipeline benachrichtigt (via `threading.Event`).
- **HealthMonitor:** Ein weiterer Thread überwacht Heartbeat-Pings aller Worker. Antwortet ein Worker nicht rechtzeitig (z.B. wegen eines C-Level-Segfaults im KI-Modell), wird der Worker abgeschossen, neu gestartet und der fehlerhafte Job abgebrochen.

### Ablauf einer dezentralen Function (Map-Reduce)

1. **Map (`job_distribution_call`):** Bevor der Job an den Pool geht, spaltet diese Callback-Funktion die Last auf. Aus "Kodiere alle Bilder" werden 5 Jobs: "Kodiere Bild 1", "Kodiere Bild 2", etc.
2. **Execute:** Der Pool verteilt die 5 Jobs an 5 freie Worker.
3. **Reduce (`result_combination_call`):** Wenn der ResultCollector alle 5 Ergebnisse gemeldet hat, führt dieser Callback die Einzelergebnisse wieder in das zentrale `InspectionData`-Objekt zusammen (z.B. Anhängen an eine Liste).

---

## 5. Speichermanagement (Shared Memory & Zero-Copy)

Das kritischste Design-Pattern des Systems ist die Vermeidung von Pickling/Serialisierung großer Arrays.

### Das Konzept der Shared Memory Container

Bilder (NumPy Arrays) werden niemals über Queues gesendet. Stattdessen wird `multiprocessing.shared_memory` genutzt:

1. Es wird ein Speicherblock auf OS-Ebene (RAM) mit einer UUID alloziert.
2. Die Bilddaten werden in diesen Block geschrieben.
3. Das System generiert kleine Python-Objekte (`SharedMemoryBlock`, `SharedMemoryFrame`, `SharedMemoryEncodedImage`), die lediglich diese UUID, die Shape (Breite/Höhe) und den Datentyp (z. B. uint8) speichern.
4. **Zero-Copy-Abruf:** Wenn ein Worker-Prozess das Bild bearbeiten will, ruft er `.get_data()` auf dieses Proxy-Objekt auf. Das Objekt nutzt die UUID, verbindet sich mit dem C-Level Buffer des OS und stülpt eine NumPy-Maske darüber. Das Array kann nun ohne Kopieren gelesen werden.

### Der Lebenszyklus & Memory Leak Prävention

Da das OS den Speicher verwaltet, würde ein nicht geschlossener Block zu einem sofortigen Memory Leak führen. Es gibt ein striktes Ownership-Konzept:

- **`close()`:** Wird aufgerufen, wenn ein einzelner Prozess mit dem Block fertig ist. Es löst nur die lokale Bindung. Das Memory bleibt für andere Prozesse erhalten.
- **`destroy()`:** Darf nur exakt **einmal** aufgerufen werden, ganz am Ende der Pipeline, wenn das Bild vollständig verarbeitet wurde. Dies befiehlt dem OS, den Speicher global freizugeben.
- **Ausfallsicherheit:** Der Hauptcontainer (`InspectionData`) registriert sich bei seiner Erzeugung via `atexit`. Stirbt das Skript unerwartet, greift der Hook und feuert ein hartes `destroy()` auf alle angehängten Speicherelemente. Auch werden "verwaiste" Blöcke, die in Queues stecken geblieben sind, über Timestamp-Heuristiken erkannt und abgeräumt.

---

## 6. Datenmodellierung: Columnar Storage für Defekte

Um CPU-Cache-Hits zu maximieren und Speicher-Overhead zu minimieren, nutzt das System für die gefundenen Defekte (`DefectsNew`) das "Struct of Arrays" (bzw. Columnar) Pattern statt "Array of Structs".

Anstatt für jeden der ggf. 10.000 gefundenen Fehler auf einem Brett ein eigenes Python-Objekt (Klasse `Defect`) zu erstellen, gibt es **eine einzige Instanz** von `DefectsNew`.

- Diese Instanz enthält 1D- und N-D-NumPy-Arrays (`ids`, `classes`, `corners`, `contours`, `scores`).
- Der Defekt mit dem Index `i` besteht aus den Werten `ids[i]`, `classes[i]`, `corners[i]` etc.
- **Vorteil beim Mergen (Reduce):** Wenn mehrere Worker parallele Fehler finden und diese zusammenführen müssen, muss das System keine Python-Objekte iterieren. Es führt lediglich ein extrem schnelles `numpy.concatenate()` auf die jeweiligen Arrays (z. B. alle `scores`-Arrays aneinanderhängen) aus. Index-Mappings (für Klassennamen) werden dynamisch umgeschrieben (`remap`), sodass die Konsistenz gewahrt bleibt.

---

## 7. Der Chronologische Datenfluss (Zusammenfassung)

1. **Init:** Der `InspectionDataHandlerProcess` erzeugt Container #123 und legt ihn in die Queue.
2. **Acquisition:** Der `FrameGrabber` nimmt Container #123. Er reserviert 3 Shared Memory Blöcke für 3 Kamerakanäle. Er schreibt die rohen Pixel vom Sensor dorthin. Er sendet Container #123 (enthält jetzt UUIDs der Blöcke) an den `PipelineManager`.
3. **Pipeline Start:** Der Manager empfängt #123. Er startet Step 1.
4. **KI-Inferenz (Worker):** Step 1, Branch 1 beinhaltet die KI-Erkennung. Der Container geht als Argument an den Worker-Pool.
5. **Execution (Zero-Copy):** Ein Subprozess-Worker erhält den Job. Er liest die UUIDs, mappt den Speicher, führt das PyTorch-Modell aus. Er generiert `DefectsNew` (Numpy-Arrays) und sendet das Ergebnis zurück an den Manager.
6. **Reduktion:** Der Manager hängt die gefundenen KI-Defekte in Container #123 ein.
7. **Ende:** Nachdem Geometrie, Qualität und Bildkompression (alle über parallele Worker) abgeschlossen sind, wird Container #123 für den Export in Django aufbereitet.
8. **Cleanup:** Der Manager ruft `Container_123.destroy()` auf. Das Betriebssystem gibt die Gigabytes an Bilddaten augenblicklich frei. Der Zyklus für das nächste Bild geht weiter.
9.
