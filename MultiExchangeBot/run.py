# -*- coding: utf-8 -*-
"""
Główny punkt wejścia: ładuje config, uruchamia pętlę asyncio.
Pipeline: MarketData -> FeatureEngine -> Detectors -> SignalBus -> Execution (+ opcjonalnie MT5 writer).
"""
import asyncio
import logging
import time

from config import load_config, BotConfig
from market_data.collector import MarketDataCollector
from models.events import NormalizedTrade, TickerEvent
from features.engine import FeatureEngine
from signals.bus import SignalBus
from execution.engine import ExecutionEngine
from execution.risk import RiskManager

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("MultiExchangeBot")


async def run_event_consumer(config: BotConfig, queue: asyncio.Queue) -> None:
    """Konsument: trade/ticker -> FeatureEngine -> co 5s Detectors -> SignalBus -> Execution + MT5."""
    fe = FeatureEngine(window_sec=60.0)
    risk = RiskManager(
        config.risk.max_position_usdt,
        config.risk.max_daily_loss_usdt,
        config.risk.max_orders_per_minute,
        config.risk.circuit_breaker_cooldown_sec,
    )
    signal_bus = SignalBus(
        momentum_enabled=config.momentum_enabled,
        anomaly_enabled=config.anomaly_enabled,
        arbitrage_enabled=config.arbitrage_enabled,
    )
    executor = ExecutionEngine(config.mode, risk)
    last_aggregate = 0.0
    aggregate_interval = 5.0
    count = 0

    while True:
        try:
            kind, ev = await asyncio.wait_for(queue.get(), timeout=2.0)
            count += 1
            if kind == "trade" and isinstance(ev, NormalizedTrade):
                fe.update_trade(ev)
            elif kind == "ticker" and isinstance(ev, TickerEvent):
                fe.update_ticker(ev)
            fe.maybe_reset_windows()
        except asyncio.TimeoutError:
            pass
        except asyncio.CancelledError:
            break

        now = time.time()
        if now - last_aggregate >= aggregate_interval:
            last_aggregate = now
            sig = signal_bus.aggregate(fe, config.symbols, config.exchanges)
            if sig:
                if config.mt5_signal_enabled and config.mt5_signal_path:
                    from mt5_bridge.writer import write_mt5_signal
                    write_mt5_signal(sig, config.mt5_signal_path)
                if sig.source:
                    logger.info("Signal: %s strength=%.2f source=%s", sig.direction.value, sig.strength, sig.source)
                    for symbol in config.symbols[:1]:
                        executor.execute(sig, symbol)


async def main() -> None:
    config = load_config()
    logger.info("Starting Multi-Exchange Bot | mode=%s | exchanges=%s", config.mode, config.exchanges)

    event_queue: asyncio.Queue = asyncio.Queue(maxsize=100_000)
    collector = MarketDataCollector(
        config.exchanges,
        config.symbols,
        config.exchange_configs,
        event_queue=event_queue,
    )
    await collector.start()

    consumer = asyncio.create_task(run_event_consumer(config, event_queue))
    try:
        await consumer
    except asyncio.CancelledError:
        pass
    finally:
        await collector.stop()
        consumer.cancel()
        try:
            await consumer
        except asyncio.CancelledError:
            pass
    logger.info("Shutdown done.")


if __name__ == "__main__":
    asyncio.run(main())
