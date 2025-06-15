@echo off
REM Custom compilation script for TeXworks
REM Usage: latexbibtex.bat filename.tex
REM This script runs: latex (3x) -> bibtex -> latex (2x)

REM Get the filename without extension
for %%i in (%1) do set filename=%%~ni
for %%i in (%1) do set dirname=%%~dpi

cd "%dirname%"

REM Run latex 3 times
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"

REM Run bibtex
bibtex "%filename%"

REM Run latex 2 more times
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"