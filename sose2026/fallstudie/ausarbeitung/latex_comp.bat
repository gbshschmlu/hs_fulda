@echo off
REM Kompilierungsscript Fachartikel Gesundheitstechnik (PDFLaTeX + Biber)
REM Usage: latex_comp.bat  (aus dem Verzeichnis der main.tex ausführen)

for %%i in (%~dp0) do set DIRNAME=%%~fi
cd /d "%DIRNAME%"

echo [0/4] Aufräumen...
del /q *.aux *.log *.out *.toc *.bcf *.run.xml *.acn *.bbl *.blg *.glo *.lof *.synctex.gz *.xmpi 2>nul

echo [1/4] PDFLaTeX (1. Durchlauf)...
pdflatex -synctex=1 -interaction=nonstopmode main.tex

echo [2/4] Biber (Literaturverzeichnis)...
biber main

echo [3/4] PDFLaTeX (Literaturverzeichnis einbinden)...
pdflatex -synctex=1 -interaction=nonstopmode main.tex

echo [4/4] PDFLaTeX (Querverweise auflösen)...
pdflatex -synctex=1 -interaction=nonstopmode main.tex

echo.
echo Fertig. PDF: %DIRNAME%main.pdf
pause
