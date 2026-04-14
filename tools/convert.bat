@echo off
REM Script zur Konvertierung von Markdown zu PDF mit Grenzebach BSH Branding
REM Verwendung: convert.bat datei.md oder tools\convert.bat datei.md

if "%~1"=="" (
    echo Verwendung: convert.bat ^<markdown-datei.md^>
    exit /b 1
)

set INPUT_FILE=%~1
set OUTPUT_FILE=%~n1.pdf
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR:~0,-6%

REM Pruefe ob die Eingabedatei existiert
if not exist "%INPUT_FILE%" (
    echo Fehler: Datei '%INPUT_FILE%' nicht gefunden
    exit /b 1
)

REM Pruefe ob pdf-defaults.yaml existiert im tools Verzeichnis
if exist "%SCRIPT_DIR%pdf-defaults.yaml" (
    pandoc "%INPUT_FILE%" -o "%OUTPUT_FILE%" --defaults="%SCRIPT_DIR%pdf-defaults.yaml" --resource-path="%PROJECT_ROOT%"
) else (
    echo Warnung: pdf-defaults.yaml nicht gefunden, verwende Standard-Einstellungen
    pandoc "%INPUT_FILE%" -o "%OUTPUT_FILE%" -V geometry:margin=2.5cm --resource-path="%PROJECT_ROOT%"
)

if %errorlevel% equ 0 (
    echo PDF erfolgreich erstellt: %OUTPUT_FILE%
) else (
    echo Fehler bei der PDF-Erstellung
    exit /b 1
)
