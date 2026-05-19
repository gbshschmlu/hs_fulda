# Exposé – Praxisorientierte Fallstudie AI3955

**Titel:** Verfügbarkeit und Fehlertoleranz des ROSI-Systems im industriellen Dauerbetrieb

**Student:** Schmidt, Luca Michael | Matrikelnummer: 1540963
**Betreuer:** Manuel Pilz, Grenzebach BSH GmbH
**Modul:** Praxisorientierte Fallstudie – AI3955, 4. Semester SoSe26

---

## 1. Kontext & Problemstellung

ROSI (Realtime Optical Surface Inspection) ist ein von Grenzebach BSH GmbH entwickeltes
Inline-Scan-System zur automatisierten Qualitätskontrolle von Baustoffen. Das System erfasst
Materialoberflächen im laufenden Produktionsprozess, erkennt Defekte mittels KI-Inferenz und
stuft das Material regelbasiert in Qualitätsstufen ein. Der Betrieb erfolgt on-premise, direkt
in der Produktionsanlage des Kunden, im 24/7-Dauerbetrieb.

Das System befindet sich in aktiver Entwicklung. Die erste Kundeninbetriebnahme ist für
Mitte/Ende 2026 geplant. Mit dem bevorstehenden produktiven Einsatz steigen die Anforderungen
an Verfügbarkeit und Fehlertoleranz des Systems erheblich: Ausfälle bedeuten Produktionsstillstand,
fehlende Inspektionsergebnisse und im schlimmsten Fall unbemerkte Qualitätsmängel beim Kunden.

---

## 2. Risiken im industriellen 24/7-Betrieb

Systeme die ohne Unterbrechung laufen sind einer Klasse von Problemen ausgesetzt die im
Entwicklungsbetrieb selten sichtbar werden. Dazu zählen unter anderem:

- **Speichererschöpfung:** Puffer, Logs oder Datenbanken wachsen schleichend bis Schreiboperationen
  systemweit fehlschlagen
- **Stille Prozessausfälle:** Ein Teilprozess stürzt ab, das System läuft scheinbar weiter –
  ohne Alarm, ohne Neustart
- **Verbindungsabbrüche:** Datenbankverbindungen veralten nach langen Pausen und führen beim
  nächsten Zugriff zu hartem Systemabsturz
- **Kaskadeneffekte:** Die Verlangsamung einer Komponente blockiert über gemeinsame Queues
  und Shared Memory das gesamte System
- **Blinde Flecken im Monitoring:** Vorhandene Überwachungskomponenten erfassen nicht alle
  kritischen Ressourcen – etwa flüchtige RAM-Dateisysteme oder interne Queue-Tiefen

ROSI verfügt aktuell über kein externes Alerting. Probleme werden erst durch ausbleibende
Inspektionsergebnisse oder manuelle Beobachtung sichtbar. Diese Fallstudie untersucht genau
diese Klasse von Problemen: stille, schleichende und kaskadierende Fehler auf Prozess- und
Betriebssystem-Ebene, die im Dauerbetrieb entstehen und reproduzierbar simuliert werden können.

---

## 3. Themenblöcke & Failure Cases

Die identifizierten Failure Cases werden in drei Themenblöcke gegliedert. Die genaue Analyse
der einzelnen Cases erfolgt in der Ausarbeitung – hier wird die inhaltliche Ausrichtung
auf übergeordneter Ebene dargestellt.

### Block A – Speicher- & Ressourcenverwaltung

_Leitfrage: Wie geht das System mit begrenzten Ressourcen um, wenn Subsysteme überlaufen
oder Prozesse unkontrolliert enden?_

Untersucht werden Szenarien rund um den flüchtigen Bildspeicher (RAM Disk) als Single Point
of Failure sowie Timing-Konflikte im Shared-Memory-Management des Worker-Pools unter Last.

### Block B – Systembeobachtbarkeit & Fehlertoleranz

_Leitfrage: Wie schnell erkennt das System eigene Ausfälle – und reagiert es überhaupt?_

Untersucht wird die Lücke zwischen der vorhandenen Prozess-API (State-Management, Start/Stop)
und der fehlenden Supervisor-Logik in der Laufzeitüberwachung. Ergänzend werden die konkreten
Blind Spots des neu eingeführten Load Monitors analysiert.

### Block C – Datenpersistenz, Retention & Kaskadeneffekte

_Leitfrage: Wie verhält sich das System wenn Datenbankverbindungen unterbrochen werden oder
Datenmengen unkontrolliert wachsen – und welche Folgefehler entstehen daraus?_

Untersucht werden täglich reproduzierbare Verbindungsabbrüche nach Produktionspausen sowie
Kaskadeneffekte durch blockierende Log-Queues, die das gesamte System zum Stillstand bringen
können.

---

## 4. Methodik

Die Untersuchung erfolgt am Referenzsystem im Labor Bad Hersfeld (Xubuntu 24.04 LTS,
AMD Ryzen 9 9950X, NVIDIA RTX 5090). Alle Failure Cases sind vollständig ohne echte
Kamerahardware simulierbar – der vorhandene Simulator erlaubt reproduzierbare Szenarien
unter kontrollierten Bedingungen.

Pro Case werden konkrete Messgrößen erhoben und systematisch ausgewertet, darunter
Time-to-Detection bei Prozessausfällen, Inspections/s als Durchsatzmetrik sowie
Queue-Tiefe und Speicherfüllstand über die Zeit.

---

## 5. Projektplanung

| Meilenstein | Datum           | Zwischenergebnis                                                        |
| ----------- | --------------- | ----------------------------------------------------------------------- |
| M1          | 18. Juni 2026   | Theorierahmen erarbeitet, Testumgebung aufgesetzt, erste Cases gemessen |
| M2          | 16. Juli 2026   | Alle Failure Cases gemessen, Rohdaten vollständig vorhanden             |
| M3          | 13. August 2026 | Auswertung aller Cases abgeschlossen, Ausarbeitung begonnen             |
| Abgabe      | 27. August 2026 | Ausarbeitung (15 Seiten) und Präsentation (15 Minuten) fertig           |
