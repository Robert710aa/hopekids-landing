//+------------------------------------------------------------------+
//| Smart Gold Trend EA - XAUUSD                                     |
//| Bez iMA/iRSI – ręczne EMA/RSI z CopyClose (działa w Testerze)   |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

// ==== PARAMETRY ====
input string   SymbolToTrade     = "XAUUSD";
input double   RiskPercent       = 1.0;
input int      StopLossPoints    = 300;
input int      TakeProfitPoints  = 600;
input int      StartHour         = 8;
input int      EndHour           = 18;
input ulong    MagicNumber       = 234567;

// Okresy (ręczne EMA/RSI)
input int      EMA_H1_Period     = 200;
input int      EMA_M15_Period    = 50;
input int      RSI_M15_Period    = 14;

//+------------------------------------------------------------------+
// Ręczne EMA z CopyClose (dla danego symbolu i timeframe)
//+------------------------------------------------------------------+
double CalcEMA(string symbol, ENUM_TIMEFRAMES tf, int shift, int period)
{
   int need = period + 50;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(symbol, tf, shift, need, close) < need) return 0.0;
   double alpha = 2.0 / (period + 1.0);
   double ema = 0.0;
   for(int i = need - 1; i >= need - period; i--) ema += close[i];
   ema /= period;
   for(int i = need - period - 1; i >= 0; i--) ema = alpha * close[i] + (1.0 - alpha) * ema;
   return ema;
}

double CalcRSI(string symbol, ENUM_TIMEFRAMES tf, int shift, int period)
{
   int need = period + 2;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(symbol, tf, shift, need, close) < need) return 0.0;
   double sumGain = 0.0, sumLoss = 0.0;
   for(int i = 0; i < period; i++)
   {
      double chg = close[i] - close[i + 1];
      if(chg > 0.0) sumGain += chg; else if(chg < 0.0) sumLoss -= chg;
   }
   double avgGain = sumGain / period, avgLoss = sumLoss / period;
   if(avgLoss <= 0.0) return (avgGain > 0.0) ? 100.0 : 50.0;
   return 100.0 - 100.0 / (1.0 + avgGain / avgLoss);
}

bool HasEnoughBars()
{
   int needH1  = EMA_H1_Period + 50;
   int needM15 = MathMax(EMA_M15_Period + 50, RSI_M15_Period + 2);
   if(Bars(SymbolToTrade, PERIOD_H1)  < needH1)  return false;
   if(Bars(SymbolToTrade, PERIOD_M15) < needM15) return false;
   return true;
}

//+------------------------------------------------------------------+
double CalculateLot(double stopLossPoints)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;

   double tickValue = SymbolInfoDouble(SymbolToTrade, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(SymbolToTrade, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(SymbolToTrade, SYMBOL_POINT);
   if(tickSize <= 0.0 || point <= 0.0) return SymbolInfoDouble(SymbolToTrade, SYMBOL_VOLUME_MIN);

   double lot = riskAmount / (stopLossPoints * point * tickValue / tickSize);

   double minLot = SymbolInfoDouble(SymbolToTrade, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(SymbolToTrade, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(SymbolToTrade, SYMBOL_VOLUME_STEP);
   if(lotStep <= 0.0) lotStep = 0.01;
   lot = MathMax(minLot, MathMin(maxLot, lot));
   lot = NormalizeDouble(lot / lotStep, 0) * lotStep;
   return lot;
}

bool IsOurPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != SymbolToTrade) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)MagicNumber) continue;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(!SymbolInfoInteger(SymbolToTrade, SYMBOL_SELECT))
      SymbolSelect(SymbolToTrade, true);
   double point = SymbolInfoDouble(SymbolToTrade, SYMBOL_POINT);
   if(point <= 0.0) { Print("Smart Gold Trend: błąd symbolu ", SymbolToTrade); return INIT_FAILED; }
   trade.SetExpertMagicNumber((int)MagicNumber);
   Print("Smart Gold Trend EA start (ręczne EMA/RSI, bez wskaźników – brak 4801).");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) { }

//+------------------------------------------------------------------+
void OnTick()
{
   if(_Symbol != SymbolToTrade) return;
   if(IsOurPosition()) return;
   if(!HasEnoughBars()) return;

   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   if(time.hour < StartHour || time.hour > EndHour) return;

   double emaH1  = CalcEMA(SymbolToTrade, PERIOD_H1,  1, EMA_H1_Period);
   double emaM15 = CalcEMA(SymbolToTrade, PERIOD_M15, 1, EMA_M15_Period);
   double rsi    = CalcRSI(SymbolToTrade, PERIOD_M15, 1, RSI_M15_Period);

   if(emaH1 == 0.0 || emaM15 == 0.0) return;

   double bid   = SymbolInfoDouble(SymbolToTrade, SYMBOL_BID);
   double ask   = SymbolInfoDouble(SymbolToTrade, SYMBOL_ASK);
   double point = SymbolInfoDouble(SymbolToTrade, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(SymbolToTrade, SYMBOL_DIGITS);

   double lot = CalculateLot((double)StopLossPoints);
   double sl, tp;

   // BUY: price > EMA H1 && price <= EMA M15 && RSI < 40
   if(bid > emaH1 && bid <= emaM15 && rsi < 40.0)
   {
      sl = NormalizeDouble(ask - StopLossPoints * point, digits);
      tp = NormalizeDouble(ask + TakeProfitPoints * point, digits);
      if(!trade.Buy(lot, SymbolToTrade, ask, sl, tp, "Smart Buy"))
         Print("Smart Gold Trend Buy błąd: ", GetLastError());
      return;
   }

   // SELL: price < EMA H1 && price >= EMA M15 && RSI > 60
   if(bid < emaH1 && bid >= emaM15 && rsi > 60.0)
   {
      sl = NormalizeDouble(bid + StopLossPoints * point, digits);
      tp = NormalizeDouble(bid - TakeProfitPoints * point, digits);
      if(!trade.Sell(lot, SymbolToTrade, bid, sl, tp, "Smart Sell"))
         Print("Smart Gold Trend Sell błąd: ", GetLastError());
   }
}
//+------------------------------------------------------------------+
