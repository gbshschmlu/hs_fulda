# Aufgabe A1.1: Grundlagen von ROS2

## Grundbegriffe von ROS2

- **Node (Knoten):** Ein Knoten ist ein Prozess, der eine spezifische Aufgabe im ROS2-System ausführt. Jeder Knoten sollte für einen einzigen, modularen Zweck verantwortlich sein (z.B. die Steuerung eines Motors, das Auslesen eines Sensors). Knoten können miteinander über Topics, Services oder Actions kommunizieren.

- **Topic (Thema):** Ein Topic ist ein benannter "Bus", über den Knoten Daten austauschen. Er funktioniert nach dem Publisher-Subscriber-Modell. Ein Knoten (Publisher) sendet Daten an ein Topic, und ein anderer Knoten (Subscriber) kann diese Daten empfangen, indem er das Topic abonniert. Dies ermöglicht eine entkoppelte 1-zu-n-Kommunikation.

- **Message (Nachricht):** Eine Message ist die Datenstruktur, die über ein Topic gesendet wird. Jedes Topic hat einen festen Message-Typ (z.B. `String`, `Int32`, `Point`), der die Struktur und die Datentypen der zu übertragenden Informationen definiert.

- **Workspace (Arbeitsbereich):** Ein Workspace ist ein Verzeichnis, das eine Sammlung von ROS2-Paketen enthält. Er dient dazu, den eigenen Code zu organisieren, zu kompilieren (build) und zu installieren. Ein typischer Workspace enthält Verzeichnisse wie `src` (Quellcode), `build`, `install` und `log`.

- **Package (Paket):** Ein Paket ist die kleinste Organisationseinheit in ROS2. Es bündelt zusammengehörigen Code (Knoten), Konfigurationsdateien, Launchfiles und eine `package.xml`-Datei, die Metadaten wie den Namen, die Version und die Abhängigkeiten des Pakets beschreibt.

## Wichtige Werkzeuge zur Inspektion des ROS2-Systems

Die wichtigsten Kommandozeilen-Tools (CLI-Tools) zur Inspektion eines laufenden ROS2-Systems beginnen alle mit `ros2`:

- **`ros2 node list`**: Listet alle aktuell laufenden Knoten auf.
- **`ros2 topic list`**: Zeigt alle aktiven Topics an. Mit `-t` werden zusätzlich die Message-Typen angezeigt.
- **`ros2 topic echo <topic_name>`**: Gibt die Nachrichten aus, die auf einem bestimmten Topic live gesendet werden.
- **`ros2 topic info <topic_name>`**: Zeigt detaillierte Informationen zu einem Topic an, z.B. wie viele Publisher und Subscriber es hat.
- **`ros2 topic hz <topic_name>`**: Misst und zeigt die durchschnittliche Frequenz an, mit der Nachrichten auf einem Topic veröffentlicht werden.
- **`ros2 interface show <message_type>`**: Zeigt die Struktur (Felder und Datentypen) eines bestimmten Message-Typs an.
- **`rqt_graph`**: Ein GUI-Tool, das die Knoten und Topics sowie deren Verbindungen grafisch darstellt.

## Ablauf des Build-Prozesses eines ROS2-Workspaces

Der Build-Prozess wird typischerweise mit dem Tool `colcon` durchgeführt und läuft in folgenden Schritten ab:

1.  **Workspace erstellen:** Ein Verzeichnis für den Workspace und ein Unterverzeichnis `src` werden angelegt.
2.  **Pakete platzieren:** Der Quellcode der zu bauenden Pakete wird in das `src`-Verzeichnis kopiert oder geklont.
3.  **Abhängigkeiten installieren:** Mit dem Befehl `rosdep install --from-paths src -y --ignore-src` werden alle in den `package.xml`-Dateien deklarierten Abhängigkeiten der Pakete im Workspace installiert.
4.  **Build starten:** Im Wurzelverzeichnis des Workspaces wird der Befehl `colcon build` ausgeführt. Colcon findet die Pakete im `src`-Verzeichnis und kompiliert sie. Dabei entstehen die Verzeichnisse `build`, `install` und `log`.
5.  **Workspace aktivieren (Sourcing):** Nach dem erfolgreichen Build muss die Umgebung der aktuellen Terminalsitzung mit dem Befehl `source install/setup.bash` (oder `.zsh`) aktualisiert werden. Dadurch werden die gebauten Pakete und deren ausführbare Dateien für das ROS2-System auffindbar gemacht.

## Was sind Launchfiles?

Ein Launchfile ist eine Datei (in ROS2 meist in Python geschrieben), die es ermöglicht, **mehrere Knoten gleichzeitig zu starten und zu konfigurieren**. Anstatt jeden Knoten manuell in einem eigenen Terminal zu starten, kann man mit einem einzigen Befehl ein komplettes System oder Teilsystem hochfahren.

**Hauptfunktionen von Launchfiles:**

- **Automatisches Starten** von mehreren Knoten.
- **Konfiguration** von Knoten durch das Setzen von Parametern.
- **Umbenennen (Remapping)** von Topic-Namen.
- **Strukturierung** durch das Setzen von Namensräumen (Namespaces) für Knoten.
- **Starten anderer Launchfiles**, um komplexe Startvorgänge modular aufzubauen.

Sie werden mit dem Befehl `ros2 launch <package_name> <launch_file_name.py>` ausgeführt.

# Aufgabe A1.2: Erstellung eines URDF-Modells für einen Differentialantrieb

Diese Dokumentation beschreibt die Erstellung eines ROS2-Pakets und einer URDF-Datei für einen vierrädrigen Roboter mit den Maßen 50cm x 30cm x 10cm und einem Raddurchmesser von 14cm (Radius 7cm).

## 1. Erstellung des ROS2 Packages

Zuerst wird ein neues Paket im `src`-Ordner des Workspaces erstellt. Wir nennen es `my_robot_description`.

```bash
# Navigieren in den Workspace
cd ~/ros2_ws/src

# Erstellen des Pakets (ament_cmake für Beschreibungs-Pakete üblich)
ros2 pkg create --build-type ament_cmake my_robot_description

# Unterordner erstellen
cd my_robot_description
mkdir urdf launch
```

## 2. Das URDF-Modell (`urdf/robot.urdf`)

In der Datei `urdf/robot.urdf` wird die Geometrie definiert. Wir verwenden `fixed` Joints, wie in der Aufgabenstellung gefordert.

**Wichtig:** Maße in URDF sind immer in **Metern**.

```xml
<?xml version="1.0"?>
<robot name="my_diff_bot">

  <!-- Materialien für die Visualisierung -->
  <material name="blue">
    <color rgba="0 0 0.8 1"/>
  </material>
  <material name="black">
    <color rgba="0 0 0 1"/>
  </material>

  <!-- BASE LINK (Root Link) -->
  <link name="base_link">
  </link>

  <!-- CHASSIS LINK -->
  <joint name="chassis_joint" type="fixed">
    <parent link="base_link"/>
    <child link="chassis"/>
    <!-- Positionierung des Chassis: 5cm über dem Boden (Mitte der 10cm Höhe) -->
    <origin xyz="0 0 0.1"/>
  </joint>

  <link name="chassis">
    <visual>
      <geometry>
        <box size="0.5 0.3 0.1"/>
      </geometry>
      <material name="blue"/>
    </visual>
  </link>

  <!-- Räder Definition (Beispiel für vorne links) -->
  <!-- Wir wiederholen dies für alle 4 Räder mit entsprechenden Offsets -->

  <!-- Vorne Links -->
  <joint name="front_left_wheel_joint" type="fixed">
    <parent link="chassis"/>
    <child link="front_left_wheel"/>
    <!-- Radstand x=0.2, Spurweite y=0.17 (0.15 + halbe Radbreite) -->
    <origin xyz="0.2 0.17 -0.03" rpy="-1.5708 0 0"/>
  </joint>

  <link name="front_left_wheel">
    <visual>
      <geometry>
        <cylinder radius="0.07" length="0.04"/>
      </geometry>
      <material name="black"/>
    </visual>
  </link>

  <!-- Vorne Rechts -->
  <joint name="front_right_wheel_joint" type="fixed">
    <parent link="chassis"/>
    <child link="front_right_wheel"/>
    <origin xyz="0.2 -0.17 -0.03" rpy="-1.5708 0 0"/>
  </joint>

  <link name="front_right_wheel">
    <visual>
      <geometry>
        <cylinder radius="0.07" length="0.04"/>
      </geometry>
      <material name="black"/>
    </visual>
  </link>

  <!-- Hinten Links -->
  <joint name="rear_left_wheel_joint" type="fixed">
    <parent link="chassis"/>
    <child link="rear_left_wheel"/>
    <origin xyz="-0.2 0.17 -0.03" rpy="-1.5708 0 0"/>
  </joint>

  <link name="rear_left_wheel">
    <visual>
      <geometry>
        <cylinder radius="0.07" length="0.04"/>
      </geometry>
      <material name="black"/>
    </visual>
  </link>

  <!-- Hinten Rechts -->
  <joint name="rear_right_wheel_joint" type="fixed">
    <parent link="chassis"/>
    <child link="rear_right_wheel"/>
    <origin xyz="-0.2 -0.17 -0.03" rpy="-1.5708 0 0"/>
  </joint>

  <link name="rear_right_wheel">
    <visual>
      <geometry>
        <cylinder radius="0.07" length="0.04"/>
      </geometry>
      <material name="black"/>
    </visual>
  </link>

</robot>
```

## 3. Visualisierung in RViz

Um das Modell zu überprüfen, nutzen wir das Tool aus dem `urdf_tutorial` Paket.

### Vorbereitung

Stellen Sie sicher, dass das Paket installiert ist:

```bash
sudo apt update
sudo apt install ros-jazzy-urdf-tutorial
```

### Start der Visualisierung

Führen Sie den Launch-Befehl aus und geben Sie den Pfad zu Ihrer Datei an:

```bash
# Im Workspace-Root
colcon build --packages-select my_robot_description
source install/setup.bash

# Starten von RViz mit dem Modell
ros2 launch urdf_tutorial display.launch.py model:=src/my_robot_description/urdf/robot.urdf
```

## 4. Erklärungen zu den Komponenten

- **Links:** Repräsentieren die physischen Körper (Chassis, Räder). Sie enthalten die `<visual>` Tags, um Form (`geometry`) und Farbe (`material`) zu definieren.
- **Joints:** Verbinden die Links.
    - Der Typ `fixed` bedeutet, dass die Räder starr mit dem Chassis verbunden sind (ideal für den ersten Geometrie-Check).
    - `<origin>` definiert die Transformation (Position und Rotation) vom Parent zum Child.
    - `rpy="-1.5708 0 0"` wird bei den Rädern genutzt, um den Zylinder (der standardmäßig aufrecht steht) um 90 Grad (Pi/2 Radiant) zu kippen, damit er wie ein Rad rollen könnte.
- **Robot State Publisher:** Diese Node liest die URDF und veröffentlicht die statischen Transformationen zwischen den Links als TF-Daten, die RViz zur Darstellung benötigt.
