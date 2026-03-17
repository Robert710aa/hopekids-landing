# -*- coding: utf-8 -*-
"""ExecutionEngine: odbiera sygnały, w dry_run tylko loguje, w testnet/prod wysyła zlecenia (placeholder)."""
import logging
from typing import Optional

from signals.bus import TradingSignal, SignalDirection
from .risk import RiskManager

logger = logging.getLogger("MultiExchangeBot.execution")


class ExecutionEngine:
    """Na razie: loguje sygnał i sprawdza RiskManager. Pełna integracja z API giełd w kolejnym kroku."""

    def __init__(self, mode: str, risk: RiskManager):
        self.mode = mode
        self.risk = risk

    def execute(self, signal: TradingSignal, symbol: str) -> bool:
        if signal.direction == SignalDirection.NEUTRAL:
            return True
        if not self.risk.can_open_order():
            logger.warning("Execution blocked by risk manager")
            return False
        if self.mode == "dry_run":
            logger.info("DRY-RUN: would open %s %s strength=%.2f", signal.direction.value, symbol, signal.strength)
            self.risk.record_order()
            return True
        if self.mode in ("testnet", "prod"):
            # TODO: real order placement via exchange API
            logger.info("LIVE: would place order %s %s (not implemented yet)", signal.direction.value, symbol)
            self.risk.record_order()
            return True
        return False
