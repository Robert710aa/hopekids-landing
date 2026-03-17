//+------------------------------------------------------------------+
//|                                          XAU_Profit_Helpers.mqh  |
//|  Nowy bar, bary, spread, liczba pozycji. Kompiluj tylko EA.     |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
extern string         g_symbol;
extern ENUM_TIMEFRAMES InpEntryTF;
extern datetime       g_lastBarTime;
extern double         g_point;
extern int            InpWPRPeriod;
extern int            InpMaxSpreadPoints;
extern int            InpMagicNumber;
extern bool           InpBiasUseH1;
extern bool           InpBiasUseH4;
extern bool           InpBiasUseD1;

bool IsNewBar()
{
   datetime t = iTime(g_symbol, InpEntryTF, 0);
   if(t != 0 && t != g_lastBarTime) { g_lastBarTime = t; return true; }
   return false;
}

bool HasEnoughBars()
{
   int req = InpWPRPeriod + 30;
   if(Bars(g_symbol, InpEntryTF) < req) return false;
   if(InpBiasUseH1 && Bars(g_symbol, PERIOD_H1) < req) return false;
   if(InpBiasUseH4 && Bars(g_symbol, PERIOD_H4) < req) return false;
   if(InpBiasUseD1 && Bars(g_symbol, PERIOD_D1) < req) return false;
   return true;
}

bool SpreadOK()
{
   long spread = SymbolInfoInteger(g_symbol, SYMBOL_SPREAD);
   return (spread >= 0 && spread <= InpMaxSpreadPoints);
}

int CountOurPositions()
{
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) != g_symbol) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
      n++;
   }
   return n;
}
