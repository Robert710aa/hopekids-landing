@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
echo Otwieram folder MT5_XAU_Profit (gdzie sa pliki bota)...
echo.

set "FOUND="
for %%P in ("%APPDATA%\MetaQuotes\Terminal" "%LOCALAPPDATA%\MetaQuotes\Terminal") do (
  for /d %%D in ("%%~P\*") do (
    set "TGT=%%D\MQL5\Experts\MT5_XAU_Profit"
    if exist "!TGT!" (
      start "" "!TGT!"
      set "FOUND=1"
      goto opened
    )
  )
)

:opened
if not defined FOUND (
  echo Nie znaleziono folderu MT5_XAU_Profit. Uruchom Skopiuj_do_MT5.bat, potem POKAZ_MI_GDZIE_JEST_BOT.bat i wejdz recznie: folder - MQL5 - Experts - MT5_XAU_Profit
)
:end
pause
