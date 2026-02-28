//+------------------------------------------------------------------+
//|                                            Rational Indicator.mq5 |
//|                                    Copyright 2025, Yousuf Mesalm. |
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Yousuf Mesalm. www.yousufmesalm.com | WhatsApp +201006179048"
#property link      "https://www.yousufmesalm.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   7
//--- plot buy
#property indicator_label1  "buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_width1  1
//
//--- plot sell
#property indicator_label2  "sell"
#property indicator_type2  DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  1
////--- plot upper
#property indicator_label3  "Upper"      // Name of a plot for the Data Window
//#property indicator_type3  DRAW_LINE   // Type of plotting is line
//#property indicator_color3  clrGreen      // Line color
//#property indicator_style3 STYLE_SOLID // Line style
//#property indicator_width3  1
////plot Lower
//
#property indicator_label4  "Lower"      // Name of a plot for the Data Window
//#property indicator_type4  DRAW_LINE   // Type of plotting is line
//#property indicator_color4  clrRed      // Line color
//#property indicator_style4  STYLE_SOLID // Line style
//#property indicator_width4  1

#property indicator_label5 "Signal"
#property indicator_label6 "Upper Border"
#property indicator_label7 "Lower Border"
#include <Arrays\ArrayDouble.mqh>
#include <Indicators\TimeSeries.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>

input int n=1;
input int n_Numbers=1000;
input int Divide=10000;
input color LineColor=clrRed;
input bool Show_HLine=true;
input int PipFilter=5;

//array

CArrayDouble Rarr;
double signal[];
double Buy[];
double Sell[];
double Upper[];
double Lower[];
double UpperB[],LowerB[];
CiHigh High;
CChartObjectHLine Hline;
double Highest,Lowest;
int HighIdx,LowIdx;
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+


   SetIndexBuffer(0,Buy,INDICATOR_DATA);
   SetIndexBuffer(1,Sell,INDICATOR_DATA);
   SetIndexBuffer(2,Upper,INDICATOR_DATA);
   SetIndexBuffer(3,Lower,INDICATOR_DATA);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
   SetIndexBuffer(5,UpperB,INDICATOR_DATA);
   SetIndexBuffer(6,LowerB,INDICATOR_DATA);
//Plot Buy
//--- Define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
//--- Set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
//--- Set as an empty value 0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---------------------------------------------------------------------
//Plot Sell
//--- Define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- Set the vertical shift of arrows in pixels
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,5);
//--- Set as an empty value 0
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//-----------------------------------------------------------------------
   High.Create(Symbol(),PERIOD_CURRENT);
   High.Refresh(-1);
   Highest=High.MaxValue(0,WHOLE_ARRAY,HighIdx);
   Lowest=0;
   Highest+=(Highest*2);
   RationalNumbers(Rarr);
   Rarr.Sort();
 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,-1,-1);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   if(prev_calculated==0)   //--- If it is the first call go through all bars
      limit=2;
   else
      limit=rates_total-1;  //--- Else just check the most current bar that has not yet finished

   for(int i=limit; i<rates_total; i++)
     {
      
         double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      //check if channel changed?
      if((close[i]>Upper[i-1])||(close[i]<Lower[i-1]))
        {
         //loop for update channel
         for(int x=0; x<Rarr.Total()-1; x++)
           {
            if(close[i]>Rarr.At(x)&&close[i]<Rarr.At(x+1))
              {
               Upper[i]=Rarr.At(x+1);
               UpperB[i]=Rarr.At(x+2);
               Lower[i]=Rarr.At(x);
               LowerB[i]=Rarr.At(x-1);
              }
           }
        }
      else
        {
         Upper[i]=Upper[i-1];
         UpperB[i]=UpperB[i-1];
         Lower[i]=Lower[i-1];
         LowerB[i]=LowerB[i-1];
        }
      //Print(Upper[i]);
      //Print(Lower[i]);
      if((open[i]<=Lower[i]||open[i-1]<=Lower[i])&&open[i]<Upper[i]&&open[i]<close[i]&&Bid>=Lower[i]+PipFilter*10*Point())
        { 
         Buy[i]=Lower[i];
         Sell[i]=0;
         signal[i]=1;
        }
      else
         if((open[i]>=Upper[i]||open[i-1]>=Upper[i])&&open[i]>Lower[i]&&open[i]>close[i]&&Bid<=Upper[i]-PipFilter*10*Point())
           {
            Sell[i]=Upper[i]; 
            Buy[i]=0;
            signal[i]=0;
           }
           else{
            signal[i]=signal[i-1];
           }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
void RationalNumbers(CArrayDouble & arr)
  {

   for(int i = 1; i <=n_Numbers; i++)
     {
      double result = ((double)n / (double) i) * Divide;
      if(result>=Lowest&&result<=Highest)
        {
         
         arr.Add(result);
         if(Show_HLine)
            CreateHline(Hline, "Hline"+ (string)n+(string)Divide+ (string) i, result);

        }
        
     }
  }

//+------------------------------------------------------------------+
//|  www.yousufmesalm.com | WhatsApp +201006179048 | Upwork: https://www.upwork.com/freelancers/youssefmesalm |
//+------------------------------------------------------------------+
bool CreateHline(CChartObjectHLine & line, string name, double price)
  {
   if(!line.Create(0, name, 0, price))
     {
      return false;
     }
     line.Color(LineColor);
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
