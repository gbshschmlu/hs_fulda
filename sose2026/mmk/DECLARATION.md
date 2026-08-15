# Team-Beiträge, Eigenständigkeitserklärung & KI-Offenlegung

**Modul:** Multimedia-Kommunikation (AI1033)
**Semester:** Sommersemester 2026
**Gruppe:** Gruppe 4
**Gruppenmitglieder:** Luca Michael Schmidt, Roman Walter Sippel, Thomas Krasel, Florian Ruppel

---

## 1. Team-Beiträge

| Mitglied                 | Spezifische Aufgaben & Beiträge                                                                                                                                                                                                                                           |
| :----------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Luca Michael Schmidt** | Konzeption und Implementierung der räumlichen Modulo-256-Differenzkodierung, der einfachen zeitlichen Frame-Differenzierung sowie der adaptiven Residualkodierung mit Raw-Daten, Nullmaske, PackBits-artiger Lauflängenkodierung und optionaler kanonischer Huffman-Stufe |
| **Roman Walter Sippel**  | Entwurf und Implementierung der skalaren Quantisierung und Dequantisierung mit getrennten Schrittweiten für Luminanz und Chrominanz, der Containerformate `LS01`/`LY01`, der I-/P-Frame-Struktur sowie der Validierung von Metadaten, Frame-Typen und Payload-Längen      |
| **Thomas Krasel**        | Implementierung der Testsuite in `tests/test_codec.py`, automatisierte Lossless- und Lossy-Differenzbilder sowie Tests der Round-Trips, der RLE-/Huffman-Kodierung und des Error-Handlings bei abgeschnittenen oder ungültigen Bitstreams                                 |
| **Florian Ruppel**       | Entwicklung der Benchmark- und Rate-Distortion-Diagramme mit NumPy und `matplotlib`, Durchführung der Größen- und Quantisierungsvergleiche, visuelle Artefaktanalyse sowie Ausarbeitung und Abstimmung von `README.md` und `EXPERIMENTS.md` auf die Endfassung            |

---

## 2. Eigenständigkeitserklärung

Hiermit erklären wir, dass das vorliegende Projekt unsere eigene Arbeit ist. Das gesamte Systemdesign, die Implementierung sowie die Schlussfolgerungen wurden von den oben genannten Teammitgliedern erstellt. Alle Vorschläge und Ergebnisse, die mithilfe von KI-Werkzeugen generiert wurden, wurden von uns vor der Aufnahme in dieses Projekt kritisch geprüft, verifiziert und überarbeitet.

---

## 3. Offenlegung der Nutzung generativer KI

| Werkzeug             | Aufgabe / Funktion                   | Art der Unterstützung                                                                                                                                                                                                                                                                       |
| :------------------- | :----------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Claude Fable 5**   | Architektur- und Konzeptionsberatung | Entwurf der einfachen I-/P-Frame-Struktur, Vergleich von Raw-Daten, Nullmaske und PackBits-artiger Lauflängenkodierung für Residuals sowie Abwägung von Dateigröße, Laufzeit und Verständlichkeit                                                                                           |
| **Claude Sonnet 5**  | Code-Auditing und Logikprüfung       | Prüfung der Modulo-256-Grenzfälle, Suche nach Fehlern bei abgeschnittenen Bitstreams und falschen Payload-Längen sowie Hinweise zur Strukturierung und Validierung der selbst implementierten RLE- und Huffman-Funktionen                                                                   |
| **GPT-5.6-Luna-Max** | Dokumentations- und Testfall-Hilfe   | Mathematische Prüfung der Quantisierungsfehler-Schranken, Unterstützung bei Tests für Lossless-/Lossy-, RLE- und Huffman-Round-Trips sowie Hilfe bei Benchmark-Tabellen, Asset-Erzeugung und der Abstimmung der technischen Dokumentation auf die finale Implementierung und den Foliensatz |

KI-generierte Vorschläge wurden nicht ungeprüft übernommen. Wir haben die verwendeten Algorithmen ausgewählt, den erzeugten Code ausgeführt und getestet sowie Messwerte und fachliche Aussagen anhand der bereitgestellten Y4M-Datei und des Foliensatzes überprüft.
