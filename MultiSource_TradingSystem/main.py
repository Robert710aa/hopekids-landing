# -*- coding: utf-8 -*-
"""
Signal Hub – odbiera webhook (TradingView), zbiera dane z Alpha Vantage, Twelve Data, COT,
agreguje sygnały i zapisuje plik dla MT5 EA.
Uruchom: uvicorn main:app --host 0.0.0.0 --port 8000
"""
import json
import threading
import time
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import PlainTextResponse

from config import SIGNAL_FILE_PATH, SYMBOL
from aggregator import aggregate_signals, SignalDirection

app = FastAPI(title="Multi-Source Trading Signal Hub")

# Bufor sygnałów z webhooków (TradingView) – dołączany do źródeł API
_collected_signals: list = []
_lock = threading.Lock()


def _gather_api_signals():
    """Zbiera sygnały z Alpha Vantage, Twelve Data, COT. Zwraca listę (direction, strength)."""
    out = []
    try:
        from sources.alpha_vantage import fetch_signal as av_signal
        s = av_signal()
        if s:
            out.append(s)
    except Exception:
        pass
    try:
        from sources.twelve_data import fetch_signal as td_signal
        s = td_signal()
        if s:
            out.append(s)
    except Exception:
        pass
    try:
        from sources.cot_report import fetch_signal as cot_signal
        s = cot_signal()
        if s:
            out.append(s)
    except Exception:
        pass
    return out


def write_signal_file(direction: SignalDirection, strength: float) -> None:
    """Zapisuje sygnał do pliku: LONG 0.75 1734567890 (kierunek, siła, timestamp Unix)."""
    path = Path(SIGNAL_FILE_PATH)
    path.parent.mkdir(parents=True, exist_ok=True)
    ts = int(time.time())
    line = f"{direction.value} {strength:.2f} {ts}\n"
    path.write_text(line, encoding="utf-8")


def refresh_signal() -> None:
    """Zbiera sygnały z wszystkich źródeł (API + bufor webhook), agreguje, zapisuje plik."""
    with _lock:
        api_signals = _gather_api_signals()
        all_signals = api_signals + list(_collected_signals)
    if not all_signals:
        write_signal_file(SignalDirection.NEUTRAL, 0.5)
        return
    direction, strength = aggregate_signals(all_signals)
    write_signal_file(direction, strength)


def _background_refresh(interval_seconds: int = 60):
    """W tle co interval_seconds odświeża sygnał z API."""
    while True:
        time.sleep(interval_seconds)
        try:
            refresh_signal()
        except Exception:
            pass


@app.on_event("startup")
def startup():
    refresh_signal()
    t = threading.Thread(target=_background_refresh, args=(60,), daemon=True)
    t.start()


@app.get("/health")
def health():
    return {"status": "ok", "symbol": SYMBOL}


@app.get("/refresh")
def refresh():
    """Ręczne odświeżenie sygnału z API (Alpha Vantage, Twelve Data, COT)."""
    try:
        refresh_signal()
        return {"status": "ok", "message": "Signal refreshed"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.post("/webhook/tradingview", response_class=PlainTextResponse)
async def tradingview_webhook(request: Request):
    """
    TradingView Alert → Webhook URL: http://TWOJ_IP:8000/webhook/tradingview
    Body może być JSON np. {"direction": "long", "strength": 0.8} lub tekst.
    """
    try:
        body = await request.body()
        try:
            data = json.loads(body)
            direction_str = (data.get("direction") or data.get("action") or "neutral").upper()
            strength = float(data.get("strength", 0.7))
        except Exception:
            direction_str = body.decode("utf-8", errors="ignore").strip().upper() or "NEUTRAL"
            strength = 0.7

        if "LONG" in direction_str or "BUY" in direction_str:
            direction = SignalDirection.LONG
        elif "SHORT" in direction_str or "SELL" in direction_str:
            direction = SignalDirection.SHORT
        else:
            direction = SignalDirection.NEUTRAL

        strength = max(0.0, min(1.0, strength))
        with _lock:
            _collected_signals.append((direction, strength))
            if len(_collected_signals) > 50:
                _collected_signals.pop(0)
        refresh_signal()
        return "OK"
    except Exception as e:
        return PlainTextResponse(f"ERROR {e}", status_code=500)


@app.post("/signal")
async def set_signal(request: Request):
    """Ręczne ustawienie sygnału (POST JSON: {"direction": "LONG", "strength": 0.8})."""
    try:
        data = await request.json()
        direction_str = (data.get("direction") or "NEUTRAL").upper()
        strength = float(data.get("strength", 0.7))
        if "LONG" in direction_str or "BUY" in direction_str:
            direction = SignalDirection.LONG
        elif "SHORT" in direction_str or "SELL" in direction_str:
            direction = SignalDirection.SHORT
        else:
            direction = SignalDirection.NEUTRAL
        strength = max(0.0, min(1.0, strength))
        write_signal_file(direction, strength)
        return {"status": "ok", "direction": direction.value, "strength": strength}
    except Exception as e:
        return {"status": "error", "message": str(e)}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
