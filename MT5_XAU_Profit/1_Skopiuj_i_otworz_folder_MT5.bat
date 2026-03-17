@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set "SRC=%~dp0"
echo.
echo [1/2] Kopiowanie 5 plikow do MT5...
set "COUNT=0"
set "PIERWSZY="
for %%P in ("%APPDATA%\MetaQuotes\Terminal" "%LOCALAPPDATA%\MetaQuotes\Terminal") do (
  for /d %%D in ("%%~P\*") do (
    set "TGT=%%D\MQL5\Experts\MT5_XAU_Profit"
    if exist "%%D\MQL5\Experts" (
      if not exist "!TGT!" mkdir "!TGT!"
      copy /Y "%SRC%XAU_Profit_EA.mq5" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Indicators.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Helpers.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Signals.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Trade.mqh" "!TGT!\" >nul
      set /a COUNT+=1
      if "!PIERWSZY!"=="" set "PIERWSZY=!TGT!"
    )
  )
)
echo      Skopiowano do !COUNT! terminali.
echo.
echo [2/2] Otwieram folder w MT5...
if defined PIERWSZY (
  start "" "!PIERWSZY!"
  echo.
  echo W otwartym folderze:
  echo   - dwuklik na XAU_Profit_EA.mq5  (otworzy sie w MetaEditorze)
  echo   - w MetaEditorze wcisnij F7  (Kompiluj)
) else (
  echo Nie znaleziono folderu MT5. Uruchom Skopiuj_do_MT5.bat i zobacz instrukcje.
)
echo.
pause
