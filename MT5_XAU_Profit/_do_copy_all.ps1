$src = "c:\Users\Crypt\noktra-start-static\MT5_XAU_Profit"
$base = "c:\Users\Crypt\AppData\Roaming\MetaQuotes\Terminal"
$files = @("XAU_Profit_EA.mq5","XAU_Profit_Trade.mqh","XAU_Profit_Helpers.mqh","XAU_Profit_Indicators.mqh","XAU_Profit_Signals.mqh")

# 1) Copy to MT5_XAU_Profit (as before)
Get-ChildItem $base -Directory | ForEach-Object {
  $experts = Join-Path $_.FullName "MQL5\Experts"
  if (Test-Path $experts) {
    $tgt = Join-Path $experts "MT5_XAU_Profit"
    if (-not (Test-Path $tgt)) { New-Item -ItemType Directory -Path $tgt -Force }
    foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $tgt -Force -ErrorAction SilentlyContinue }
    Write-Host "OK: $tgt"
  }
}

# 2) Copy to Free Robots (where MetaEditor is opening from)
Get-ChildItem $base -Directory | ForEach-Object {
  $freeRobots = Join-Path $_.FullName "MQL5\Experts\Advisors\Examples\Free Robots"
  if (Test-Path $freeRobots) {
    foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $freeRobots -Force -ErrorAction SilentlyContinue }
    Write-Host "OK Free Robots: $freeRobots"
  }
}

# 3) Any folder under Experts that contains XAU_Profit_EA.mq5 - overwrite there too
Get-ChildItem $base -Directory | ForEach-Object {
  $expertsPath = Join-Path $_.FullName "MQL5\Experts"
  if (-not (Test-Path $expertsPath)) { return }
  Get-ChildItem $expertsPath -Recurse -Filter "XAU_Profit_EA.mq5" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $dir = $_.DirectoryName
    foreach ($f in $files) { Copy-Item (Join-Path $src $f) -Destination $dir -Force -ErrorAction SilentlyContinue }
    Write-Host "OK (znaleziono): $dir"
  }
}

Write-Host "Koniec."
