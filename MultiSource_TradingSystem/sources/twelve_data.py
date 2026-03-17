# -*- coding: utf-8 -*-
"""Twelve Data – ceny, RSI dla XAU/USD. Zwraca LONG/SHORT/NEUTRAL + siła 0–1."""
import os
from typing import Tuple, Optional
import requests

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from aggregator import SignalDirection

API_KEY = os.getenv("TWELVE_DATA_API_KEY", "")
# Twelve Data: symbol np. XAU/USD lub GOLD
SYMBOL_TD = os.getenv("TWELVE_DATA_SYMBOL", "XAU/USD")


def fetch_signal() -> Optional[Tuple[SignalDirection, float]]:
    if not API_KEY:
        return None
    try:
        # RSI endpoint
        url = "https://api.twelvedata.com/rsi"
        params = {
            "symbol": SYMBOL_TD,
            "interval": "1day",
            "time_period": 14,
            "apikey": API_KEY,
        }
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        data = r.json()
        rsi_val = float(data.get("values", [{}])[0].get("rsi", 50))
        if rsi_val < 35:
            strength = 0.5 + (35 - rsi_val) / 70.0
            return SignalDirection.LONG, min(0.95, round(strength, 2))
        if rsi_val > 65:
            strength = 0.5 + (rsi_val - 65) / 70.0
            return SignalDirection.SHORT, min(0.95, round(strength, 2))
        return SignalDirection.NEUTRAL, 0.5
    except Exception:
        try:
            # Fallback: time_series – trend z ostatnich zamknięć
            url = "https://api.twelvedata.com/time_series"
            params = {
                "symbol": SYMBOL_TD,
                "interval": "1day",
                "outputsize": 10,
                "apikey": API_KEY,
            }
            r = requests.get(url, params=params, timeout=10)
            r.raise_for_status()
            data = r.json()
            values = data.get("values", [])
            if len(values) < 5:
                return None
            closes = [float(v["close"]) for v in values[:5]]
            recent = closes[0]
            older = sum(closes[1:]) / (len(closes) - 1)
            if recent > older * 1.002:
                return SignalDirection.LONG, 0.55
            if recent < older * 0.998:
                return SignalDirection.SHORT, 0.55
        except Exception:
            pass
        return None
