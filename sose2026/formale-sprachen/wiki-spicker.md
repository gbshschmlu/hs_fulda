# Spickzettel: Ableitungsbaum & Stackmaschine

## 1. Was ist ein Ableitungsbaum?

- **Die Idee:** Er ist wie die Bauanleitung eines Lego-Hauses. Er zeigt die Struktur des Wortes (Wurzel = Startsymbol, Blätter = fertiges Wort).
- **Der Clou:** Der Baum zeigt _nicht_, in welcher Reihenfolge die Steine aufeinandergesetzt wurden. Er zeigt nur das fertige Gerüst.

## 2. Links- vs. Rechtsableitung

Wenn wir ein Wort per Hand auf dem Papier ableiten, müssen wir uns für eine Reihenfolge entscheiden:

- **Linksableitung:** Wir ersetzen immer konsequent die Variable, die am weitesten **links** steht.
- **Rechtsableitung:** Wir ersetzen immer die Variable, die am weitesten **rechts** steht.
- **Wichtig für den Vortrag:** Egal welchen Weg wir gehen, am Ende kommt (bei eindeutigen Grammatiken) **exakt derselbe Ableitungsbaum** heraus!

## 3. Die Stackmaschine (Der Parser in Action)

- **Der Zusammenhang:** Ein Computer arbeitet stur von links nach rechts. Wenn die Stackmaschine ein Wort liest und den Baum von oben nach unten (Top-Down) aufbaut, simuliert sie dabei exakt eine **Linksableitung**.
- **Das Orientierungsproblem:** Die Stackmaschine hat nur ihr Kurzzeitgedächtnis (den Stack). Wenn sie Variablen auf den Stack schiebt, vergisst sie leicht, an welchen Ast im Baum diese Variablen später eigentlich angehängt werden müssen.

## 4. Der Trick mit den IDs (Das Tupel)

- Um nicht die Orientierung zu verlieren, pushen wir nicht mehr nur nackte Buchstaben auf den Stack, sondern **Tupel**: `(Variable, ID des Vaterknotens)`.
- Jeder Knoten, den wir zeichnen, kriegt einfach stur eine fortlaufende Nummer (1, 2, 3...).

## 5. Walkthrough im Kopf (Beispiel `01011`):

So kannst du den Trace in eigenen Worten erklären:

1.  **Start:** Wurzel ist da (Knoten 1). Auf dem Stack liegt `(R, 0)`.
2.  **Lese 0:** Regel macht aus R ein RS. Wir pushen `R` und `S` auf den Stack. Beide bekommen die Info `1` mit, damit sie wissen: _"Unser Papa ist Knoten 1!"_
3.  **Lese 1:** Wir nehmen das `R` vom Stack (es wird zu Knoten 2). Daraus entsteht ein `E`. Wir pushen `(E, 2)`. Das `E` weiß jetzt: _"Mein Papa ist Knoten 2."_
4.  **Lese 0:** `E` (Knoten 3) wird vom Stack genommen. Es entsteht ein `S`. Wir pushen `(S, 3)`.
5.  **Lese 1:** Wir nehmen das `S` vom Stack. Regel sagt: Weg damit ($\epsilon$). Das ist jetzt ein Blatt im Baum.
6.  **Lese 1:** Jetzt liegt ganz unten auf dem Stack nur noch das allererste `S` aus Schritt 2 (mit der Info: Papa ist Knoten 1). Wir nehmen es runter. Regel sagt: Weg damit ($\epsilon$).
7.  **Ziel erreicht:** Wort ist zu Ende gelesen, Stack ist leer, und der Baum wurde fehlerfrei gezeichnet.
