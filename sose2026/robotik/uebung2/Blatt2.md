# Hinweis

Durch die Größe der ROS2-Packages wurden diese nicht angehängt. Die Code-Lösungen liegen in den beigefügten Dateien `FakeEncoder.cpp` und `recorder.cpp`.

# Aufgabe A2.1 (Transformationen)

Gegeben:
$$T = mat(a, b, c; d, e, f; g, h, i)$$

## (a) Was ist eine Transformation?

- Mathematische Operation zur Veränderung von Punkten, Vektoren oder Koordinatensystemen im Raum.
- Dient der Darstellung von Translationen (Verschiebungen), Rotationen (Drehungen) und Skalierungen.
- Typischer Anwendungsfall: Umrechnung von Sensordaten in das Koordinatensystem des Roboters.

## (b) Rotationskomponenten

- Obere linke 2x2 Untermatrix.
- Einträge: **a, b, d, e** (Hier stehen üblicherweise Sinus- und Kosinus-Werte).

## (c) Translationskomponenten

- Rechte Spalte der Matrix (Verschiebung in x- und y-Richtung).
- Einträge: **c, f**.

## (d) Transformation eines Punktes im 2D Raum

- Punkt $vec(x, y)$ muss in **homogene Koordinaten** umgewandelt werden.
- Eine $1$ wird als dritte Dimension angehängt: $vec(x, y, 1)$.
- Anschließend Multiplikation mit der Matrix $T$.

---

# Aufgabe A2.2 (Joint State Publisher - Theorie)

- Um die Gelenke in RViz zu animieren, muss ein `JointState`-Publisher erstellt werden.
- Ein Timer aktualisiert die Winkel periodisch um 1 Grad ($pi / 180$) und hält sie im Intervall $[0, 2 pi]$.
- **Code-Lösung:** Siehe beiliegende Datei `FakeEncoder.cpp`.

---

# Aufgabe A2.3 (Absolutgeber - Theorie)

## (a) Wie ist der Roboter gefahren?

- **Linker Motor ($M_l$):** Zählt vorwärts (101 -> 110 -> 111...). Dreht sich pro Zeitschritt um exakt 1 Sektor.
- **Rechter Motor ($M_r$):** Zählt rückwärts (111 -> 110 -> 101...). Ändert den Sektor nur jeden _zweiten_ Zeitschritt.
- **Fazit:** Linkes Rad dreht schnell vorwärts, rechtes Rad langsam rückwärts $->$ Roboter fährt eine **enge Rechtskurve** auf der Stelle.

## (b) Zurückgelegte Strecke

- Durchmesser $d = 0.3 "m"$
- Umfang $U = pi dot 0.3 "m" approx 0.9425 "m"$
- Strecke pro Sektor ($45 degree$): $U / 8 approx 0.1178 "m"$

| T             | 0   | 1      | 2       | 3       | 4       | 5       | 6       | 7       | 8       | 9       |
| :------------ | :-- | :----- | :------ | :------ | :------ | :------ | :------ | :------ | :------ | :------ |
| **$D_l$ (m)** | 0   | 0.1178 | 0.2356  | 0.3534  | 0.4712  | 0.5890  | 0.7069  | 0.8247  | 0.9425  | 1.0603  |
| **$D_r$ (m)** | 0   | 0      | -0.1178 | -0.1178 | -0.2356 | -0.2356 | -0.3534 | -0.3534 | -0.4712 | -0.4712 |

## (c) Probleme der Kodierung

- **Problem:** Bei der Standard-Binärkodierung wechseln oft mehrere Bits gleichzeitig beim Sektorübergang (z.B. von 011 zu 100). Ungenaues Ablesen auf der Kante führt zu massiven Messfehlern.
- **Lösung:** Nutzung eines **Gray-Codes**. Hier ändert sich pro Sektorübergang immer exakt nur 1 Bit.

---

# Aufgabe B2.1 (Differenzialantrieb)

Startwerte: $x_0 = 0$, $y_0 = 0$, $theta_0 = 0 degree$, $b = 30 "cm"$
Formeln: $Delta d = (s_l + s_r) / 2$ und $Delta theta = (s_r - s_l) / b$

## (a) Posenberechnung

**Zeitpunkt t = 1:** ($s_r = 6 "cm"$, $s_l = 10 "cm"$)

- $Delta d = (10 + 6) / 2 = 8 "cm"$
- $Delta theta = (6 - 10) / 30 = -4 / 30 approx -0.1333 "rad"$ (ca. $-7.64 degree$)
- $x_1 = 0 + 8 dot 1 = 8 "cm"$
- $y_1 = 0 + 8 dot 0 = 0 "cm"$
- $theta_1 = 0 - 0.1333 = -0.1333 "rad"$
- **Pose 1:** `(8 cm, 0 cm, -0.1333 rad)`

**Zeitpunkt t = 2:** ($s_l = 5 "cm"$, $s_r = 7 "cm"$)

- $Delta d = (5 + 7) / 2 = 6 "cm"$
- $Delta theta = (7 - 5) / 30 = 2 / 30 approx 0.0667 "rad"$
- $x_2 = 8 + 6 dot cos(-0.1333) approx 8 + 6 dot 0.991 = 13.94 "cm"$
- $y_2 = 0 + 6 dot sin(-0.1333) approx 0 + 6 dot (-0.132) = -0.79 "cm"$
- $theta_2 = -0.1333 + 0.0667 = -0.0666 "rad"$
- **Pose 2:** `(13.94 cm, -0.79 cm, -0.0666 rad)`

## (b) Fehlerwirkung (Rotation vs. Translation)

- **Rotationsfehler** wirken sich langfristig viel stärker aus.
- Translationsfehler summieren sich nur linear auf.
- Ein Rotationsfehler ändert die globale Fahrtrichtung $->$ der resultierende Positionsfehler (Abbe-Fehler) wächst mit jedem gefahrenen Meter an.

---

# Aufgabe B2.2 (Lokalisierungsqualität)

## ROS2-Node zum Aufzeichnen

- Node abonniert das Topic `/odom`.
- Extrahiert die Werte `msg->pose.pose.position.x` und `y`.
- Schreibt die Koordinaten zeilenweise in eine Textdatei.
- **Code-Lösung:** Siehe beiliegende Datei `recorder.cpp`.

## Bei welchen Operationen ist der Fehler hoch?

- **Bei Drehungen / Rotationen** wächst der Odometrie-Fehler besonders stark.
- Gründe:
    - Radschlupf (Durchdrehen) auf dem Untergrund.
    - Ungenauigkeiten in der Annahme der exakten Spurweite ($b$).
    - Bodenunebenheiten (Rad dreht frei in der Luft, was fälschlicherweise als Vorwärtsbewegung integriert wird).
