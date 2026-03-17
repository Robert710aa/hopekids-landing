# -*- coding: utf-8 -*-
"""
Feature engine: z kolejki trade/ticker buduje okna czasowe i liczy:
- returns (ROC), volatility (np. std), volume delta (buy - sell), book imbalance.
"""
import collections
import logging
import time
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Deque

from models.events import NormalizedTrade, TickerEvent

logger = logging.getLogger("MultiExchangeBot.features")


@dataclass
class SymbolFeatures:
    """Feature'y dla jednego symbolu (np. BTCUSDT) – ostatnie okno."""
    symbol: str
    # Ostatnie ceny (do ROC)
    prices: Deque[float] = field(default_factory=lambda: collections.deque(maxlen=200))
    # Volume buy/sell w oknie
    vol_buy: float = 0.0
    vol_sell: float = 0.0
    last_ts: float = 0.0
    # Ostatni mid (ticker)
    mid: float = 0.0
    spread: float = 0.0

    def add_trade(self, price: float, size: float, side: str, ts: float) -> None:
        self.prices.append(price)
        self.last_ts = ts
        if side == "buy":
            self.vol_buy += size
        else:
            self.vol_sell += size

    def add_ticker(self, bid: float, ask: float, ts: float) -> None:
        self.mid = (bid + ask) / 2.0 if (bid and ask) else self.mid
        self.spread = ask - bid if (bid and ask) else 0.0
        self.last_ts = ts

    def roc(self, period: int = 10) -> float:
        """Rate of change (period barów)."""
        if len(self.prices) < period + 1:
            return 0.0
        p0 = list(self.prices)[-(period + 1)]
        p1 = list(self.prices)[-1]
        if p0 <= 0:
            return 0.0
        return (p1 - p0) / p0

    def volatility(self, period: int = 20) -> float:
        """Odchylenie std cen w oknie."""
        if len(self.prices) < period:
            return 0.0
        arr = list(self.prices)[-period:]
        mean = sum(arr) / len(arr)
        var = sum((x - mean) ** 2 for x in arr) / len(arr)
        return var ** 0.5

    def volume_delta(self) -> float:
        """vol_buy - vol_sell (w oknie)."""
        return self.vol_buy - self.vol_sell

    def reset_window(self) -> None:
        """Reset okna (np. co 60s)."""
        self.vol_buy = 0.0
        self.vol_sell = 0.0


class FeatureEngine:
    """Utrzymuje stan per symbol, aktualizuje z trade/ticker, udostępnia feature'y."""

    def __init__(self, window_sec: float = 60.0):
        self._by_symbol: Dict[str, SymbolFeatures] = {}
        self._window_sec = window_sec
        self._last_reset = time.time()

    def update_trade(self, t: NormalizedTrade) -> None:
        key = f"{t.exchange}:{t.symbol}"
        if key not in self._by_symbol:
            self._by_symbol[key] = SymbolFeatures(symbol=t.symbol)
        self._by_symbol[key].add_trade(t.price, t.size, t.side, t.ts)

    def update_ticker(self, tick: TickerEvent) -> None:
        key = f"{tick.exchange}:{tick.symbol}"
        if key not in self._by_symbol:
            self._by_symbol[key] = SymbolFeatures(symbol=tick.symbol)
        self._by_symbol[key].add_ticker(tick.bid, tick.ask, tick.ts)

    def maybe_reset_windows(self) -> None:
        now = time.time()
        if now - self._last_reset >= self._window_sec:
            for f in self._by_symbol.values():
                f.reset_window()
            self._last_reset = now

    def get_features(self, symbol: str, exchange: Optional[str] = None) -> Optional[SymbolFeatures]:
        """Zwraca feature'y dla symbolu (np. BTCUSDT). Jeśli exchange podany, klucz exchange:symbol."""
        if exchange:
            key = f"{exchange}:{symbol}"
            return self._by_symbol.get(key)
        for k, v in self._by_symbol.items():
            if k.endswith(f":{symbol}"):
                return v
        return None

    def all_symbols(self) -> List[str]:
        seen = set()
        for k in self._by_symbol:
            sym = k.split(":")[-1]
            seen.add(sym)
        return list(seen)
