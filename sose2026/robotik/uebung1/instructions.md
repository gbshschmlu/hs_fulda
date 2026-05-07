# Robotik Übungsblatt 1 - Simulation Setup

Wir haben die Simulation (Aufgabe B1.2) erfolgreich auf ROS2 Jazzy zum Laufen gebracht.
Da der offizielle `volksbot_driver` aktuell noch auf ROS1 basiert, haben wir ein eigenes
Paket `volksbot_description` erstellt, das ein Gazebo-kompatibles URDF-Modell enthält
(inkl. Inertial- und Collision-Tags für die Physik-Engine).

## Voraussetzungen

- Ubuntu 24.04 mit ROS2 Jazzy (oder der Docker-Container der Vorlesung)
- Installierte Gazebo-Bridge:
  `sudo apt update && sudo apt install ros-jazzy-ros-gz`

## Setup & Start

1. Entpacke die `src.zip` in deinen `~/ros2_ws/` Ordner.
2. Gehe in das Hauptverzeichnis des Workspaces:

    ```bash
    cd ~/ros2_ws
    ```

3. Installiere evtl. fehlende Abhängigkeiten:
    ```bash
    rosdep install --from-paths src --ignore-src -r -y
    ```
4. Bauen den Workspace:
    ```bash
    colcon build --symlink-install
    source install/setup.bash
    ```
5. Starte die Simulation mit dem Volksbot auf dem HSFD Campus:
    ```bash
    ros2 launch hsfd_gazebo_simulation simulation.launch.py \
    robot_pkg_name:=volksbot_description \
    robot_urdf_file:=volksbot.urdf \
    world_name:=hsfd
    ```

### Wichtige Info zum Inhalt:

In dem `src`-Ordner, den ich euch schicke, sind zwei Pakete:

1. **hsfd_gazebo_simulation**: (Geklont von der RWTH-Git) - Das stellt die Campus-Welt bereit.
2. **volksbot_description**: (Selbst erstellt) - Das ist unser Roboter-Modell (URDF).

**Hinweis:** Der `apt install`-Befehl oben ist notwendig, damit ROS2 mit Gazebo kommunizieren kann (die sog. Bridge). Ohne diesen Befehl wird die Simulation zwar starten, aber der Roboter wird sich nicht bewegen oder keine Sensordaten senden.

## Bedienung des Roboters

Um den Roboter in der Simulation zu bewegen, öffne ein zweites Terminal und führe aus:

```bash
source ~/ros2_ws/install/setup.bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```
