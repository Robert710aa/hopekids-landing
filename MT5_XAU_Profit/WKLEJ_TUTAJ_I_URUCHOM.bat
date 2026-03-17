@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
set "SRC=c:\Users\Crypt\noktra-start-static\MT5_XAU_Profit"
echo.
echo 1. W MT5: Plik - Otworz folder danych
echo 2. Wejdz: MQL5 - Experts
echo 3. Skopiuj TEN plik (WKLEJ_TUTAJ_I_URUCHOM.bat) do folderu Experts
echo 4. Dwuklik na WKLEJ_TUTAJ_I_URUCHOM.bat
echo.
echo Albo uruchom ten bat Z TEGO FOLDERU - wklei pliki do Experts\MT5_XAU_Profit
echo w kazdym terminalu MT5...
echo.
pause
goto :run
:run
set "COUNT=0"
for /d %%D in ("%APPDATA%\MetaQuotes\Terminal\*") do (
  set "TGT=%%D\MQL5\Experts\MT5_XAU_Profit"
  set "EX=%%D\MQL5\Experts"
  if exist "!EX!" (
    if not exist "!TGT!" mkdir "!TGT!"
    copy /Y "%SRC%\XAU_Profit_EA.mq5" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Trade.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Helpers.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Indicators.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Signals.mqh" "!TGT!\" >nul
    echo OK: !TGT!
    set /a COUNT+=1
  )
)
for /d %%D in ("%LOCALAPPDATA%\MetaQuotes\Terminal\*") do (
  set "TGT=%%D\MQL5\Experts\MT5_XAU_Profit"
  set "EX=%%D\MQL5\Experts"
  if exist "!EX!" (
    if not exist "!TGT!" mkdir "!TGT!"
    copy /Y "%SRC%\XAU_Profit_EA.mq5" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Trade.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Helpers.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Indicators.mqh" "!TGT!\" >nul
    copy /Y "%SRC%\XAU_Profit_Signals.mqh" "!TGT!\" >nul
    echo OK: !TGT!
    set /a COUNT+=1
  )
)
echo.
echo Skopiowano do %COUNT% folderow. W MetaEditorze: Plik-Otworz folder danych - MQL5-Experts-MT5_XAU_Profit - otworz XAU_Profit_EA.mq5 - F7.
pause
