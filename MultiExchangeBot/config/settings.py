# -*- coding: utf-8 -*-
"""
Konfiguracja z .env: giełdy (testnet/prod), symbole, limity ryzyka, ścieżki.
"""
import os
from pathlib import Path
from dataclasses import dataclass, field
from typing import List

from dotenv import load_dotenv

# Ładuj .env z katalogu MultiExchangeBot lub z głównego repo
_env_path = Path(__file__).resolve().parent.parent / ".env"
if not _env_path.exists():
    _env_path = Path(__file__).resolve().parent.parent.parent / "MultiSource_TradingSystem" / ".env"
load_dotenv(_env_path)


@dataclass
class ExchangeConfig:
    """Konfiguracja jednej giełdy."""
    id: str  # binance, bybit
    use_testnet: bool = True
    api_key: str = ""
    api_secret: str = ""
    ws_base: str = ""
    rest_base: str = ""


@dataclass
class RiskLimits:
    """Limity ryzyka – circuit breaker, max pozycja, dzienne straty."""
    max_position_usdt: float = 1000.0
    max_leverage: int = 5
    max_daily_loss_usdt: float = 200.0
    max_orders_per_minute: int = 10
    circuit_breaker_cooldown_sec: int = 60


@dataclass
class BotConfig:
    """Główna konfiguracja bota."""
    # Tryb: dry_run (tylko logi), testnet (API testnet), prod
    mode: str = "dry_run"
    # Giełdy: lista id (binance, bybit)
    exchanges: List[str] = field(default_factory=lambda: ["binance", "bybit"])
    # Symbole do skanowania i ewentualnego execution (perpetuals)
    symbols: List[str] = field(default_factory=lambda: ["BTCUSDT", "ETHUSDT"])
    # Konfiguracja per exchange (klucze, URL)
    exchange_configs: dict = field(default_factory=dict)
    risk: RiskLimits = field(default_factory=RiskLimits)
    # MT5: czy zapisywać sygnał do pliku (format jak w Signal Hub)
    mt5_signal_enabled: bool = False
    mt5_signal_path: str = ""
    # Detektory: włączenie
    momentum_enabled: bool = True
    anomaly_enabled: bool = True
    arbitrage_enabled: bool = True


def _read_exchange_config(exchange_id: str) -> ExchangeConfig:
    key_prefix = exchange_id.upper().replace("-", "_")
    use_testnet = os.getenv(f"{key_prefix}_TESTNET", "true").lower() in ("1", "true", "yes")
    if exchange_id == "binance":
        # WebSocket: domyślnie PROD (testnet często zwraca 502). REST = testnet/prod z BINANCE_TESTNET.
        ws_use_prod = os.getenv("BINANCE_WS_USE_PROD", "true").lower() in ("1", "true", "yes")
        ws_base = "wss://fstream.binance.com" if ws_use_prod else "wss://testnet.binancefuture.com"
        rest_base = "https://testnet.binancefuture.com" if use_testnet else "https://fapi.binance.com"
    elif exchange_id == "bybit":
        ws_use_prod = os.getenv("BYBIT_WS_USE_PROD", "true").lower() in ("1", "true", "yes")
        ws_base = "wss://stream.bybit.com/v5/public/linear" if ws_use_prod else "wss://stream-testnet.bybit.com/v5/public/linear"
        rest_base = "https://api-testnet.bybit.com" if use_testnet else "https://api.bybit.com"
    else:
        ws_base = rest_base = ""
    return ExchangeConfig(
        id=exchange_id,
        use_testnet=use_testnet,
        api_key=os.getenv(f"{key_prefix}_API_KEY", ""),
        api_secret=os.getenv(f"{key_prefix}_API_SECRET", ""),
        ws_base=ws_base,
        rest_base=rest_base,
    )


def load_config() -> BotConfig:
    """Ładuje BotConfig z zmiennych środowiskowych."""
    mode = os.getenv("BOT_MODE", "dry_run").lower()
    exchanges_raw = os.getenv("BOT_EXCHANGES", "binance,bybit").strip()
    exchanges = [x.strip() for x in exchanges_raw.split(",") if x.strip()]
    symbols_raw = os.getenv("BOT_SYMBOLS", "BTCUSDT,ETHUSDT").strip()
    symbols = [s.strip() for s in symbols_raw.split(",") if s.strip()]

    exchange_configs = {eid: _read_exchange_config(eid) for eid in exchanges}

    risk = RiskLimits(
        max_position_usdt=float(os.getenv("RISK_MAX_POSITION_USDT", "1000")),
        max_leverage=int(os.getenv("RISK_MAX_LEVERAGE", "5")),
        max_daily_loss_usdt=float(os.getenv("RISK_MAX_DAILY_LOSS_USDT", "200")),
        max_orders_per_minute=int(os.getenv("RISK_MAX_ORDERS_PER_MINUTE", "10")),
        circuit_breaker_cooldown_sec=int(os.getenv("RISK_CIRCUIT_BREAKER_SEC", "60")),
    )

    mt5_path = os.getenv("MT5_SIGNAL_FILE_PATH", "")
    if not mt5_path and os.getenv("MT5_SIGNAL_ENABLED", "false").lower() in ("1", "true", "yes"):
        mt5_path = str(Path.home() / "AppData" / "Roaming" / "MetaQuotes" / "Terminal" / "Common" / "Files" / "signal_xau.txt")

    return BotConfig(
        mode=mode,
        exchanges=exchanges,
        symbols=symbols,
        exchange_configs=exchange_configs,
        risk=risk,
        mt5_signal_enabled=os.getenv("MT5_SIGNAL_ENABLED", "false").lower() in ("1", "true", "yes"),
        mt5_signal_path=mt5_path,
        momentum_enabled=os.getenv("DETECTOR_MOMENTUM", "true").lower() in ("1", "true", "yes"),
        anomaly_enabled=os.getenv("DETECTOR_ANOMALY", "true").lower() in ("1", "true", "yes"),
        arbitrage_enabled=os.getenv("DETECTOR_ARBITRAGE", "true").lower() in ("1", "true", "yes"),
    )
