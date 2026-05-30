# Schreib- und Formatregeln – Fallstudie AI3955

> Angepasst für die **Ausarbeitung** der praxisorientierten Fallstudie (nicht Exposé).
> Übernommen und gefiltert aus dem Modul Wiss. Kommunikation (WiSe25), an den
> Fallstudien-Kontext angepasst. Stand: 30. Mai 2026.

---

## 1. Formale Vorgaben

| Punkt         | Vorgabe                        | Status                               |
| ------------- | ------------------------------ | ------------------------------------ |
| Format        | LaTeX                          | Template vorhanden (`ausarbeitung/`) |
| Schriftart    | 12pt Libertine                 | in `preamble.sty` gesetzt            |
| Seitenränder  | alle 25mm                      | in `preamble.sty` gesetzt            |
| Zeilenabstand | 1,5-zeilig (`\onehalfspacing`) | gesetzt                              |
| Umfang        | **15 Seiten**                  | Fallstudien-Vorgabe (Exposé)         |
| Zitierstil    | IEEE (nummeriert)              | `style=ieee` in `preamble.sty`       |

---

## 2. Wissenschaftlicher Stil

- Klare, präzise, strukturierte Darstellung; ein durchgehender roter Faden.
- Sachlicher, objektiver Ton.
- **Keine** Ich-Form, keine Umgangssprache, keine Ironie.
- **Keine** unbestimmten Zahlwörter („viele", „einige", „oft") – stattdessen konkrete
  Werte aus den Messungen (z. B. „Time-to-Detection von 0,992 s").
- Füllwörter, Redundanzen und unnötige Wiederholungen vermeiden.
- Korrekte Rechtschreibung, Grammatik und Zeichensetzung.
- **Fettdruck sparsam einsetzen.** Zur Einführung von Fachbegriffen und für
  Listen-Labels Kursivschrift (`\textit`) bevorzugen. Fett (`\textbf`) bleibt
  funktionalen Elementen wie Tabellenköpfen und wenigen Schlüsselstellen vorbehalten.

---

## 3. Quellen und Zitation

- Korrekte direkte und indirekte Zitation im IEEE-Stil (`\cite{key}`).
- Hochwertige Quellen bevorzugen: Primärquellen, referierte Paper, offizielle
  Dokumentationen (Standards, Framework-Docs).
- Bei Online-Quellen: Zugriffsdatum angeben (hier: 30. Mai 2026).
- Alle BibTeX-Einträge liegen in `ausarbeitung/bib/references.bib`.

---

## 4. Abbildungen und Tabellen

- **Mindestens eine** Grafik einbinden (Obergrenze des Exposé-Moduls entfällt hier).
- Jede Abbildung, Tabelle und jeder Code-Listing **muss im Text referenziert** werden
  (z. B. „siehe Abbildung 1", „vgl. Tabelle 2").
- Jede Grafik braucht eine **korrekte Quellenangabe** (`\source{...}`); eigene
  Darstellungen als „Eigene Darstellung" kennzeichnen.
- Kandidaten für diese Arbeit:
    - Prozessarchitektur-Diagramm (aus `Pipeline.md` / `Basis.md`)
    - Zeitreihen-Plot Speicherfüllstand (Case 2, CSV vorhanden)
    - Zeitreihen-Plot Queue-Tiefe (Case 3, CSV vorhanden)
    - Tabellen mit Messergebnissen pro Case

---

## 5. Struktur der Ausarbeitung

> **Wichtig:** Dies ist eine fertige Ausarbeitung **mit empirischen Ergebnissen**

1. **Titelseite** – Titel, Name, Matr.-Nr., Betreuer, Datum
2. **Zusammenfassung / Abstract** – Thema, Methodik, Kernergebnisse (mit Ergebnissen,
   anders als im Exposé)
3. **Inhaltsverzeichnis** (+ ggf. Abbildungsverzeichnis)
4. **Einleitung & Problemstellung** – ROSI-Kontext, 24/7-Risiken, Zielsetzung,
   Forschungsfragen pro Themenblock
5. **Theoretische Grundlagen** – aus `theorierahmen.md`
6. **Methodik** – Referenzsystem, Simulator, Fault Injection, Messgrößen
7. **Failure Cases (Ergebnisse)** – Cases 1–5, je: Kontext → Problem → Messung →
   Interpretation → Empfehlung
8. **Fazit & Handlungsempfehlungen** – Synthese, Kaskaden-Zusammenhänge, Ausblick
9. **Literaturverzeichnis**
10. **Eidesstattliche Erklärung**
