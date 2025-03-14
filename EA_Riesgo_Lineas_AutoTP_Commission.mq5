#include <Trade\Trade.mqh>
CTrade trade;

// Prototipo de la función PlaceOrder
void PlaceOrder();

// Parámetros del EA
input double RiskPercent      = 1.0;   // Porcentaje de riesgo sobre el balance
input double RiskReward       = 1.2;   // Relación riesgo-beneficio (ej. 1:1.2)
input int    Slippage         = 5;     // Slippage permitido
input double CommissionPerLot = 0.0;   // Comisión por lote en moneda

// Nombre del botón para ejecutar la orden
string btnName = "btnNewOrder";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Crear botón "Nueva Orden" en la esquina superior derecha
   if(!ObjectCreate(0, btnName, OBJ_BUTTON, 0, 0, 0))
   {
      Print("Error al crear el botón: ", GetLastError());
      return(INIT_FAILED);
   }
   ObjectSetInteger(0, btnName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, btnName, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, btnName, OBJPROP_YDISTANCE, 10);
   ObjectSetString(0, btnName, OBJPROP_TEXT, "Nueva Orden");
   ObjectSetInteger(0, btnName, OBJPROP_XSIZE, 100);
   ObjectSetInteger(0, btnName, OBJPROP_YSIZE, 30);
   ObjectSetInteger(0, btnName, OBJPROP_HIDDEN, false);
   
   Print("EA iniciado. Coloca la línea 'SL' en el gráfico y presiona 'Nueva Orden'.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Eliminar el botón al salir
   ObjectDelete(0, btnName);
}

//+------------------------------------------------------------------+
//| Chart Event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Al detectar un click sobre el botón se ejecuta la orden
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == btnName)
      {
         PlaceOrder();
      }
   }
}

//+------------------------------------------------------------------+
//| Función que coloca la orden                                      |
//+------------------------------------------------------------------+
void PlaceOrder()
{
   string symbol = _Symbol;
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   // Verificar que exista el objeto "SL" en el gráfico
   if(ObjectFind(0, "SL") < 0)
   {
      Print("No se encontró la línea 'SL' en el gráfico.");
      return;
   }
   
   // Extraer el nivel de SL
   double slLevel = ObjectGetDouble(0, "SL", OBJPROP_PRICE);
   
   // Determinar el tipo de orden basado en la posición de SL respecto al precio actual
   ENUM_ORDER_TYPE orderType;
   double entryPrice;
   
   // Para una compra, SL debe estar por debajo del precio de compra (ask)
   if(ask - slLevel > 0)
   {
      orderType = ORDER_TYPE_BUY;
      entryPrice = ask;
   }
   // Para una venta, SL debe estar por encima del precio de venta (bid)
   else if(slLevel - bid > 0)
   {
      orderType = ORDER_TYPE_SELL;
      entryPrice = bid;
   }
   else
   {
      Print("El nivel de SL no es adecuado respecto al precio actual.");
      return;
   }
   
   // Calcular la distancia en precio entre la entrada y el SL (riesgo en precio)
   double riskDistance = MathAbs(entryPrice - slLevel);
   if(riskDistance <= 0)
   {
      Print("Error: La distancia al SL es cero o negativa.");
      return;
   }
   
   // Calcular el Take Profit automáticamente basado en la relación riesgo-beneficio
   double tpLevel;
   if(orderType == ORDER_TYPE_BUY)
      tpLevel = entryPrice + riskDistance * RiskReward;
   else
      tpLevel = entryPrice - riskDistance * RiskReward;
   
   // Calcular el riesgo monetario definido (porcentaje del balance)
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = accountBalance * (RiskPercent / 100.0);
   
   // Obtener el tamaño y valor del tick para el símbolo
   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   
   // Cálculo del riesgo por lote sin comisión
   double riskPerLot = (riskDistance / tickSize) * tickValue;
   if(riskPerLot <= 0)
   {
      Print("Error en el cálculo del riesgo por lote.");
      return;
   }
   
   // Comisión por lote (definida en los parámetros)
   double commissionPerLot = CommissionPerLot;
   
   // Riesgo efectivo por lote = riesgo por movimiento + comisión
   double effectiveRiskPerLot = riskPerLot + commissionPerLot;
   
   // Calcular el volumen (lotaje) considerando el riesgo total (incluyendo comisión)
   double lots = riskMoney / effectiveRiskPerLot;
   
   // Ajustar el volumen a los parámetros del símbolo (mínimo, step, máximo)
   double minLot, lotStep, maxLot;
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN, minLot);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP, lotStep);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX, maxLot);
   
   lots = MathMax(lots, minLot);
   // Ajustar a múltiplos de lotStep
   lots = MathFloor(lots / lotStep) * lotStep;
   if(lots > maxLot)
      lots = maxLot;
   
   // Mostrar en el log la información calculada
   Print("Tipo de operación: ", (orderType==ORDER_TYPE_BUY ? "COMPRA" : "VENTA"));
   Print("Entrada: ", DoubleToString(entryPrice, digits),
         "  SL: ", DoubleToString(slLevel, digits),
         "  TP (auto): ", DoubleToString(tpLevel, digits));
   Print("Riesgo monetario: ", DoubleToString(riskMoney,2),
         "  Riesgo sin comisión por lote: ", DoubleToString(riskPerLot,2),
         "  Comisión por lote: ", DoubleToString(commissionPerLot,2),
         "  Riesgo efectivo por lote: ", DoubleToString(effectiveRiskPerLot,2),
         "  Volumen calculado: ", DoubleToString(lots,2));
   
   // Preparar la solicitud de orden
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   request.action       = TRADE_ACTION_DEAL;
   request.symbol       = symbol;
   request.volume       = lots;
   request.type         = orderType;
   request.price        = (orderType==ORDER_TYPE_BUY ? ask : bid);
   request.sl           = slLevel;
   request.tp           = tpLevel;
   request.deviation    = Slippage;
   request.magic        = 123456;
   request.type_filling = ORDER_FILLING_FOK;
   
   // Enviar la orden
   if(!OrderSend(request, result))
   {
      Print("Error al enviar la orden: ", result.comment);
      return;
   }
   
   if(result.retcode == TRADE_RETCODE_DONE)
      Print("Operación realizada exitosamente. Ticket: ", result.order);
   else
      Print("Error en la operación: ", result.comment);
}
