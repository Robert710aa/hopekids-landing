# -*- coding: utf-8 -*-
"""FastAPI: /health, /status, opcjonalnie /start, /stop (do integracji z run.py)."""
import logging
from typing import Any, Dict

from fastapi import FastAPI

logger = logging.getLogger("MultiExchangeBot.api")

app = FastAPI(title="Multi-Exchange Bot Control API")


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok"}


@app.get("/status")
def status() -> Dict[str, Any]:
    return {"mode": "dry_run", "exchanges": [], "message": "Use run.py for full bot; API is for health/status only."}
