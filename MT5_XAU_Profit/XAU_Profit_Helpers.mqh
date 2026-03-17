//+------------------------------------------------------------------+
//|                                          XAU_Profit_Helpers.mqh  |
//|  Nowy bar, bary, spread, liczba pozycji. Kompiluj tylko EA.     |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
// g_symbol, InpEntryTF, InpBiasUse1/2/3, InpBiasTF1/2/3, ... – z EA

bool IsNewBar()
{
   datetime t = iTime(g_symbol, InpEntryTF, 0);
   if(t != 0 && t != g_lastBarTime) { g_lastBarTime = t; return true; }
   return false;
}

bool HasEnoughBars()
{
   int req;
   int reqBias = InpWPRPeriod + 15;
   if(InpSignalFromCandle)
      req = 2;
   else
      req = InpUseBias ? reqBias : (InpWPRPeriod + 2);

   // Minimalna liczba barów żeby ATR/wskaźniki miały sens (bez dużego bufora – bot ma handlować)
   int reqATR = InpATRPeriod + 10;
   if(req < reqATR) req = reqATR;

   if(Bars(g_symbol, InpEntryTF) < req) return false;
   if(InpUseBias)
   {
      if(InpBiasUse1 && Bars(g_symbol, InpBiasTF1) < reqBias) return false;
      if(InpBiasUse2 && Bars(g_symbol, InpBiasTF2) < reqBias) return false;
      if(InpBiasUse3 && Bars(g_symbol, InpBiasTF3) < reqBias) return false;
   }
   if(InpUseTrendFilter && Bars(g_symbol, InpTrendMATF) < InpTrendMAPeriod + 50) return false;
   return true;
}

bool SpreadOK()
{
   long spread = SymbolInfoInteger(g_symbol, SYMBOL_SPREAD);
   return (spread >= 0 && spread <= InpMaxSpreadPoints);
}

// Nie wchodź gdy zmienność za niska (rynek płaski, fałszywe sygnały)
bool ATRFilterOK()
{
   if(!InpUseATRFilter || InpATRMinMult <= 0.0) return true;
   double atr = CalcATR(1, InpATRPeriod, InpEntryTF);
   double atrLong = CalcATR(1, InpATRPeriod * 2, InpEntryTF);
   if(atrLong <= 0.0) return true;
   return (atr >= InpATRMinMult * atrLong);
}

int CountOurPositions()
{
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i)) continue;  // wybiera pozycję i
      if(PositionGetString(POSITION_SYMBOL) != g_symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
      n++;
   }
   return n;
}

// CountOurPositionsOnBar jest zdefiniowane w XAU_Profit_EA.mq5 (jedna kopia, z (datetime) dla barEnd)
