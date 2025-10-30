#!/bin/bash

# Script zur Konvertierung von Markdown zu PDF mit Grenzebach BSH Branding
# Verwendung: ./convert.sh datei.md

if [ $# -eq 0 ]; then
    echo "Verwendung: ./convert.sh <markdown-datei.md>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.md}.pdf"

# Prüfe ob die Eingabedatei existiert
if [ ! -f "$INPUT_FILE" ]; then
    echo "Fehler: Datei '$INPUT_FILE' nicht gefunden"
    exit 1
fi

# Prüfe ob pdf-defaults.yaml existiert
if [ ! -f "pdf-defaults.yaml" ]; then
    echo "Warnung: pdf-defaults.yaml nicht gefunden, verwende Standard-Einstellungen"
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" -V geometry:margin=2.5cm
else
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --defaults=pdf-defaults.yaml
fi

if [ $? -eq 0 ]; then
    echo "PDF erfolgreich erstellt: $OUTPUT_FILE"
else
    echo "Fehler bei der PDF-Erstellung"
    exit 1
fi
