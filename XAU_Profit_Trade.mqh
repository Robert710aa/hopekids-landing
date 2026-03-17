//+------------------------------------------------------------------+
//|                                           XAU_Profit_Trade.mqh   |
//|  Otwieranie pozycji (ATR SL/TP), trailing, zarządzanie. Kompiluj EA. |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
extern string            g_symbol;
extern int               g_digits;
extern double            g_point;
extern ENUM_TIMEFRAMES   InpEntryTF;
extern double            InpLots;
extern int               InpATRPeriod;
extern double            InpATRMultiplierSL;
extern double            InpATRMultiplierTP;
extern bool              InpUseTrailingStop;
extern double            InpTrailATRMult;
extern int               InpMagicNumber;
extern bool              InpDebug;

double NormPrice(double price)
{
   return NormalizeDouble(price, g_digits);
}
double NormLots(double lots)
{
   double minLot = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0) step = 0.01;
   double n = MathFloor(lots / step + 0.5) * step;
   if(n < minLot) n = minLot;
   if(n > maxLot) n = maxLot;
   return NormalizeDouble(n, 2);
}

bool OpenPosition(bool isBuy)
{
   if(SymbolInfoInteger(g_symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED) return false;
   double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0) return false;

   double atr = CalcATR(1, InpATRPeriod, InpEntryTF);
   if(atr <= 0.0) return false;

   double entry = isBuy ? ask : bid;
   double slDist = atr * InpATRMultiplierSL;
   double tpDist = atr * InpATRMultiplierTP;
   double sl = isBuy ? NormPrice(entry - slDist) : NormPrice(entry + slDist);
   double tp = isBuy ? NormPrice(entry + tpDist) : NormPrice(entry - tpDist);

   double lots = NormLots(InpLots);
   string sym = g_symbol;
   bool ok = false;
   if(isBuy)
      ok = g_trade.Buy(lots, sym, entry, sl, tp, "XAU_WPR");
   else
      ok = g_trade.Sell(lots, sym, entry, sl, tp, "XAU_WPR");

   if(InpDebug && !ok) Print("OpenPosition ", (isBuy?"Buy":"Sell"), " err ", GetLastError());
   return ok;
}

void ManagePositions()
{
   double atr = CalcATR(1, InpATRPeriod, InpEntryTF);
   if(atr <= 0.0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) != g_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long type = PositionGetInteger(POSITION_TYPE);

      if(!InpUseTrailingStop) continue;

      double trailDist = atr * InpTrailATRMult;
      double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);

      if(type == POSITION_TYPE_SELL)
      {
         double newSl = NormPrice(bid + trailDist);
         if(newSl < openPrice && (sl == 0.0 || newSl < sl))
         {
            if(g_trade.PositionModify(ticket, newSl, tp))
               if(InpDebug) Print("Trail Sell ticket ", ticket, " SL ", newSl);
         }
      }
      else
      {
         double newSl = NormPrice(ask - trailDist);
         if(newSl > openPrice && (sl == 0.0 || newSl > sl))
         {
            if(g_trade.PositionModify(ticket, newSl, tp))
               if(InpDebug) Print("Trail Buy ticket ", ticket, " SL ", newSl);
         }
      }
   }
}
