#!/bin/bash

# Script zur Konvertierung von Markdown zu PDF mit Grenzebach BSH Branding
# Verwendung: ./convert.sh datei.md oder tools/convert.sh datei.md

if [ $# -eq 0 ]; then
    echo "Verwendung: ./convert.sh <markdown-datei.md>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.md}.pdf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Prüfe ob die Eingabedatei existiert
if [ ! -f "$INPUT_FILE" ]; then
    echo "Fehler: Datei '$INPUT_FILE' nicht gefunden"
    exit 1
fi

# Setze PATH für xelatex wenn nicht vorhanden
if ! command -v xelatex &> /dev/null; then
    export PATH="/usr/local/texlive/2026/bin/universal-darwin:/usr/local/texlive/2025/bin/universal-darwin:$PATH"
fi

# Prüfe ob pdf-defaults.yaml existiert und nutze absoluten Pfad
if [ ! -f "$SCRIPT_DIR/pdf-defaults.yaml" ]; then
    echo "Warnung: pdf-defaults.yaml nicht gefunden, verwende Standard-Einstellungen"
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" -V geometry:margin=2.5cm --resource-path="$PROJECT_ROOT"
else
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --defaults="$SCRIPT_DIR/pdf-defaults.yaml" --resource-path="$PROJECT_ROOT"
fi

if [ $? -eq 0 ]; then
    echo "PDF erfolgreich erstellt: $OUTPUT_FILE"
else
    echo "Fehler bei der PDF-Erstellung"
    exit 1
fi
