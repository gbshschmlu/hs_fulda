#!/bin/bash
# Kompilierungsscript für den Fachartikel (pdflatex + biber)
# Äquivalent zur latex_comp.bat aus der WiKo-Hausarbeit

FILENAME="main"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "[0/4] Aufräumen..."
rm -f *.aux *.log *.out *.toc *.bcf *.run.xml *.acn *.bbl *.blg *.glo *.lof *.synctex.gz *.xmpi

echo "[1/4] PDFLaTeX (1. Durchlauf)..."
pdflatex -synctex=1 -interaction=nonstopmode "$FILENAME"

echo "[2/4] Biber (Literaturverzeichnis)..."
biber "$FILENAME"

echo "[3/4] PDFLaTeX (Literaturverzeichnis einbinden)..."
pdflatex -synctex=1 -interaction=nonstopmode "$FILENAME"

echo "[4/4] PDFLaTeX (Querverweise auflösen)..."
pdflatex -synctex=1 -interaction=nonstopmode "$FILENAME"

echo "Fertig. PDF: $DIR/main.pdf"
