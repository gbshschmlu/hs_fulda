# Hilfe: Übungsblatt 7 - Suchbäume

## 🌳 Aufgabe 7.1: Der Binäre Suchbaum

### Regeln beim Einfügen

1. Starte immer an der **Wurzel**.
2. Ist der einzufügende Wert **kleiner** als der aktuelle Knoten? -> Geh nach **Links**.
3. Ist er **größer**? -> Geh nach **Rechts**.
4. Ist der Platz leer (null)? -> Hier neuen Knoten erstellen.

### Die Traversierungen (Eselsbrücken)

- **Pre-Order (Pre = Vor):** Die Wurzel wird **vor** den Kindern besucht.
    - _Muster:_ Ich (Wurzel) -> Links -> Rechts
- **In-Order (In = Dazwischen):** Die Wurzel wird **zwischen** den Kindern besucht.
    - _Muster:_ Links -> Ich (Wurzel) -> Rechts
    - _Merksatz:_ Bei Suchbäumen liefert dies immer die sortierte Folge!
- **Post-Order (Post = Nach):** Die Wurzel wird **nach** den Kindern besucht.
    - _Muster:_ Links -> Rechts -> Ich (Wurzel)

---

## 🔍 Aufgabe 7.2: Die "Ceiling" Suche

Die Aufgabe verlangt den kleinsten Wert im Baum, der $\ge k$ ist.

### Visuelle Vorstellung

Stell dir vor, du suchst eine Zahl auf einem Zahlenstrahl. Du tippst mit dem Finger auf $k$. Wenn $k$ nicht da ist, rutschst du mit dem Finger nach rechts zur **nächstgrößeren** Zahl, die da ist.

### Logik im Code

Wir merken uns einen "besten Kandidaten".

- Sind wir bei einem Knoten, der **zu klein** ist (`node < k`):
    - Dieser Knoten nützt uns nichts. Wir müssen **rechts** gehen, um größere Zahlen zu finden.
- Sind wir bei einem Knoten, der **groß genug** ist (`node >= k`):
    - Das könnte die Lösung sein! Wir speichern ihn als `kandidat`.
    - Aber vielleicht gibt es im **linken** Teilbaum noch eine Zahl, die auch groß genug ist, aber _näher_ an $k$ dran ist (also kleiner als der aktuelle Kandidat). Darum gehen wir nach links.

### Beispiel

Baum: `10, 20, 30`. Wir suchen `>= 15`.

1.  Start bei **20**. `20 >= 15`. Das passt!
    - Merk dir `20` als Kandidat.
    - Geh nach links (vielleicht finden wir was Kleineres als 20, das immer noch >= 15 ist?).
2.  Wir sind bei **10**. `10 < 15`. Zu klein!
    - Geh nach rechts.
3.  Rechts von 10 ist nichts. Ende.
4.  Ergebnis: Der gemerkte Kandidat **20**.
