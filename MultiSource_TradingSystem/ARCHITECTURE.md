# Multi-Source Trading System – Architektura

## Cel
System zbiera dane z wielu źródeł (MetaTrader 5, TradingView, API rynkowe, sentiment), analizuje je i **wspiera bota XAU_Profit_EA** w przewidywaniu ruchu rynku (XAU/zloto).

---

## Źródła danych

| Źródło | Typ | Opis | Integracja |
|--------|-----|------|------------|
| **MetaTrader 5** | Ceny, wolumen | Wykres, EA – już masz | Bot działa na MT5 |
| **TradingView** | Alerty, webhook | Sygnały z Pine Script / wskaźników | HTTP webhook → nasz serwis |
| **cTrader** | Ceny (opcjonalnie) | Drugi broker / platforma | API lub export do pliku |
| **Alpha Vantage** | Dane rynkowe | Ceny, wskaźniki, forex/commodities | REST API |
| **Twelve Data** | Dane rynkowe | Realtime, history, wskaźniki | REST API / WebSocket |
| **Polygon.io** | Dane rynkowe (USA) | Akcje, forex, indeksy | REST API |
| **Binance** | Crypto (XAU proxy / sentiment) | Ceny, wolumen | REST API |
| **Coinbase** | Crypto | Ceny, wolumen | REST API |
| **COT Report (CFTC)** | Sentiment | Pozycje instytucji na złoto (COMEX) | Pobieranie CSV/API |

---

## Przepływ danych (high-level)

```
[TradingView Webhook] ──┐
[Alpha Vantage] ────────┤
[Twelve Data] ──────────┼──► [Signal Hub] ──► Agregacja / scoring ──► Plik sygnału
[Polygon.io] ───────────┤         │                                      │
[Binance/Coinbase] ─────┤         └── COT, sentiment                     │
[COT Report] ──────────┘                                                  ▼
                                                              [XAU_Profit_EA czyta plik]
                                                              MT5 wykonuje / wspiera decyzje
```

1. **Signal Hub** (aplikacja w Pythonie/Node) – uruchamiana np. na VPS lub u Ciebie.
2. Zbiera dane z API (Alpha Vantage, Twelve Data, Polygon, Binance, Coinbase, COT).
3. Odbiera webhooki z TradingView (alerty).
4. Agreguje: np. średnia ważona „bullish score” 0–1, kierunek LONG/SHORT/NEUTRAL.
5. Zapisuje wynik do **pliku** w folderze dostępnym dla MT5 (np. `MQL5/Files/`).
6. **XAU_Profit_EA** czyta ten plik i:
   - albo **wspiera** sygnał ze świecy (np. tylko LONG gdy hub mówi LONG),
   - albo **nadpisuje** kierunek (gdy hub ma pierwszeństwo).

---

## Połączenie z botem (MT5)

- **Plik sygnału** (np. `signal_xau.txt`):
  - Zawartość: `LONG 0.75` lub `SHORT 0.60` lub `NEUTRAL 0.50`
  - Format: kierunek + opcjonalnie siła (0–1).
- **EA** co tick/bar:
  - Otwiera plik (FileOpen w MQL5, folder Files).
  - Czyta kierunek i ewentualnie siłę.
  - Jeśli `UseExternalSignal = true`: wejście tylko gdy kierunek z pliku = kierunek ze świecy, albo wejście wg samego pliku.

---

## Kolejność wdrożenia (fazy)

1. **Faza 1 – Szkielet**
   - Signal Hub: konfig (klucze API), odbieranie webhooka TradingView, zapis do pliku.
   - EA: czytanie pliku, parametr „użyj zewnętrznego sygnału”.

2. **Faza 2 – API rynkowe**
   - Alpha Vantage, Twelve Data (ceny XAU/forex).
   - Prosty scoring: np. trend + RSI z API → LONG/SHORT/NEUTRAL.

3. **Faza 3 – Crypto + sentiment**
   - Binance/Coinbase (np. BTC jako proxy ryzyka).
   - COT Report (CFTC) dla złota – parsowanie, waga w score.

4. **Faza 4 – cTrader / Polygon**
   - Opcjonalnie: dodatkowe źródła cen lub indeksów.

---

## Technologie (propozycja)

- **Signal Hub:** Python 3.10+ (FastAPI lub Flask pod webhook, aiohttp/requests do API).
- **Konfiguracja:** `.env` na klucze API (Alpha Vantage, Twelve Data, Polygon, Binance, Coinbase).
- **Plik dla MT5:** zwykły tekst w `MQL5/Files/` (ścieżka konfigurowalna w EA).

---

## Pliki w repozytorium (struktura)

```
MultiSource_TradingSystem/
├── ARCHITECTURE.md          (ten plik)
├── README.md                (jak uruchomić, klucze API)
├── requirements.txt
├── .env.example             (szablon kluczy)
├── config.py                (stałe, ścieżki)
├── main.py                  (webhook + zapis pliku, start hub)
├── sources/
│   ├── tradingview.py       (webhook handler)
│   ├── alpha_vantage.py     (API client)
│   ├── twelve_data.py
│   ├── polygon_io.py
│   ├── binance.py
│   ├── coinbase.py
│   └── cot_report.py        (COT dla złota)
├── aggregator.py            (scoring, LONG/SHORT/NEUTRAL)
└── output/
    └── signal_xau.txt       (generowany plik dla EA)
```

EA (w folderze MT5_XAU_Profit): nowy input `InpUseExternalSignal`, `InpExternalSignalPath`, logika czytania pliku i wsparcia/nadpisania sygnału.
