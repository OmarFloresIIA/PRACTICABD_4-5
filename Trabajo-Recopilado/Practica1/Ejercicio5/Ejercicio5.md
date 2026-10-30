# Ejercicio 5: Caso de Estudio y Modelo Entidad-Relación (Empresa Ergon)

## 1. Identificación del Problema

* **Empresa / Contexto:** Ergon (Sector Industrial de Especialidades Petroleras y Aceites).
* **Problema:** Falta de un sistema centralizado de gestión de ventas y comercialización de aceites industriales que permita registrar transacciones, consultar el histórico de facturación, analizar rendimientos por producto y determinar el volumen de compras por cliente empresarial para la generación de reportes financieros anuales.

## 2. Descripción de la Problemática y Entrevista Simulada

La empresa requiere consolidar la información comercial de su catálogo de aceites industriales y clientes B2B. Actualmente, la falta de una estructura relacional adecuada dificulta el cálculo preciso de la utilidad anual, el rastreo de histórico de ventas y la identificación de métricas clave de rendimiento.

### Entrevista Simulada: Consultor de BD y Gerente Comercial de Ergon

* **Consultor:** ¿Qué datos clave necesitan registrar sobre los productos de aceites y cómo se identifican?
* **Gerente:** Manejamos líneas especializadas como *Hyvolt* (y sus variantes), *Omnigold* y *Hyprene*. Cada producto tiene una clave numérica única de 7 dígitos. Necesitamos guardar su nombre, precio unitario de venta y costo de producción para calcular el margen de utilidad.
* **Consultor:** ¿Cómo manejan la información de los clientes?
* **Gerente:** Nuestros clientes son otras empresas que transforman nuestros insumos. A cada uno le asignamos un número único de cliente de 6 dígitos. Guardamos su razón social, datos de contacto e identificación fiscal.
* **Consultor:** ¿Qué información se genera en las transacciones de venta?
* **Gerente:** Cada venta registra qué cliente compra, los productos adquiridos, las cantidades, la fecha de transacción y el monto total en dólares.
* **Consultor:** ¿Con qué frecuencia consultan la base de datos y qué reportes requieren?
* **Gerente:** La consulta de ventas es diaria para seguimiento operativo. Los reportes consolidados son mensuales y anuales: necesitamos conocer los ingresos totales en dólares, la utilidad neta acumulada, el ranking de productos más vendidos y los clientes que generan mayor volumen de compra.

## 3. Documentación de Requerimientos

### Requerimientos de Datos (Entidades y Atributos)

1. **Producto:**
   * `clave_producto`: Número único de 7 dígitos (Llave Primaria - PK).
   * `nombre_producto`: Nombre comercial (ej. *Hyvolt I*, *Omnigold 2000*, *Hyprene L500*).
   * `linea_familia`: Clasificación del producto (*Hyvolt*, *Omnigold*, *Hyprene*, etc.).
   * `costo_unitario`: Costo de producción por unidad en USD.
   * `precio_unitario`: Precio de venta por unidad en USD.

2. **Cliente:**
   * `numero_cliente`: Número único de 6 dígitos (Llave Primaria - PK).
   * `razon_social`: Nombre comercial o legal de la empresa cliente.
   * `rfc_tax_id`: Identificador fiscal de la empresa.
   * `telefono`: Número telefónico de contacto.
   * `correo_contacto`: Correo electrónico del representante o área de compras.

3. **Venta / Pedido:**
   * `folio_venta`: Identificador único de la transacción (Llave Primaria - PK).
   * `fecha`: Fecha y hora de la transacción.
   * `numero_cliente`: Cliente que realiza la compra (Llave Foránea - FK).
   * `monto_total`: Suma total de la venta en USD.
   * `utilidad_total`: Utilidad neta generada en la transacción en USD.

4. **Detalle de Venta:**
   * `id_detalle`: Identificador único de la línea de detalle (Llave Primaria - PK).
   * `folio_venta`: Referencia a la venta correspondiente (Llave Foránea - FK).
   * `clave_producto`: Referencia al producto comprado (Llave Foránea - FK).
   * `cantidad`: Cantidad de unidades/litros vendidos.
   * `precio_aplicado`: Precio unitario al que se vendió en esa transacción (USD).
   * `subtotal`: Monto total de esa línea en USD (`cantidad` × `precio_aplicado`).

### Requerimientos Funcionales (Funciones del Sistema)

* **Gestión de Catálogos:** Registrar, actualizar y consultar información de clientes y líneas de productos.
* **Registro de Transacciones:** Generar órdenes de venta asociando clientes con múltiples productos y cantidades.
* **Cálculo Automático Financiero:** Calcular importes totales en dólares y márgenes de utilidad a nivel de transacción, producto y cliente.
* **Generación de Reportes Comerciales:**
  * Reporte de ingresos totales en dólares por periodo (mensual/anual).
  * Reporte de utilidad acumulada anual de la empresa.
  * Ranking de productos más vendidos (por volumen de unidades y monto en USD).
  * Ranking de clientes principales (por total facturado e ingresos generados).