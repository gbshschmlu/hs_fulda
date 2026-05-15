# Lernplan: Robotik Test 1 (Crashkurs in 5 Tagen)

**Zeitraum:** Freitag bis Donnerstag (Sonntag & Montag sind frei)
**Ziel:** Wichtige Konzepte, Skizzen, Mathe-Grundlagen und die "orangen Stichwörter" für den Test beherrschen.

---

## Tag 1: Freitag (Heute) – ROS Basics & Begriffe

**Fokus:** Verstehen, wie das Robot Operating System (ROS) grundlegend kommuniziert.

- **ROS Computation Graph (Nodes & Topics)**
    - _Was du lernen musst:_ Was ist ein Knoten (Node)? Was ist ein Topic? Wie funktioniert das Publish/Subscribe-Prinzip?
    - _Wo du es findest:_ **Vorlesung Folie 35** (Der ROS Computation Graph) und **Folien 49-51** (ROS Messaging, Skizzen zu Publisher/Subscriber).
- **ROS-Begriffe klären**
    - _Was du lernen musst:_ Definitionen von Workspace, Package, Message, Node und Launchfiles.
    - _Wo du es findest:_ **Übungsblatt 1, Aufgabe A1.1** (Grundlagen von ROS2) & **Vorlesung Folien 52-53** (ROS - Launch Files).
- **To-Do heute:** Zeichne das Prinzip von _Publisher $->$ Topic $->$ Subscriber_ aus dem Kopf auf (orientiere dich an Folie 49).

---

## Tag 2: Samstag – Mathe-Grundlagen (Transformationen)

**Fokus:** Matrizen für Drehung und Verschiebung (Wichtig zum Rechnen in der Klausur!).

- **Rotationsmatrizen (2D & 3D)**
    - _Was du lernen musst:_ Wie sieht die Matrix für eine 2D-Rotation um den Winkel $alpha$ aus?
    - _Wo du es findest:_ **Vorlesung Folie 60** (Rotationen 1).
- **Homogene Koordinaten & Basiswechsel**
    - _Was du lernen musst:_ Wie vereint man Translation (Verschiebung) und Rotation in einer Matrix? Wie rechnet man Punkte von einem Koordinatensystem in ein anderes um?
    - _Wo du es findest:_ **Vorlesung Folien 63-68** (Homogene Koordinaten & Basiswechsel).
- **To-Do heute:** Rechne **Übungsblatt 2, Aufgabe A2.1 (Transformationen)** komplett durch. Du musst wissen, an welchen Stellen der Matrix Translation und Rotation stehen (Folie 64 hilft dir dabei!).

---

_(Sonntag & Montag: Frei)_

---

## Tag 3: Dienstag – Radkinematiken, Stabilität & Skizzen

**Fokus:** Welche Räder gibt es, wie skizziert man die Antriebsarten und wann kippt der Roboter um?

- **Räder & Freiheitsgrade (DOF)**
    - _Was du lernen musst:_ Aktive vs. passive Freiheitsgrade. Merke dir die 4 Radtypen und ihre DOFs.
    - _Wo du es findest:_ **Vorlesung Folie 113** (Freiheitsgrade / Holonomie) und **Folie 114** (Räder – Unbedingt die Skizzen einprägen!).
- **Kinematiken & Stabilität skizzieren**
    - _Was du lernen musst:_ Wie zeichnet man ein Zweirad, Dreirad oder vier Räder (Ackermann)? Wann ist ein Zweirad "statisch stabil"? (Antwort: Schwerpunkt unter der Achse!).
    - _Wo du es findest:_ **Vorlesung Folien 115-116** (Radkinematiken).
- **To-Do heute:** Skizziere aus dem Kopf: Standard-Rad, Laufrad, Mecanum-Rad sowie einen Differenzialantrieb. Notiere jeweils die aktiven/passiven Freiheitsgrade daneben.

---

## Tag 4: Mittwoch – Differenzialantrieb, Formeln & Odometrie

**Fokus:** Die Mechanik und Wegberechnung (Odometrie) des Roboters (Klausur-Klassiker!).

- **Differenzialantrieb (Die harten Formeln)**
    - _Was du lernen musst:_ Wie berechnet man die Bahngeschwindigkeit $v$ und die Winkelgeschwindigkeit $omega$ bzw. $theta$ aus den Einzelgeschwindigkeiten der Räder ($v_L$, $v_R$) und der Spurweite ($b$)?
    - _Wo du es findest:_ **Vorlesung Folien 129-130** (Differenzialantrieb).
- **Odometrie & Integration**
    - _Was du lernen musst:_ Wie berechnet der Roboter seine aktuelle X/Z-Position aus den Radumdrehungen?
    - _Wo du es findest:_ **Vorlesung Folien 131-138** (Berechnung der Orientierung / Berechnung von $x$ und $z$).
- **To-Do heute:** Löse **Übungsblatt 2, Aufgabe B2.1 (Differenzialantrieb)**. Wende die Formeln für $Delta d$ und $Delta theta$ an.

---

## Tag 5: Donnerstag – Die "Orangen Stichwörter", Motoren & Encoder

**Fokus:** Buzzwords auswendig lernen und Wissen festigen.

- **Sensoren: Grobklassifikation & Eigenschaften**
    - _Was du lernen musst:_ Aktiv vs. Passiv, Propriozeptiv vs. Exterozeptiv. Eigenschaften wie Messbereich, Dynamik, Auflösung, Linearität.
    - _Wo du es findest:_ **Vorlesung Folie 88** (Grobklassifikation) und **Folien 89-92** (Sensoreigenschaften).
- **Sensorfehler**
    - _Was du lernen musst:_ Systematische Fehler (z.B. Linsenverzerrung) vs. Zufällige Fehler (Rauschen).
    - _Wo du es findest:_ **Vorlesung Folien 93-95** (Sensorfehler 1 & 2).
- **Motoren (PWM) & Encoder (Absolutgeber)**
    - _Was du lernen musst:_ Was ist PWM (Pulsweitenmodulation)? Was ist der Unterschied zwischen einem binären Absolutgeber und einem Graycode-Absolutgeber? Warum nutzt man Graycode? (Antwort: Nur 1 Bit ändert sich beim Sektorübergang $->$ weniger Ablesefehler).
    - _Wo du es findest:_ **Vorlesung Folie 110** (Motoransteuerung / PWM) und **Folien 104-108** (Absolutgeber & Inkrementalgeber).
- **To-Do heute:** Bearbeite **Übungsblatt 2, Aufgabe A2.3 (Absolutgeber - Theorie)**. Lass dich danach von einem Kumpel oder Kommilitonen zu allen orangen Stichwörtern abfragen.
