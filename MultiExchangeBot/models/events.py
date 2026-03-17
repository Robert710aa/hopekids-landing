# -*- coding: utf-8 -*-
"""
Zunifikowane zdarzenia rynkowe z dowolnej giełdy.
Używane przez MarketDataCollectors i FeatureEngine.
"""
from dataclasses import dataclass, field
from enum import Enum
from typing import Optional, List
import time


class EventType(str, Enum):
    TRADE = "trade"
    BOOK = "book"
    TICKER = "ticker"


@dataclass
class MarketEvent:
    """Bazowe zdarzenie: exchange, symbol, typ, timestamp."""
    exchange: str
    symbol: str
    event_type: EventType
    ts: float = field(default_factory=time.time)


@dataclass
class TradeEvent(MarketEvent):
    """Pojedynczy trade (tick)."""
    price: float = 0.0
    size: float = 0.0
    side: str = ""  # buy / sell
    trade_id: str = ""
    event_type: EventType = field(default=EventType.TRADE, init=False)


@dataclass
class BookLevel:
    """Jedna warstwa order book (price, size)."""
    price: float
    size: float


@dataclass
class BookSnapshot(MarketEvent):
    """Snapshot order book (bid/ask)."""
    bids: List[BookLevel] = field(default_factory=list)
    asks: List[BookLevel] = field(default_factory=list)
    event_type: EventType = field(default=EventType.BOOK, init=False)


@dataclass
class TickerEvent(MarketEvent):
    """Best bid/ask (np. z bookTicker)."""
    bid: float = 0.0
    ask: float = 0.0
    bid_size: float = 0.0
    ask_size: float = 0.0
    last_price: float = 0.0
    event_type: EventType = field(default=EventType.TICKER, init=False)


@dataclass
class NormalizedTrade:
    """Zunifikowany trade do feature engine: exchange, symbol, price, size, side, ts."""
    exchange: str
    symbol: str
    price: float
    size: float
    side: str  # "buy" | "sell"
    ts: float
