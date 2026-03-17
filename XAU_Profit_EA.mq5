//+------------------------------------------------------------------+
//|                                              XAU_Profit_EA.mq5   |
//|  MTF WPR: Bias H1/H4/D1 + Entry M5/M15/M30 (jak MTF_Screener_WPR) |
//|  Kompiluj ZAWSZE ten plik (F7). Nie kompiluj plików .mqh.        |
//+------------------------------------------------------------------+
#property copyright "XAU_Profit_EA"
#property version   "5.0"
#property strict

#include <Trade/Trade.mqh>

// === WEJŚCIA (zgodne z MTF_Screener_WPR) ===
input string   InpSymbol            = "";           // Symbol (pusty = chart)
input ENUM_TIMEFRAMES InpEntryTF     = PERIOD_M15;  // Entry TF (M5,M15,M30 z obrazka)
input int      InpWPRPeriod          = 14;          // Okres WPR (Ind1=WPR)
input double   InpWPROverbought      = -20.0;       // WPR >= = overbought (Short)
input double   InpWPROversold       = -80.0;       // WPR <= = oversold (Long)
input bool     InpBiasUseH1          = true;        // Bias z H1 (BiasTFs)
input bool     InpBiasUseH4          = true;        // Bias z H4
input bool     InpBiasUseD1          = true;        // Bias z D1
input bool     InpTradeStrict        = true;        // TRADE_STRICT: wszystkie bias TF muszą się zgadzać
input bool     InpAllowLong          = false;       // Zezwól na Long
input bool     InpAllowShort         = true;       // Zezwól na Short

input double   InpLots               = 0.01;       // Stały wolumen
input int      InpMaxPositions       = 3;          // Maks. pozycji
input int      InpATRPeriod          = 14;         // ATR dla SL/TP
input double   InpATRMultiplierSL    = 1.0;        // SL = ATR * ten mnożnik
input double   InpATRMultiplierTP   = 5.0;        // TP = ATR * ten mnożnik
input bool     InpUseTrailingStop    = true;       // Trailing stop
input double   InpTrailATRMult       = 0.5;        // Trailing = ATR * ten mnożnik

input int      InpMaxSpreadPoints    = 500;        // Maks. spread (pts)
input int      InpMagicNumber        = 234567;     // Magic
input bool     InpDebug              = false;

// === ZMIENNE GLOBALNE ===
#define _XAU_PROFIT_EA_COMPILING_
CTrade         g_trade;
string         g_symbol;
int            g_digits;
double         g_point;
datetime       g_lastBarTime = 0;
datetime       g_lastBarOpenTime = 0;

// Opakowania Copy* – w EA, żeby uniknąć przeciążeń MQL5 (bez static – .mqh ich wywołuje)
int CopyCloseInt(const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyClose(sym, tf, start, count, arr); }
int CopyOpenInt (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyOpen(sym, tf, start, count, arr); }
int CopyHighInt (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyHigh(sym, tf, start, count, arr); }
int CopyLowInt  (const string sym, ENUM_TIMEFRAMES tf, int start, int count, double &arr[]) { return CopyLow(sym, tf, start, count, arr); }

#include "XAU_Profit_Indicators.mqh"
#include "XAU_Profit_Helpers.mqh"
#include "XAU_Profit_Signals.mqh"
#include "XAU_Profit_Trade.mqh"

//+------------------------------------------------------------------+
int OnInit()
{
   g_symbol = (InpSymbol == "" || InpSymbol == NULL) ? _Symbol : InpSymbol;
   if(!SymbolInfoInteger(g_symbol, SYMBOL_SELECT))
   {
      if(!SymbolSelect(g_symbol, true)) { Print("Symbol ", g_symbol, " niedostępny."); return INIT_FAILED; }
   }
   g_digits = (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS);
   g_point  = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
   if(g_point <= 0.0) { Print("Błędny point."); return INIT_FAILED; }

   g_trade.SetExpertMagicNumber((int)InpMagicNumber);
   g_lastBarTime = iTime(g_symbol, InpEntryTF, 0);
   g_lastBarOpenTime = 0;
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnTick()
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED)) return;
   if(!HasEnoughBars()) return;

   ManagePositions();

   bool isNewBar = IsNewBar();
   if(!isNewBar) return;

   if(CountOurPositions() >= InpMaxPositions) return;
   if(!SpreadOK()) return;

   bool doLong  = InpAllowLong  && SignalLong();
   bool doShort = InpAllowShort && SignalShort();
   if(doLong)  OpenPosition(true);
   if(doShort) OpenPosition(false);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { }
