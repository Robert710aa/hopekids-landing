$src = "c:\Users\Crypt\noktra-start-static\MT5_XAU_Profit"
$files = @("XAU_Profit_EA.mq5","XAU_Profit_Trade.mqh","XAU_Profit_Helpers.mqh","XAU_Profit_Indicators.mqh","XAU_Profit_Signals.mqh")

$paths = @(
  "$env:APPDATA\MetaQuotes\Terminal",
  "$env:LOCALAPPDATA\MetaQuotes\Terminal",
  "C:\Program Files\Libertex MetaTrader 5\MQL5\Experts",
  "C:\Program Files (x86)\Libertex MetaTrader 5\MQL5\Experts",
  "$env:USERPROFILE\Documents\MetaQuotes\Terminal",
  "$env:USERPROFILE\AppData\Roaming\MetaQuotes\Terminal",
  "$env:USERPROFILE\AppData\Local\MetaQuotes\Terminal"
)

$count = 0
foreach ($base in $paths) {
  if ($base -like "*Terminal*") {
    if (Test-Path $base) {
      Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $experts = Join-Path $_.FullName "MQL5\Experts"
        if (Test-Path $experts) {
          $tgt = Join-Path $experts "MT5_XAU_Profit"
          if (-not (Test-Path $tgt)) { New-Item -ItemType Directory -Path $tgt -Force }
          foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $tgt -Force -ErrorAction SilentlyContinue }
          Write-Host "OK: $tgt"
          $count++
        }
      }
    }
  } else {
    if (Test-Path $base) {
      $tgt = Join-Path $base "MT5_XAU_Profit"
      if (-not (Test-Path $tgt)) { New-Item -ItemType Directory -Path $tgt -Force }
      foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $tgt -Force -ErrorAction SilentlyContinue }
      Write-Host "OK: $tgt"
      $count++
    }
  }
}

Write-Host "`nSkopiowano do $count miejsc."
Write-Host "Teraz: zamknij MT5 i MetaEditor. Uruchom MT5. F4 = MetaEditor. Plik - Otworz - wejdz w MQL5 - Experts - MT5_XAU_Profit - otworz XAU_Profit_EA.mq5 - nacisnij F7. W MT5: Eksperci - prawy przycisk - Odswiez."
