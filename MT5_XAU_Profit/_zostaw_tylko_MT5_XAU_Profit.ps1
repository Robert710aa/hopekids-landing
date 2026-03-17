# Usuwa XAU_Profit z folderu Experts (root) i innych - zostawia TYLKO w Experts\MT5_XAU_Profit
$base = "c:\Users\Crypt\AppData\Roaming\MetaQuotes\Terminal"
$files = @("XAU_Profit_EA.mq5","XAU_Profit_Trade.mqh","XAU_Profit_Helpers.mqh","XAU_Profit_Indicators.mqh","XAU_Profit_Signals.mqh")

Get-ChildItem $base -Directory | ForEach-Object {
  $expertsPath = Join-Path $_.FullName "MQL5\Experts"
  if (-not (Test-Path $expertsPath)) { return }

  # Usun z glownego folderu Experts (nie w podfolderze)
  foreach ($f in $files) {
    $path = Join-Path $expertsPath $f
    if (Test-Path $path) {
      Remove-Item $path -Force
      Write-Host "Usunieto: $path"
    }
  }

  # Szukaj tych plikow w podfolderach OPROCZ MT5_XAU_Profit - usun
  Get-ChildItem $expertsPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -in $files -and $_.DirectoryName -notlike "*MT5_XAU_Profit*"
  } | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "Usunieto: $($_.FullName)"
  }
}

Write-Host "Gotowe. Zostal tylko Experts\MT5_XAU_Profit\"
