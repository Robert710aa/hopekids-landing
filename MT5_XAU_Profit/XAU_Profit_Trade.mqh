//+------------------------------------------------------------------+
//|                                           XAU_Profit_Trade.mqh   |
//|  Otwieranie pozycji (ATR SL/TP), trailing, zarządzanie. Kompiluj EA. |
//+------------------------------------------------------------------+
#ifndef _XAU_PROFIT_EA_COMPILING_
   #error "Kompiluj XAU_Profit_EA.mq5 (F7), nie ten plik."
#endif
#property strict
// g_symbol, g_digits, g_point, InpEntryTF, InpLots, InpATRPeriod, InpATRMultiplierSL/TP, InpUseTrailingStop, InpTrailATRMult, InpMagicNumber, InpDebug – z EA

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
   long stopsLevel = SymbolInfoInteger(g_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = (stopsLevel > 0) ? (stopsLevel * g_point) : (50.0 * g_point);
   double slDist, tpDist;
   if(atr > 0.0)
   {
      slDist = atr * InpATRMultiplierSL;
      tpDist = atr * InpATRMultiplierTP;
   }
   else
   {
      slDist = MathMax(100.0 * g_point, minDist);
      tpDist = MathMax(200.0 * g_point, minDist);
   }
   if(slDist < minDist) slDist = minDist;
   if(tpDist < minDist) tpDist = minDist;
   // Na realu: TP bez spreadu = trzeba więcej ruchu żeby trafić. Dodaj spread do TP żeby realnie zarabiać.
   if(InpAddSpreadToTP)
   {
      long spreadPts = SymbolInfoInteger(g_symbol, SYMBOL_SPREAD);
      if(spreadPts > 0) tpDist += (double)spreadPts * g_point;
   }

   double entry = isBuy ? ask : bid;
   double sl = 0.0, tp = 0.0;
   if(InpUseSLTP)
   {
      sl = isBuy ? NormPrice(entry - slDist) : NormPrice(entry + slDist);
      tp = isBuy ? NormPrice(entry + tpDist) : NormPrice(entry - tpDist);
   }

   double lots = InpLots;
   if(InpInvestAmount > 0.0)
   {
      double margin1 = 0.0;
      if(OrderCalcMargin(isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, g_symbol, 1.0, entry, margin1) && margin1 > 0.0)
         lots = InpInvestAmount / margin1;
   }
   lots = NormLots(lots);
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
   if(CountOurPositions() == 0) return;   // brak pozycji = zero zapytań (ATR, Bid/Ask) co tick
   double atr = CalcATR(1, InpATRPeriod, InpEntryTF);
   if(atr <= 0.0) return;

   long stopsLevel = SymbolInfoInteger(g_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDist = (stopsLevel > 0) ? (stopsLevel * g_point) : (50.0 * g_point);
   double slDist = atr * InpATRMultiplierSL;
   double tpDist = atr * InpATRMultiplierTP;
   if(slDist < minDist) slDist = minDist;
   if(tpDist < minDist) tpDist = minDist;

   double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
   double beDist = atr * InpBE_Trigger_ATR;
   double beOffset = (InpBE_OffsetPoints > 0) ? ((double)InpBE_OffsetPoints * g_point) : 0.0;
   double trailMinDist = atr * InpTrailMinATR;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!PositionGetTicket(i)) continue;  // wybiera pozycję i
      if(PositionGetString(POSITION_SYMBOL) != g_symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;

      ulong ticket = PositionGetInteger(POSITION_TICKET);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long type = PositionGetInteger(POSITION_TYPE);

      // Max strata na pozycję (w ATR) – zamknij przy przekroczeniu
      if(InpMaxLossATR > 0.0)
      {
         double lossDist = (type == POSITION_TYPE_SELL) ? (bid - openPrice) : (openPrice - bid);
         if(lossDist >= InpMaxLossATR * atr)
         {
            if(g_trade.PositionClose(ticket))
               if(InpDebug) Print("MaxLossATR zamknięto ticket ", ticket, " strata ", DoubleToString(lossDist/g_point, 0), " pts");
            continue;
         }
      }

      // Zawsze ustaw SL/TP gdy pozycja bez stopów (także gdy InpUseSLTP=false – safety net)
      if(sl == 0.0 || tp == 0.0)
      {
         double newSl = (type == POSITION_TYPE_BUY) ? NormPrice(openPrice - slDist) : NormPrice(openPrice + slDist);
         double newTp = (type == POSITION_TYPE_BUY) ? NormPrice(openPrice + tpDist) : NormPrice(openPrice - tpDist);
         if(g_trade.PositionModify(ticket, newSl, newTp))
         { sl = newSl; tp = newTp; if(InpDebug) Print("Wymuszono SL/TP ticket ", ticket); }
      }

      // SL tylko w stronę zysku: Long = SL w górę, Short = SL w dół; nigdy nie cofa się
      if(type == POSITION_TYPE_SELL)
      {
         double profitDist = openPrice - bid;
         bool atBE = (sl <= openPrice + g_point*5);
         if(InpUseBreakEven && !atBE && profitDist >= beDist)
         {
            double newSl = NormPrice(openPrice - beOffset);
            if(sl == 0.0 || newSl < sl)  // tylko w dół, nie cofać w górę
               if(g_trade.PositionModify(ticket, newSl, tp))
               { if(InpDebug) Print("BE Sell ticket ", ticket); continue; }
         }
         if(InpUseTrailingStop && (!InpTrailOnlyAfterBE || atBE) && (InpTrailMinATR <= 0.0 || profitDist >= trailMinDist))
         {
            double trailDist = atr * InpTrailATRMult;
            double newSl = NormPrice(bid + trailDist);
            if(newSl < openPrice && (sl == 0.0 || newSl < sl))  // tylko w dół (świece w dół = zysk), nigdy w górę
            {
               if(g_trade.PositionModify(ticket, newSl, tp))
                  if(InpDebug) Print("Trail Sell ticket ", ticket, " SL ", newSl);
            }
         }
      }
      else
      {
         double profitDist = bid - openPrice;
         bool atBE = (sl >= openPrice - g_point*5);
         if(InpUseBreakEven && !atBE && profitDist >= beDist)
         {
            double newSl = NormPrice(openPrice + beOffset);
            if(sl == 0.0 || newSl > sl)  // tylko w górę, nie cofać w dół
               if(g_trade.PositionModify(ticket, newSl, tp))
               { if(InpDebug) Print("BE Buy ticket ", ticket); continue; }
         }
         if(InpUseTrailingStop && (!InpTrailOnlyAfterBE || atBE) && (InpTrailMinATR <= 0.0 || profitDist >= trailMinDist))
         {
            double trailDist = atr * InpTrailATRMult;
            double newSl = NormPrice(ask - trailDist);
            if(newSl > openPrice && (sl == 0.0 || newSl > sl))  // tylko w górę (świece w górę = zysk), nigdy w dół
            {
               if(g_trade.PositionModify(ticket, newSl, tp))
                  if(InpDebug) Print("Trail Buy ticket ", ticket, " SL ", newSl);
            }
         }
      }
   }
}
