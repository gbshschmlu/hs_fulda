# Übungsblatt 9 - Graphen Crashkurs

## Grundlagen

### Was ist ein Graph?

Ein Graph besteht aus:

- **Knoten (Vertices)**: Die Punkte im Graph (A, B, C, 1, 2, 3, etc.)
- **Kanten (Edges)**: Die Verbindungen zwischen Knoten

### Arten von Graphen

- **Gerichtet**: Kanten haben eine Richtung (Pfeile). A → B bedeutet nur von A nach B
- **Ungerichtet**: Kanten haben keine Richtung. A - B bedeutet in beide Richtungen
- **Gewichtet**: Kanten haben Zahlen (Kosten, Distanz, etc.)
- **Grad eines Knotens**: Anzahl der Kanten, die an diesem Knoten andocken

---

## Aufgabe 9.1: Adjazenzmatrix lesen

### Was ist eine Adjazenzmatrix?

Eine Tabelle, die zeigt, welche Knoten miteinander verbunden sind.

### Wie liest man sie?

```
    A   B   C
A   0   5   ∞
B   ∞   0   8
C   ∞   ∞   0
```

- **Zeile = Startknoten** (von wo?)
- **Spalte = Zielknoten** (wohin?)
- **Zahl = Gewicht** der Kante
- **∞ = keine direkte Verbindung**

Beispiel: Zeile A, Spalte B = 5 → Es gibt eine Kante von A nach B mit Gewicht 5

### Für die Präsentation

Einfach Zeile für Zeile durchgehen:

- "Von A nach B gibt es eine Kante mit Gewicht 5"
- "Von A nach F gibt es eine Kante mit Gewicht 3"
- etc.

---

## Aufgabe 9.3: Eulerpfade

### Die Frage

Kann man den Graphen zeichnen, ohne den Stift abzusetzen und ohne eine Linie doppelt zu malen?

### Der Trick

Zähle bei jedem Knoten, wie viele Kanten andocken (= Grad des Knotens)

**Regeln:**

1. **Alle Knoten haben geraden Grad (2, 4, 6, ...)**:
    - JA, es gibt sogar einen Eulerkreis (Start = Ziel)

2. **Genau 2 Knoten haben ungeraden Grad (1, 3, 5, ...)**:
    - JA, es gibt einen Eulerpfad (Start bei einem ungeraden, Ende beim anderen)

3. **Mehr als 2 Knoten haben ungeraden Grad**:
    - NEIN, kein Eulerpfad möglich

### Für die Präsentation

1. Bei jedem Knoten die Kanten zählen
2. Ungerade Knoten markieren
3. Regel anwenden und Antwort geben

Beispiel Graph 1:

- A: 4 Kanten (gerade)
- B: 4 Kanten (gerade)
- C: 4 Kanten (gerade)
- etc.
  → Alle gerade → JA, Eulerkreis möglich

---

## Aufgabe 9.4: Tiefensuche (DFS)

### Das Prinzip

"Immer weiter in die Tiefe laufen, bis es nicht mehr geht. Dann zurückgehen (Backtracking) und anderen Weg probieren."

### Schritt für Schritt

1. Starte bei Knoten 1
2. Gehe zum ersten Nachbarn (z.B. 2)
3. Von 2 zum ersten Nachbarn (z.B. 4)
4. 4 ist Sackgasse? → Zurück zu 2
5. Von 2 zum nächsten unbesuchten Nachbarn (z.B. 5)
6. 5 ist Sackgasse? → Zurück zu 2
7. Alle Nachbarn von 2 besucht? → Zurück zu 1
8. Von 1 zum nächsten unbesuchten Nachbarn (z.B. 3)
9. Weiter bis alle erreichbaren Knoten besucht

### Für die Präsentation

Schreibe die Reihenfolge mit, in der du die Knoten besuchst:
"Start 1 → 2 → 4 (Sackgasse, zurück) → 5 (Sackgasse, zurück) → 3 → 6"

**Wichtig**: Knoten 7 und 8 werden nicht erreicht, weil sie nicht mit Knoten 1 verbunden sind!

---

## Aufgabe 9.5: Topologisches Sortieren

### Was ist das?

Eine Reihenfolge finden, in der man Aufgaben erledigen kann.

**Beispiel**: Anziehen

- Erst Unterhose → dann Hose → dann Schuhe
- Nicht: Schuhe → Unterhose (geht nicht!)

### Wann geht es?

- **Nur bei DAGs** (Directed Acyclic Graph = Gerichteter Graph ohne Zyklen)
- **Kein Zyklus**: Es darf keinen Kreis geben (A → B → C → A)

### Wie prüfen?

1. Gibt es einen Zyklus? → NEIN, geht nicht
2. Gibt es keinen Zyklus? → JA, geht

### Wie sortieren?

1. Finde einen Knoten mit Eingangsgrad 0 (kein Pfeil zeigt auf ihn)
2. Setze ihn in die Reihenfolge
3. Entferne ihn gedanklich aus dem Graph
4. Wiederhole bis alle Knoten sortiert sind

### Für die Präsentation

**Linker Graph**:

- Hat Zyklus: 1 → 3 → 2 → 6 → 4 → 5 → 1
- Antwort: NEIN, nicht sortierbar

**Rechter Graph**:

- Hat keinen Zyklus
- Knoten 1 hat Eingangsgrad 0 → Start mit 1
- Dann 3, dann 6, etc.
- Mögliche Sortierung: 1, 3, 6, 7, 4, 5, 2, 8

---

## Aufgabe 9.6: Minimaler Spannbaum (MST)

### Das Ziel

Alle Knoten mit Kanten verbinden, sodass:

- Alle Knoten erreichbar sind
- Die Gesamtkosten minimal sind
- Keine Zyklen entstehen

**Analogie**: Stromnetz in einer Stadt so verlegen, dass es am billigsten ist

### Algorithmus 1: Prim

**Prinzip**: "Der Virus" - breitet sich vom Startknoten aus

1. Start bei Knoten X
2. Welche Kante geht vom aktuellen Teilbaum weg und ist am billigsten?
3. Füge diese Kante hinzu
4. Wiederhole bis alle Knoten verbunden

**Beispiel mit Start A:**

```
Start: {A}
Billigste Kante von A: A-B (2) → {A, B}
Billigste Kante von {A,B}: B-C (3) → {A, B, C}
Billigste Kante von {A,B,C}: C-D (1) → {A, B, C, D}
Billigste Kante von {A,B,C,D}: C-E (5) → {A, B, C, D, E}
Billigste Kante von {A,B,C,D,E}: D-F (6) → {A, B, C, D, E, F}
Billigste Kante von {A,B,C,D,E,F}: F-G (0) → {A, B, C, D, E, F, G}

Gesamtkosten: 2 + 3 + 1 + 5 + 6 + 0 = 17
```

### Algorithmus 2: Kruskal

**Prinzip**: "Der Lego-Bauer" - sortiere alle Kanten und füge billigste hinzu

1. Sortiere alle Kanten nach Gewicht (aufsteigend)
2. Nimm die billigste Kante
3. Würde sie einen Zyklus erzeugen? → Verwerfen
4. Sonst: Hinzufügen
5. Wiederhole bis N-1 Kanten (für N Knoten)

**Beispiel:**

```
Sortierte Kanten:
F-G (0), C-D (1), A-B (2), B-C (3), B-D (4), C-E (5), D-F (6), A-C (7), A-E (8), E-G (9), D-G (10)

1. F-G (0) ✓ → {F,G}
2. C-D (1) ✓ → {C,D} und {F,G}
3. A-B (2) ✓ → {A,B}, {C,D}, {F,G}
4. B-C (3) ✓ → {A,B,C,D}, {F,G}
5. B-D (4) ✗ Zyklus! (B-C-D schon verbunden)
6. C-E (5) ✓ → {A,B,C,D,E}, {F,G}
7. D-F (6) ✓ → {A,B,C,D,E,F,G}
Fertig!

Gesamtkosten: 0 + 1 + 2 + 3 + 5 + 6 = 17
```

### Wichtige Erkenntnisse

**Frage c)**: Warum sind die Kosten immer gleich?

- Der MST ist eindeutig (bei eindeutigen Gewichten)
- Egal wo man startet, man findet denselben Baum
- Gesamtkosten sind immer 17

**Frage e)**: Neue Kante A-E mit Gewicht 11

- A und E sind bereits über A-B-C-E verbunden (Kosten: 2+3+5 = 10)
- Die neue Kante mit 11 ist teurer
- Sie wird ignoriert (würde Zyklus erzeugen und ist teurer)
- MST bleibt gleich, Kosten bleiben 17

---

## Tipps für die Präsentation

1. **Ruhe bewahren**: Auch wenn du nervös bist, langsam und deutlich sprechen
2. **Visualisieren**: Die HTML-Datei zeigen und Schritt für Schritt durchklicken
3. **Bei Eulerpfaden**: Einfach die Grade zählen und Regel anwenden
4. **Bei DFS**: Die Reihenfolge aufschreiben während du durchgehst
5. **Bei MST**: Die Schritte genau nachvollziehen und aufschreiben

### Häufige Fehler vermeiden

- Bei Eulerpfaden: Nicht vergessen zu zählen (nicht raten!)
- Bei DFS: Backtracking nicht vergessen
- Bei Topologischer Sortierung: Zyklus-Check nicht vergessen
- Bei MST: Zyklen-Check bei Kruskal nicht vergessen
