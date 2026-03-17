# -*- coding: utf-8 -*-
"""Zapisuje linię sygnału do pliku w formacie LONG 0.75 1734567890 (EA czyta z Common/Files)."""
import logging
from pathlib import Path
from typing import Optional

from signals.bus import TradingSignal

logger = logging.getLogger("MultiExchangeBot.mt5_bridge")


def write_mt5_signal(signal: TradingSignal, file_path: str) -> None:
    if not file_path or not file_path.strip():
        return
    path = Path(file_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    line = f"{signal.direction.value} {signal.strength:.2f} {signal.ts}\n"
    path.write_text(line, encoding="utf-8")
    if signal.direction.value != "NEUTRAL":
        logger.info("MT5 signal written: %s", line.strip())
    else:
        logger.debug("MT5 signal written: %s", line.strip())
