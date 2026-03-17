# -*- coding: utf-8 -*-
"""
COT Report (CFTC) – sentiment dla złota (COMEX).
Pobiera dane CSV z CFTC, parsuje net positions. Commercial net long → bullish dla złota.
"""
import os
from typing import Tuple, Optional
import csv
import requests
from io import StringIO

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from aggregator import SignalDirection

# CFTC COT – Gold (COMEX) futures, contract code 088691 (Legacy) lub w nowym formacie
# URL do tygodniowego raportu (Legacy format, złoto)
COT_GOLD_URL = "https://www.cftc.gov/files/dea/history/deacot2024.txt"  # zmień rok w razie potrzeby


def _fetch_cot_csv() -> Optional[str]:
    """Pobiera ostatni dostępny plik COT (lista plików: https://www.cftc.gov/MarketReports/CommitmentsofTraders/HistoricalCompressed/index.htm)."""
    try:
        # CFTC publikuje pliki np. deacot2024.txt – lista: cot_YYYY.txt. Używamy prostego pobrania.
        for year in [2025, 2024, 2023]:
            url = f"https://www.cftc.gov/files/dea/history/deacot{year}.txt"
            r = requests.get(url, timeout=15)
            if r.status_code != 200:
                continue
            return r.text
    except Exception:
        pass
    return None


def _parse_cot_gold(csv_text: str) -> Optional[Tuple[SignalDirection, float]]:
    """
    Parsuje COT Legacy. Format: CFTC podaje kolumny m.in. Commercial Long/Short, Noncommercial Long/Short.
    Złoto = 088691 (instrument code w Legacy).
    Net Commercial = Commercial Long - Commercial Short. Dodatni net commercial często = bullish (instytucje kupują).
    """
    if not csv_text or "088691" not in csv_text and "Gold" not in csv_text:
        return None
    try:
        lines = csv_text.strip().split("\n")
        reader = csv.reader(StringIO(csv_text), delimiter=",")
        header = next(reader, None)
        if not header:
            return None
        # Szukamy wiersza dla złota (COMEX Gold). W Legacy: kolumny mogą być "Market", "Commercial Long", "Commercial Short", ...
        net_commercials = []
        for row in reader:
            if len(row) < 10:
                continue
            # Typowo kolumny: Report Date, CFTC Contract Market Code, Open Interest, Commercial Long, Commercial Short, ...
            try:
                code = str(row[1]) if len(row) > 1 else ""
                if "088691" in code or "Gold" in str(row).upper():
                    # Indeksy zależą od formatu CFTC – uproszczone: szukamy long/short
                    comm_long = int(row[4]) if len(row) > 4 else 0
                    comm_short = int(row[5]) if len(row) > 5 else 0
                    net = comm_long - comm_short
                    net_commercials.append(net)
                    if len(net_commercials) >= 3:
                        break
            except (ValueError, IndexError):
                continue
        if not net_commercials:
            return None
        # Ostatni tydzień vs poprzedni – wzrost net long = bullish
        latest = net_commercials[0]
        prev = net_commercials[-1] if len(net_commercials) > 1 else latest
        if latest > prev and prev != 0:
            change_pct = (latest - prev) / abs(prev)
            strength = 0.5 + min(0.4, max(-0.4, change_pct * 2))
            return SignalDirection.LONG, round(strength, 2)
        if latest < prev and prev != 0:
            change_pct = (prev - latest) / abs(prev)
            strength = 0.5 + min(0.4, max(-0.4, change_pct * 2))
            return SignalDirection.SHORT, round(strength, 2)
        return SignalDirection.NEUTRAL, 0.5
    except Exception:
        return None


def fetch_signal() -> Optional[Tuple[SignalDirection, float]]:
    csv_text = _fetch_cot_csv()
    if not csv_text:
        return None
    return _parse_cot_gold(csv_text)
