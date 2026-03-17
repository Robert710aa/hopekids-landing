# -*- coding: utf-8 -*-
"""WebSocket Binance Futures: aggTrade + bookTicker (opcjonalnie)."""
import asyncio
import json
import logging
from typing import Callable, Awaitable, List, Optional

import websockets
from websockets.exceptions import ConnectionClosed

from market_data.normalizer import normalize_binance_trade, normalize_binance_ticker
from models.events import NormalizedTrade, TickerEvent

logger = logging.getLogger("MultiExchangeBot.binance_ws")


def _binance_stream_url(ws_base: str, symbols: List[str], streams: List[str]) -> str:
    """Strumienie: aggTrade, bookTicker. Dla wielu symboli: combined stream."""
    if not symbols or not streams:
        return ws_base.rstrip("/")
    # combined: stream?streams=btcusdt@aggTrade/btcusdt@bookTicker
    parts = []
    for s in symbols:
        sym = s.lower()
        for st in streams:
            parts.append(f"{sym}@{st}")
    return f"{ws_base.rstrip('/')}/stream?streams={'/'.join(parts)}"


async def run_binance_ws(
    ws_base: str,
    symbols: List[str],
    on_trade: Optional[Callable[[NormalizedTrade], Awaitable[None]]] = None,
    on_ticker: Optional[Callable[[TickerEvent], Awaitable[None]]] = None,
    queue: Optional[asyncio.Queue] = None,
) -> None:
    """
    Pętla WS Binance Futures. Subskrybuje aggTrade i bookTicker.
    Zdarzenia: przekazuje do on_trade/on_ticker lub wrzuca do queue.
    """
    streams = ["aggTrade", "bookTicker"]
    url = _binance_stream_url(ws_base, symbols, streams)
    logger.info("Binance WS connecting to %s", url)
    backoff = 5
    while True:
        try:
            async with websockets.connect(url, ping_interval=60, ping_timeout=60, close_timeout=10) as ws:
                logger.info("Binance WS connected")
                backoff = 5
                async for msg in ws:
                    try:
                        data = json.loads(msg)
                        stream = data.get("stream", "")
                        ev = data.get("data", data)
                        if "aggTrade" in stream or ev.get("e") == "aggTrade":
                            t = normalize_binance_trade(ev, "binance")
                            if t:
                                if queue:
                                    await queue.put(("trade", t))
                                elif on_trade:
                                    await on_trade(t)
                        elif "bookTicker" in stream or ev.get("e") == "bookTicker":
                            tick = normalize_binance_ticker(ev, "binance")
                            if tick:
                                if queue:
                                    await queue.put(("ticker", tick))
                                elif on_ticker:
                                    await on_ticker(tick)
                    except Exception as e:
                        logger.debug("Binance parse error: %s", e)
        except ConnectionClosed as e:
            logger.warning("Binance WS closed: %s – reconnecting in %ss", e, backoff)
        except Exception as e:
            logger.exception("Binance WS error: %s", e)
        await asyncio.sleep(backoff)
        backoff = min(backoff * 2, 60)
