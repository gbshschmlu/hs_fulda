@echo off
where pandoc >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing pandoc...
    choco install pandoc miktex -y
)
