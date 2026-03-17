# -*- coding: utf-8 -*-
"""Normalizacja surowych wiadomości WS z giełd do zunifikowanych eventów."""
import time
from typing import Optional, Any

from models.events import NormalizedTrade, TickerEvent


def normalize_binance_trade(raw: dict, exchange: str = "binance") -> Optional[NormalizedTrade]:
    """
    Binance Futures: aggTrade lub trade.
    aggTrade: e=aggTrade, p=price, q=qty, m=buyer_maker (true = sell).
    """
    if not raw:
        return None
    price = float(raw.get("p", raw.get("p", 0)))
    qty = float(raw.get("q", raw.get("q", 0)))
    if not price or not qty:
        return None
    # buyer_maker true => sell (maker was buyer)
    is_sell = raw.get("m", raw.get("m", False))
    side = "sell" if is_sell else "buy"
    ts = float(raw.get("T", raw.get("E", time.time() * 1000))) / 1000.0
    symbol = raw.get("s", "")
    return NormalizedTrade(exchange=exchange, symbol=symbol, price=price, size=qty, side=side, ts=ts)


def normalize_bybit_trade(raw: dict, exchange: str = "bybit") -> Optional[NormalizedTrade]:
    """
    Bybit V5: topic publicLinear.<symbol>, data.list[]: price, size, side, time.
    """
    if not raw:
        return None
    data = raw.get("data", raw)
    if isinstance(data, dict) and "list" in data:
        lst = data["list"]
        if not lst:
            return None
        t = lst[0]
        price = float(t.get("price", 0))
        size = float(t.get("size", 0))
        side = str(t.get("side", "")).lower()
        ts_ms = int(t.get("time", 0))
        ts = ts_ms / 1000.0 if ts_ms else time.time()
        symbol = data.get("symbol", raw.get("topic", "").split(".")[-1] if isinstance(raw.get("topic"), str) else "")
    else:
        price = float(data.get("price", 0))
        size = float(data.get("size", 0))
        side = str(data.get("side", "")).lower()
        ts = float(data.get("time", time.time() * 1000)) / 1000.0
        symbol = data.get("symbol", "")
    if not price or not size:
        return None
    return NormalizedTrade(exchange=exchange, symbol=symbol, price=price, size=size, side=side, ts=ts)


def normalize_binance_ticker(raw: dict, exchange: str = "binance") -> Optional[TickerEvent]:
    """Binance: bookTicker – b=best bid, a=best ask, B=bid qty, A=ask qty."""
    if not raw:
        return None
    s = raw.get("s", "")
    bid = float(raw.get("b", 0))
    ask = float(raw.get("a", 0))
    bid_size = float(raw.get("B", 0))
    ask_size = float(raw.get("A", 0))
    return TickerEvent(
        exchange=exchange,
        symbol=s,
        bid=bid,
        ask=ask,
        bid_size=bid_size,
        ask_size=ask_size,
        last_price=float(raw.get("a", 0)),
        ts=float(raw.get("E", time.time() * 1000)) / 1000.0,
    )


def normalize_bybit_ticker(raw: dict, exchange: str = "bybit") -> Optional[TickerEvent]:
    """Bybit V5 tickers: bid1Price, ask1Price, lastPrice."""
    if not raw:
        return None
    data = raw.get("data", raw)
    symbol = data.get("symbol", "")
    bid = float(data.get("bid1Price", data.get("bid", 0)))
    ask = float(data.get("ask1Price", data.get("ask", 0)))
    last = float(data.get("lastPrice", ask))
    ts_ms = int(data.get("ts", 0))
    ts = ts_ms / 1000.0 if ts_ms else time.time()
    return TickerEvent(
        exchange=exchange,
        symbol=symbol,
        bid=bid,
        ask=ask,
        bid_size=0,
        ask_size=0,
        last_price=last,
        ts=ts,
    )
