# -*- coding: utf-8 -*-
"""WebSocket Bybit V5 Linear: trade + tickers."""
import asyncio
import json
import logging
from typing import Callable, Awaitable, List, Optional

import websockets
from websockets.exceptions import ConnectionClosed

from market_data.normalizer import normalize_bybit_trade, normalize_bybit_ticker
from models.events import NormalizedTrade, TickerEvent

logger = logging.getLogger("MultiExchangeBot.bybit_ws")


def _bybit_ws_url(ws_base: str) -> str:
    return ws_base.rstrip("/")


async def run_bybit_ws(
    ws_base: str,
    symbols: List[str],
    on_trade: Optional[Callable[[NormalizedTrade], Awaitable[None]]] = None,
    on_ticker: Optional[Callable[[TickerEvent], Awaitable[None]]] = None,
    queue: Optional[asyncio.Queue] = None,
) -> None:
    """
    Bybit V5 Linear: subskrypcja trade + tickers.
    """
    url = _bybit_ws_url(ws_base)
    # Subskrypcja: {"op":"subscribe","args":["publicLinear.BTCUSDT.trade","publicLinear.BTCUSDT.tickers"]}
    args = []
    for s in symbols:
        args.append(f"publicLinear.{s}.trade")
        args.append(f"publicLinear.{s}.tickers")
    sub = json.dumps({"op": "subscribe", "args": args})
    logger.info("Bybit WS connecting to %s", url)
    backoff = 5
    while True:
        try:
            async with websockets.connect(url, ping_interval=60, ping_timeout=60, close_timeout=10) as ws:
                logger.info("Bybit WS connected")
                backoff = 5
                await ws.send(sub)
                async for msg in ws:
                    try:
                        data = json.loads(msg)
                        topic = data.get("topic", "")
                        if "trade" in topic:
                            t = normalize_bybit_trade(data, "bybit")
                            if t:
                                if queue:
                                    await queue.put(("trade", t))
                                elif on_trade:
                                    await on_trade(t)
                        elif "tickers" in topic:
                            tick = normalize_bybit_ticker(data, "bybit")
                            if tick:
                                if queue:
                                    await queue.put(("ticker", tick))
                                elif on_ticker:
                                    await on_ticker(tick)
                    except Exception as e:
                        logger.debug("Bybit parse error: %s", e)
        except ConnectionClosed as e:
            logger.warning("Bybit WS closed: %s – reconnecting in %ss", e, backoff)
        except Exception as e:
            logger.exception("Bybit WS error: %s", e)
        await asyncio.sleep(backoff)
        backoff = min(backoff * 2, 60)
