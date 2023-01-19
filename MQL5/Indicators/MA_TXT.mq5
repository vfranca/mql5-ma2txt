//+------------------------------------------------------------------+
//|                                                      MA_TXT.mq5 |
//|                                           Valmir França da Silva |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Valmir França da Silva"
#property link      "https://www.mql5.com"
#property version   "1.41"
#property indicator_chart_window
#property indicator_buffers 1
//--- Dependências
#include "Split.mqh"
//--- Parâmetros de entrada
input int input_period_amount=20; // períodos:
input ENUM_MA_METHOD input_method=MODE_SMA; // Método:
input ENUM_APPLIED_PRICE input_applied_price=PRICE_CLOSE; // Aplicada a:
input int input_timer=60; // Tempo de atualização:
input int input_amount=2; // Quantidade de médias no histórico:
input int input_digits=0; // Dígitos da moeda:
input double input_variacao_flat=20; // Variação flat:
//--- buffer do indicador
double ma[];
//--- variável para armazenar o manipulador do indicator iMA
int handle;
//--- Resultado da cópia para o buffer
int copied;
//--- Cotações
MqlRates rates[];
//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Dispara o temporizador
   EventSetTimer(input_timer);
//--- atribuição de array para buffer do indicador
   SetIndexBuffer(0,ma,INDICATOR_DATA);
//--- inicialização normal do indicador
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Função de iteração do indicador personalizado                      |
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Encerra o temporizador
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Função disparada pelo temporizador  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   double ma[];
//--- Obtem a média móvel
   handle = iMA(_Symbol, Period(), input_period_amount, 0, input_method, input_applied_price);
//--- Copia resultados para array do buffer do indicador
   copied = CopyBuffer(handle, 0, 0, input_amount, ma);
   if(copied < 0)
     {
      Print("Erro no manipulador!");
      return;
     }
//--- Exporta os dados para o arquivo TXT
   ExportaIndicadorCSV(Period(), ma);
  }
//+------------------------------------------------------------------+
//| Função paa exportar os dados para TXT                          |
//+------------------------------------------------------------------+
void ExportaIndicadorCSV(ENUM_TIMEFRAMES timeframes, const double &ind[])
  {
//--- Abre o arquivo para exportação dos dados
   int FILE = FileOpen(Symbol() + Split(_Period) + "-MA" + input_period_amount + ".csv", FILE_WRITE | FILE_TXT);
   if(FILE != INVALID_HANDLE)
     {
      //--- Obtem as cotações
      int copy = CopyRates(Symbol(), timeframes, TimeTradeServer(), input_amount, rates);
      //--- Escreve no arquivo
      for(int i = 1; i < copy; i++)
        {
         //--- Define a inclinação da média móvel
         string sInclinacao = "flat";
         string sVariacao = DoubleToString((MathAbs(ind[i] - ind[i-1])), input_digits);
         if(ind[i] > (ind[i-1]+input_variacao_flat))
            sInclinacao = "up";
         if(ind[i] < (ind[i-1]-input_variacao_flat))
            sInclinacao = "down" ;
         //--- Escreve no arquivo TXT
         FileWrite(FILE,
                   rates[i].time, ",",
                   rates[i].close, ",",
                   NormalizeDouble(ind[i], input_digits), ",",
                   sInclinacao, ",",
                   sVariacao, ",",
                   input_variacao_flat, ",",
                   input_period_amount, ",",
                   EnumToString(input_method), ",",
                   EnumToString(input_applied_price));
        }//end for
     }
   else
     {
      Print("Erro ao abrir arquivo, arquivo pode já estar aberto!");
     }
//--- Fecha o arquivo
   FileClose(FILE);
  }
//+------------------------------------------------------------------+
