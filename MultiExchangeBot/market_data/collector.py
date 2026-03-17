# -*- coding: utf-8 -*-
"""
MarketDataCollector: uruchamia WS dla każdej giełdy i wrzuca znormalizowane eventy do kolejki.
Konsumować w FeatureEngine.
"""
import asyncio
import logging
from typing import List, Optional

from models.events import NormalizedTrade, TickerEvent

logger = logging.getLogger("MultiExchangeBot.collector")


class MarketDataCollector:
    """Uruchamia konektory WS (Binance, Bybit) i przekazuje eventy do asyncio.Queue."""

    def __init__(
        self,
        exchanges: List[str],
        symbols: List[str],
        exchange_configs: dict,
        event_queue: Optional[asyncio.Queue] = None,
    ):
        self.exchanges = exchanges
        self.symbols = symbols
        self.exchange_configs = exchange_configs
        self.event_queue = event_queue or asyncio.Queue(maxsize=100_000)
        self._tasks: List[asyncio.Task] = []

    async def start(self) -> None:
        """Uruchamia jedną taskę WS per giełdę."""
        from .binance_ws import run_binance_ws
        from .bybit_ws import run_bybit_ws

        for ex in self.exchanges:
            cfg = self.exchange_configs.get(ex)
            if not cfg or not cfg.ws_base:
                logger.warning("No WS config for %s, skip", ex)
                continue
            if ex == "binance":
                t = asyncio.create_task(
                    run_binance_ws(cfg.ws_base, self.symbols, queue=self.event_queue)
                )
            elif ex == "bybit":
                t = asyncio.create_task(
                    run_bybit_ws(cfg.ws_base, self.symbols, queue=self.event_queue)
                )
            else:
                continue
            self._tasks.append(t)
        logger.info("MarketDataCollector started %d WS tasks", len(self._tasks))

    async def stop(self) -> None:
        for t in self._tasks:
            t.cancel()
        await asyncio.gather(*self._tasks, return_exceptions=True)
        self._tasks.clear()

    def get_queue(self) -> asyncio.Queue:
        return self.event_queue
