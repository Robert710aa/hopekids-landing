# -*- coding: utf-8 -*-
"""Alpha Vantage – ceny, trend, RSI dla XAU/forex. Zwraca LONG/SHORT/NEUTRAL + siła 0–1."""
import os
from typing import Tuple, Optional
import requests

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from aggregator import SignalDirection

API_KEY = os.getenv("ALPHA_VANTAGE_API_KEY", "")
# Alpha Vantage: XAUUSD = "XAU", lub GOLD (commodity). Forex: FX_DAILY np. "XAU" nie zawsze – używamy GOLD
SYMBOL_AV = os.getenv("ALPHA_VANTAGE_SYMBOL", "GOLD")  # lub XAUUSD w zależności od API


def _rsi(prices: list, period: int = 14) -> float:
    if len(prices) < period + 1:
        return 50.0
    gains, losses = [], []
    for i in range(len(prices) - period, len(prices) - 1):
        ch = prices[i + 1] - prices[i]
        gains.append(ch if ch > 0 else 0)
        losses.append(-ch if ch < 0 else 0)
    avg_gain = sum(gains) / period
    avg_loss = sum(losses) / period
    if avg_loss == 0:
        return 100.0
    rs = avg_gain / avg_loss
    return 100.0 - (100.0 / (1.0 + rs))


def fetch_signal() -> Optional[Tuple[SignalDirection, float]]:
    if not API_KEY:
        return None
    try:
        url = "https://www.alphavantage.co/query"
        params = {
            "function": "FX_DAILY",
            "from_symbol": "XAU",
            "to_symbol": "USD",
            "apikey": API_KEY,
            "outputsize": "compact",
        }
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        data = r.json()
        series = data.get("Time Series FX (Daily)", data.get("Time Series (Daily)", {}))
        if not series:
            return None
        dates = sorted(series.keys(), reverse=True)
        closes = [float(series[d].get("4. close", series[d].get("5. close", 0))) for d in dates[:30]]
        if len(closes) < 15:
            return None
        rsi_val = _rsi(closes, 14)
        # RSI < 30 = oversold → LONG, RSI > 70 = overbought → SHORT
        if rsi_val < 35:
            strength = 0.5 + (35 - rsi_val) / 70.0
            return SignalDirection.LONG, min(0.95, strength)
        if rsi_val > 65:
            strength = 0.5 + (rsi_val - 65) / 70.0
            return SignalDirection.SHORT, min(0.95, strength)
        # Trend: ostatnie 5 vs poprzednie 5
        recent = sum(closes[:5]) / 5
        older = sum(closes[5:10]) / 5
        if recent > older * 1.002:
            return SignalDirection.LONG, 0.55
        if recent < older * 0.998:
            return SignalDirection.SHORT, 0.55
        return SignalDirection.NEUTRAL, 0.5
    except Exception:
        return None
