#!/bin/bash
# Erzeugt die Abbildungen der Ausarbeitung aus den Mess-CSVs.

DIR="$(cd "$(dirname "$0")" && pwd)"
python "$DIR/make_plots.py"
