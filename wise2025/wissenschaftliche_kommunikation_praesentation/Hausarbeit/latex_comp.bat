@echo off
REM Custom compilation script for TeXworks (PDFLaTeX + Biber)
REM Usage: compile_biber.bat filename.tex

REM Clean up auxiliary files
del *.aux *.log *.out *.toc *.bcf *.run.xml /s /q

REM Get the filename without extension
for %%i in (%1) do set filename=%%~ni
REM Get the directory path
for %%i in (%1) do set dirname=%%~dpi

REM Change to the directory of the tex file
cd /d "%dirname%"

echo [1/4] Running PDFLaTeX (Initial run)...
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"

echo [2/4] Running Biber (Bibliography)...
biber "%filename%"

echo [3/4] Running PDFLaTeX (incorporating bibliography)...
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"

echo [4/4] Running PDFLaTeX (resolving cross-references)...
pdflatex -synctex=1 -interaction=nonstopmode "%filename%"

echo Done.
