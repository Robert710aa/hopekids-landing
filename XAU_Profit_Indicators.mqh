//+------------------------------------------------------------------+
//|                                        XAU_Profit_Indicators.mqh  |
//|  WPR (Williams %R) + ATR. NIE kompiluj – kompiluj XAU_Profit_EA  |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
extern string            g_symbol;
extern ENUM_TIMEFRAMES   InpEntryTF;
extern int               InpWPRPeriod;

// Williams %R: -100..0. Overbought ~-20, oversold ~-80
double CalcWPR(int shift, int period, ENUM_TIMEFRAMES tf)
{
   int need = period + 2;
   double high[], low[], close[];
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true);
   if(CopyHighInt(g_symbol, tf, shift, need, high) < need) return 0.0;
   if(CopyLowInt(g_symbol, tf, shift, need, low) < need) return 0.0;
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return 0.0;
   double hh = high[0], ll = low[0];
   for(int i = 1; i < period; i++)
   {
      if(high[i] > hh) hh = high[i];
      if(low[i] < ll)  ll = low[i];
   }
   if(hh <= ll) return -50.0;
   return -100.0 * (hh - close[0]) / (hh - ll);
}

double CalcATR(int shift, int period, ENUM_TIMEFRAMES tf)
{
   int need = period + 2;
   double high[], low[], close[];
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true);
   if(CopyHighInt(g_symbol, tf, shift, need, high) < need) return 0.0;
   if(CopyLowInt(g_symbol, tf, shift, need, low) < need) return 0.0;
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return 0.0;
   double tr = 0.0;
   for(int i = 0; i < period; i++)
   {
      double hl = high[i] - low[i];
      double hc = (i+1 < need) ? MathAbs(high[i] - close[i+1]) : hl;
      double lc = (i+1 < need) ? MathAbs(low[i] - close[i+1]) : hl;
      tr += MathMax(hl, MathMax(hc, lc));
   }
   return tr / (double)period;
}
