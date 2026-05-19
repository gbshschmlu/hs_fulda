## Lernplan Robotik Test 1

### **Teil 1: Thematische Wissensblöcke**

Dieser Teil dient als strukturierte Übersicht der prüfungsrelevanten Inhalte.

#### **Themenblock A: Grundlagen des Robot Operating System (ROS)**

- **Lernziele:** Die grundlegende Architektur und Kommunikationsweise von ROS verstehen.
- **Inhalte:**
    - **ROS Computation Graph:** Die Rollen und das Zusammenspiel von `Node` (einzelnes Programm/Prozess), `Topic` (benannter Kommunikationskanal) und `Message` (die zu übermittelnde Datenstruktur) erklären können.
    - **Publish/Subscribe-Modell:** Das Prinzip verstehen, bei dem ein Publisher-`Node` Daten auf ein `Topic` sendet, ohne den Empfänger (Subscriber) zu kennen.
    - **Launch-Files:** Deren Zweck als Werkzeug zum simultanen Starten und Konfigurieren mehrerer `Nodes` definieren.
    - **Topic Remapping:** Das Konzept verstehen, um die standardmäßigen Topic-Namen einer `Node` zur Laufzeit zu ändern, was die Wiederverwendbarkeit von Code ermöglicht (z.B. bei zwei identischen Sensoren).
- **Material:** Vorlesungsfolien 35, 49-55; Übungsblatt 1, Aufgabe A1.1.

#### **Themenblock B: Koordinatensysteme und Transformationen**

- **Lernziele:** Den Zweck von Transformationen und die dahinterstehenden mathematischen Konzepte auf einer konzeptionellen Ebene verstehen.
- **Inhalte:**
    - **Grundproblem:** Erklären können, warum Transformationen notwendig sind (Umrechnung von Daten zwischen verschiedenen Koordinatensystemen, z.B. vom Sensor zum Roboter-Mittelpunkt).
    - **Homogene Koordinaten:** Das Prinzip verstehen, dass durch die Erweiterung eines 3D-Vektors auf 4D eine Translation (Verschiebung) als Matrixmultiplikation dargestellt werden kann. Dies vereint Rotations- und Translationsoperationen.
    - **Quaternionen:** Deren primären Anwendungszweck definieren: die Vermeidung des sogenannten _Gimbal Lock_, einem Problem bei der 3D-Rotation, das zum Verlust eines Freiheitsgrades führt.
- **Material:** Vorlesungsfolien 60-68.

#### **Themenblock C: Kinematik und Antriebsarten**

- **Lernziele:** Verschiedene mobile Roboterplattformen und ihre Bewegungsprinzipien unterscheiden können.
- **Inhalte:**
    - **Rad-Typen:** Die grundlegenden Eigenschaften und Freiheitsgrade (DOF) von Standard-Rad, Laufrad (castor wheel) und Mecanum-Rad kennen.
    - **Holonome vs. Nicht-holonome Systeme:** Den Unterschied erklären können. Ein holonomes System (z.B. mit Mecanum-Rädern) kann sich in jede Richtung bewegen (auch seitwärts), ein nicht-holonomes System (z.B. ein Auto) unterliegt Bewegungseinschränkungen.
    - **Differenzialantrieb:** Das Funktionsprinzip verstehen. Die Formeln dienen hierbei als konzeptionelle Grundlage:
        - Die Geschwindigkeit $v = frac(v_R + v_L, 2)$ beschreibt, dass die translatorische Geschwindigkeit des Roboters dem Durchschnitt der Radgeschwindigkeiten entspricht.
        - Die Winkelgeschwindigkeit $omega = frac(v_L - v_R, b)$ beschreibt, dass die Rotation aus der _Differenz_ der Radgeschwindigkeiten resultiert.
- **Material:** Vorlesungsfolien 113-116, 129-138.

#### **Themenblock D: Sensorik und Messtechnik**

- **Lernziele:** Sensoren klassifizieren, ihre Eigenschaften benennen und grundlegende Messprinzipien (insbesondere von Encodern) verstehen.
- **Inhalte:**
    - **Sensor-Klassifikation:** Die Unterscheidung zwischen `Propriozeptiv` (interner Zustand, z.B. Gelenkwinkel) und `Exterozeptiv` (externe Umgebung, z.B. Abstand) sowie zwischen `Aktiv` (sendet Energie aus, z.B. Laser) und `Passiv` (empfängt nur, z.B. Kamera) kennen.
    - **Sensor-Eigenschaften:** Begriffe wie `Messbereich (Range)` und `Auflösung (Resolution)` definieren können.
    - **Fehlertypen:** `Systematische Fehler` (konsistent, prinzipiell korrigierbar) von `Zufälligen Fehlern` (Rauschen) unterscheiden.
    - **Encoder:** Den fundamentalen Unterschied zwischen `Inkrementalgebern` (zählen nur Änderungen, Position bei Start unbekannt) und `Absolutgebern` (Position immer bekannt) erklären. Innerhalb der Absolutgeber den Vorteil von `Graycode` (nur 1 Bit ändert sich pro Schritt, robust gegen Lesefehler) gegenüber `Binärcode` verstehen.
- **Material:** Vorlesungsfolien 88-95, 104-108.

---

### **Teil 2: Chronologischer Lernplan**

Dieser Plan baut auf Ihren bisherigen Aktivitäten auf und führt Sie strukturiert zur Prüfungsreife.

- **Freitag:**
    - **Aktivität:** Erste Sichtung der ROS-Grundlagen.
    - **Ergebnis:** Ein grundlegendes Verständnis für die Komponenten aus **Themenblock A** wurde etabliert.

- **Samstag:**
    - **Aktivität:** Erste Durchsicht der Folien zu Transformationen.
    - **Ergebnis:** Eine erste, konzeptionelle Auseinandersetzung mit **Themenblock B** fand statt.

- **Sonntag & Montag:**
    - Lernfreie Tage.

- **Dienstag:**
    - **Aktivität:** Bearbeitung von Übungsblatt 02 in der Gruppe.
    - **Heutiges Ziel:** Festigung des Verständnisses von Transformationen und Kinematik durch die praktische Diskussion.
    - **Aufgabe:** Reflektieren Sie die Übungsaufgaben. Fokussieren Sie sich darauf, die Prinzipien aus **Themenblock B (Transformationen)** und **Themenblock C (Kinematik)** mit eigenen Worten zu erklären. Warum wurde welche Formel im Konzept benötigt?

- **Mittwoch:**
    - **Ziel:** Die Hardware-Komponenten und die übergeordnete Software-Architektur verstehen.
    - **Aufgabe:** Arbeiten Sie **Themenblock D (Sensorik)** vollständig durch. Erstellen Sie eine vergleichende Liste (z.B. Inkremental vs. Absolut). Wiederholen Sie anschließend die fortgeschrittenen Konzepte aus **Themenblock A** (insbesondere Launch-Files und Topic Remapping).

- **Donnerstag:**
    - **Ziel:** Finale Wissenskonsolidierung und Vorbereitung auf das Prüfungsformat.
    - **Aufgabe:** Gehen Sie alle vier Themenblöcke nochmals durch. Formulieren Sie für jeden zentralen Begriff (insbesondere die orange markierten) eine prägnante Ein-Satz-Definition. Simulieren Sie Multiple-Choice-Fragen, indem Sie sich fragen: "Was ist der entscheidende Unterschied zwischen X und Y?".
