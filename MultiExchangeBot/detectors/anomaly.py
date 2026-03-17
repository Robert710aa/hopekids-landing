# -*- coding: utf-8 -*-
"""Detektor anomalii: z-score ceny / volume delta (EWMA + std)."""
import logging
from dataclasses import dataclass
from typing import Optional

from features.engine import FeatureEngine, SymbolFeatures

logger = logging.getLogger("MultiExchangeBot.detectors")


@dataclass
class AnomalySignal:
    symbol: str
    z_score: float
    is_high: bool  # true = anomalia w górę (może redukcja size / alert)


class AnomalyDetector:
    """Anomalia gdy |z-score| > threshold. Używa ostatnich N cen."""

    def __init__(self, window: int = 50, z_threshold: float = 2.5):
        self.window = window
        self.z_threshold = z_threshold

    def check(self, fe: FeatureEngine, symbol: str) -> Optional[AnomalySignal]:
        f = fe.get_features(symbol)
        if not f or len(f.prices) < self.window:
            return None
        arr = list(f.prices)[-self.window:]
        mean = sum(arr) / len(arr)
        var = sum((x - mean) ** 2 for x in arr) / len(arr)
        std = (var / len(arr)) ** 0.5
        if std <= 0:
            return None
        last = arr[-1]
        z = (last - mean) / std
        if abs(z) >= self.z_threshold:
            return AnomalySignal(symbol=symbol, z_score=z, is_high=(z > 0))
        return None
