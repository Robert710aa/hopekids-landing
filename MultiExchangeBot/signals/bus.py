# -*- coding: utf-8 -*-
"""
SignalBus: zbiera sygnały z detektorów (momentum, arbitraż), agreguje, TTL, throttling.
Format wyjścia: LONG/SHORT/NEUTRAL + strength (0–1) + timestamp – zgodny z MT5 i Execution.
"""
import time
import logging
from enum import Enum
from dataclasses import dataclass
from typing import Optional, List

from detectors.momentum import MomentumDetector, MomentumSignal
from detectors.anomaly import AnomalyDetector, AnomalySignal
from detectors.arbitrage import ArbitrageDetector, ArbitrageSignal
from features.engine import FeatureEngine

logger = logging.getLogger("MultiExchangeBot.signals")


class SignalDirection(str, Enum):
    LONG = "LONG"
    SHORT = "SHORT"
    NEUTRAL = "NEUTRAL"


@dataclass
class TradingSignal:
    direction: SignalDirection
    strength: float
    ts: int
    source: str = ""  # momentum, arbitrage, anomaly


class SignalBus:
    """Agreguje sygnały z detektorów, zwraca jeden sygnał (kierunek + siła) z TTL i throttlingiem."""

    def __init__(
        self,
        signal_ttl_sec: float = 60.0,
        min_interval_sec: float = 5.0,
        momentum_enabled: bool = True,
        anomaly_enabled: bool = True,
        arbitrage_enabled: bool = True,
    ):
        self.signal_ttl_sec = signal_ttl_sec
        self.min_interval_sec = min_interval_sec
        self._last_emit_ts = 0.0
        self._last_signal: Optional[TradingSignal] = None
        self.momentum = MomentumDetector() if momentum_enabled else None
        self.anomaly = AnomalyDetector() if anomaly_enabled else None
        self.arbitrage = ArbitrageDetector() if arbitrage_enabled else None

    def aggregate(
        self,
        fe: FeatureEngine,
        symbols: List[str],
        exchanges: List[str],
    ) -> Optional[TradingSignal]:
        """Uruchamia detektory, agreguje wyniki (na razie: pierwszy nie-NEUTRAL wygrywa)."""
        now = time.time()
        candidates: List[TradingSignal] = []

        for symbol in symbols:
            if self.momentum:
                m = self.momentum.check(fe, symbol)
                if m:
                    direction = SignalDirection.LONG if m.direction == "long" else SignalDirection.SHORT
                    candidates.append(TradingSignal(direction=direction, strength=m.strength, ts=int(now), source="momentum"))
            if self.anomaly:
                a = self.anomaly.check(fe, symbol)
                if a:
                    logger.debug("Anomaly %s z_score=%.2f (ostrzeżenie, bez sygnału NEUTRAL)", symbol, a.z_score)
            if self.arbitrage and len(exchanges) >= 2:
                arb = self.arbitrage.check(fe, symbol, exchanges)
                if arb:
                    # Arbitraż: kup na buy_exchange, sprzedaj na sell_exchange – sygnał LONG na symbol (uproszczenie)
                    candidates.append(TradingSignal(direction=SignalDirection.LONG, strength=min(0.99, arb.spread_pct / 1.0), ts=int(now), source="arbitrage"))

        if not candidates:
            return TradingSignal(direction=SignalDirection.NEUTRAL, strength=0.5, ts=int(now), source="")

        # Throttle
        if now - self._last_emit_ts < self.min_interval_sec and self._last_signal:
            return self._last_signal

        # Wybierz najsilniejszy nie-NEUTRAL, potem NEUTRAL
        long_short = [c for c in candidates if c.direction != SignalDirection.NEUTRAL]
        if long_short:
            best = max(long_short, key=lambda c: c.strength)
        else:
            best = candidates[0]
        self._last_emit_ts = now
        self._last_signal = best
        return best

    def format_for_mt5(self, sig: TradingSignal) -> str:
        """Linia pliku dla MT5/EA: LONG 0.75 1734567890"""
        return f"{sig.direction.value} {sig.strength:.2f} {sig.ts}\n"
