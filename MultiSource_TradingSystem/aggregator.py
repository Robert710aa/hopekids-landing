# -*- coding: utf-8 -*-
"""
Agregator sygnałów z wielu źródeł → jeden sygnał LONG/SHORT/NEUTRAL + siła 0–1.
Na razie: placeholder – można dodać wagi i logikę (np. średnia, voting).
"""
from enum import Enum
from typing import List, Tuple

class SignalDirection(str, Enum):
    LONG = "LONG"
    SHORT = "SHORT"
    NEUTRAL = "NEUTRAL"

def aggregate_signals(signals: List[Tuple[SignalDirection, float]]) -> Tuple[SignalDirection, float]:
    """
    signals: lista (kierunek, siła 0–1).
    Zwraca: (kierunek, siła 0–1).
    """
    if not signals:
        return SignalDirection.NEUTRAL, 0.5

    long_score = sum(s for d, s in signals if d == SignalDirection.LONG)
    short_score = sum(s for d, s in signals if d == SignalDirection.SHORT)
    neutral_score = sum(s for d, s in signals if d == SignalDirection.NEUTRAL)

    if long_score > short_score and long_score > neutral_score:
        strength = min(0.99, long_score / max(len(signals), 1))
        return SignalDirection.LONG, round(strength, 2)
    if short_score > long_score and short_score > neutral_score:
        strength = min(0.99, short_score / max(len(signals), 1))
        return SignalDirection.SHORT, round(strength, 2)
    return SignalDirection.NEUTRAL, 0.5
