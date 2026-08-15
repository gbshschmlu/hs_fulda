# Team-Beiträge, Eigenständigkeitserklärung & KI-Offenlegung

**Modul:** Multimedia-Kommunikation (AI1033)
**Semester:** Sommersemester 2026
**Gruppe:** Gruppe 4
**Gruppenmitglieder:** Luca Michael Schmidt, Roman Walter Sippel, Thomas Krasel, Florian Ruppel

---

## 1. Team-Beiträge

| Mitglied                 | Spezifische Aufgaben & Beiträge                                                                                                                                                                                                                                                                         |
| :----------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Luca Michael Schmidt** | Konzeption & Implementierung der räumlichen Prädiktion (Intra-Frame-Differenzierung mit Modulo-256-Arithmetik), der zeitlichen Inter-Frame-Prädiktion sowie der adaptiven Residual-Payload-Kodierung (1-Bit-Nullmaske via `np.packbits` mit automatischem Raw-Fallback)                                |
| **Roman Walter Sippel**  | Entwurf der verlustbehafteten Quantisierungs-Engine (skalare Quantisierung/Dequantisierung mit getrennten Schrittweiten für Luminanz und Chrominanz), Container-Architektur (`LS01`/`LY01`), GOP-Strukturierung (I-/P-Frame-Rhythmus) sowie Bitstream-Validierungslogik                                |
| **Thomas Krasel**        | Implementierung der verifizierenden Testsuite (`tests/test_codec.py`), automatisierte Lossless- und Lossy-Differenzbild-Erzeugung zur visuellen Verifikation sowie Error-Handling bei korrupten/abgeschnittenen Bitstreams                                                                                                  |
| **Florian Ruppel**       | Entwicklung der Benchmark-Suite mit `matplotlib` (Laufzeit- & Rate-Distortion-Analysen), Durchführung der empirischen Vergleichsmessungen (PackBits-RLE vs. Nullmaske, Quantisierungs-Sweep), visuelle Artefakt-Analyse und Ausarbeitung der technischen Dokumentation (`README.md`, `EXPERIMENTS.md`) |

---

## 2. Eigenständigkeitserklärung

Hiermit erklären wir, dass das vorliegende Projekt unsere eigene Arbeit ist. Das gesamte Systemdesign, die Implementierung sowie die Schlussfolgerungen wurden von den oben genannten Teammitgliedern erstellt. Alle Vorschläge und Ergebnisse, die mithilfe von KI-Werkzeugen generiert wurden, wurden von uns vor der Aufnahme in dieses Projekt kritisch geprüft, verifiziert und überarbeitet.

---

## 3. Offenlegung der Nutzung generativer KI

| Werkzeug             | Aufgabe / Funktion                     | Art der Unterstützung                                                                                                                                                                                                 |
| :------------------- | :------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Claude Fable 5**   | **Architektur- & Konzeptionsberatung** | • Entwurf der GOP-Struktur und des einfachen I-/P-Frame-Ablaufs<br>• Vergleich von PackBits-RLE und Nullmasken-Kodierung für Residuals<br>• Abwägung von Dateigröße, Laufzeit und Verständlichkeit der Lösung |
| **Claude Sonnet 5**  | **Code-Auditing & Logikprüfung**       | • Prüfung der Modulo-256-Grenzfälle bei der Prädiktion<br>• Suche nach Fehlern bei abgeschnittenen Bitstreams und falschen Payload-Längen<br>• Hinweise für kleine Clean-Code- und Strukturverbesserungen |
| **GPT-5.6-Luna-Max** | **Dokumentations- & Testfall-Hilfe**   | • Mathematische Validierung der Quantisierungsfehler-Schranken<br>• Unterstützung bei Testfällen für Lossless- und Lossy-Round-Trips<br>• Hilfe bei Tabellen, Benchmark-Texten und der Formatierung der technischen Dokumentation |
