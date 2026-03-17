//+------------------------------------------------------------------+
//|                                              XAU_Profit_EA.mq5   |
//|  MTF WPR: Bias H1/H4/D1 + Entry M5/M15/M30.                       |
//|  FIXED: anti-overtrading, spread check, loss-direction, guards.  |
//+------------------------------------------------------------------+
#property copyright "XAU_Profit_EA"
#property version   "5.21"
#property strict
// v5.21: SL tylko w stronę zysku (Long=w górę, Short=w dół), nigdy nie cofa – logika w XAU_Profit_Trade.mqh

// 1 = w testach zawsze zezwalaj na Long i Short (ignoruj InpAllowLong/InpAllowShort z .set)
#define XAU_FORCE_ALLOW_BOTH_DIRECTIONS 1
// Stały bufor na start testu: 0 = handluj od pierwszego baru (bot ma pracować cały czas)
#define XAU_MIN_BARS_NO_ENTRY 0

#include <Trade/Trade.mqh>

// === WEJŚCIA (zgodne z MTF_Screener_WPR) ===
input string   InpSymbol            = "";           // Symbol (pusty = chart)
input ENUM_TIMEFRAMES InpEntryTF     = PERIOD_M5;   // Entry TF (M5 = jedna świeca = jedno wejście)
input int      InpWPRPeriod          = 14;          // Okres WPR (Ind1=WPR)
input double   InpWPROverbought      = -18.0;      // WPR Short: bias gdy WPR < -18 (mocniejsza strefa bearish)
input double   InpWPROversold       = -84.0;       // WPR Long: bias gdy WPR > -84 (mocniejsza strefa bullish)
input int      InpMinBarsBetweenTrades = 0;        // 0 = bez limitu (jak piątek wieczorem)
input bool     InpEntryOnlyOnNewBar   = false;     // false = wejście co tick/co 1 s (agresywnie). true = tylko co nowy bar (mniej zapytań)
input int      InpMaxTradesPerDay     = 0;          // Maks. wejść dziennie (0 = bez limitu)
input int      InpMaxLossesPerDay     = 0;          // 0 = bez limitu
input int      InpMaxConsecutiveLosses = 3;         // Stop po 3 stratach z rzędu
input double   InpMaxEquityDDPercent   = 18.0;     // Stop handlu gdy DD od szczytu equity >= X% (wył. gdy InpUseEquityDDStop=false)
input bool     InpUseEquityDDStop      = false;    // false = NIE zamykaj/nie blokuj z powodu DD – bot ma cały czas handlować
input int      InpEquityDDGraceBars    = 250;      // Na start: przez N barów NIE zamykaj pozycji z powodu DD (gdy DD włączony)
input int      InpEquityDDResetAfterBars = 100;    // Po N barach blokady: zresetuj szczyt i wznów handel (gdy DD włączony)
input int      InpEquityDDRelaxBarsAfterReset = 80; // Po resecie: przez N barów pełny DD, bez zacieśniania
input bool     InpTightenEquityDDOnGain = false;   // false = bez zacieśniania DD po zysku – żeby bot mógł zarabiać i tracić
input double   InpTightenEquityDDGainPct = 3.0;    // Od jakiego zysku zacieśniać DD (gdy włączone)
input double   InpTightenEquityDDNewPercent = 8.0; // DD% po osiągnięciu zysku (gdy zacieśnianie włączone)
input bool     InpUseSessionFilter     = false;    // false = handel 24h (cała doba). true = tylko w oknie godzin
input int      InpSessionStartHour     = 7;        // Start godzina (0-23), gdy filtr włączony
input int      InpSessionEndHour       = 21;       // Koniec godzina (0-23), gdy filtr włączony
input bool     InpStopOnFridayEvening  = false;    // false = handel cały tydzień (także piątek). true = stop w piątek po godzinie X
input int      InpFridayStopHour       = 20;       // Godzina stop w piątek (czas serwera)
input int      InpCooldownAfterLossBars = 0;        // 0 = po stracie bez pauzy (jak piątek wieczorem)
input int      InpCooldownSameDirBars  = 0;        // 0 = bez blokady
input int      InpSkipFirstBars      = 0;          // Początek: 0 = handluj od startu (bot ma pracować cały czas)
input int      InpSkipFirstSeconds   = 0;          // Początek: nie handluj przez N sekund. 0 = handluj od startu
input int      InpMinBarsHighestTF   = 0;          // Min. barów D1 przed wejściem. 0 = wył. (czysty test)
input bool     InpBiasUse1           = true;        // Bias slot 1 włączony
input ENUM_TIMEFRAMES InpBiasTF1    = PERIOD_H1;   // Bias TF 1 (np. H1 lub M1,M5,M15)
input bool     InpBiasUse2           = true;        // Bias slot 2 włączony
input ENUM_TIMEFRAMES InpBiasTF2    = PERIOD_H4;   // Bias TF 2 (np. H4 lub M5,M15)
input bool     InpBiasUse3           = true;        // Bias slot 3 włączony
input ENUM_TIMEFRAMES InpBiasTF3    = PERIOD_D1;   // Bias TF 3 (np. D1 lub M15,M30)
input bool     InpUseBias            = true;       // true = wymagaj bias H1/H4/D1 (lepsze wejścia z trendem)
input bool     InpTradeStrict        = false;      // false = bias na min. 1 TF, true = wszystkie 3 TF
input bool     InpRequireWPRCross    = false;      // false = wejście gdy WPR w strefie, true = tylko przy wejściu w strefę
input bool     InpUseTrendFilter     = false;      // false = bez filtra (jak piątek wieczorem – więcej wejść)
input ENUM_TIMEFRAMES InpTrendMATF   = PERIOD_H1;  // TF dla filtra trendu
input int      InpTrendMAPeriod      = 50;         // Okres EMA trendu
input bool     InpUseRegimeDistFilter = false;     // reżim: tylko gdy cena wyraźnie od EMA (X ATR). 0 = wył.
input double   InpRegimeMinDistATR   = 0.2;        // min. odległość cena–EMA w ATR (np. 0.2 = wyraźny trend)
// --- Momentum / odwrócenia (HFT) ---
input bool     InpUseRSIFilter       = false;     // RSI: filtr momentum (Long gdy RSI < overbought, Short gdy RSI > oversold)
input int      InpRSIPeriod          = 14;        // RSI okres
input double   InpRSIOverbought      = 70.0;      // RSI powyżej = nie Long
input double   InpRSIOversold        = 30.0;      // RSI poniżej = nie Short
input bool     InpUseStochFilter     = false;     // Stochastyczny: Long gdy K>D, Short gdy K<D
input int      InpStochK             = 5;         // Stoch %K okres
input int      InpStochD             = 3;         // Stoch %D okres
input int      InpStochSlowing       = 3;         // Stoch wygładzanie
input bool     InpUseMACDFilter      = false;     // MACD: Long gdy main>signal, Short gdy main<signal
input int      InpMACDFast           = 12;       // MACD szybka EMA
input int      InpMACDSlow           = 26;       // MACD wolna EMA
input int      InpMACDSignal         = 9;        // MACD sygnał
input bool     InpUseBBFilter        = false;     // Bollinger: Long gdy cena > dolna, Short gdy cena < górna (odstęp od pasm)
input int      InpBBPeriod           = 20;       // Bollinger okres
input double   InpBBDev              = 2.0;       // Bollinger odchylenie
input bool     InpSignalFromCandle   = true;       // true = w stronę świecy: zielona=Kupno, czerwona=Sprzedaż
input bool     InpCandleUseCurrentBar = false;      // false = ostatnia ZAMKNIĘTA świeca (co bar: Long lub Short). true = bieżąca (często doji)
input bool     InpCandleRequireTwo   = false;     // false = 1 świeca (jak piątek wieczorem)
input double   InpMinBodyPct         = 25.0;     // Min. korpus świecy w % zakresu (25=tylko wyraźne świece = lepsze wejścia)
input bool     InpInvertCandleSignal  = false;     // false = NORMAL (zielona=Kupno, czerwona=Sprzedaż). true = FADE
input bool     InpAllowLong          = true;      // Zezwól na Long (Kupno)
input bool     InpAllowShort         = true;      // Zezwól na Short (Sprzedaż)
input bool     InpUseExternalSignal  = false;     // false = sygnał z pliku NIE blokuje bota. true = czytaj plik (Signal Hub)
input string   InpExternalSignalFile = "signal_xau.txt";  // Plik w Terminal/Common/Files
input int      InpExternalSignalMaxAgeSec = 300;  // Sygnał starszy niż N sek = ignoruj (0 = bez limitu)
input double   InpExternalSignalMinStrength = 0.3; // Min. siła sygnału 0–1 (słabszy = NEUTRAL)
input double   InpExternalSignalBlockStrength = 1.0; // Blokuj przeciwny kierunek tylko gdy siła >= X (1.0 = praktycznie wył., niżej = blokuje)

input double   InpLots               = 0.01;       // Stały wolumen (dźwignia 0.01 lota). Gdy InpInvestAmount=0 używaj tego
input double   InpInvestAmount       = 0.0;        // 0 = używaj InpLots. >0 = wolumen z marży (ostrożnie przy stratach)
input int      InpMaxPositions       = 4;          // Maks. pozycji łącznie (0 = bez limitu)
input int      InpMaxPositionsPerBar = 1;         // Maks. pozycji na JEDNĄ świecę (1 = jedno wejście na świecę M5)
input int      InpMaxPositionsStart  = 1;          // Start: max pozycji (ramp-up). Zmniejsza ryzyko "na początku"
input int      InpMaxPositionsRampBars = 0;        // 0 = od startu pełna liczba pozycji (InpMaxPositions). >0 = ramp-up
input bool     InpUseSLTP            = true;       // true = ustaw SL/TP (mniejsze straty), false = bez SL/TP
input int      InpATRPeriod          = 14;         // ATR dla SL/TP
input double   InpATRMultiplierSL    = 1.4;       // SL w ATR (luźniejszy = więcej luzu)
input double   InpATRMultiplierTP    = 0.85;      // TP w ATR (niżej = szybsze zamykanie zysku)
input bool     InpUseTrailingStop    = true;       // Trailing stop
input double   InpTrailATRMult       = 0.18;      // Trailing w ATR
input double   InpTrailMinATR        = 0.06;      // Trailing od minimalnego zysku w ATR (niżej = trailing wcześniej)
input bool     InpUseBreakEven       = true;       // Break-even
input double   InpBE_Trigger_ATR     = 0.28;       // BE gdy zysk >= X ATR (jak piątek wieczorem)
input int      InpBE_OffsetPoints    = 10;        // BE: przesunięcie SL w punktach (np. 10 = mały zysk)
input double   InpMaxLossATR         = 0.34;       // Max strata na pozycję w ATR (niżej = mniejsze straty)
input bool     InpTrailOnlyAfterBE   = true;      // true = trailing dopiero po BE (daj zyskowi dojść do TP)

input bool     InpUseDailyLossLimit  = false;     // false = bez limitu dziennej straty. true = blokada przy X%
input double   InpDailyLossLimitPct  = 1.5;       // Blokada gdy dzienna strata >= X% salda (gdy limit włączony)
input bool     InpUseConsecLossStop  = false;     // false = bez limitu strat z rzędu. true = stop po N stratach

input bool     InpUseATRFilter       = false;      // false = wchodź także przy niskiej zmienności (więcej wejść)
input double   InpATRMinMult         = 0.3;        // Min ATR przy włączonym filtrze (niżej = więcej wejść)

input int      InpManageThrottleSec  = 20;         // Sprawdzanie SL/TP/trailing co N sek (20=min. zapytań, mniejsze ryzyko blokady)
input int      InpMaxSpreadPoints    = 400;        // Maks. spread (pts) – na realu nie wchodź gdy spread za duży (XAU 300–500)
input bool     InpAddSpreadToTP      = true;       // true = dodaj spread do TP (na realu zysk po spreadzie; w testerze można false)
input int      InpDeviationPoints    = 50;         // Slippage (pts) przy zleceniu
input int      InpMagicNumber        = 234567;     // Magic
input bool     InpDebug              = true;       // true = na wykresie widać WPR, sygnał, powód braku wejścia
input bool     InpTestForceOneOpen   = false;      // TEST: true = 1× Sell przy starcie. Na co dzień zostaw false.

// === ZMIENNE GLOBALNE ===
#define _XAU_PROFIT_EA_COMPILING_
CTrade         g_trade;
string         g_symbol;
int            g_digits;
double         g_point;
datetime       g_lastBarTime = 0;
datetime       g_lastBarOpenTime = 0;
datetime       g_dayStart = 0;
int            g_tradesOpenedToday = 0;
int            g_lossesToday = 0;
datetime       g_lastLossTime = 0;
int            g_lastLossDirection = 0;   // 1 = zamknięto stratny Long, -1 = stratny Short
int            g_barsSinceStart = 0;   // licznik barów od startu (pomijanie początku)
datetime       g_eaStartTime = 0;      // czas startu EA (do InpSkipFirstSeconds)
bool           g_skipPassedLogged = false;
int            g_totalClosed = 0;      // Expectancy: liczba zamknięć
int            g_wins = 0;
double         g_sumWin = 0.0;
double         g_sumLoss = 0.0;
string         g_expectancyStr = "";   // tekst na wykresie; jednorazowy log: czy już zalogowano przejście skip
bool           g_testForceOpenDone = false;  // TEST: czy już wykonano próbę InpTestForceOneOpen
bool           g_equityLock = false;         // blokada handlu po przekroczeniu DD
datetime       g_equityLockDay = 0;          // dzień aktywacji blokady
static int      s_guardConsecLosses = 0;      // licznik strat z rzędu (reset przy zysku / nowy dzień)
static double   s_guardEquityPeak = 0.0;      // szczyt equity (do InpMaxEquityDDPercent)
double         g_startEquity = 0.0;          // equity na starcie (do ochrony peaku / zacieśniania DD)
double         g_dailyStartBalance = 0.0;     // saldo na początek dnia (do InpDailyLossLimitPct)
double         g_lastExternalSignalStrength = 0.0;  // siła ostatniego sygnału z pliku (do blokady tylko przy silnym)

int            g_handleRSI = INVALID_HANDLE;       // RSI wbudowany MT5 (precyzja wejść)

// Opakowania Copy* – w EA, żeby uniknąć przeciążeń MQL5 (bez static – .mqh ich wywołuje)
int CopyCloseInt(const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyClose(sym, tf, start, count, arr); }
int CopyOpenInt (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyOpen(sym, tf, start, count, arr); }
int CopyHighInt (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyHigh(sym, tf, start, count, arr); }
int CopyLowInt  (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyLow(sym, tf, start, count, arr); }

int MaxPositionsNow()
{
   int maxPos = InpMaxPositions;
   if(maxPos <= 0) return 999999;
   if(InpMaxPositionsRampBars > 0 && g_barsSinceStart < InpMaxPositionsRampBars)
   {
      int startMax = InpMaxPositionsStart;
      if(startMax <= 0) return maxPos;
      return (startMax < maxPos) ? startMax : maxPos;
   }
   return maxPos;
}

// Liczba naszych pozycji otwartych na tej samej swiecy (zduplikowane z Helpers na potrzeby kompilacji)
int CountOurPositionsOnBar(datetime barTime)
{
   if(barTime <= 0) return 0;
   long barSec = (long)PeriodSeconds(InpEntryTF);
   datetime barEnd = (datetime)((long)barTime + barSec);
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i)) continue;
      if(PositionGetString(POSITION_SYMBOL) != g_symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
      datetime pt = (datetime)PositionGetInteger(POSITION_TIME);
      if(pt >= barTime && pt < barEnd) n++;
   }
   return n;
}

#include "XAU_Profit_Indicators.mqh"
#include "XAU_Profit_Helpers.mqh"
#include "XAU_Profit_Signals.mqh"
#include "XAU_Profit_Trade.mqh"

// Zwraca: 1 = LONG, -1 = SHORT, 0 = NEUTRAL/brak/stary/słaby. Format pliku: LONG 0.75 1734567890
int ReadExternalSignal()
{
   g_lastExternalSignalStrength = 0.0;
   if(InpExternalSignalFile == "" || InpExternalSignalFile == NULL) return 0;
   int h = FileOpen(InpExternalSignalFile, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
   if(h == INVALID_HANDLE) return 0;
   string line = FileReadString(h);
   FileClose(h);
   if(line == "") return 0;
   StringTrimLeft(line);
   StringTrimRight(line);
   StringToUpper(line);
   int dir = 0;
   if(StringFind(line, "LONG") >= 0)  dir = 1;
   else if(StringFind(line, "SHORT") >= 0) dir = -1;
   if(dir == 0) return 0;

   double strength = 0.5;
   long   fileTime = 0;
   string parts[];
   int n = StringSplit(line, ' ', parts);
   if(n >= 2) strength = (double)StringToDouble(parts[1]);
   if(n >= 3) fileTime = (long)StringToInteger(parts[2]);

   if(strength < InpExternalSignalMinStrength) { g_lastExternalSignalStrength = 0.0; return 0; }
   if(InpExternalSignalMaxAgeSec > 0 && fileTime > 0)
   {
      long now = (long)TimeCurrent();
      if(fileTime > now) { g_lastExternalSignalStrength = 0.0; return 0; }   // data z pliku w przyszłości = odrzuć
      if(now - fileTime > InpExternalSignalMaxAgeSec) { g_lastExternalSignalStrength = 0.0; return 0; }
   }
   g_lastExternalSignalStrength = strength;
   return dir;
}

// true = nie wchodź w tym kierunku (po stracie w tym samym kierunku)
bool BlockedSameDirectionAfterLoss(bool wantLong)
{
   if(InpCooldownSameDirBars <= 0 || g_lastLossTime == 0) return false;
   if(wantLong  && g_lastLossDirection !=  1) return false;
   if(!wantLong && g_lastLossDirection != -1) return false;
   int barsSince = (int)Bars(g_symbol, InpEntryTF, g_lastLossTime, TimeCurrent());
   return (barsSince >= 0 && barsSince < InpCooldownSameDirBars);
}

// --- RISK GUARDS (anti-dive) ---
bool SessionOK()
{
   if(!InpUseSessionFilter) return true;
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   int h = dt.hour;
   if(InpSessionStartHour == InpSessionEndHour) return true;
   if(InpSessionStartHour < InpSessionEndHour)
      return (h >= InpSessionStartHour && h < InpSessionEndHour);
   return (h >= InpSessionStartHour || h < InpSessionEndHour);
}

bool FridayOK()
{
   if(!InpStopOnFridayEvening) return true;
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   if(dt.day_of_week != 5) return true; // Friday
   return (dt.hour < InpFridayStopHour);
}

bool EquityDDOK()
{
   if(!InpUseEquityDDStop || InpMaxEquityDDPercent <= 0.0)
      return true;

   static int s_barsAtDDBlock = -1;
   static int s_barsAtReset = -1;

   // Okres ochronny na start: przez pierwsze N barów nie zamykaj wszystkiego z powodu DD i nie aktualizuj szczytu
   if(InpEquityDDGraceBars > 0 && g_barsSinceStart < InpEquityDDGraceBars)
      return true;

   double eq = AccountInfoDouble(ACCOUNT_EQUITY);

   // Po okresie ochronnym: ustaw szczyt na bieżące equity (DD liczony od "po starcie", nie od depozytu)
   if(s_guardEquityPeak <= 0.0)
      s_guardEquityPeak = eq;

   if(eq > s_guardEquityPeak)
      s_guardEquityPeak = eq;

   double allowedDD = InpMaxEquityDDPercent;
   // Zacieśnij DD tylko gdy był zysk od startu – ale NIE od razu po resecie (żeby nie nurkowało i reszta nie stała)
   bool relaxAfterReset = (InpEquityDDRelaxBarsAfterReset > 0 && s_barsAtReset >= 0 && (g_barsSinceStart - s_barsAtReset) < InpEquityDDRelaxBarsAfterReset);
   if(!relaxAfterReset && InpTightenEquityDDOnGain && InpTightenEquityDDGainPct > 0.0 && InpTightenEquityDDNewPercent > 0.0 && g_startEquity > 0.0)
   {
      double gainPct = (s_guardEquityPeak - g_startEquity) / g_startEquity * 100.0;
      if(gainPct >= InpTightenEquityDDGainPct)
         allowedDD = MathMin(allowedDD, InpTightenEquityDDNewPercent);
   }

   double dd = (s_guardEquityPeak - eq) / s_guardEquityPeak * 100.0;

   if(dd >= allowedDD)
   {
      if(s_barsAtDDBlock < 0)
         s_barsAtDDBlock = g_barsSinceStart;

      // Po N barach blokady: zresetuj szczyt do bieżącego equity, żeby EA mógł znowu handlować (wykres nie stoi w miejscu)
      if(InpEquityDDResetAfterBars > 0 && (g_barsSinceStart - s_barsAtDDBlock) >= InpEquityDDResetAfterBars)
      {
         s_guardEquityPeak = eq;
         s_barsAtDDBlock = -1;
         s_barsAtReset = g_barsSinceStart;  // od teraz przez InpEquityDDRelaxBarsAfterReset barów pełny DD (bez zacieśniania)
         Print("XAU_Profit: reset szczytu equity po ", InpEquityDDResetAfterBars, " barach blokady – wznawiam handel (przez ", InpEquityDDRelaxBarsAfterReset, " barow pelny DD).");
         return true;
      }

      // zamknij wszystkie pozycje EA (bez blokady do konca dnia)
      int closed = 0;
      for(int i=PositionsTotal()-1; i>=0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket &&
            PositionGetString(POSITION_SYMBOL)==g_symbol &&
            (long)PositionGetInteger(POSITION_MAGIC)==InpMagicNumber)
         {
            g_trade.PositionClose(ticket);
            closed++;
         }
      }
      if(closed > 0)
         Print("XAU_Profit | EQUITY DD ", DoubleToString(dd,2), "% (limit ", DoubleToString(allowedDD,2), "%) – zamknieto ", closed, " pozycji. Handlowac ponownie po odbiciu lub po ", InpEquityDDResetAfterBars, " barach.");

      return false;  // blokuj wejscia dopoki dd >= prog; po odbiciu equity wraca true
   }

   s_barsAtDDBlock = -1;  // reset licznika gdy equity OK
   if(s_barsAtReset >= 0 && InpEquityDDRelaxBarsAfterReset > 0 && (g_barsSinceStart - s_barsAtReset) >= InpEquityDDRelaxBarsAfterReset)
      s_barsAtReset = -1;  // koniec okresu relaksu po resecie
   return true;
}

bool DailyLossLimitOK()
{
   if(!InpUseDailyLossLimit || InpDailyLossLimitPct <= 0.0) return true;
   if(g_dailyStartBalance <= 0.0) return true;
   double curBal = AccountInfoDouble(ACCOUNT_BALANCE);
   double lossPct = (g_dailyStartBalance - curBal) / g_dailyStartBalance * 100.0;
   return (lossPct < InpDailyLossLimitPct);
}

bool ConsecutiveLossesOK()
{
   if(!InpUseConsecLossStop) return true;
   if(InpMaxConsecutiveLosses <= 0) return true;
   return (s_guardConsecLosses < InpMaxConsecutiveLosses);
}

//+------------------------------------------------------------------+
int OnInit()
{
   g_symbol = (InpSymbol == "" || InpSymbol == NULL) ? _Symbol : InpSymbol;
   if(!SymbolInfoInteger(g_symbol, SYMBOL_SELECT))
   {
      if(!SymbolSelect(g_symbol, true)) { Print("Symbol ", g_symbol, " niedostępny."); return INIT_FAILED; }
   }
   g_digits = (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS);
   g_point  = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
   if(g_point <= 0.0) { Print("Błędny point."); return INIT_FAILED; }

   g_trade.SetExpertMagicNumber((int)InpMagicNumber);
   g_trade.SetDeviationInPoints((ulong)MathMax(0, InpDeviationPoints));
   g_lastBarTime = iTime(g_symbol, InpEntryTF, 0);
   g_lastBarOpenTime = 0;
   g_barsSinceStart = 0;
   g_eaStartTime = TimeCurrent();
   g_skipPassedLogged = false;
   g_lossesToday = 0;
   g_testForceOpenDone = false;
   s_guardConsecLosses = 0;
   // Szczyt equity ustawiany po okresie ochronnym (EquityDDOK), nie od salda startu – żeby na starcie nie zjadało
   // s_guardEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);  // wyłączone
   g_startEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   int needBars = InpUseBias ? (InpWPRPeriod+15) : (InpWPRPeriod+2);
   Print("XAU_Profit v5.21 start | ", g_symbol, " EntryTF=", EnumToString(InpEntryTF),
         " barow=", Bars(g_symbol, InpEntryTF), " (potrzeba ", needBars, ") AutoTrade=", (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ? "TAK" : "NIE"));
   Print("XAU_Profit PARAMETRY: Trend=", InpUseTrendFilter ? "TAK" : "NIE",
         " | RSI=", InpUseRSIFilter ? "TAK" : "NIE", " Stoch=", InpUseStochFilter ? "TAK" : "NIE",
         " | MACD=", InpUseMACDFilter ? "TAK" : "NIE", " BB=", InpUseBBFilter ? "TAK" : "NIE",
         " | 2swiece=", InpCandleRequireTwo ? "TAK" : "NIE",
         " | MinBarsBetween=", InpMinBarsBetweenTrades,
         " | SL=", InpATRMultiplierSL, " TP=", InpATRMultiplierTP,
         " | BE=", InpBE_Trigger_ATR, " MaxLossATR=", InpMaxLossATR);
   if(InpSignalFromCandle)
      Print("XAU_Profit TRYB: ", InpInvertCandleSignal ? "FADE" : "NORMAL",
            " (zielona=Kupno, czerwona=Sprzedaz)");
   if(XAU_MIN_BARS_NO_ENTRY > 0)
      Print("XAU_Profit START: pierwsze ", XAU_MIN_BARS_NO_ENTRY, " barow testu BEZ otwierania pozycji (staly bufor).");
   if(InpUseRSIFilter)
   {
      g_handleRSI = iRSI(g_symbol, InpEntryTF, InpRSIPeriod, PRICE_CLOSE);
      if(g_handleRSI == INVALID_HANDLE) Print("XAU_Profit: RSI nie utworzony – filtr RSI wyłączony.");
   }
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   ulong dealTicket = trans.deal;
   if(dealTicket == 0) return;
   if(!HistoryDealSelect(dealTicket)) return;
   if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT) return;
   if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != g_symbol) return;
   if((long)HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != (long)InpMagicNumber) return;
   double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT) + HistoryDealGetDouble(dealTicket, DEAL_SWAP) + HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
   g_totalClosed++;
   if(profit > 0.0)
   {
      g_wins++; g_sumWin += profit;
      g_lastLossTime = 0; g_lastLossDirection = 0;
      s_guardConsecLosses = 0;
   }
   else
   {
      g_sumLoss += profit;
      g_lastLossTime = TimeCurrent();
      g_lossesToday++;
      s_guardConsecLosses++;
      long dealType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
      if(dealType == DEAL_TYPE_SELL)      g_lastLossDirection =  1;  // stratny Long
      else if(dealType == DEAL_TYPE_BUY)  g_lastLossDirection = -1;  // stratny Short
      else g_lastLossDirection = 0;
   }
   if(InpDebug) Print("XAU_Profit zamknięcie ", g_symbol, " profit+swap+comm=", DoubleToString(profit, 2));
}

string GetExpectancyString()
{
   if(g_totalClosed <= 0) return "";
   double winRate = (double)g_wins / (double)g_totalClosed;
   double avgWin = (g_wins > 0) ? (g_sumWin / (double)g_wins) : 0.0;
   double avgLoss = (g_totalClosed > g_wins) ? (g_sumLoss / (double)(g_totalClosed - g_wins)) : 0.0;
   double expectancy = winRate * avgWin + (1.0 - winRate) * avgLoss;
   return StringFormat("Expectancy: %.2f | Win%%=%.0f | AvgWin=%.2f AvgLoss=%.2f | N=%d",
                       expectancy, winRate*100.0, avgWin, avgLoss, g_totalClosed);
}

//+------------------------------------------------------------------+
void OnTick()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Comment("XAU_Profit | Wlacz AutoTrading (zielony przycisk w pasku)!");
      return;
   }

   // === TEST: jedna próba otwarcia Sell bez żadnych warunków (sprawdzenie czy broker w ogóle przyjmuje) ===
   if(InpTestForceOneOpen && !g_testForceOpenDone)
   {
      g_testForceOpenDone = true;
      double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
      double lots = 0.01;
      if(SymbolInfoInteger(g_symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
      {
         Print("XAU_Profit TEST: Symbol ", g_symbol, " – handel wylaczony (SYMBOL_TRADE_MODE_DISABLED)");
         Comment("XAU_Profit TEST | Symbol bez handlu. Zmien symbol lub broker.");
         return;
      }
      ResetLastError();
      bool ok = g_trade.Sell(lots, g_symbol, bid, 0.0, 0.0, "XAU_TEST");
      int err = GetLastError();
      if(ok)
      {
         Print("XAU_Profit TEST: OK – otwarto Sell ", lots, " ", g_symbol, ". Broker przyjmuje zlecenia.");
         Comment("XAU_Profit TEST | SUKCES – otwarto zlecenie. Mozna wylaczyc InpTestForceOneOpen.");
      }
      else
      {
         Print("XAU_Profit TEST: FAIL – Sell nie przeszlo. Blad=", err, " ", (err==10019?"TRADE_NOT_ALLOWED":err==10018?"MARKET_CLOSED":err==10014?"INVALID_VOLUME":err==10013?"INVALID_TRADE_VOLUME":""), ". Sprawdz Dziennik.");
         Comment("XAU_Profit TEST | Blad ", err, " – sprawdz Dziennik (Ctrl+J). AutoTrade wlaczony?");
      }
      return;
   }

   // Główny throttle: cała logika (bary, pozycje, wejścia) co 20 s = min. zapytań do serwera
   static datetime s_lastOnTickRun = 0;
   if(TimeCurrent() - s_lastOnTickRun < 20) return;
   s_lastOnTickRun = TimeCurrent();

   if(!HasEnoughBars())
   {
      int need = InpSignalFromCandle ? (InpUseBias ? (InpWPRPeriod+15) : 2) : (InpUseBias ? (InpWPRPeriod+15) : (InpWPRPeriod+2));
      Comment("XAU_Profit | Za malo barow. Potrzeba ", need, " (Entry+bias). Mam: ", Bars(g_symbol, InpEntryTF));
      return;
   }

   if(InpManageThrottleSec <= 0)
      ManagePositions();
   else
   {
      static datetime s_lastManageTime = 0;
      if(TimeCurrent() - s_lastManageTime >= InpManageThrottleSec)
      {
         ManagePositions();
         s_lastManageTime = TimeCurrent();
      }
   }
   g_expectancyStr = GetExpectancyString();

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime todayStart = StringToTime(StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day));
   if(todayStart != g_dayStart)
   {
      g_dayStart = todayStart;
      g_tradesOpenedToday = 0;
      g_lossesToday = 0;
      g_lastLossDirection = 0;
      s_guardConsecLosses = 0;
      g_equityLock = false;
      g_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);

      // Opcjonalnie: reset szczytu equity na nowy dzień (mniej blokowania po DD z poprzedniego dnia)
      // s_guardEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
   }

   if(!SessionOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: poza oknem godzin."); return; }
   if(!FridayOK())  { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: piatek po godzinie stop."); return; }
   if(!EquityDDOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: max equity DD przekroczony."); return; }
   if(!DailyLossLimitOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: dzienny limit straty ", InpDailyLossLimitPct, "%."); return; }
   if(!ConsecutiveLossesOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: zbyt duzo strat z rzedu."); return; }

   bool isNewBar = IsNewBar();
   if(isNewBar) g_barsSinceStart++;
   int maxPosNow = MaxPositionsNow();

   // Zawsze pomiń początek testu (gdy XAU_MIN_BARS_NO_ENTRY>0) – .set tego nie nadpisuje
   if(g_barsSinceStart < XAU_MIN_BARS_NO_ENTRY)
      return;
   if(XAU_MIN_BARS_NO_ENTRY > 0)
   { static bool _startLogged = false; if(!_startLogged) { _startLogged = true; Print("XAU_Profit: pomijanie startu zakonczone, bar ", g_barsSinceStart, " – od teraz mozliwe wejscia."); } }

   // === TRYB ŚWIECA: logika wejścia (throttle 20 s = min. zapytań, mniejsze ryzyko blokady) ===
   if(InpSignalFromCandle)
   {
      static datetime s_lastCandleEntryCheck = 0;
      if(TimeCurrent() - s_lastCandleEntryCheck < 20) return;
      s_lastCandleEntryCheck = TimeCurrent();
      if(InpSkipFirstSeconds > 0 && (TimeCurrent() - g_eaStartTime) < InpSkipFirstSeconds) return;
      if(InpSkipFirstBars > 0 && g_barsSinceStart < InpSkipFirstBars) return;
      if(InpMinBarsHighestTF > 0 && Bars(g_symbol, InpBiasTF3) < InpMinBarsHighestTF) return;

      if(!SpreadOK())
      {
         if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: spread ", (long)SymbolInfoInteger(g_symbol, SYMBOL_SPREAD), " > max ", InpMaxSpreadPoints);
         return;
      }
      if(!ATRFilterOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Rezim: za niska zmiennosc (ATR)."); return; }

      datetime barTime = iTime(g_symbol, InpEntryTF, 0);
      if(InpMinBarsBetweenTrades > 0 && g_lastBarOpenTime == barTime)
      {
         if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Ten bar juz obsluzony. Pozycje: ", CountOurPositions(), "/", maxPosNow);
         return;
      }

      if(InpMinBarsBetweenTrades > 0 && g_lastBarOpenTime > 0)
      {
         int barsSince = (int)Bars(g_symbol, InpEntryTF, g_lastBarOpenTime, TimeCurrent());
         if(barsSince >= 0 && barsSince < InpMinBarsBetweenTrades) return;
      }
      if(InpMaxTradesPerDay > 0 && g_tradesOpenedToday >= InpMaxTradesPerDay)
      {
         if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: dzisiaj juz ", g_tradesOpenedToday, "/", InpMaxTradesPerDay, " wejsc");
         return;
      }
      if(InpMaxLossesPerDay > 0 && g_lossesToday >= InpMaxLossesPerDay) return;
      if(InpCooldownAfterLossBars > 0 && g_lastLossTime > 0)
      {
         int barsSinceLoss = (int)Bars(g_symbol, InpEntryTF, g_lastLossTime, TimeCurrent());
         if(barsSinceLoss >= 0 && barsSinceLoss < InpCooldownAfterLossBars) return;
      }
      if(CountOurPositions() >= maxPosNow)
      {
         if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Max pozycje ", CountOurPositions(), "/", maxPosNow);
         if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime;
         return;
      }
      if(InpMaxPositionsPerBar > 0 && CountOurPositionsOnBar(barTime) >= InpMaxPositionsPerBar)
      {
         if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Max ", InpMaxPositionsPerBar, " pozycji na te swiecy (limit na swiece).");
         if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime;
         return;
      }

      string noEntryReason = "";
      if(CountOurPositions() < maxPosNow)
      {
         int sh = InpCandleUseCurrentBar ? 0 : 1;
         double o1 = iOpen(g_symbol, InpEntryTF, sh);
         double c1 = iClose(g_symbol, InpEntryTF, sh);
         bool isGreen = (o1 > 0.0 && c1 >= o1);
         bool isRed   = (o1 > 0.0 && c1 < o1);
         if(InpDebug) Print("XAU_Profit nowy bar ", TimeToString(barTime,TIME_DATE|TIME_MINUTES), " bar#", sh, " O=", DoubleToString(o1,g_digits), " C=", DoubleToString(c1,g_digits), " zielona=", isGreen, " czerwona=", isRed);
         if(InpCandleRequireTwo)
         {
            double o2 = iOpen(g_symbol, InpEntryTF, sh+1);
            double c2 = iClose(g_symbol, InpEntryTF, sh+1);
            bool prevGreen = (o2 > 0.0 && c2 >= o2);
            bool prevRed   = (o2 > 0.0 && c2 < o2);
            if(!(isGreen && prevGreen)) isGreen = false;
            if(!(isRed && prevRed)) isRed = false;
         }
         // Precyzja: tylko świece z wyraźnym korpusem (omijaj doji)
         if(InpMinBodyPct > 0.0 && (isGreen || isRed))
         {
            double h1 = iHigh(g_symbol, InpEntryTF, sh);
            double l1 = iLow(g_symbol, InpEntryTF, sh);
            double range = (h1 > l1) ? (h1 - l1) : 0.0;
            if(range > 0.0)
            {
               double bodyPct = 100.0 * MathAbs(c1 - o1) / range;
               if(bodyPct < InpMinBodyPct) { isGreen = false; isRed = false; }
            }
         }
         bool trendOkLong = true, trendOkShort = true;
         if(InpUseTrendFilter)
         {
            double closeH = iClose(g_symbol, InpTrendMATF, 1);
            double emaH   = CalcEMAOnTF(1, InpTrendMAPeriod, InpTrendMATF);
            if(emaH > 0.0)
            {
               trendOkLong  = (closeH > emaH);
               trendOkShort = (closeH < emaH);
               if(InpUseRegimeDistFilter && InpRegimeMinDistATR > 0.0)
               {
                  double atrT = CalcATR(1, InpATRPeriod, InpTrendMATF);
                  if(atrT > 0.0)
                  {
                     if(!(trendOkLong  && (closeH - emaH) >= InpRegimeMinDistATR * atrT)) trendOkLong  = false;
                     if(!(trendOkShort && (emaH - closeH) >= InpRegimeMinDistATR * atrT)) trendOkShort = false;
                  }
               }
            }
         }
         // Filtry momentum/odwrócenia: RSI (wbudowany MT5), Stoch/MACD/BB – opcjonalnie
         bool rsiOkLong = true, rsiOkShort = true, stochOkLong = true, stochOkShort = true;
         bool macdOkLong = true, macdOkShort = true, bbOkLong = true, bbOkShort = true;
         int shInd = 1;   // ostatnia zamknięta świeca
         if(InpUseRSIFilter && g_handleRSI != INVALID_HANDLE)
         {
            double rsiBuf[];
            ArraySetAsSeries(rsiBuf, true);
            if(CopyBuffer(g_handleRSI, 0, shInd, 1, rsiBuf) == 1)
            {
               double rsi = rsiBuf[0];
               rsiOkLong  = (rsi < InpRSIOverbought);
               rsiOkShort = (rsi > InpRSIOversold);
            }
         }
         if(InpUseStochFilter)
         {
            double sk, sd;
            CalcStoch(shInd, InpStochK, InpStochD, InpStochSlowing, InpEntryTF, sk, sd);
            stochOkLong  = (sk > sd);
            stochOkShort = (sk < sd);
         }
         if(InpUseMACDFilter)
         {
            double macdMain, macdSig;
            CalcMACD(shInd, InpMACDFast, InpMACDSlow, InpMACDSignal, InpEntryTF, macdMain, macdSig);
            macdOkLong  = (macdMain > macdSig);
            macdOkShort = (macdMain < macdSig);
         }
         if(InpUseBBFilter)
         {
            double bbMid, bbUp, bbLo;
            CalcBollinger(shInd, InpBBPeriod, InpBBDev, InpEntryTF, bbMid, bbUp, bbLo);
            double close1 = iClose(g_symbol, InpEntryTF, shInd);
            bbOkLong  = (close1 > bbLo);
            bbOkShort = (close1 < bbUp);
         }
         int ext = InpUseExternalSignal ? ReadExternalSignal() : 0;
         // Blokuj przeciwny kierunek tylko przy SILNYM sygnale z pliku (żeby bot mógł i kupować i sprzedawać)
         bool blockLong  = (ext == -1 && g_lastExternalSignalStrength >= InpExternalSignalBlockStrength);
         bool blockShort = (ext == 1  && g_lastExternalSignalStrength >= InpExternalSignalBlockStrength);
         bool allowLong  = (XAU_FORCE_ALLOW_BOTH_DIRECTIONS ? true : InpAllowLong)  && !blockLong && trendOkLong && rsiOkLong && stochOkLong && macdOkLong && bbOkLong;
         bool allowShort = (XAU_FORCE_ALLOW_BOTH_DIRECTIONS ? true : InpAllowShort) && !blockShort && trendOkShort && rsiOkShort && stochOkShort && macdOkShort && bbOkShort;
         if(InpUseBias) { allowLong = allowLong && BiasBullish(); allowShort = allowShort && BiasBearish(); }
         if(!InpInvertCandleSignal)
         {
            if(isGreen && allowLong && !BlockedSameDirectionAfterLoss(true) && OpenPosition(true))
            { if(InpDebug) Print("XAU_Profit otwarto Long ", TimeToString(barTime, TIME_DATE|TIME_MINUTES)); if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
            if(isRed && allowShort && !BlockedSameDirectionAfterLoss(false) && OpenPosition(false))
            { if(InpDebug) Print("XAU_Profit otwarto Short ", TimeToString(barTime, TIME_DATE|TIME_MINUTES)); if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
            if(isGreen && allowLong && InpDebug) { noEntryReason = "Kupno odrzucone, blad: " + IntegerToString(GetLastError()); Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Zielona swieca - ", noEntryReason); Print("XAU_Profit Buy odrzucone, blad ", GetLastError()); }
            if(isRed && allowShort && InpDebug) { noEntryReason = "Sprzedaz odrzucona, blad: " + IntegerToString(GetLastError()); Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Czerwona swieca - ", noEntryReason); Print("XAU_Profit Sell odrzucone, blad ", GetLastError()); }
            if(isGreen && noEntryReason == "") { if(!allowLong) noEntryReason = "Long: trend/RSI/Stoch/MACD/BB lub sygnal z pliku"; else if(BlockedSameDirectionAfterLoss(true)) noEntryReason = "Long: blokada po stracie w tym kierunku"; else noEntryReason = "broker odrzucil Kupno (Dziennik)"; }
            if(isRed && noEntryReason == "") { if(!allowShort) noEntryReason = "Short: trend/RSI/Stoch/MACD/BB lub sygnal z pliku"; else if(BlockedSameDirectionAfterLoss(false)) noEntryReason = "Short: blokada po stracie w tym kierunku"; else noEntryReason = "broker odrzucil Sprzedaz (Dziennik)"; }
         }
         else
         {
            if(isGreen && allowShort && !BlockedSameDirectionAfterLoss(false) && OpenPosition(false))
            { if(InpDebug) Print("XAU_Profit otwarto Short (fade) ", TimeToString(barTime, TIME_DATE|TIME_MINUTES)); if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
            if(isRed && allowLong && !BlockedSameDirectionAfterLoss(true) && OpenPosition(true))
            { if(InpDebug) Print("XAU_Profit otwarto Long (fade) ", TimeToString(barTime, TIME_DATE|TIME_MINUTES)); if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
            if(isGreen && allowShort && InpDebug) { noEntryReason = "Sprzedaz (fade) odrzucona, blad: " + IntegerToString(GetLastError()); Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Zielona (fade) - ", noEntryReason); Print("XAU_Profit Sell (fade) odrzucone, blad ", GetLastError()); }
            if(isRed && allowLong && InpDebug) { noEntryReason = "Kupno (fade) odrzucone, blad: " + IntegerToString(GetLastError()); Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Czerwona (fade) - ", noEntryReason); Print("XAU_Profit Buy odrzucone, blad ", GetLastError()); }
            if(isGreen && noEntryReason == "") { if(!allowShort) noEntryReason = "Short (fade): trend/RSI/Stoch/MACD/BB lub sygnal"; else if(BlockedSameDirectionAfterLoss(false)) noEntryReason = "Short: blokada po stracie"; else noEntryReason = "broker odrzucil Sprzedaz (Dziennik)"; }
            if(isRed && noEntryReason == "") { if(!allowLong) noEntryReason = "Long (fade): trend/RSI/Stoch/MACD/BB lub sygnal"; else if(BlockedSameDirectionAfterLoss(true)) noEntryReason = "Long: blokada po stracie"; else noEntryReason = "broker odrzucil Kupno (Dziennik)"; }
         }
         if(!(isGreen || isRed)) noEntryReason = InpCandleRequireTwo ? "brak 2 zielonych lub 2 czerwonych swiec" : "brak zielonej/czerwonej swiecy (doji)";
         if((isGreen || isRed) && InpDebug)
         {
            static datetime s_lastBarLog = 0;
            if(s_lastBarLog != barTime)
            {
               s_lastBarLog = barTime;
               string wantDir = "", why = "";
               if(InpInvertCandleSignal)
               {
                  if(isGreen) { wantDir = "Short"; if(!allowShort) { if(!InpAllowShort) why = "InpAllowShort=0"; else if(ext == 1) why = "sygnal z pliku=LONG"; else if(!trendOkShort) why = "filtr trendu (cena > EMA)"; else why = "allowShort=0"; } else if(BlockedSameDirectionAfterLoss(false)) why = "blocked Short"; else why = "err "+IntegerToString(GetLastError()); }
                  if(isRed)   { wantDir = "Long";  if(!allowLong)  { if(!InpAllowLong) why = "InpAllowLong=0"; else if(ext == -1) why = "sygnal z pliku=SHORT"; else if(!trendOkLong) why = "filtr trendu (cena < EMA)"; else why = "allowLong=0"; } else if(BlockedSameDirectionAfterLoss(true))  why = "blocked Long";  else why = "err "+IntegerToString(GetLastError()); }
               }
               else
               {
                  if(isGreen) { wantDir = "Long";  if(!allowLong)  { if(!InpAllowLong) why = "InpAllowLong=0"; else if(ext == -1) why = "sygnal z pliku=SHORT"; else if(!trendOkLong) why = "filtr trendu (cena < EMA)"; else why = "allowLong=0"; } else if(BlockedSameDirectionAfterLoss(true))  why = "blocked Long";  else why = "err "+IntegerToString(GetLastError()); }
                  if(isRed)   { wantDir = "Short"; if(!allowShort) { if(!InpAllowShort) why = "InpAllowShort=0"; else if(ext == 1) why = "sygnal z pliku=LONG"; else if(!trendOkShort) why = "filtr trendu (cena > EMA)"; else why = "allowShort=0"; } else if(BlockedSameDirectionAfterLoss(false)) why = "blocked Short"; else why = "err "+IntegerToString(GetLastError()); }
               }
               if(wantDir != "" && why != "")
                  Print("XAU_Profit | ", TimeToString(barTime, TIME_DATE|TIME_MINUTES), " ", isGreen ? "zielona" : "czerwona", " -> ", wantDir, " odrzucony: ", why);
            }
         }
      }
      if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime;
      if(InpDebug && CountOurPositions() >= maxPosNow)
         Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Zielona/czerwona OK, ale max pozycje ", CountOurPositions(), "/", maxPosNow);
      else if(InpDebug)
         Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Brak wejscia na tym barze. Pozycje: ", CountOurPositions(), "/", maxPosNow, (noEntryReason != "" ? "\nPowod: " + noEntryReason : ""));
      return;
   }

   // Poniżej: tryb WPR (gdy InpSignalFromCandle = false)
   // Gdy InpEntryOnlyOnNewBar=false: wejście co nowy bar LUB co 1 s (agresywnie, bez limitu wejść na bar)
   if(InpEntryOnlyOnNewBar && !isNewBar)
   {
      if(InpDebug) { static datetime _lastW = 0; if(TimeCurrent() - _lastW >= 10) { string wLim = (InpMaxTradesPerDay > 0) ? IntegerToString(g_tradesOpenedToday)+"/"+IntegerToString(InpMaxTradesPerDay) : IntegerToString(g_tradesOpenedToday)+" (bez limitu)"; Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit WPR | Oczekiwanie na nowy bar. Wejsc: ", wLim); _lastW = TimeCurrent(); } }
      return;
   }
   if(!isNewBar)
   {
      static datetime s_lastWprEntryCheck = 0;
      if(TimeCurrent() - s_lastWprEntryCheck < 20) return;  // bez limitu wejść, ale co 20 s (min. zapytań do serwera)
      s_lastWprEntryCheck = TimeCurrent();
   }

   if(CountOurPositions() >= maxPosNow)
   {
      if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: max pozycje ", CountOurPositions(), "/", maxPosNow);
      return;
   }
   if(!SpreadOK())
   {
      if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Blokada: spread ", (long)SymbolInfoInteger(g_symbol, SYMBOL_SPREAD), " > max ", InpMaxSpreadPoints);
      return;
   }
   if(!ATRFilterOK()) { if(InpDebug) Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Rezim: za niska zmiennosc (ATR)."); return; }

   if(InpSkipFirstSeconds > 0 && (TimeCurrent() - g_eaStartTime) < InpSkipFirstSeconds) return;
   // Początek testu: nie wchodź przez N barów (licznik barów od startu)
   if(InpSkipFirstBars > 0 && g_barsSinceStart < InpSkipFirstBars) return;
   // Rozgrzewka D1: nie wchodź dopóki na najwyższym TF (D1) nie ma wystarczająco barów
   if(InpMinBarsHighestTF > 0 && Bars(g_symbol, InpBiasTF3) < InpMinBarsHighestTF) return;

   // Jednorazowy log: weryfikacja, że pominięcie początku zadziałało (zobacz Dziennik)
   if(!g_skipPassedLogged) { Print("XAU_Profit: pierwsze wejście dozwolone od baru ", g_barsSinceStart, " (D1 bars=", Bars(g_symbol, InpBiasTF3), ")"); g_skipPassedLogged = true; }

   datetime barTime = iTime(g_symbol, InpEntryTF, 0);
   if(InpMinBarsBetweenTrades > 0 && g_lastBarOpenTime == barTime) return;
   if(InpMaxPositionsPerBar > 0)
   {
      int onBar = CountOurPositionsOnBar(barTime);
      if(onBar >= InpMaxPositionsPerBar) return;
   }
   if(InpMinBarsBetweenTrades > 0 && g_lastBarOpenTime > 0)
   {
      int barsSince = (int)Bars(g_symbol, InpEntryTF, g_lastBarOpenTime, TimeCurrent());
      if(barsSince >= 0 && barsSince < InpMinBarsBetweenTrades) return;
   }

   if(InpMaxTradesPerDay > 0)
   {
      MqlDateTime dt2;
      TimeToStruct(TimeCurrent(), dt2);
      datetime todayStart2 = StringToTime(StringFormat("%04d.%02d.%02d", dt2.year, dt2.mon, dt2.day));

      // FIX: reset dnia MUSI resetować też guardy, inaczej tryby zachowują się niespójnie
      if(todayStart2 != g_dayStart)
      {
         g_dayStart = todayStart2;
         g_tradesOpenedToday = 0;
         g_lossesToday = 0;
         g_lastLossDirection = 0;
         s_guardConsecLosses = 0;
         g_equityLock = false;
         g_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);

         // Opcjonalnie:
         // s_guardEquityPeak = AccountInfoDouble(ACCOUNT_EQUITY);
      }

      if(g_tradesOpenedToday >= InpMaxTradesPerDay)
      {
         if(InpDebug)
            Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "",
                    "XAU_Profit | Blokada: dzisiaj juz ", g_tradesOpenedToday, "/", InpMaxTradesPerDay, " wejsc");
         return;
      }
   }
   if(InpMaxLossesPerDay > 0 && g_lossesToday >= InpMaxLossesPerDay) return;

   // Po stracie: nie wchodź przez N barów (ogranicza serię strat)
   if(InpCooldownAfterLossBars > 0 && g_lastLossTime > 0)
   {
      int barsSinceLoss = (int)Bars(g_symbol, InpEntryTF, g_lastLossTime, TimeCurrent());
      if(barsSinceLoss >= 0 && barsSinceLoss < InpCooldownAfterLossBars) return;
   }

   bool doLong  = (XAU_FORCE_ALLOW_BOTH_DIRECTIONS ? true : InpAllowLong)  && SignalLong();
   bool doShort = (XAU_FORCE_ALLOW_BOTH_DIRECTIONS ? true : InpAllowShort) && SignalShort();
   if(doLong && !BlockedSameDirectionAfterLoss(true) && OpenPosition(true))  { if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
   if(doShort && !BlockedSameDirectionAfterLoss(false) && OpenPosition(false)) { if(InpMinBarsBetweenTrades > 0) g_lastBarOpenTime = barTime; g_tradesOpenedToday++; return; }
   if(doLong && InpDebug)
   {
      int err = GetLastError();
      Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Sygnal Long (Kupno) TAK, ale Buy odrzucone. Blad: ", err, " - sprawdz Dziennik (Ctrl+J)");
      Print("XAU_Profit Buy odrzucone, blad ", err);
      return;
   }
   if(doShort && InpDebug)
   {
      int err = GetLastError();
      Comment(g_expectancyStr != "" ? g_expectancyStr + "\n" : "", "XAU_Profit | Sygnal Short TAK, ale Sell odrzucone. Blad: ", err, " (sprawdz Dziennik)");
      return;
   }

   if(InpDebug)
   {
      double wpr = CalcWPR(1, InpWPRPeriod, InpEntryTF);
      bool biasS = BiasBearish(), biasL = BiasBullish();
      long spread = SymbolInfoInteger(g_symbol, SYMBOL_SPREAD);
      string cmt = (StringLen(g_expectancyStr) > 0) ? (g_expectancyStr + "\n") : "";
      cmt += "XAU_Profit | WPR(Entry)=" + DoubleToString(wpr, 1);
      cmt += "\nBias Short=" + (biasS ? "OK" : "--") + " Bias Long=" + (biasL ? "OK" : "--");
      cmt += " | Syg Short=" + (doShort ? "TAK" : "nie") + " Long=" + (doLong ? "TAK" : "nie");
      cmt += "\nPozycje " + IntegerToString(CountOurPositions()) + "/" + IntegerToString(MaxPositionsNow());
      cmt += " | spread " + IntegerToString(spread) + " max " + IntegerToString(InpMaxSpreadPoints);
      cmt += " | barow OK=" + (HasEnoughBars() ? "tak" : "nie");
      Comment(cmt);
   }
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_handleRSI != INVALID_HANDLE) { IndicatorRelease(g_handleRSI); g_handleRSI = INVALID_HANDLE; }
   Comment("");
}
