# HS Fulda Unterlagen

Dieses Repository enthält alle Aufgaben/Lösungen zu den verschiedenen Modulen die ich im Verlauf meines dualen Studiums an der Hochschule Fulda bearbeitet habe.

**Dualer Student bei:** Grenzebach BSH GmbH

## Struktur

- Semester
    - Module
    - Unterlagen
        - Aufgaben
        - Lösungen
        - Skripte
        - Sonstiges

## Tools

### Markdown zu PDF Konvertierung

**Lokale Konvertierung (empfohlen):**

Für die lokale Umwandlung von Markdown-Vorlagen zu PDF steht ein automatisches Setup zur Verfügung:

**macOS:**

```bash
./install.sh
```

**Windows:**

```batch
install.bat
```

Die Scripts installieren automatisch Pandoc und die notwendigen LaTeX-Dependencies. Nach der Installation können Markdown-Dateien einfach konvertiert werden:

**Einfache Konvertierung mit Grenzebach BSH Branding:**

```bash
# macOS
chmod +x convert.sh
./convert.sh datei.md

# Windows
convert.bat datei.md
```

Das Branding wird automatisch auf alle konvertierten PDFs angewendet und enthält:

- Grenzebach BSH Logo-Farben
- Header mit Firmennamen
- Footer mit "Duales Studium | HS Fulda"
- Seitennummerierung

**Manuelle Konvertierung:**

```bash
pandoc datei.md -o datei.pdf --defaults=pdf-defaults.yaml
```

**Online Alternative:**

- [PDFForge](https://www.pdfforge.org/online/en/markdown-to-pdf) - Markdown zu PDF (ohne Branding)
