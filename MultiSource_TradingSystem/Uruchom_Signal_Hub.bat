@echo off
if "%~1"=="_run_" goto :main
start "Signal Hub" cmd /k "%~f0" _run_
exit /b 0

:main
chcp 65001 >nul
cd /d "%~dp0"
echo ========================================
echo   Multi-Source Signal Hub - Uruchomienie
echo ========================================
echo.
echo Folder: %CD%
echo.

if not exist "venv" (
    echo Tworze srodowisko Python ^(venv^)...
    python -m venv venv
    if errorlevel 1 (
        echo BLAD: Zainstaluj Python 3.10+ z python.org i zaznacz "Add to PATH"
        goto :koniec
    )
    echo OK.
)

echo Aktywuje venv i instaluje zaleznosci...
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
if errorlevel 1 (
    echo BLAD przy pip install.
    goto :koniec
)
echo OK.

echo.
echo Uruchamiam Signal Hub na http://127.0.0.1:8000
echo Zostaw to okno otwarte. Zamknij ^(Ctrl+C^) zeby zatrzymac.
echo W MT5: EA ma juz wlaczony sygnał z pliku ^(InpUseExternalSignal=true^).
echo Plik sygnału: zapis bezposrednio do MT5 Common/Files ^(z .env^).
echo.
python -m uvicorn main:app --host 127.0.0.1 --port 8000
if errorlevel 1 (
    echo.
    echo BLAD uruchomienia - przeczytaj komunikat powyzej.
)
:koniec
echo.
echo Nacisnij DOWOLNY KLAWISZ aby zamknac to okno...
pause >nul
