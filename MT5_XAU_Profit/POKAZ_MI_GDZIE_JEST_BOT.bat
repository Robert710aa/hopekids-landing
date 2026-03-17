@echo off
chcp 65001 >nul
echo Otwieram folder danych MT5...
echo.
echo W otwartym oknie zobaczysz 1 lub wiecej folderow (dlugie nazwy). Wejdz do jednego,
echo potem: MQL5 - Experts - MT5_XAU_Profit. Tam sa pliki bota.
echo.
start "" "%APPDATA%\MetaQuotes\Terminal"
echo.
echo Jesli zamiast tego chcesz od razu folder z botem - uruchom: POKAZ_BOT_bezposrednio.bat
pause
