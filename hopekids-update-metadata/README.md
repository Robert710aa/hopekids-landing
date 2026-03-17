# Aktualizacja metadanych HopeKids (HKD)

Skrypt aktualizuje metadane tokena na Solanie (nazwa, symbol, URI do JSON z Pinaty).

## Wymagania

- Node.js 18+
- Plik JSON z kluczem portfela, który jest **update authority** dla mintu `6u5PLy9ePpuGEBK3kmQ9isVDFjqSurKpvmCFzheDgQke`
- SOL na opłaty (kilka setek lamportów)

## Kroki

1. Otwórz terminal w tym folderze:
   ```bash
   cd hopekids-update-metadata
   ```

2. Zainstaluj zależności:
   ```bash
   npm install
   ```

3. Ustaw ścieżkę do pliku z kluczem (np. eksport z Phantom / Solana CLI):

   **PowerShell (Windows):**
   ```powershell
   $env:WALLET_PATH="C:\Users\Crypt\AppData\...\keypair.json"
   npm run update
   ```

   **CMD (Windows):**
   ```cmd
   set WALLET_PATH=C:\Users\Crypt\AppData\...\keypair.json
   npm run update
   ```

4. Zatwierdź w portfelu, jeśli skrypt o to poprosi (w tym skrypcie klucz jest z pliku, więc transakcja zostanie podpisana automatycznie).

Po sukcesie na Solscan (po 1–2 min) powinny być widoczne: **HopeKids**, **HKD** i logo.
