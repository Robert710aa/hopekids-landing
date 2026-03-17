@echo off
chcp 65001 >nul
set "SRC=c:\Users\Crypt\noktra-start-static\MT5_XAU_Profit"
set "TGT=%~dp0"
echo Kopiuje poprawione pliki z Cursor do tego folderu...
echo.
copy /Y "%SRC%\XAU_Profit_EA.mq5" "%TGT%"
copy /Y "%SRC%\XAU_Profit_Trade.mqh" "%TGT%"
copy /Y "%SRC%\XAU_Profit_Helpers.mqh" "%TGT%"
copy /Y "%SRC%\XAU_Profit_Indicators.mqh" "%TGT%"
copy /Y "%SRC%\XAU_Profit_Signals.mqh" "%TGT%"
echo.
echo Gotowe. W MetaEditorze nacisnij F7.
pause
