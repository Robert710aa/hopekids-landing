//+------------------------------------------------------------------+
//|                                          XAU_Profit_Signals.mqh  |
//|  Bias H1/H4/D1 + Entry na InpEntryTF (M5/M15/M30). Kompiluj EA. |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
extern string            g_symbol;
extern ENUM_TIMEFRAMES   InpEntryTF;
extern int               InpWPRPeriod;
extern double            InpWPROverbought;
extern double            InpWPROversold;
extern bool              InpBiasUseH1;
extern bool              InpBiasUseH4;
extern bool              InpBiasUseD1;
extern bool              InpTradeStrict;
extern bool              InpAllowLong;
extern bool              InpAllowShort;

// Bias bearish = WPR < -20 na danym TF. Dla Short wymagamy bias bearish.
bool BiasBearish()
{
   int ok = 0, req = 0;
   if(InpBiasUseH1) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_H1) < InpWPROverbought) ok++; }
   if(InpBiasUseH4) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_H4) < InpWPROverbought) ok++; }
   if(InpBiasUseD1) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_D1) < InpWPROverbought) ok++; }
   if(req == 0) return true;
   return InpTradeStrict ? (ok == req) : (ok >= 1);
}

bool BiasBullish()
{
   int ok = 0, req = 0;
   if(InpBiasUseH1) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_H1) > InpWPROversold) ok++; }
   if(InpBiasUseH4) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_H4) > InpWPROversold) ok++; }
   if(InpBiasUseD1) { req++; if(CalcWPR(1, InpWPRPeriod, PERIOD_D1) > InpWPROversold) ok++; }
   if(req == 0) return true;
   return InpTradeStrict ? (ok == req) : (ok >= 1);
}

// Short: bias bearish + WPR na Entry TF w strefie overbought (>= -20)
bool SignalShort()
{
   if(!InpAllowShort) return false;
   if(!BiasBearish()) return false;
   double wpr = CalcWPR(1, InpWPRPeriod, InpEntryTF);
   return (wpr >= InpWPROverbought && wpr <= 0.0);
}

// Long: bias bullish + WPR na Entry TF w strefie oversold (<= -80)
bool SignalLong()
{
   if(!InpAllowLong) return false;
   if(!BiasBullish()) return false;
   double wpr = CalcWPR(1, InpWPRPeriod, InpEntryTF);
   return (wpr <= InpWPROversold && wpr >= -100.0);
}
