# Multi-Source Trading Signal Hub

System zbiera sygnały z wielu źródeł (TradingView webhook, Alpha Vantage, Twelve Data, Polygon, Binance, Coinbase, COT Report) i zapisuje **jeden sygnał** do pliku, który **XAU_Profit_EA** w MT5 może czytać i używać do wsparcia decyzji (kupno/sprzedaż XAU).

## Szybki start

1. **Środowisko**
   ```bash
   cd MultiSource_TradingSystem
   python -m venv venv
   venv\Scripts\activate   # Windows
   pip install -r requirements.txt
   ```

2. **Konfiguracja**
   - Skopiuj `.env.example` do `.env`.
   - Ustaw `SIGNAL_FILE_PATH` na ścieżkę w folderze **MT5 → MQL5 → Files** (np. `C:\Users\...\AppData\Roaming\MetaQuotes\Terminal\...\MQL5\Files\signal_xau.txt`), żeby EA miał dostęp do pliku.

3. **Uruchomienie**
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

4. **TradingView**
   - W alertach ustaw Webhook URL: `http://TWOJ_IP:8000/webhook/tradingview`.
   - Body (opcjonalnie): `{"direction": "long", "strength": 0.8}`.

5. **EA (MT5)**
   - Skopiuj plik sygnału do folderu **MQL5/Files** (np. `signal_xau.txt`) albo ustaw w Signal Hub `SIGNAL_FILE_PATH` na ten folder.
   - W XAU_Profit_EA włącz **InpUseExternalSignal = true** i ustaw **InpExternalSignalFile = "signal_xau.txt"** (nazwa pliku w MQL5/Files).
   - Bot: gdy plik mówi LONG – nie otwiera Short; gdy plik mówi SHORT – nie otwiera Long. Świeca (zielona/czerwona) nadal decyduje o momencie wejścia; plik tylko blokuje wejście pod prąd.

## Architektura

Zobacz [ARCHITECTURE.md](ARCHITECTURE.md) – źródła, przepływ, fazy wdrożenia (TradingView → API rynkowe → COT → integracja z EA).

## Klucze API (opcjonalnie)

- **Alpha Vantage:** https://www.alphavantage.co/support/#api-key  
- **Twelve Data:** https://twelvedata.com/  
- **Polygon.io:** https://polygon.io/  

Bez kluczy działa tylko webhook TradingView i ręczny POST `/signal`.
