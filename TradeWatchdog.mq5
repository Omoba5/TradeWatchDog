//+------------------------------------------------------------------+
//|                                                TradeWatchdog.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2022, Ogabi Prince"
//--
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper

//--- Input Parameters
input ENUM_MA_METHOD ma_method = MODE_EMA; // smoothing type for both MAs
input int ma_shift = 1; // horizontal shift for both MAs
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE; // type of price or handle for both MAs

input int ma_period1 = 13;                   // averaging period for MA1

input int ma_period2 = 49;                   // averaging period for MA2

input int      Inp_RSI_Period    = 42;       // RSI: Period

//--- Global Variables
int    handle_iMA1;                          // variable for storing the handle of the MA indicator 1
int    handle_iMA2;                          // variable for storing the handle of the MA indicator 2
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle of the indicator iMA1
   handle_iMA1=iMA(m_symbol.Name(),Period(), ma_period1, ma_shift, ma_method, applied_price);
//--- if the handle is not created
   if(handle_iMA1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA1 indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA2
   handle_iMA2=iMA(m_symbol.Name(),Period(), ma_period2, ma_shift, ma_method, applied_price);
//--- if the handle is not created
   if(handle_iMA2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA1 indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }

//--- create handle of the indicator iCustom
   handle_iRSI=iRSI(m_symbol.Name(),Period(),Inp_RSI_Period, applied_price);
//--- if the handle is not created
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iCustom indicator \"RSI Custom Smoothing\" for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }


  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
