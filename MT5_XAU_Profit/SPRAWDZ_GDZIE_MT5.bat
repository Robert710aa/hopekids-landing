@echo off
chcp 65001 >nul
echo === Gdzie MT5 trzyma dane? ===
echo.

set "APPD=%APPDATA%\MetaQuotes\Terminal"
set "LOCAL=%LOCALAPPDATA%\MetaQuotes\Terminal"

echo Sprawdzam: %APPD%
if exist "%APPD%" (
  dir /b "%APPD%" 2>nul
  for /d %%D in ("%APPD%\*") do (
    if exist "%%D\MQL5\Experts" (echo   [OK] %%D\MQL5\Experts) else (echo   [brak MQL5\Experts] %%D)
  )
) else (
  echo   [NIE MA] tego folderu
)

echo.
echo Sprawdzam: %LOCAL%
if exist "%LOCAL%" (
  dir /b "%LOCAL%" 2>nul
  for /d %%D in ("%LOCAL%\*") do (
    if exist "%%D\MQL5\Experts" (echo   [OK] %%D\MQL5\Experts) else (echo   [brak MQL5\Experts] %%D)
  )
) else (
  echo   [NIE MA] tego folderu
)

echo.
echo === Jesli wszędzie [NIE MA] lub [brak MQL5\Experts] ===
echo W MT5: Plik - Otworz folder danych. Skopiuj pelna sciezke z paska adresu
echo i wklej ja tutaj w projekcie - wtedy da sie dopisac ta sciezke do skryptu.
echo.
pause
