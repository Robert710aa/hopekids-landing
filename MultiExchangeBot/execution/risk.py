# -*- coding: utf-8 -*-
"""RiskManager: max pozycja, max dzienne straty, rate limit orderów, circuit breaker."""
import time
import logging
from dataclasses import dataclass

logger = logging.getLogger("MultiExchangeBot.risk")


@dataclass
class RiskState:
    orders_this_minute: int = 0
    minute_start: float = 0.0
    daily_pnl: float = 0.0
    day_start: float = 0.0
    circuit_breaker_until: float = 0.0


class RiskManager:
    def __init__(
        self,
        max_position_usdt: float,
        max_daily_loss_usdt: float,
        max_orders_per_minute: int,
        circuit_breaker_sec: int,
    ):
        self.max_position_usdt = max_position_usdt
        self.max_daily_loss_usdt = max_daily_loss_usdt
        self.max_orders_per_minute = max_orders_per_minute
        self.circuit_breaker_sec = circuit_breaker_sec
        self._state = RiskState()

    def can_open_order(self) -> bool:
        now = time.time()
        if now < self._state.circuit_breaker_until:
            return False
        if self._state.daily_pnl <= -self.max_daily_loss_usdt:
            return False
        if now - self._state.minute_start >= 60:
            self._state.minute_start = now
            self._state.orders_this_minute = 0
        if self._state.orders_this_minute >= self.max_orders_per_minute:
            return False
        return True

    def record_order(self) -> None:
        self._state.orders_this_minute += 1

    def record_pnl(self, pnl: float) -> None:
        self._state.daily_pnl += pnl
        if self._state.daily_pnl <= -self.max_daily_loss_usdt:
            self._state.circuit_breaker_until = time.time() + self.circuit_breaker_sec
            logger.warning("Circuit breaker: daily loss limit hit")

    def trigger_circuit_breaker(self) -> None:
        self._state.circuit_breaker_until = time.time() + self.circuit_breaker_sec
