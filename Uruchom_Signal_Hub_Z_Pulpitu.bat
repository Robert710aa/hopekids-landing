@echo off
chcp 65001 >nul
cd /d "C:\Users\Crypt\noktra-start-static\MultiSource_TradingSystem"
if not exist "Uruchom_Signal_Hub.bat" (
    echo Nie znaleziono. Sciezka: %CD%
    pause
    exit /b 1
)
call "Uruchom_Signal_Hub.bat"
pause
