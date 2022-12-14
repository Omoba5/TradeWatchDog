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

input int      Inp_RSI_Period    = 42;             // RSI: Period
input int      Inp_RSI_Level1    = 30.0;           // RSI: Value Level UP
input double   Inp_RSI_Level2    = 60.0;           // RSI: Value Level DOWN

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

//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(), Inp_RSI_Period, PRICE_CLOSE);
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

   double ma1[],ma2[],rsi[];
   ArraySetAsSeries(ma1,true);
   ArraySetAsSeries(ma2,true);
   ArraySetAsSeries(rsi,true);
   int start_pos=0,count=3;
   if(!iGetArray(handle_iMA1,0,start_pos,count,ma1) ||
      !iGetArray(handle_iMA2,0,start_pos,count,ma2) ||
      !iGetArray(handle_iRSI,0,start_pos,count,rsi))
     {
      PrevBars=0;
      return;
     }
   if(ma1[0]>ma2[1] && rsi[1]<Inp_RSI_Level1)
     {
      Print("POSSIBLE BUY OPPURTUNITY");
      SendNotification("POSSIBLE BUY OPPURTUNITY");
     }
   else
      if(ma1[0]<ma2[1] && rsi[1]>Inp_RSI_Level2)
        {
         Print("POSSIBLE SELL OPPURTUNITY");
         SendNotification("POSSIBLE SELL OPPURTUNITY");
        }
  }

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
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
double iGetArray(const int handle,const int buffer,const int start_pos,const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
