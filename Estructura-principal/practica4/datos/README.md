# Fuente de datos del proyecto propio

El archivo de trabajo es:

    base_datos_pedidos2.xlsx

Cópialo aquí antes de ejecutar el cargador:

    Estructura-principal/practica4/datos/base_datos_pedidos2.xlsx

Hojas relacionales esperadas:
- cliente: 80 registros
- transportista: 30 registros
- producto: 40 registros
- sucursal: 100 registros
- pedido: 500 registros
- detalle: 1,500 registros
- envio: 452 registros

La hoja Notas contiene reglas y supuestos, pero no se importa.

Todos los registros son sintéticos. El equipo adaptó la estructura de referencia de una base privada y explicó el modelo a Claude (Anthropic), que colaboró en la generación aleatoria y controlada de los datos. No se deben añadir datos confidenciales ni presentar el Excel como una exportación de ventas reales.

El cargador valida estos conteos para detectar que se está utilizando la versión correcta. Si el Excel cambia, debe revisarse fuente.md y actualizar el programa de carga de forma intencional.
