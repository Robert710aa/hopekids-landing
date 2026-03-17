# Multi-Exchange Bot (AI + Market Scanner + Execution)

System pobiera dane z wielu giełd crypto w czasie rzeczywistym (WebSocket), wykrywa **momentum**, **anomalie** (z-score) i **arbitraż** cross-exchange, agreguje sygnały i w trybie **dry_run** loguje, w **testnet/prod** może wysyłać zlecenia. Opcjonalnie zapisuje sygnał do pliku MT5 (format jak Signal Hub).

## Uruchomienie

- **Windows:** dwuklik `Uruchom_Bot.bat` (tworzy venv przy pierwszym uruchomieniu).
- **Ręcznie:**
```bash
cd MultiExchangeBot
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# Skopiuj .env.example do .env
python run.py
```

## Tryby (.env: BOT_MODE)

- **dry_run** – tylko logi, brak wysyłki zleceń (domyślny).
- **testnet** – API testnet (Binance Futures Testnet, Bybit Testnet).
- **prod** – produkcja (użyj po walidacji na testnecie).

## Architektura

MarketData (Binance + Bybit WS) → FeatureEngine (ceny, volume delta, ROC, volatility) → Detectors (momentum, anomaly, arbitrage) → SignalBus → ExecutionEngine + opcjonalnie MT5 writer.

## API (opcjonalnie)

Do uruchomienia osobno: `uvicorn api.app:app --host 127.0.0.1 --port 8001` – endpointy `/health`, `/status`.
