@echo off
if "%~1"=="_run_" goto :main
start "Multi-Exchange Bot" cmd /k "%~f0" _run_
exit /b 0

:main
chcp 65001 >nul
cd /d "%~dp0"
echo ========================================
echo   Multi-Exchange Bot ^(AI + Scanner + Execution^)
echo ========================================
echo Folder: %CD%
echo.

if not exist "venv" (
    echo Tworze venv...
    python -m venv venv
    if errorlevel 1 (
        echo BLAD: Zainstaluj Python i dodaj do PATH
        goto :koniec
    )
)
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
if errorlevel 1 (
    echo BLAD pip install
    goto :koniec
)

echo Uruchamiam bota ^(Ctrl+C = stop^)
echo Tryb: sprawdz .env BOT_MODE=dry_run
echo.
python run.py

:koniec
echo.
echo Nacisnij dowolny klawisz aby zamknac...
pause >nul
