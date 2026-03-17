# -*- coding: utf-8 -*-
"""Konfiguracja Signal Hub – ścieżki, stałe, ładowanie .env."""
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# Plik sygnału dla EA (MT5 czyta z MQL5/Files – skopiuj tam lub ustaw tę samą ścieżkę)
SIGNAL_FILE_PATH = os.getenv("SIGNAL_FILE_PATH", str(Path(__file__).parent / "output" / "signal_xau.txt"))
SYMBOL = os.getenv("SYMBOL", "XAUUSD")

# API keys (opcjonalne – bez kluczy dane z tych źródeł są pomijane)
ALPHA_VANTAGE_API_KEY = os.getenv("ALPHA_VANTAGE_API_KEY", "")
TWELVE_DATA_API_KEY = os.getenv("TWELVE_DATA_API_KEY", "")
POLYGON_API_KEY = os.getenv("POLYGON_API_KEY", "")

# Port pod webhook (TradingView)
WEBHOOK_PORT = int(os.getenv("WEBHOOK_PORT", "8000"))
