# Hinweis

Durch die Größe der ROS2-Packages wurden diese nicht angehängt. Sie wurden ausschließlich kompiliert und unmodifiziert gestartet.

# A1.1

## Topic

Benannter Datenbus für Publisher/Subscriber-Kommunikation. Publisher senden Daten, Subscriber empfangen diese. Mehrere Nodes können auf dasselbe Topic publizieren und/oder abonnieren. Topics dienen kontinuierlichen Datenströmen wie Sensordaten oder Roboterzustand.

## Message

Definierte Datenstruktur (`.msg`-Datei) für Topics. Spezifiziert Felder und Datentypen einer Nachricht.

## Node

Prozess mit einer spezifischen Aufgabe (modulare Einheit). In C++ oder Python geschrieben, kommuniziert über Topics.

## Workspace

Verzeichnis mit ROS2-Paketen (Ordner: `src`, `build`, `install`, `log`) zur Organisation und zum Bauen von Projekten.

## Package

Die kleinste Organisationseinheit (enthält Code, `package.xml` und `CMakeLists.txt`/`setup.py`).

## Info-Tools

- **`ros2 node list`**: Zeigt aktive Knoten
- **`ros2 topic list`**: Listet alle Topics auf
- **`ros2 topic info <topic_name>`**: Zeigt Typ und Anzahl der Publisher/Subscriber
- **`ros2 topic echo <topic_name>`**: Gibt Live-Daten im Terminal aus
- **`ros2 topic hz <topic_name>`**: Prüft die Sendefrequenz

### Welche Topics sind da?

**Volksbot:**
ros2 topic list
/cmd_vel
/joint_states
/joy
/joy/set_feedback
/odom
/parameter_events
/robot_description
/rosout
/tf
/tf_static

### Wie oft werden Daten gesendet?

Die Sendefrequenz hängt vom jeweiligen Topic bzw. Ereignis ab.
Kontinuierliche Daten (z. B. Sensoren) werden regelmäßig gesendet, Eingaben wie Tastendrücke nur bei Änderungen.

**Volksbot:**
Jeder Knopfdruck, sogar der Sicherungsknopf sendet an ein Topic.

### Message-Typen beim Volksbot

**Bewegungsbefehle** (`/cmd_vel`) – lineare und rotatorische Geschwindigkeiten

```yaml
linear:
    x: -0.0
    y: 0.0
    z: 0.0
angular:
    x: 0.0
    y: 0.0
    z: -0.0
```

**Gelenkzustände** (`/joint_states`) – Positionen, Geschwindigkeiten, Drehmomente

```yaml
header:
    stamp:
        sec: 177048031
        nanosec: 68320181
    frame_id: ""
name:
    - left_front_wheel_joint
    - left_rear_wheel_joint
    - right_front_wheel_joint
    - right_rear_wheel_joint
position:
    - 9.990349453453654
    - 9.990349453453654
    - 33.43428543854355
    - 33.43428543854355
velocity: []
effort: []
```

## Ablauf Buildprozess des ROS2-Workspaces

1. Im Workspace-Root den Befehl **`colcon build`** ausführen.
2. Die Umgebung mit **`source install/setup.bash`** laden (Sourcing), damit das System die Pakete findet.

## Launchfiles

Skripte (meist Python), die mehrere Nodes gleichzeitig mit spezifischen Parametern und Konfigurationen starten.

# B 1.1

## `/cmd_vel` – Steuerbefehle

Gewünschte lineare und rotatorische Geschwindigkeit des Roboters.

```bash
ros2 topic echo /cmd_vel
```

```yaml
linear:
    x: -0.0 # Vorwärts-/Rückwärtsgeschwindigkeit in m/s
    y: 0.0 # Seitwärtsgeschwindigkeit (bei Differentialantrieb immer 0)
    z: 0.0 # Nicht genutzt
angular:
    x: 0.0 # Nicht genutzt
    y: 0.0 # Nicht genutzt
    z: -0.0 # Drehgeschwindigkeit um die Hochachse in rad/s
```

---

## `/joint_states` – Gelenkzustände

Aktueller Zustand der vier Radgelenke (Position, Geschwindigkeit, Drehmoment).

```bash
ros2 topic echo /joint_states
```

```yaml
header:
    stamp:
        sec: 177048031
        nanosec: 68320181
    frame_id: ""
name:
    - left_front_wheel_joint
    - left_rear_wheel_joint
    - right_front_wheel_joint
    - right_rear_wheel_joint
position:
    - 9.990349453453654 # Winkelposition des linken Vorderrads in rad
    - 9.990349453453654 # Winkelposition des linken Hinterrads in rad
    - 33.43428543854355 # Winkelposition des rechten Vorderrads in rad
    - 33.43428543854355 # Winkelposition des rechten Hinterrads in rad
velocity: [] # Aktuell nicht befüllt
effort: [] # Aktuell nicht befüllt
```

---

## `/joy` – Joystick-Eingaben

Rohdaten des angeschlossenen Joysticks (Achsen und Tasten).

```yaml
header:
    stamp:
        sec: 177047940
        nanosec: 618534333
    frame_id: joy
axes:
    - -0.0 # Linker Stick X
    - -0.0 # Linker Stick Y
    - 0.0 # Rechter Stick X
    - 0.0 # Rechter Stick Y
    - 0.0 # L2-Trigger
    - 0.0 # R2-Trigger
buttons:
    - 0 # Taste 1
    - 0 # Taste 2
    - 0 # Taste 3
    - 0 # Taste 4
    - ...
```

---

## Weitere Topics (Überblick)

| Topic                | Bedeutung                                                                        |
| -------------------- | -------------------------------------------------------------------------------- |
| `/odom`              | Odometriedaten – berechnete Position und Geschwindigkeit des Roboters im Raum    |
| `/tf` / `/tf_static` | Koordinatentransformationen zwischen den Frames des Roboters (z. B. Rad → Basis) |
| `/robot_description` | URDF-Modell des Roboters (Struktur, Gelenke, Dimensionen)                        |
| `/joy/set_feedback`  | Feedback-Kanal zum Joystick (z. B. Vibration)                                    |
| `/parameter_events`  | ROS2-interne Ereignisse bei Parameteränderungen                                  |
| `/rosout`            | Zentrales Logging-Topic für alle ROS2-Nodes                                      |

# B 1.2

### Komponenten der Simulation

Die Simulation basiert auf Gazebo Sim mit folgenden Elementen:

**Welt-Modellierung:**

- **SDF (Simulation Description Format):** Umgebung wird in SDF-Dateien definiert
- **Physik-Engine:** `dartsim`-Plugin mit `ode` als Kollisionsdetektor
- **Umgebungsparameter:** Gravitation, Lichtquellen, atmosphärische Bedingungen
- **Szenen-Objekte:** 3D-Meshes für Campus, Bäume, Gelände

**Roboter-Beschreibung:**

- **Struktur:** Hierarchisch mit zentralem `base_link` im Entity Tree
- **Visual/Collision:** Jede Komponente hat hochaufgelöste Meshes (Visual) und vereinfachte Geometrien (Collision)
- **Plugins:** Sensoren und Aktoren integriert für Physik-Interaktion

### Austauschbarkeit von Simulation und Realität

Der simulierte Roboter kann nahtlos durch echte Hardware ersetzt werden:

- **ROS-Abstraktion:** Simulation und echte Hardware kommunizieren über identische ROS-Schnittstellen (Topics, Services, Actions)
- **Identische API:** Steuerung über denselben Befehlssatz (`geometry_msgs/Twist` auf Topic `cmd_vel`)
- **Kompatible Sensordaten:** Simulation nutzt dieselben Nachrichtentypen wie reale Treiber
- **Hardware-Agnostik:** Algorithmen unterscheiden nicht zwischen Gazebo-Plugin und echtem Hardware-Interface
