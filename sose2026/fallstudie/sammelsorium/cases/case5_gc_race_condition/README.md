# Case 5 – GC Race Condition im Worker-Pool unter Last

**Block:** A – Speicher- und Ressourcenverwaltung  
**Forschungsfrage:** Kann der Worker-GC SharedMemory-Blöcke zerstören, während der PipelineManager sie noch benötigt?  
**Status:** HYPOTHESE WIDERLEGT – System durch zwei unabhängige Mechanismen geschützt

---

## Hintergrund

Jeder Worker-Prozess führt nach Abarbeitung eines Jobs eine GC-Routine aus:

**`.venv/.../worker/types/base.py` (Auszug):**
```python
cleanup_old_sm_blocks(blocks=sm_blocks_in_use, remove_after_seconds=10)
```

Diese Routine zerstört `SharedMemoryBlock`-Objekte, die seit mehr als `remove_after_seconds` Sekunden nicht mehr zugegriffen wurden. Ziel: Verhindern, dass `/dev/shm` durch akkumulierte Blöcke volläuft (Case 2).

**Ablauf einer Inspektion:**
- **Step 4** (`encode_frames`): Workers erstellen SM-Blöcke mit Bilddaten
- **Step 5** (`store_images_to_disk` + `extract_features`): Workers lesen SM-Blöcke (letzter Zugriff)
- **Step 6** (`convert_inspection_to_model`): Django-ORM-Persistenz; greift **nicht** direkt auf SM-Blöcke zu

**Hypothetisches Race:**
```
Step 5 fertig → SM-Blöcke nicht mehr gelesen
GC (remove_after_seconds=10) → destroy() nach 10s
             ↑
             Aber: PipelineManager hält noch Referenz?
             → FileNotFoundError beim .get_data()-Aufruf
```

---

## Hypothese

Wenn ein Worker nach Step 5 idle bleibt (Job-Queue leer) und der PipelineManager noch SM-Blöcke referenziert (z.B. wegen langsamem Step 6), könnte der GC die Blöcke zerstören bevor sie nicht mehr benötigt werden.

- `FileNotFoundError` bei `SharedMemory(name=...)` (Kernel-Block bereits `unlink()`'d)
- `BrokenPipeError` bei Zugriffen auf zerstörten Shared Memory
- → Worker-Crash → PipelineManager-Crash → Shutdown

---

## Messgrößen

| Größe | Beschreibung |
|---|---|
| `FileNotFoundError` aufgetreten | Ja/Nein: SM-Block während Zugriff zerstört |
| `BrokenPipeError` aufgetreten | Ja/Nein: defekter SM-Zugriff |
| GC hat Blöcke zerstört | Ja/Nein: GC war aktiv |
| Inspektionen abgeschlossen | Anzahl vollständiger Pipelines im Testzeitraum |
| Crash | Ja/Nein |

---

## Testumgebung

Wie [Baseline](../baseline/README.md). Zusätzlich:

| Eigenschaft | Wert |
|---|---|
| Testdauer | 120s (Genug Zeit für mehrere Inspektionen mit künstlichem Delay) |
| GC-Threshold (Patch) | `remove_after_seconds`: **10 → 2** |
| Step-6-Delay (Patch) | `time.sleep(4.0)` in `convert_inspection_to_model` |
| Beobachtet | stdout nach `FileNotFoundError`, `BrokenPipeError`, `CRASHED` |

---

## Methodik / Durchführung

**Stress-Test mit zwei temporären Code-Patches (automatisch rückgängig gemacht).**

### Code-Modifikationen

#### Patch 1: Aggressiverer GC-Threshold
**Datei:** `.venv/lib/python3.13/site-packages/gbbm_rosi_dependencies/worker/types/base.py`

```python
# Vorher:
cleanup_old_sm_blocks(blocks=sm_blocks_in_use, remove_after_seconds=10)

# Nachher:
cleanup_old_sm_blocks(blocks=sm_blocks_in_use, remove_after_seconds=2)
# ↑ GC zerstört Blöcke schon nach 2s statt 10s
```

#### Patch 2: Step-6-Verzögerung
**Datei:** `gbbm_rosi_django/gbbm_rosi_django/inspection/utils.py`

```python
# Eingefügt am Anfang von convert_inspection_to_model():
import time; time.sleep(4.0)  # CASE5_DELAY
```

**Effekt:** Step-6-Worker sind 4s länger beschäftigt. In dieser Zeit sind Step-4/5-Worker (encode_frames) idle und triggern ihren GC. Bei `remove_after_seconds=2` werden SM-Blöcke zerstört, während Step 6 noch läuft.

### Testablauf

1. Patches anwenden
2. `main_sim.py` starten, 120s laufen lassen
3. Stdout auf `FileNotFoundError`, `BrokenPipeError`, `CRASHED` überwachen
4. Patches automatisch rückgängig machen (im `finally`-Block)
5. Log speichern

**Testskript:** [results/test_case5_gc_race.py](results/test_case5_gc_race.py)

```bash
.venv/bin/python .luca/results/test_case5_gc_race.py
```

---

## Ergebnisse

### Messung

| Messgröße | Wert |
|---|---|
| Laufzeit | 120s |
| Inspektionen abgeschlossen | mehrere (mit je ~4s Step-6-Delay) |
| `FileNotFoundError` aufgetreten | **NEIN** |
| `BrokenPipeError` aufgetreten | **NEIN** |
| GC hat Blöcke zerstört | **JA** (encode_frames-Worker idle >2s) |
| Crash | **NEIN** |

**Log:** [results/case5_gc_race.log](results/case5_gc_race.log)

### Timing-Analyse (warum kein Race)

Aus dem Log (erste vollständige Pipeline nach Warmup):

```
11:31:01.898  Step 4 (encode_frames) verteilt Jobs
11:31:01.936  Step 5 (store_images_to_disk + extract_features) FERTIG [TOOK=37ms]
              ↑ SM-Blöcke werden hier ZULETZT gelesen
11:31:02.398  GPU memory cleared (Worker idle ab jetzt → GC-Uhr tickt)
11:31:03.936  GC kann Blöcke zerstören (last_access + 2s)
              ↑ Aber Step 5 hat die Blöcke bereits bei 11:31:01.936 gelesen!
11:31:05.942  Step 6 (convert_inspection_to_model mit sleep(4s)) FERTIG
```

**Zeitliche Abfolge:**
```
SM-Blöcke erstellt:        ~11:31:00.6  (Step 4 startet)
SM-Blöcke zuletzt gelesen:  11:31:01.936 (Step 5 done)
GC triggert frühestens:     11:31:03.936 (last_access + 2s)
                             └─ 2s nach Step-5-Ende
Step 5 fertig:              11:31:01.936
GC-Window beginnt:          11:31:03.936
→ Step 5 ist 2s VOR GC fertig → kein Overlap → kein Race
```

**Wichtig:** Step 6 (`convert_inspection_to_model`) greift **nicht** direkt auf SM-Blöcke zu. Es konvertiert das bereits deserialisierte `InspectionData`-Objekt im Python-Heap (RAM) in Django-Modelle. Die SM-Blöcke sind für Step 6 irrelevant.

---

## Idempotentes `destroy()` verhindert Double-Free

Auch wenn GC und PipelineManager theoretisch gleichzeitig auf einen Block zugreifen würden, verhindert die Implementierung einen Crash:

**`.venv/.../shared_memory/block.py`:**
```python
def destroy(self) -> bool:
    if self._sm is None:   # ← idempotent: bereits zerstört
        return False
    self._sm.close()
    self._sm.unlink()
    self._sm = None        # ← Marker: "zerstört"
    return True
```

Ein zweites `destroy()` gibt `False` zurück statt zu crashen. Kein `FileNotFoundError` beim doppelten `unlink()`.

---

## Unter welchen Bedingungen wäre ein Race möglich?

Ein Race würde auftreten, wenn:
1. Step 5 länger als `remove_after_seconds` dauert **UND**
2. Ein Worker in diesem Zeitraum idle ist (GC läuft)

Konkret: Step 5 müsste in Produktion (`remove_after_seconds=10`) **länger als 10s** dauern.

**Baseline-Messung:** Step 5 dauert typisch **45–107ms**. Selbst bei sehr langsamer Disk (z.B. NFS oder fast-volle tmpfs) bleibt ein 100-facher Sicherheitspuffer (100ms vs. 10s = 100×).

**Ausnahme:** Extrem langsame oder blockierende Disk I/O (z.B. NFS-Hänger, volle tmpfs → `OSError` führt zu Case 2, nicht zu Case 5) könnte Step 5 verlangsamen. Bei gleichzeitig idle-Worker > 10s wäre ein Race theoretisch möglich, aber der OSError würde zuerst als Case-2-Fehler einschlagen.

---

## Interpretation

Die Untersuchung widerlegt die Ausgangshypothese durch zwei unabhängige Befunde:

**Schutzebene 1 – Zeitpuffer:** Step 5 greift zuletzt auf SM-Blöcke zu und dauert typisch 45–107ms. Der GC-Threshold liegt bei 10s. Der Sicherheitspuffer beträgt damit das ~100-fache der tatsächlichen Zugriffsdauer. Die Hypothese setzte implizit voraus, dass Step 5 und GC in einem konkurrierenden Zeitfenster operieren – das tun sie nicht.

**Schutzebene 2 – Idempotentes `destroy()`:** Selbst bei einem theoretischen Overlap würde `destroy()` beim zweiten Aufruf `False` zurückgeben statt zu crashen – kein `FileNotFoundError`, kein Double-Free.

**Wichtiger Nebenbefund:** Step 6 (`convert_inspection_to_model`) greift überhaupt nicht auf SM-Blöcke zu. Das deserialisierte `InspectionData`-Objekt liegt im Python-Heap (RAM). Die ursprüngliche Annahme, dass ein langsamer Step 6 eine Race-Situation erzeugt, war falsch.

Der GC-Mechanismus selbst ist aktiv und funktioniert korrekt – er zerstört Blöcke nach 10s. Das ist absichtliches Verhalten, kein Bug.

---

## Risikobewertung

**Produktionsrelevanz: NIEDRIG**
- Theoretischer Bug, empirisch nicht reproduzierbar
- 100-facher Sicherheitspuffer durch kurze Step-5-Laufzeiten
- Idempotentes `destroy()` als zweite Schutzebene
- **Einziger kritischer Pfad:** langsame Disk + idle Workers + ROSI weiterläuft (hypothetisch)

---

## Empfehlung

Kein unmittelbarer Handlungsbedarf. Zur defensiven Absicherung langfristig:

1. **Referenzzähler für SM-Blöcke:** `destroy()` erst wenn Referenzzähler = 0 (verhindert Race vollständig)
2. **Step-5-Dauer-Monitoring:** Alarm wenn `store_images_to_disk > 5s` (frühzeitiger Hinweis auf Disk-Probleme, die auch Case 2 ankündigen)
3. `remove_after_seconds=10` bleibt konservativ und ausreichend für aktuelle Workloads
