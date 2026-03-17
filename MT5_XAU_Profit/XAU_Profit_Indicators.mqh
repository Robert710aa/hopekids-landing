//+------------------------------------------------------------------+
//|                                        XAU_Profit_Indicators.mqh  |
//|  WPR (Williams %R) + ATR. NIE kompiluj - kompiluj XAU_Profit_EA  |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
// g_symbol, InpEntryTF, InpWPRPeriod z EA

double CalcEMAOnTF(int shift, int period, ENUM_TIMEFRAMES tf)
{
   int need = period + 50;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return 0.0;
   double alpha = 2.0 / (period + 1.0);
   double ema = 0.0;
   for(int i = need - 1; i >= need - period; i--) ema += close[i];
   ema /= period;
   for(int i = need - period - 1; i >= 0; i--) ema = alpha * close[i] + (1.0 - alpha) * ema;
   return ema;
}

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

// RSI 0..100 (Wilder). Long gdy RSI < overbought, Short gdy RSI > oversold
double CalcRSI(int shift, int period, ENUM_TIMEFRAMES tf)
{
   int need = period + 20;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return 50.0;
   double sumG = 0.0, sumL = 0.0;
   for(int i = 0; i < period; i++)
   {
      double chg = close[i] - close[i+1];
      if(chg > 0.0) sumG += chg; else sumL -= chg;
   }
   double avgG = sumG / (double)period, avgL = sumL / (double)period;
   for(int i = period; i < need - 1 && i < period + 30; i++)
   {
      double chg = close[i] - close[i+1];
      avgG = (avgG * (period - 1) + (chg > 0.0 ? chg : 0.0)) / (double)period;
      avgL = (avgL * (period - 1) + (chg < 0.0 ? -chg : 0.0)) / (double)period;
   }
   if(avgL <= 0.0) return 100.0;
   double rs = avgG / avgL;
   return 100.0 - 100.0 / (1.0 + rs);
}

// Stochastic %K i %D (0..100). Long gdy K > D (momentum w górę), Short gdy K < D
void CalcStoch(int shift, int Kperiod, int Dperiod, int slowing, ENUM_TIMEFRAMES tf, double &outK, double &outD)
{
   outK = 50.0; outD = 50.0;
   int need = Kperiod + Dperiod + slowing + 5;
   double high[], low[], close[];
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true);
   if(CopyHighInt(g_symbol, tf, shift, need, high) < need) return;
   if(CopyLowInt(g_symbol, tf, shift, need, low) < need) return;
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return;
   double rawK[];
   ArrayResize(rawK, need);
   for(int i = 0; i < need - Kperiod; i++)
   {
      double hh = high[i], ll = low[i];
      for(int j = 1; j < Kperiod; j++) { if(high[i+j] > hh) hh = high[i+j]; if(low[i+j] < ll) ll = low[i+j]; }
      if(hh <= ll) rawK[i] = 50.0; else rawK[i] = 100.0 * (close[i] - ll) / (hh - ll);
   }
   for(int s = 0; s < slowing - 1; s++)
      for(int i = 0; i < need - Kperiod - 1; i++)
         rawK[i] = (rawK[i] + rawK[i+1]) / 2.0;
   outK = rawK[0];
   double sum = 0.0;
   for(int d = 0; d < Dperiod && d < need; d++) sum += rawK[d];
   outD = (Dperiod > 0) ? sum / (double)Dperiod : outK;
}

// MACD: main = EMA(fast) minus EMA(slow), signal = EMA(main). Long gdy main > signal
void CalcMACD(int shift, int fast, int slow, int signal, ENUM_TIMEFRAMES tf, double &outMain, double &outSignal)
{
   outMain = 0.0; outSignal = 0.0;
   int need = slow + signal + 30;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return;
   double aF = 2.0 / (fast + 1.0), aS = 2.0 / (slow + 1.0), aSig = 2.0 / (signal + 1.0);
   double emaF = close[need-1], emaS = close[need-1];
   for(int i = need - 2; i >= 0; i--)
   {
      emaF = aF * close[i] + (1.0 - aF) * emaF;
      emaS = aS * close[i] + (1.0 - aS) * emaS;
   }
   outMain = emaF - emaS;
   double macdArr[]; ArrayResize(macdArr, need);
   emaF = close[need-1]; emaS = close[need-1];
   for(int i = need - 2; i >= 0; i--)
   {
      emaF = aF * close[i] + (1.0 - aF) * emaF;
      emaS = aS * close[i] + (1.0 - aS) * emaS;
      macdArr[i] = emaF - emaS;
   }
   double emaSig = macdArr[0];
   for(int i = 1; i < MathMin(signal + 5, need); i++) emaSig = aSig * macdArr[i] + (1.0 - aSig) * emaSig;
   outSignal = emaSig;
}

// Bollinger: middle = SMA(period), upper/lower = middle +/- dev*StdDev
void CalcBollinger(int shift, int period, double dev, ENUM_TIMEFRAMES tf, double &outMiddle, double &outUpper, double &outLower)
{
   outMiddle = 0.0; outUpper = 0.0; outLower = 0.0;
   int need = period + 2;
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyCloseInt(g_symbol, tf, shift, need, close) < need) return;
   double sum = 0.0;
   for(int i = 0; i < period; i++) sum += close[i];
   outMiddle = sum / (double)period;
   double sq = 0.0;
   for(int i = 0; i < period; i++) sq += (close[i] - outMiddle) * (close[i] - outMiddle);
   double std = (period > 0 && sq >= 0.0) ? MathSqrt(sq / (double)period) : 0.0;
   outUpper = outMiddle + dev * std;
   outLower = outMiddle - dev * std;
}
