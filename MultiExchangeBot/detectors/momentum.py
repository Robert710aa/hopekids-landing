# -*- coding: utf-8 -*-
"""Detektor momentum: ROC przekracza próg + filtr zmienności."""
import logging
from dataclasses import dataclass
from typing import Optional

from features.engine import FeatureEngine, SymbolFeatures

logger = logging.getLogger("MultiExchangeBot.detectors")


@dataclass
class MomentumSignal:
    symbol: str
    direction: str  # "long" | "short"
    strength: float
    roc: float
    volatility: float


class MomentumDetector:
    """Sygnał gdy |ROC| > threshold i volatility w zakresie."""

    def __init__(
        self,
        roc_threshold: float = 0.002,
        min_volatility: float = 0.0,
        max_volatility: float = 1e9,
        roc_period: int = 10,
    ):
        self.roc_threshold = roc_threshold
        self.min_volatility = min_volatility
        self.max_volatility = max_volatility
        self.roc_period = roc_period

    def check(self, fe: FeatureEngine, symbol: str) -> Optional[MomentumSignal]:
        f = fe.get_features(symbol)
        if not f or len(f.prices) < self.roc_period + 1:
            return None
        roc = f.roc(self.roc_period)
        vol = f.volatility(self.roc_period)
        if vol < self.min_volatility or vol > self.max_volatility:
            return None
        if roc >= self.roc_threshold:
            strength = min(0.99, (roc - self.roc_threshold) / 0.01)
            return MomentumSignal(symbol=symbol, direction="long", strength=strength, roc=roc, volatility=vol)
        if roc <= -self.roc_threshold:
            strength = min(0.99, (-roc - self.roc_threshold) / 0.01)
            return MomentumSignal(symbol=symbol, direction="short", strength=strength, roc=roc, volatility=vol)
        return None
