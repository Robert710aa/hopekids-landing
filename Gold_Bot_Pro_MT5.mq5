//+------------------------------------------------------------------+
//|                    GOLD BOT PRO+ MT5                            |
//|  Trend H1 + Entry M15 + ATR SL/TP + Trailing + USA Session     |
//|  Jesli dalej straty: 1) Testuj tylko Long (AllowShort=false)    |
//|  lub tylko Short (AllowLong=false). 2) Uzyj Optymalizacji      |
//|  (Tester: Optymalizacja, kryterium Profit Factor).              |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

//---- INPUTS
input double FixedLot = 0.01;
input int MaxPositions = 1;        // 1 = mniej ryzyka, jedna pozycja

input int StrategyMode = 1;         // 0 = Trend (w strone trendu), 1 = Reversal (odwrotka od dołka/szczytu)
input int RSIPeriod = 14;
input double RSI_Buy = 50;          // Trend: Buy RSI> | Reversal: Buy RSI<
input double RSI_Sell = 50;         // Trend: Sell RSI< | Reversal: Sell RSI>
input double RSI_MaxBuy = 72;       // Trend: max RSI przy Buy
input double RSI_MinSell = 28;      // Trend: min RSI przy Sell
input double RSI_Oversold = 35;     // Reversal: strefa dołka
input double RSI_Overbought = 65;   // Reversal: strefa szczytu
input bool RequireRSICross = true;  // Reversal: wejscie tylko gdy RSI wlasnie wyszedl ze strefy (cross)

input int ATRPeriod = 14;
input double SL_ATR_Multiplier = 1.0;   // SL wąsko = szybki stop
input double TP_ATR_Multiplier = 2.0;   // TP = 2*SL (szybki zysk, stosunek 2:1)

input bool UseBreakEven = true;     // Przesuń SL na wejście po X zysku
input double BE_ATR_Mult = 0.5;     // Break-even gdy zysk >= ATR * ten

input bool UseTrailing = true;
input double Trailing_ATR_Multiplier = 0.8;  // Trailing bliżej ceny = szybsze zamykanie zysku
input double TrailMinATR = 0.3;    // Trailing tylko gdy zysk >= ATR * ten

input bool AllowLong = true;        // Zezwol na Long (wylacz = testuj tylko Short)
input bool AllowShort = true;       // Zezwol na Short (wylacz = testuj tylko Long)
input bool UseUSASession = false;   // false = handluj caly dzien (do testow), true = tylko 14:00-22:00
input bool Debug = false;           // true = w Dzienniku pokaz, dlaczego nie otwarto

//---- Indicator Handles
int emaH1Handle;
int rsiHandle;
int atrHandle;

// Nowy bar M15 = jedno wejście na bar (brak lawiny zleceń)
datetime g_lastBarTime = 0;
const ENUM_TIMEFRAMES ENTRY_TF = PERIOD_M15;

//+------------------------------------------------------------------+
int OnInit()
{
   emaH1Handle = iMA(_Symbol, PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);
   rsiHandle   = iRSI(_Symbol, PERIOD_M15, RSIPeriod, PRICE_CLOSE);
   atrHandle   = iATR(_Symbol, PERIOD_M15, ATRPeriod);

   if(emaH1Handle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
   {
      Print("Blad tworzenia wskaznikow.");
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(emaH1Handle != INVALID_HANDLE) IndicatorRelease(emaH1Handle);
   if(rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
}

//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime t = iTime(_Symbol, ENTRY_TF, 0);
   if(t == 0) return false;
   if(t != g_lastBarTime) { g_lastBarTime = t; return true; }
   return false;
}

//+------------------------------------------------------------------+
bool IsUSASession()
{
   MqlDateTime str;
   TimeToStruct(TimeCurrent(), str);
   return (str.hour >= 14 && str.hour <= 22);
}

//+------------------------------------------------------------------+
void OnTick()
{
   // Trailing zawsze (takze poza sesja USA), zeby SL sie przesuwal
   if(UseTrailing)
   {
      double atr[];
      if(CopyBuffer(atrHandle, 0, 0, 1, atr) == 1)
         ManageTrailing(atr[0]);
   }

   if(UseUSASession && !IsUSASession())
   {
      if(Debug) Comment("GOLD_BOT: poza sesja USA (14-22).");
      return;
   }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
      return;
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
      return;

   if(CountPositions() >= MaxPositions)
      return;

   // Wejscie TYLKO na nowym barze M15 = jedno zlecenie na bar (bez lawiny)
   if(!IsNewBar())
      return;

   // Wystarczy ze symbol ma tyle barow (BarsCalculated w testerze czesto blokuje)
   if(Bars(_Symbol, PERIOD_H1) < 200 || Bars(_Symbol, PERIOD_M15) < 30)
   {
      if(Debug) Comment("GOLD_BOT: za malo barow. H1=", Bars(_Symbol, PERIOD_H1), " M15=", Bars(_Symbol, PERIOD_M15));
      return;
   }

   // Sygnal na barze ZAMKNIETYM (shift 1); dla Reversal+Cross potrzebujemy 2 bary RSI
   double emaH1[], rsi[], atr[];
   int rsiBars = (StrategyMode == 1 && RequireRSICross) ? 2 : 1;
   int c1 = CopyBuffer(emaH1Handle, 0, 1, 1, emaH1);
   int c2 = CopyBuffer(rsiHandle, 0, 1, rsiBars, rsi);
   int c3 = CopyBuffer(atrHandle, 0, 1, 1, atr);
   if(c1 != 1 || c2 != rsiBars || c3 != 1)
   {
      if(Debug) Print("GOLD_BOT CopyBuffer: ema=", c1, " rsi=", c2, " atr=", c3, " err=", GetLastError());
      return;
   }

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0 || bid <= 0 || atr[0] <= 0)
      return;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0) return;

   double SL = atr[0] * SL_ATR_Multiplier;
   double TP = atr[0] * TP_ATR_Multiplier;
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = (stopsLevel > 0) ? (stopsLevel * point) : (10 * point);
   if(SL < minDist) SL = minDist;
   if(TP < minDist) TP = minDist;

   double slBuy  = NormalizeDouble(ask - SL, digits);
   double tpBuy  = NormalizeDouble(ask + TP, digits);
   double slSell = NormalizeDouble(bid + SL, digits);
   double tpSell = NormalizeDouble(bid - TP, digits);

   bool doBuy = false, doSell = false;
   if(StrategyMode == 0)
   {
      doBuy  = (bid > emaH1[0] && rsi[0] > RSI_Buy && rsi[0] < RSI_MaxBuy);
      doSell = (bid < emaH1[0] && rsi[0] < RSI_Sell && rsi[0] > RSI_MinSell);
   }
   else
   {
      // REVERSAL: wejscie gdy RSI wlasnie wyszlo ze strefy (cross) = odwrotka, nie wejscie w sam dołek
      if(RequireRSICross && rsiBars >= 2)
      {
         // Buy: poprzedni bar RSI < oversold, teraz RSI > oversold (cross w gore) + cena pod EMA
         doBuy  = (bid < emaH1[0] && rsi[1] < RSI_Oversold && rsi[0] > RSI_Oversold && rsi[0] < 50);
         // Sell: poprzedni bar RSI > overbought, teraz RSI < overbought (cross w dol) + cena nad EMA
         doSell = (bid > emaH1[0] && rsi[1] > RSI_Overbought && rsi[0] < RSI_Overbought && rsi[0] > 50);
      }
      else
      {
         doBuy  = (bid < emaH1[0] && rsi[0] < RSI_Oversold);
         doSell = (bid > emaH1[0] && rsi[0] > RSI_Overbought);
      }
   }

   if(AllowLong && doBuy)
   {
      if(Debug) Print("GOLD_BOT: proba BUY [", (StrategyMode==0?"Trend":"Reversal"), "] bid=", bid, " EMA=", emaH1[0], " RSI=", rsi[0]);
      if(trade.Buy(FixedLot, _Symbol, ask, slBuy, tpBuy, "GOLD_BOT"))
         return;
      if(Debug) Print("GOLD_BOT Buy blad: ", GetLastError());
   }
   if(AllowShort && doSell)
   {
      if(Debug) Print("GOLD_BOT: proba SELL [", (StrategyMode==0?"Trend":"Reversal"), "] bid=", bid, " EMA=", emaH1[0], " RSI=", rsi[0]);
      if(!trade.Sell(FixedLot, _Symbol, bid, slSell, tpSell, "GOLD_BOT") && Debug)
         Print("GOLD_BOT Sell blad: ", GetLastError());
   }

   if(Debug)
      Comment("GOLD_BOT | ", (StrategyMode==0?"Trend":"Reversal"), " | EMA=", DoubleToString(emaH1[0], (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
              " RSI=", DoubleToString(rsi[0],1), " | Buy=", (doBuy?"TAK":"nie"), " Sell=", (doSell?"TAK":"nie"));
}

//+------------------------------------------------------------------+
void ManageTrailing(double atrValue)
{
   if(atrValue <= 0) return;

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0) return;

   double beDist = atrValue * BE_ATR_Mult;
   double trailMinDist = atrValue * TrailMinATR;
   double trailDist = atrValue * Trailing_ATR_Multiplier;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long type = PositionGetInteger(POSITION_TYPE);
      double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      if(type == POSITION_TYPE_BUY)
      {
         double profitDist = currentBid - openPrice;
         bool atBE = (sl >= openPrice - point*5 && sl <= openPrice + point*5);

         if(UseBreakEven && !atBE && profitDist >= beDist)
         {
            double newSl = NormalizeDouble(openPrice, digits);
            if(trade.PositionModify(ticket, newSl, tp)) continue;
         }
         if(UseTrailing && (TrailMinATR <= 0 || profitDist >= trailMinDist))
         {
            double newSL = NormalizeDouble(currentBid - trailDist, digits);
            if(newSL > openPrice && (sl == 0 || newSL > sl))
               trade.PositionModify(ticket, newSL, tp);
         }
      }
      else if(type == POSITION_TYPE_SELL)
      {
         double profitDist = openPrice - currentAsk;
         bool atBE = (sl >= openPrice - point*5 && sl <= openPrice + point*5);

         if(UseBreakEven && !atBE && profitDist >= beDist)
         {
            double newSl = NormalizeDouble(openPrice, digits);
            if(trade.PositionModify(ticket, newSl, tp)) continue;
         }
         if(UseTrailing && (TrailMinATR <= 0 || profitDist >= trailMinDist))
         {
            double newSL = NormalizeDouble(currentAsk + trailDist, digits);
            if(newSL < openPrice && (sl == 0 || newSL < sl))
               trade.PositionModify(ticket, newSL, tp);
         }
      }
   }
}

//+------------------------------------------------------------------+
int CountPositions()
{
   int total = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i))
         continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
         total++;
   }
   return total;
}

