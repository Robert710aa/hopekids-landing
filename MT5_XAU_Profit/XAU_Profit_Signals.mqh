//+------------------------------------------------------------------+
//|                                          XAU_Profit_Signals.mqh  |
//|  Bias H1/H4/D1 + Entry na InpEntryTF (M5/M15/M30). Kompiluj EA. |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
// Wszystkie Inp* i g_symbol – z EA

// Bias bearish = WPR < -20 na danym TF. Dla Short wymagamy bias bearish.
bool BiasBearish()
{
   int ok = 0, req = 0;
   if(InpBiasUse1) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF1) < InpWPROverbought) ok++; }
   if(InpBiasUse2) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF2) < InpWPROverbought) ok++; }
   if(InpBiasUse3) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF3) < InpWPROverbought) ok++; }
   if(req == 0) return true;
   return InpTradeStrict ? (ok == req) : (ok >= 1);
}

bool BiasBullish()
{
   int ok = 0, req = 0;
   if(InpBiasUse1) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF1) > InpWPROversold) ok++; }
   if(InpBiasUse2) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF2) > InpWPROversold) ok++; }
   if(InpBiasUse3) { req++; if(CalcWPR(1, InpWPRPeriod, InpBiasTF3) > InpWPROversold) ok++; }
   if(req == 0) return true;
   return InpTradeStrict ? (ok == req) : (ok >= 1);
}

// Świeca: zielona = close >= open (również doji = lekko wzrost), czerwona = close < open. Bar 0 = bieżąca (ze strzałką)
bool CandleBullish()
{
   int sh = InpCandleUseCurrentBar ? 0 : 1;
   double o = iOpen(g_symbol, InpEntryTF, sh);
   double c = iClose(g_symbol, InpEntryTF, sh);
   return (o > 0.0 && c >= o);
}
bool CandleBearish()
{
   int sh = InpCandleUseCurrentBar ? 0 : 1;
   double o = iOpen(g_symbol, InpEntryTF, sh);
   double c = iClose(g_symbol, InpEntryTF, sh);
   return (o > 0.0 && c < o);
}

// Short: opcjonalnie bias bearish + WPR w strefie overbought + opcjonalnie trend w dół (cena < EMA)
bool SignalShort()
{
   if(!InpAllowShort) return false;
   if(InpSignalFromCandle) return CandleBearish();
   if(InpUseBias && !BiasBearish()) return false;
   if(InpUseTrendFilter)
   {
      double closeH = iClose(g_symbol, InpTrendMATF, 1);
      double emaH   = CalcEMAOnTF(1, InpTrendMAPeriod, InpTrendMATF);
      if(emaH == 0.0 || closeH >= emaH) return false;  // short tylko w trendzie w dół
      if(InpUseRegimeDistFilter && InpRegimeMinDistATR > 0.0)
      {
         double atrT = CalcATR(1, InpATRPeriod, InpTrendMATF);
         if(atrT > 0.0 && (emaH - closeH) < InpRegimeMinDistATR * atrT) return false;
      }
   }
   double wpr1 = CalcWPR(1, InpWPRPeriod, InpEntryTF);
   if(wpr1 < InpWPROverbought || wpr1 > 0.0) return false;
   if(InpRequireWPRCross)
   {
      double wpr2 = CalcWPR(2, InpWPRPeriod, InpEntryTF);
      if(wpr2 >= InpWPROverbought) return false;
   }
   return true;
}

// Long: opcjonalnie bias bullish + WPR w strefie oversold + opcjonalnie trend w górę (cena > EMA)
bool SignalLong()
{
   if(!InpAllowLong) return false;
   if(InpSignalFromCandle) return CandleBullish();
   if(InpUseBias && !BiasBullish()) return false;
   if(InpUseTrendFilter)
   {
      double closeH = iClose(g_symbol, InpTrendMATF, 1);
      double emaH   = CalcEMAOnTF(1, InpTrendMAPeriod, InpTrendMATF);
      if(emaH == 0.0 || closeH <= emaH) return false;
      if(InpUseRegimeDistFilter && InpRegimeMinDistATR > 0.0)
      {
         double atrT = CalcATR(1, InpATRPeriod, InpTrendMATF);
         if(atrT > 0.0 && (closeH - emaH) < InpRegimeMinDistATR * atrT) return false;
      }
   }
   double wpr1 = CalcWPR(1, InpWPRPeriod, InpEntryTF);
   if(wpr1 > InpWPROversold || wpr1 < -100.0) return false;
   if(InpRequireWPRCross)
   {
      double wpr2 = CalcWPR(2, InpWPRPeriod, InpEntryTF);
      if(wpr2 <= InpWPROversold) return false;
   }
   return true;
}
