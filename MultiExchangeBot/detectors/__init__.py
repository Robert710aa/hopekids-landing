# -*- coding: utf-8 -*-
"""Detektory: momentum, anomaly (z-score), arbitraż cross-exchange."""
from .momentum import MomentumDetector
from .anomaly import AnomalyDetector
from .arbitrage import ArbitrageDetector

__all__ = ["MomentumDetector", "AnomalyDetector", "ArbitrageDetector"]
