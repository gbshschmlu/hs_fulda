# HS Fulda — Unterlagen zum dualen Studium

Alle Aufgaben, Lösungen, Projekte und Unterlagen aus meinem dualen Studium an der **Hochschule Fulda**.

**Dualer Student bei:** Grenzebach BSH GmbH

---

## Überblick

Dieses Repository dokumentiert drei Semester des dualen Studiums, unterteilt nach Zeit und Modul:

- **SoSe 2025** (Sommersemester 2025): 4 Module
- **WiSe 2025/26** (Wintersemester 2025/26): 4 Module  
- **SoSe 2026** (Sommersemester 2026): 3 Module (laufend)

Jedes Semester ist in Module gegliedert, innerhalb jedes Moduls gibt es Unterordner für Aufgaben, Lösungen, Skripte und sonstige Unterlagen.

---

## Verzeichnisstruktur

```
hs_fulda/
├── sose2025/                  # Sommersemester 2025 (abgeschlossen)
│   ├── programmiermethoden2/  # Programmierungsmethoden (Kotlin)
│   ├── programmierung2/        # Programmierung 2 (Java, SpaceInvaders Projekt)
│   ├── software_engineering/   # Software Engineering (UML, Design)
│   └── web_applikationen/      # Web-Entwicklung (Node.js/Express)
│
├── wise2025/                   # Wintersemester 2025/26 (abgeschlossen)
│   ├── algorithmen_und_datenstrukturen/  # Algorithmen & Datenstrukturen
│   ├── datenbanksysteme/       # Datenbanken (SQL)
│   ├── projektmanagement/      # Projektmanagement & Zeitplanung
│   └── wissenschaftliche_kommunikation_praesentation/  # Wissenschaftliches Schreiben
│
├── sose2026/                   # Sommersemester 2026 (laufend)
│   ├── robotik/                # Robotik (ROS2, Docker)
│   ├── gesundheitstechnik/     # Health Technology (LaTeX)
│   └── fallstudie/             # Case Study / Fallstudie
│
├── templates/                  # Wiederverwendbare Vorlagen
│   └── latex_template/         # LaTeX-Vorlage für wissenschaftliche Arbeiten
│
├── assets/                     # Branding-Assets
│   └── logo.png                # Grenzebach BSH Logo (für PDF-Header)
│
├── .gitignore                  # Git-Ausschlüsse
├── README.md                   # Diese Datei
└── typos.toml                  # PDF-Branding-Konfiguration
```

---

## Markdown → PDF Konvertierung

Die Konvertierung von Markdown zu gebrandeten PDFs erfolgt mit **[typos](https://github.com/LuMiSxh/typos)** — einem selbstständigen CLI-Tool in Rust, das **keine externen Abhängigkeiten** (kein LaTeX, kein Pandoc) benötigt.

### Installation

```bash
# Von GitHub installieren
cargo install --git https://github.com/LuMiSxh/typos

# Oder lokal aus dem Quellcode
cargo install --path /pfad/zu/typos
```

### Grundlegende Verwendung

```bash
# Einzelne Datei mit einem Profil konvertieren
typos convert sose2026/modul/datei.md --profile luca

# Mehrere Profile gleichzeitig
typos convert sose2026/modul/datei.md --profile luca,gb

# Alle konfigurierten Profile auf einmal
typos convert sose2026/modul/datei.md --profile all

# Interaktiver Modus (perfekt zum Ausprobieren)
typos
```

Das PDF wird standardmäßig **neben der Quelldatei** abgelegt.

### Verfügbare Profile

Die Branding-Konfiguration steht in [`typos.toml`](typos.toml) im Repository-Root und wird automatisch gefunden, egal aus welchem Unterordner `typos` aufgerufen wird.

| Profil | Verwendung | Branding |
|--------|-----------|----------|
| `luca` | Persönliche Arbeiten | Grenzebach BSH — Rot `#ED1B24`, mit Name & Email |
| `gb` | Allgemeine/Unternehmensarbeiten | Grenzebach BSH — Rot `#ED1B24`, generisch |

Alle konfigurierten Profile anzeigen:

```bash
typos list
```

### PDF-Struktur

Jedes generierte PDF hat:
- **Header** mit Grenzebach Logo (links) und Autorennamen (rechts)
- **Footer** mit Institut, Email und Seitennummern
- **Styling**: Kopfzeilen/Fußzeilen in Grenzebach-Rot, saubere Schriftarten
- **Standardmargen**: 2.5 cm, angepasst für professionelle Dokumente

---

## Module nach Semester

### SoSe 2025 — 4 Module

**1. Programmiermethoden 2**  
Vertiefung von Programmierungskonzepten mit Kotlin. Umfasst Funktionale Programmierung, Pattern Matching und idiomatische Kotlin-Patterns.

**2. Programmierung 2**  
Java-Kurs mit praktischen Projekten:
- SpaceInvaders-Spiel (Swing GUI)
- JavaShooter Framework
- Wöchentliche Testaufgaben (Testate)

**3. Software Engineering**  
Theoretische und praktische Grundlagen:
- UML-Modellierung
- Design Patterns
- Software-Architektur

**4. Web-Applikationen**  
Vollständige Web-Stack-Entwicklung:
- Node.js & Express Backend
- EJS Templating
- CSS/JavaScript Frontend

### WiSe 2025/26 — 4 Module

**1. Algorithmen & Datenstrukturen**  
Klassische Algorithmen, Laufzeitanalyse, Sortier- und Suchverfahren. Wöchentliche Assignments + Testaufgaben.

**2. Datenbanksysteme**  
Grundlagen von SQL und relationalen Datenbanken.

**3. Projektmanagement**  
Planung, Zeitmanagement, Koordination und Dokumentation von Projekten.

**4. Wissenschaftliche Kommunikation & Präsentation**  
Akademisches Schreiben, Hausarbeit und Präsentationsfähigkeiten.

### SoSe 2026 — 3 Module (laufend)

**1. Robotik**  
ROS2 (Robot Operating System 2) mit Docker-basierter Remote-Umgebung.  
*Workspace läuft auf Home-Server via noVNC Web-Desktop.*

**2. Gesundheitstechnik**  
Health Technology / Medical Devices. Fachartikel und Spezifikationen (LaTeX).

**3. Fallstudie**  
Praxisorientiertes Projekt mit Expose, Meetings und umfassender Dokumentation.

---

## Typischer Workflow

### Eine Aufgabe bearbeiten

1. **Datei erstellen** im entsprechenden Semester/Modul-Ordner:
   ```bash
   sose2026/robotik/uebung1/loesung.md
   ```

2. **Markdown schreiben** und evtl. lokal mit `typos` testen:
   ```bash
   typos convert sose2026/robotik/uebung1/loesung.md --profile luca
   ```

3. **PDF überprüfen** (wird automatisch neben der .md erstellt)

4. **Commiten & pushen**:
   ```bash
   git add sose2026/robotik/uebung1/
   git commit -m "sose2026/robotik: Übung 1 Lösung"
   git push
   ```

### LaTeX-Arbeiten

Für längere akademische Arbeiten (z.B. Fallstudie, Hausarbeit):

1. **Vorlage verwenden** aus `templates/latex_template/`
2. **Lokal compilieren** mit den beiliegenden Scripts (`latex_comp.sh` / `latex_comp.bat`)
3. **PDF ins Repository** commiten

Tipp: Große LaTeX-Projekte mit viel generiertem Output sollten `.gitignore` erweitern.

---

## Wichtige Dateien

| Datei | Zweck |
|-------|--------|
| `typos.toml` | Konfiguration der 2 Branding-Profile (luca, gb) |
| `assets/logo.png` | Grenzebach BSH Logo für PDF-Header |
| `.gitignore` | Git-Ausschlüsse (venv/, *.class, etc.) |
| `templates/latex_template/` | Wiederverwendbare LaTeX-Vorlage |

---

## Entwicklungsumgebung

### Python Virtual Environment

Ein Python venv ist vorhanden (`venv/`) für evtl. Skripte.  
*Wird von .gitignore ausgeschlossen.*

### IDE

- **IntelliJ IDEA** (für Java/Kotlin-Module)
- **VS Code** (für Web/JavaScript-Module)
- **LaTeX Editor** deiner Wahl (z.B. TeXShop, Overleaf)

### Build-Artefakte

Von Git ausgeschlossen:
- `*.class` (Java bytecode)
- `__pycache__/` (Python cache)
- `*.pyc` (Python compiled)
- `node_modules/` (npm dependencies)
- `dist/`, `out/` (Build output)

---

## Tipps & Best Practices

### Dateibenennung

- **Markdown-Dateien**: lowercase mit Unterstrichen  
  ✅ `uebung1_loesung.md`  
  ❌ `Übung 1 Lösung.md`

- **Assignement-Ordner**: nach Nummern  
  ✅ `sose2026/robotik/uebung1/`  
  ❌ `sose2026/robotik/Übung 1/`

### Git Commits

```bash
# Gutes Commit-Format
git commit -m "sose2026/robotik: Übung 1 abgeschlossen"

# Mehrere Module
git commit -m "sose2026: Robotik & Fallstudie Basis hinzugefügt"
```

### Markdown für typos

Schreib Markdown normal — typos handled die Konvertierung:

```markdown
# Hauptüberschrift
## Unterüberschrift
### Weitere Ebenen

**Fett** und *Kursiv* funktionieren normal.

- Listenpunkte
- Mehr Punkte

\`\`\`python
code_beispiel()
\`\`\`

| Tabelle | Unterstützt |
|---------|-----------|
| Ja | 100% |
```

---

## Fehlersuche

### typos findet typos.toml nicht

```bash
# Sicherstellen, dass du aus dem Repo-Root aufgerufen wirst
cd /Users/Luca/Documents/Projekte/hs_fulda
typos list
```

### Logo wird im PDF nicht angezeigt

1. Überprüfe `typos.toml` — Logo-Pfad muss `assets/logo.png` sein
2. Verifiziere, dass `assets/logo.png` existiert
3. Regeneriere das PDF

### Margin/Header-Größe passt nicht

Änderungen sind in `typos.toml` möglich (z.B. `top_margin`, `head_height`).  
Siehe [typos-Dokumentation](https://github.com/LuMiSxh/typos) für alle verfügbaren Optionen.

---

## Links & Ressourcen

- **[typos GitHub Repository](https://github.com/LuMiSxh/typos)** — PDF-Konvertierungstool
- **[Grenzebach BSH GmbH](https://www.grenzebach.com/)** — Arbeitgeber
- **[Hochschule Fulda](https://www.hs-fulda.de/)** — Universität

---

**Letztes Update:** 2026-05-14  
**Autor:** Luca Michael Schmidt
