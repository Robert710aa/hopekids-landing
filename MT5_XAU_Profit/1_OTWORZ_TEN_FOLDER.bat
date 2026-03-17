@echo off
:: Otwiera ten folder + liste w Notepadzie (obok), zeby okno sie nie zgubilo
start "" "%~dp0"
start notepad "%~dp0LISTA_5_PLIKOW_DO_SKOPIU.txt"
echo.
echo Folder i lista (Notepad) otwarte. Jesli zamkniesz to okno - lista zostanie w Notepadzie.
echo.
echo 1. W MetaEditorze: Plik - Otworz folder danych, wejdz: MQL5 - Experts
echo 2. W folderze zaznacz 5 plikow (Ctrl+A), skopiuj (Ctrl+C), wklej w Experts (Ctrl+V)
echo.
pause
