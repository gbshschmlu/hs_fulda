# HS Fulda Unterlagen

Dieses Repository enthält alle Aufgaben, Lösungen und Unterlagen zu den verschiedenen Modulen aus meinem dualen Studium an der Hochschule Fulda.

**Dualer Student bei:** Grenzebach BSH GmbH

## 📁 Repository-Struktur

```
├── sose2025/              # Sommersemester 2025
├── sose2026/              # Sommersemester 2026
├── wise2025/              # Wintersemester 2025
├── tools/                 # Konvertierungsskripte und Konfigurationen
│   ├── convert.sh         # Markdown → PDF (macOS/Linux)
│   ├── convert.bat        # Markdown → PDF (Windows)
│   ├── install.sh         # Abhängigkeiten installieren (macOS)
│   ├── install.bat        # Abhängigkeiten installieren (Windows)
│   ├── pdf-defaults.yaml  # Pandoc Konfiguration für Branding
│   └── gb.jpg             # Grenzebach BSH Logo
└── README.md              # Diese Datei
```

Jedes Semester ist nach Modulen strukturiert:
- **Module** - Unterordner pro Modul
- **Unterlagen** - Aufgaben, Lösungen, Skripte, Sonstiges

## 🔧 Tools: Markdown zu PDF Konvertierung

Für die Konvertierung von Markdown-Dokumenten zu brandingerten PDF-Dateien stehen automatische Scripts zur Verfügung. Diese verwenden [Pandoc](https://pandoc.org/) und [LaTeX](https://www.latex-project.org/) zur professionellen PDF-Erstellung mit Grenzebach BSH Branding (Logo, Kopf- und Fußzeilen, Seitennummerierung).

### Setup

**macOS/Linux:**

```bash
chmod +x tools/install.sh
./tools/install.sh
```

Die Installation erfolgt über Homebrew und installiert automatisch:
- Pandoc (Dokumentenkonverter)
- BasicTeX/TeX Live (LaTeX Distribution)

**Windows:**

```batch
tools\install.bat
```

Falls Homebrew/Scoop nicht installiert sind, können Sie Pandoc und MikTeX manuell von den offiziellen Websites herunterladen.

### Verwendung

**Von der Projektroot aus:**

```bash
# macOS/Linux
./tools/convert.sh <pfad-zu-datei.md>

# Windows
tools\convert.bat <pfad-zu-datei.md>
```

**Beispiele:**

```bash
# Von der Projektroot
./tools/convert.sh sose2026/gesundheitstechnik/konkretisierung.md

# Oder von innerhalb des Moduls
cd sose2026/gesundheitstechnik
../../tools/convert.sh konkretisierung.md
```

### Features

Das Branding ist automatisch aktiviert und beinhaltet:

- **Header:** Grenzebach BSH Logo (links), Autor (rechts)
- **Footer:** Studium | HS Fulda + E-Mail (links), Seitennummerierung (rechts)
- **Farben:** Grenzebach-Rot (#ED1B24) für Linien, Links und Akzente
- **Typographie:** Arial Hauptfont, Code in Menlo
- **Layout:** A4, 2.5cm Ränder, verbesserte Tabellen und Code-Blöcke
- **Seitenumbruch:** Intelligente Platzierung von Überschriften

### Bilder in PDFs

Damit Bilder in konvertierten PDFs korrekt eingebunden werden:

1. **Relative Pfade verwenden:** `![Beschreibung](./image.png)`
2. **Bilder im selben Verzeichnis** oder in einem bekannten Unterpfad speichern
3. **HTML-Syntax für Größenangaben (optional):**
   ```markdown
   <img src="./image.png" width="200" alt="Beschreibung" />
   ```

Das Script passt die Ressourcenpfade automatisch an, egal von wo es aufgerufen wird.

### Manuelle Konvertierung

Falls die Scripts nicht verwendet werden:

```bash
pandoc datei.md -o datei.pdf --defaults=tools/pdf-defaults.yaml
```

### Online-Alternative

Für schnelle Konvertierungen ohne lokale Installation: [PDFForge Markdown zu PDF](https://www.pdfforge.org/online/en/markdown-to-pdf) (ohne Branding)
