# ROSI – Wissensbasis für Fallstudie

> Modul: Praxisorientierte Fallstudie – AI3955, 4. Semester SoSe26
> Student: Schmidt, Luca Michael | Betreuer: Manuel Pilz (Grenzebach BSH GmbH)
> Thema: Analyse der Verfügbarkeit, Ausfalltolerranz und Konsistenz des KI-basierten Multisensorik ROSI-Systems

---

## 1. Was ist ROSI?

**ROSI** = **R**ealtime **O**ptical **S**urface **I**nspection

ROSI ist ein Inline-Scan-System (Portal-Bauweise) von Grenzebach BSH GmbH zur automatisierten Qualitätskontrolle von Baustoffen (primär Gips und Holz). Das System scannt Materialoberflächen, klassifiziert Defekte per KI, vermisst diese geometrisch und stuft das Material anhand eines regelbasierten Rezeptsystems (Node-basiert) in eine Qualitätsstufe und einen Stapelplatz ein.

**Betrieb:** On-premise, direkt im Portal beim Kunden, 24/7

---

## 2. Hardware

### 2.1 Laborrechner (aktuell – Bad Hersfeld)

| Komponente | Spezifikation                            |
| ---------- | ---------------------------------------- |
| Modell     | Selbstbau                                |
| CPU        | AMD Ryzen 9 9950X (16C/32T)              |
| RAM        | 64 GB DDR5 6000 MT/s                     |
| SSD        | 2 TB NVMe Gen5                           |
| GPU        | NVIDIA RTX 5090 32 GB VRAM               |
| PCIe-Karte | Euresys 1628 Grablink Duo (Framegrabber) |
| OS         | Xubuntu 24.04 LTS                        |

**Zugang:** SSH via PuTTY → `rosipc.bad-hersfeld.grenzebach.de`

### 2.2 Kundensystem (typisch / Zielkonfiguration)

- GPU: wahrscheinlich RTX 5080
- CPU: Intel (statt AMD)
- Sonst ähnliche Spezifikationen

### 2.3 Hardware-Richtlinien (Golden Master)

- **CPU:** Single-Core-Priorität, >12 Kerne, PL1/PL2 BIOS-begrenzt (~180W) gegen thermische Drosselung
- **RAM:** DDR5 5600–6400 MT/s, konservative Timings (CL36–CL40), Langzeitstabilität > Peak-Performance
- **GPU:** NVIDIA RTX, min. 16 GB VRAM, kein Blower-Lüfter, mechanische Stütze (Transport)
- **SSD:** High-TBW NVMe + Passivkühlkörper (verhindert Throttling bei Dauerwrite)
- **Netzteil:** ATX 3.1, min. 30% Leistungsreserve, BIOS: "Restore on AC Power Loss" = **Power On**
- **Mainboard:** 2× PCIe (GPU + Framegrabber, ausreichend Abstand), 2× Ethernet

### 2.4 Sensorik / Optik

- **Kamera:** Dalsa P4 (Color), 2K oder 4K je nach Kunde
- **Sensor-Typ:** Aktuell optisch (+ optional Feuchte)
- **System-Design:** Erweiterbar für weitere Sensortypen (Multisensorik-Roadmap)
- **Beleuchtung:** LED-Leisten (bis zu 3 Top + 1 Bottom), gesteuert via MTD Illumination (Ethernet)
- **Konfiguration:** 1 oder 2 Kameras möglich (Top/Bottom), Color oder Monochrome Sensor

### 2.5 Weitere Hardware-Komponenten (aus Elektroschema)

- FAST I/O Interface Module (2×): VP-3-PT-HS200UB-P
- Siemens Simatic ET 200SP Modulsbus
- Managed Switches (3×)
- UPS (Kapazität unbekannt)
- 48V Power Supply → 24V Konverter
- Encoder, Lichtschranke, Reflexionssensor

---

## 3. Software-Architektur

### 3.1 OS & System-Setup (Golden Master)

- **OS:** Xubuntu 24.04 LTS
- **Verschlüsselung:** LUKS (Full-Disk), automatisches Unlock via TPM 2.0 (clevis, PCR 7)
- **Secure Boot:** UEFI Secure Boot aktiv, Drittanbieter-Module via MOK signiert
- **Partitionierung (LVM):**
    - `root` /: ~250 GB (OS)
    - `data`: restlicher Speicher (Bilder, Modelle, Code)
- **RAID:** Software RAID via mdadm (optional, wenn Redundanz gefordert)
- **Fernwartung:** OpenSSH (Normalbetrieb) + Dropbear in initramfs (Notfall-Remote-Unlock)
- **Journal:** Größe begrenzt (SystemMaxUse=1G)
- **Auto-Reboot:** Wöchentlich/monatlich per cronjob (So 03:00) → bereinigt Zombie-Prozesse, RAM-Fragmente, Framegrabber-Treiber-Cache
- **Health-Check Script (Boot):**
    1. GPU vorhanden? (`nvidia-smi`)
    2. LUKS-Verschlüsselung OK?
    3. `/data` gemountet? → Sonst Alert (LED / E-Mail "Call Home")

### 3.2 ROSI Software-Stack

#### Backend / Core

- **Sprache:** Python (Hauptsprache für ROSI-Kern)
- **Datenbank:** PostgreSQL + PostGIS
- **Datenbankzugang:** pgAdmin (`rosi@grenzebach.com`)

#### Pipeline (aus Prozessdiagramm)

- **Load Monitor** – überwacht CPU, RAM, GPU-Auslastung
- **Logger** – schreibt in DB, anzeigbar im Frontend
- **Scanning Main** – Hauptsteuerung, initialisiert ComponentHandler/CamFigher
- **FrameCreator** – empfängt Frames vom Framegrabber, baut Frame-Packages
- **PipelineManager** – verwaltet Pipeline-Instanzen, Shared Memory
- **Worker Pool** mit Prozessen:
    - P6: Image Builder
    - P7: Headless (ggf. Display-Output)
    - P8: RO-Watcher
    - P9: Classic Defect Detector
    - P10: AI Defect Detector (KI-Inferenz)
    - P11-14: Pipeline Encoding & Saving
    - P15: DefectPackage Extraction
    - P16: Node Evaluator (Rezeptsystem)
    - P20: IO Communication
    - P21: Save to DB

#### KI-Modelle

- Format: `.pth` (PyTorch)
- Inferenz auf GPU (RTX 5090 / 5080)

#### Frontend / UI

- **Django:** API, ORM, UI-Serving (iframe-basiert)
- **SvelteKit:** Node-Server, wird als iframe in Django eingebettet
- UI dient auch Netzwerk-Serving im Kundennetz

#### Komponenten-Diagramm (vereinfacht)

```
Encoder ──┐
Lichtschranke ──┤──> Frame Grabber (Euresys, Internal IO Card)
Illumination 0/1/2 ──┤       ↓
Camera (Dalsa P4) ──┘   Image Builder
                              ↓
                    Inspection Data Handler
                              ↓
            ┌─────────────────┬─────────────────┐
            ↓                 ↓                 ↓
    AI Defect Analyzer   Quality Decision   Panel Geo Measurements
            ↓                 ↓
    Calc & Optimize      Quality to Bin Mapper
    Defect Geometry
                              ↓
                    Django (ORM + API + UI)
                    ├── External DB Handler
                    ├── ROSI DB Handler
                    ├── Logging Handler
                    └── Config Handler
```

---

## 4. Netzwerk

- ROSI-PC hat **2 Ethernet-Anschlüsse:**
    - 1× Kundennetz (dient UI, kein Internet nötig)
    - 1× MTD Illumination (dediziert für Beleuchtungssteuerung)
- Kein offizielles Netzwerkdiagramm vorhanden
- Externe Kommunikation laut Elektroschema: Siemens Simatic ET 200SP, Modbus

---

## 5. Offene / ungeklärte Punkte

> Fehlerszenarien und Risiken → siehe separate Datei: `ROSI_Fehlerszenarien.md`

| Punkt                         | Status                                                     |
| ----------------------------- | ---------------------------------------------------------- |
| UPS-Kapazität und Modell      | Unbekannt – kein Kundensystem vorhanden (~5 Monate)        |
| Stromausfall → LUKS-Unlock    | Konzept fehlt, aktives Thema der Fallstudie                |
| DB-Backup-Strategie           | Nur monatlich manuell durch Grenzebach (HDD)               |
| SLAs mit Kunde                | Unbekannt                                                  |
| NAS/HDD-Datenüberlauf         | Konzept vorhanden, nicht implementiert/dokumentiert        |
| KI-Modell-Updates / Rollback  | Plugin-System in Entwicklung, kein Rollback-Konzept        |
| Monitoring außerhalb Laufzeit | Nur Marimo Notebooks, kein externes Alerting               |
| Rezept-Validierung            | Kein beschriebenes Konzept gegen stille Fehlklassifikation |
