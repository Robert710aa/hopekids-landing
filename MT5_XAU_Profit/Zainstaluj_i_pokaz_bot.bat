@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set "SRC=%~dp0"
echo Zainstaluj i pokaz - kopiowanie XAU_Profit_EA do WSZYSTKICH folderow MT5...
echo.

set "COUNT=0"
set "FIRST_TGT="
for %%P in ("%APPDATA%\MetaQuotes\Terminal" "%LOCALAPPDATA%\MetaQuotes\Terminal") do (
  for /d %%D in ("%%~P\*") do (
    set "EXPERTS=%%D\MQL5\Experts"
    set "TGT=%%D\MQL5\Experts\MT5_XAU_Profit"
    if exist "!EXPERTS!" (
      if not exist "!TGT!" mkdir "!TGT!"
      if not defined FIRST_TGT set "FIRST_TGT=!TGT!"
      echo [!TGT!]
      copy /Y "%SRC%XAU_Profit_EA.mq5" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Indicators.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Helpers.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Signals.mqh" "!TGT!\" >nul
      copy /Y "%SRC%XAU_Profit_Trade.mqh" "!TGT!\" >nul
      echo   [OK] skopiowano 5 plikow
      set /a COUNT+=1
    )
  )
)

echo.
if %COUNT% gtr 0 (
  echo Gotowe. Skopiowano do %COUNT% terminali ^(Experts\MT5_XAU_Profit^).
  if defined FIRST_TGT (
    echo.
    echo Otwieram folder z botem...
    start "" "!FIRST_TGT!"
  )
  echo.
  echo Teraz: MetaEditor - Plik - Otworz folder danych - MQL5 - Experts - MT5_XAU_Profit
  echo Otworz XAU_Profit_EA.mq5 i nacisnij F7. W MT5: Nawigator - Eksperci - odswiez.
) else (
  echo Nie znaleziono folderu MQL5\Experts w standardowej sciezce.
  echo.
  echo ZROB TO RECZNIE:
  echo 1. W MetaTrader 5: Plik - Otworz folder danych
  echo 2. W otwartym oknie wejdz: MQL5 - Experts
  echo 3. Jesli nie ma folderu MT5_XAU_Profit - utworz go ^(prawy przycisk - Nowy - Folder^)
  echo 4. Otworz ten folder i skopiuj do niego 5 plikow z tego samego miejsca co ten bat
  echo.
  start "" "%APPDATA%\MetaQuotes\Terminal"
  start "" "%SRC%"
  echo Otworzyłem dwa okna - folder danych MT5 i folder z plikami. Skopiuj 5 plikow .mq5/.mqh do Experts\MT5_XAU_Profit
)
echo.
pause
