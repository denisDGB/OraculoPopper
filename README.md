# EA_Riesgo_Lineas_AutoTP_Commission
## Descripción del Proyecto

Este proyecto contiene un Asesor Experto (EA) desarrollado en MQL5 para MetaTrader 5, diseñado para traders que desean combinar el trading manual con cálculos automáticos de gestión de riesgo. El EA permite:

- **Gestión de Riesgo:** Definir el porcentaje de riesgo sobre el balance de la cuenta.
- **Cálculo Automático del Take Profit:** Calcula el nivel de TP basándose en una relación riesgo-beneficio configurable en decimales (por ejemplo, 1.2 para una relación 1:1.2).
- **Cálculo del Lotaje:** Ajusta el volumen de la operación para que el riesgo (incluyendo la comisión por lote) se mantenga dentro del porcentaje definido.
- **Operación Manual:** Se utiliza una línea dibujada en el gráfico denominada "SL" para establecer el Stop Loss, y un botón ("Nueva Orden") para enviar la orden con los parámetros calculados.
- **Inclusión de Comisión:** Permite definir la comisión por lote para que esta se incluya en el cálculo del riesgo efectivo.

## Pasos para Usar el EA en MetaTrader 5

1. **Crear el archivo del EA:**
   - Copia el código del EA y pégalo en un nuevo archivo en MetaEditor.
   - Guarda el archivo con extensión `.mq5` (por ejemplo, `EA_Riesgo_Lineas_AutoTP_Commission.mq5`).

2. **Compilar el EA:**
   - Abre MetaEditor y compila el código (F7) para asegurarte de que no hay errores.

3. **Agregar el EA a un gráfico en MT5:**
   - Inicia MetaTrader 5 y abre el panel "Navegador" (Ctrl+N).
   - Busca el EA en la carpeta "Asesores Expertos" y arrástralo a un gráfico o haz doble clic para cargarlo.

4. **Configurar los parámetros:**
   - En la ventana de propiedades del EA, establece:
     - **RiskPercent:** Porcentaje del balance a arriesgar.
     - **RiskReward:** Relación riesgo-beneficio en decimales (por ejemplo, 1.2 para 1:1.2).
     - **CommissionPerLot:** Comisión por lote en moneda, según las condiciones de tu broker.
     - **Slippage:** Slippage permitido.

5. **Dibujar la línea de Stop Loss (SL):**
   - En el gráfico, dibuja una línea horizontal y nómbrala "SL". Este será el nivel de Stop Loss.

6. **Ejecutar la orden:**
   - Una vez configurados los parámetros y dibujada la línea "SL", haz clic en el botón "Nueva Orden" que el EA coloca en la esquina superior derecha del gráfico.
   - El EA calculará automáticamente el TP y el volumen de la operación, y enviará la orden.

## Notas Adicionales

- **Prueba en Demo:** Se recomienda probar el EA en una cuenta demo antes de operar en real.
- **Ajustes del Broker:** Revisa que los parámetros de volumen y comisión se adapten a las condiciones de tu broker.

---

Con esta guía, podrás instalar y utilizar el EA de forma sencilla, gestionando tu riesgo de manera automática en tus operaciones manuales.
