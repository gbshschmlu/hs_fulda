# Übungsblatt 3 – Prozessmodellierung - Aktivitätsdiagramme

<div style="text-align: right">Luca M. Schmidt</div>

## 1. Geschäftsprozesse modellieren (Beispiel "Vertrieb")

### a. Inkrementelle Entwicklung der Prozessbeschreibung

* **Iteration 1 (Typischer Ablauf):**
    * Fokus auf den "Happy Path" / Standardfall
    * Grundlegende Aktionen: `Kundengespräch`, `Kosten kalkulieren`, `Vertragsverhandlung`
    * Beteiligte (Rollen) und Produkte (Datenobjekte) identifiziert
* **Iteration 2 (Alternative Abläufe):**
    * Hinzufügen von Entscheidungspunkten und alternativen Pfaden basierend auf typischen Abweichungen:
        * Kunde nicht interessiert (impliziter Abbruch nach Gespräch oder Angebot)
        * Nachkalkulation notwendig (neue Rahmenbedingungen)
        * Entscheidung durch Abteilungsleiter/Geschäftsleitung bei bestimmtem Vertragsvolumen
        * Nachfragen der Fachabteilung
    * Einführung von Kontrollknoten (Entscheidungen, Zusammenführungen)
    * Aktualisierung von Datenobjekten (z.B. Kostenvoranschlag `[initial]` vs. `[aktualisiert]`)

### b. Verbesserung der Lesbarkeit und Komplexität

* **Swimlanes (Verantwortungsbereiche):** Klare Zuordnung von Aktionen zu Rollen (Kunde, Vertriebsmitarbeiter,
  Fachabteilung)
* **Prozessverfeinerung (Sub-Aktivitäten):** Komplexe Aktionen (z.B. `Kosten kalkulieren`) in eigene, detailliertere
  Aktivitätsdiagramme auslagern
* **Konnektoren:** Bei großen Diagrammen Flüsse über Seitengrenzen hinweg mit nummerierten Kreisen verbinden
* **Konsistente Namensgebung:** Klare, verständliche Bezeichnungen für Aktionen, Objekte und Bedingungen
* **Weglassen von Details:** Z.B. redundante Objektflüsse oder zu feingranulare Zustände auf oberster Ebene vermeiden,
  wenn sie die Übersicht stören. Fokus auf den Kernprozess
* **Layout:** Übersichtliche Anordnung, Minimierung von Kreuzungen der Kontrollflüsse
* **Annotationen:** Für Erklärungen, die nicht direkt ins Modell passen

---

## 2. UML Aktivitätsdiagramme - Syntax (Abb. 13.9 & 13.10)

### Elemente und ihre Notation

| Element                               | Notation                                      | Verwendung                                                                                                                             |
|:--------------------------------------|:----------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------|
| **Startknoten**                       | Ausgefüllter Kreis                            | Beginn des Aktivitätsflusses                                                                                                           |
| **Endknoten (Aktivität)**             | Ausgefüllter Kreis mit Umrandung              | Ende des gesamten Aktivitätsflusses                                                                                                    |
| **Aktion/Aktivität**                  | Rechteck mit abgerundeten Ecken               | Auszuführende Aufgabe oder Arbeitsschritt                                                                                              |
| **Entscheidungsknoten**               | Raute (Diamant)                               | Verzweigung des Kontrollflusses basierend auf Bedingungen (ein Eingang, mehrere Ausgänge)                                              |
| **Zusammenführungsknoten**            | Raute (Diamant)                               | Vereinigt mehrere alternative Kontrollflüsse zu einem (mehrere Eingänge, ein Ausgang)                                                  |
| **Bedingung (Guard)**                 | Text in eckigen Klammern `[Bedingung]`        | Legt fest, unter welcher Bedingung ein Pfad eines Entscheidungsknotens gewählt wird                                                    |
| **Parallelisierung (Fork)**           | Dicker Balken (horizontal/vertikal)           | Teilt einen Kontrollfluss in mehrere parallel ablaufende Flüsse (ein Eingang, mehrere Ausgänge)                                        |
| **Synchronisierung (Join)**           | Dicker Balken (horizontal/vertikal)           | Vereinigt parallele Kontrollflüsse; Fortsetzung erst, wenn alle eingehenden Flüsse abgeschlossen sind (mehrere Eingänge, ein Ausgang)  |
| **Objektknoten**                      | Rechteck                                      | Repräsentiert ein Objekt (Daten, Material), das verwendet/erzeugt wird. Kann Zustände `[Zustand]` oder Gewichtungen `{weight=5}` haben |
| **Kontrollfluss**                     | Pfeil (durchgezogene Linie)                   | Zeigt die Reihenfolge der Aktionen                                                                                                     |
| **Objektfluss**                       | Pfeil (durchgezogen oder gestrichelt)         | Zeigt den Fluss von Objekten zwischen Aktionen und Objektknoten                                                                        |
| **Aktivitätsbereich (Swimlane)**      | Großes Rechteck (Partition)                   | Gruppiert Aktionen nach Verantwortlichkeit (Rolle, Abteilung, System)                                                                  |
| **Konnektor (Connector)**             | Kreis mit Buchstabe/Zahl (hier: ①)            | Verbindet Diagrammteile, oft über Seiten hinweg                                                                                        |
| **Signal senden (Send Signal)**       | Fünfeck mit Pfeil nach außen (konvex)         | Sendet ein Signal an eine andere Aktivität oder ein System                                                                             |
| **Signal empfangen (Receive Signal)** | Fünfeck mit Pfeil nach innen (konkav)         | Wartet auf ein eintreffendes Signal, um fortzufahren                                                                                   |
| **Aktivitätsbereich (gestrichelt)**   | Gestricheltes Rechteck mit abgerundeten Ecken | Gruppiert zusammengehörige Aktionen innerhalb einer Aktivität (hier zur Abgrenzung des "Party-Kernbereichs")                           |

---

## 3. Risiken im Partyverlauf (Abb. 13.9)

**Risiko 1:**

| Feld                    | Beschreibung                                                                                                                              |
|:------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|
| **Risiko**              | Zu wenig Gäste sagen zu (`[Zusagen < 50%]`)                                                                                               |
| **Auswirkung**          | Gekauftes Essen muss weggeworfen werden (falls Einkauf schon getätigt), Party findet evtl. nicht statt / Frust                            |
| **Ursache**             | Unattraktive Einladung, falscher Zeitpunkt, zu kurzfristige Einladung                                                                     |
| **Maßnahme**            | Zeitpunkt sorgfältig wählen, attraktive Einladung, frühzeitig einladen, Reminder senden. Alternativ: Einkauf erst *nach* Zusagen-Deadline |
| **Messung des Erfolgs** | Zusagenquote >= 50%, kein/wenig Essen muss wegen mangelnder Zusagen weggeworfen werden                                                    |

**Risiko 2:**

| Feld                    | Beschreibung                                                                                                |
|:------------------------|:------------------------------------------------------------------------------------------------------------|
| **Risiko**              | Selbst gekochtes Essen misslingt (`[Essen verbrannt]` oder `[Essen ungenießbar]`)                           |
| **Auswirkung**          | Gäste bleiben hungrig, schlechte Stimmung, Zusatzkosten und Aufwand für Partyservice                        |
| **Ursache**             | Mangelnde Kocherfahrung, komplexes Rezept, Ablenkung, schlechte Zutaten                                     |
| **Maßnahme**            | Einfaches, erprobtes Rezept wählen, Probekochen, hochwertige Zutaten, Partyservice als Backup-Option prüfen |
| **Messung des Erfolgs** | Essen wird von Gästen positiv bewertet, kein Partyservice als Notlösung nötig                               |

**Risiko 3:**

| Feld                    | Beschreibung                                                                                                                 |
|:------------------------|:-----------------------------------------------------------------------------------------------------------------------------|
| **Risiko**              | Vorräte (Essen/Getränke) gehen während der Party zur Neige (`[< 10% sind noch da]`)                                          |
| **Auswirkung**          | Schlechte Stimmung, Party muss frühzeitig beendet oder unterbrochen werden (`Party abbrechen` / `bei Tankstelle nachrüsten`) |
| **Ursache**             | Zu knappe Kalkulation, unerwartet hoher Verbrauch, keine Reserven                                                            |
| **Maßnahme**            | Großzügiger einkaufen, Puffer einplanen, Gäste bitten, etwas mitzubringen (BYOB), Notfall-Vorrat (z.B. Wasser)               |
| **Messung des Erfolgs** | Vorräte reichen bis zum geplanten Partyende, keine "Notkäufe" nötig                                                          |

---

## 4. UML Modellierungstool (Auftragsbearbeitung, Abb. 13.10) - Ansatz

### Eigenes Risiko und Änderungen

* **Eigenes Risiko:** Der Lieferant kann die bestellte Ware nicht (rechtzeitig oder gar nicht) liefern, *nachdem* das
  Unternehmen den Auftrag bereits gegenüber dem Kunden angenommen hat
    * *Begründung:* Im Diagramm `Auftrag annehmen` (Unternehmen) erfolgt, bevor der Lieferant die Ware tatsächlich
      liefert.
      Es gibt keine explizite Prüfung der Lieferfähigkeit des Lieferanten *vor* der Annahme des Auftrags vom
      Kunden

* **Verringerung des Risikos / Maßnahmen:**
    1. **Vorabprüfung der Lieferfähigkeit:** Das Unternehmen muss *vor* der Aktion `Auftrag annehmen` die Verfügbarkeit
       und Lieferzeit beim Lieferanten prüfen
    2. **Kommunikation bei Nichtverfügbarkeit:** Ist die Ware nicht lieferbar, muss der Kunde informiert werden (Auftrag
       kann nicht angenommen werden oder nur mit Verzögerung/Alternativen)
