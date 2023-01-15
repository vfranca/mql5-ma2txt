//+------------------------------------------------------------------+
//|                                                      IMA_TXT.mq5 |
//|                                           Valmir França da Silva |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Valmir França da Silva"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
//--- Parâmetros de entrada
input int InpTimer=1; // Tempo de atualização
input int InpBars=1000; // Quantidade de médias calculadas
input int                  ma_period=20;                 // períodos da média móvel
input int                  ma_shift=0;                   // deslocamento
input ENUM_MA_METHOD       ma_method=MODE_SMA;           // tipo de suavização
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;    // tipo de preço
input string               symbol=" ";                   // símbolo
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;        // Período da média móvel
//--- buffer do indicador
double         iMABuffer[];
//--- variável para armazenar o manipulador do indicator iMA
int    handle;
//--- variável para armazenamento
string name=symbol;
// Variáveis
// int copied;
// MqlRates rates[];
//--- manteremos o número de valores no indicador Moving Average
int    bars_calculated=1000;

//+------------------------------------------------------------------+
//| Função de inicialização do indicador personalizado                 |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- atribuição de array para buffer do indicador
   SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
//--- determinar o símbolo do indicador, é desenhado para
   name=symbol;
//--- excluir os espaços à direita e à esquerda
   StringTrimRight(name);
   StringTrimLeft(name);
//--- se resulta em comprimento zero da string do 'name'
   if(StringLen(name)==0)
     {
      //--- tomar o símbolo do gráfico, o indicador está anexado para
      name=_Symbol;
     }
//--- criar manipulador do indicador
   handle=iMA(name,period,ma_period,ma_shift,ma_method,applied_price);
//--- se o manipulador não é criado
   if(handle==INVALID_HANDLE)
     {
      //--- mensagem sobre a falha e a saída do código de erro
      PrintFormat("Falha ao criar o manipulador do indicador iMA para o símbolo %s/%s, código de erro %d",
                  name,
                  EnumToString(period),
                  GetLastError());
      //--- o indicador é interrompido precocemente
      return(INIT_FAILED);
     }
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
//--- número de valores copiados a partir do indicador iMA
   int values_to_copy;
//--- determinar o número de valores calculados no indicador
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() retornando %d, código de erro %d",calculated,GetLastError());
      return(0);
     }
//--- se for o princípio do cálculo do indicador, ou se o número de valores é modificado no indicador iMA
//--- ou se é necessário cálculo do indicador para duas ou mais barras (isso significa que algo mudou no histórico do preço)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- se o array iMABuffer é maior do que o número de valores no indicador iMA para o símbolo/período, então não copiamos tudo
      //--- caso contrário, copiamos menor do que o tamanho dos buffers do indicador
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- isso significa que não é a primeira vez do cálculo do indicador, é desde a última chamada de OnCalculate())
      //--- para o cálculo não mais do que uma barra é adicionada
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- preencher o array iMABuffer com valores do indicador Adaptive Moving Average
//--- se FillArrayFromBuffer retorna falso, significa que a informação não está pronta ainda, sair da operação
   if(!FillArrayFromBuffer(iMABuffer,ma_shift,handle,values_to_copy))
      return(0);
//--- formar a mensagem
   string comm=StringFormat("%s ==>  Valor atualizado no indicador %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            "short_name",
                            values_to_copy);
//--- exibir a mensagem de serviço no gráfico
   Comment(comm);
//--- memorizar o número de valores no indicador Moving Average
   bars_calculated=calculated;
//--- retorna o valor prev_calculated para a próxima chamada
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Preencher buffers do indicador a partir do indicador MA          |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // buffer do indicator para valores do Moving Average
                         int shift,         // deslocamento
                         int ind_handle,     // manipulador do indicador iMA
                         int amount          // número de valores copiados
                        )
  {
//--- redefinir o código de erro
   ResetLastError();
//--- preencher uma parte do array iMABuffer com valores do buffer do indicador que tem índice 0 (zero)
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- Se a cópia falhar, informe o código de erro
      PrintFormat("Falha ao copiar dados do indicador iMA, código de erro %d",GetLastError());
      //--- parar com resultado zero - significa que indicador é considerado como não calculado
      return(false);
     }
//--- está tudo bem
   return(true);
  }

//+------------------------------------------------------------------+
//| Função de desinicialização do indicador                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle!=INVALID_HANDLE)
      IndicatorRelease(handle);
//--- limpar o gráfico após excluir o indicador
   Comment("");
  }
//---
void OnTimer()
  {
//---
  }
//+------------------------------------------------------------------+
