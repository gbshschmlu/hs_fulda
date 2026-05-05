# Robotik (ROS2 Jazzy)

## ein Setup (Remote Workspace)

Anstatt lokal auf meinem Mac eine virtuelle Maschine mit Ubuntu betreiben zu müssen, nutze ich eine zentralisierte Remote-Umgebung. Mein ROS2 Jazzy Setup läuft komplett als Docker-Container mit noVNC-Web-Desktop auf meinem privaten Home-Server (Intel x86_64 Architektur für optimale Gazebo/ROS2 Kompatibilität).

### Voraussetzungen für den Zugriff

1. **Home-Server Status:** Der physische Server daheim muss eingeschaltet sein und die Docker-Stacks müssen laufen.
2. **Netzwerk:** Man muss sich entweder im lokalen Netzwerk (WLAN) befinden oder über mein VPN (Tailscale/Wireguard) verbunden sein.
3. **Konfiguration & Credentials:** Die genaue Docker-Compose Architektur, Netzwerk-Konfigurationen, IPs und Zugangsdaten sind aus Sicherheitsgründen **nicht hier**, sondern in meinem separaten, privaten Server-Repository abgelegt.

### Zugriff auf die ROS2-Umgebung

Wenn der Server läuft und das Netzwerk verbunden ist, kann die ROS2 Desktop-Umgebung einfach und ohne weitere Installationen über jeden Webbrowser aufgerufen werden:

**URL:** `http://<SERVER_IP>:6080`

Dort öffnet sich ein virtueller Ubuntu-Desktop.

- Das Verzeichnis `~/ros2_ws/` im Container ist als Docker-Volume (Bind Mount) direkt auf die Festplatte meines Servers gemappt. So bleiben alle Codes und URDF-Modelle persistent, auch wenn der Container neu gestartet wird.
