# -*- coding: utf-8 -*-
"""Detektor arbitrażu: spread mid między giełdami > threshold (po opłatach)."""
import logging
from dataclasses import dataclass
from typing import Dict, Optional

from features.engine import FeatureEngine

logger = logging.getLogger("MultiExchangeBot.detectors")


@dataclass
class ArbitrageSignal:
    symbol: str
    buy_exchange: str
    sell_exchange: str
    spread_pct: float
    mid_buy: float
    mid_sell: float


class ArbitrageDetector:
    """Arbitraż gdy spread (mid_A - mid_B) w % > threshold (uwzgl. prowizję)."""

    def __init__(self, spread_pct_threshold: float = 0.1, fee_pct: float = 0.04):
        self.spread_pct_threshold = spread_pct_threshold
        self.fee_pct = fee_pct

    def check(self, fe: FeatureEngine, symbol: str, exchanges: list) -> Optional[ArbitrageSignal]:
        mids: Dict[str, float] = {}
        for ex in exchanges:
            f = fe.get_features(symbol, exchange=ex)
            if f and f.mid > 0:
                mids[ex] = f.mid
        if len(mids) < 2:
            return None
        pairs = list(mids.items())
        for i in range(len(pairs)):
            for j in range(i + 1, len(pairs)):
                ex_a, mid_a = pairs[i]
                ex_b, mid_b = pairs[j]
                # Kupować tam gdzie taniej, sprzedawać tam gdzie drożej
                if mid_a < mid_b:
                    buy_ex, sell_ex = ex_a, ex_b
                    mid_buy, mid_sell = mid_a, mid_b
                else:
                    buy_ex, sell_ex = ex_b, ex_a
                    mid_buy, mid_sell = mid_b, mid_a
                spread_pct = (mid_sell - mid_buy) / mid_buy * 100.0 - 2 * self.fee_pct
                if spread_pct >= self.spread_pct_threshold:
                    return ArbitrageSignal(
                        symbol=symbol,
                        buy_exchange=buy_ex,
                        sell_exchange=sell_ex,
                        spread_pct=spread_pct,
                        mid_buy=mid_buy,
                        mid_sell=mid_sell,
                    )
        return None
