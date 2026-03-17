$src = "c:\Users\Crypt\noktra-start-static\MT5_XAU_Profit"
$base = "c:\Users\Crypt\AppData\Roaming\MetaQuotes\Terminal"
if (-not (Test-Path $base)) { Write-Host "Nie znaleziono: $base"; exit 1 }
$files = @("XAU_Profit_EA.mq5","XAU_Profit_Trade.mqh","XAU_Profit_Helpers.mqh","XAU_Profit_Indicators.mqh","XAU_Profit_Signals.mqh")
$n = 0
Get-ChildItem $base -Directory | ForEach-Object {
  $experts = Join-Path $_.FullName "MQL5\Experts"
  if (Test-Path $experts) {
    $tgt = Join-Path $experts "MT5_XAU_Profit"
    if (-not (Test-Path $tgt)) { New-Item -ItemType Directory -Path $tgt -Force }
    foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $tgt -Force }
    Write-Host "OK: $tgt"
    $n++
  }
}
Write-Host "Skopiowano do $n folderow."
