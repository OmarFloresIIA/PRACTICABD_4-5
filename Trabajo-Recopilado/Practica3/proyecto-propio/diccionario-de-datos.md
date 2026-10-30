# Diccionario de Datos

| Tabla | Columna | Tipo | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| **cliente** | numeroCliente | CHAR(7) | PK, NOT NULL | Identificador único del cliente. |
| **cliente** | razonSocial | VARCHAR(100) | NOT NULL | Razón social o nombre comercial del cliente. |
| **cliente** | correoCliente | VARCHAR(50) | NOT NULL | Correo electrónico de contacto del cliente. |
| **cliente** | telefonoCliente | VARCHAR(20) | NOT NULL | Número telefónico de contacto del cliente. |
| **clienteNacional** | numeroCliente | CHAR(7) | PK, FK (cliente), NOT NULL | Identificador del cliente nacional (heredado de cliente). |
| **clienteNacional** | rfc | VARCHAR(13) | NOT NULL | Registro Federal de Contribuyentes. |
| **clienteNacional** | regimenFiscal | VARCHAR(100) | NOT NULL | Régimen fiscal asignado ante el SAT. |
| **clienteNacional** | estadoOrigen | CHAR(7) | NOT NULL | Estado de origen de la república del cliente. |
| **clienteExportacion** | numeroCliente | CHAR(7) | PK, FK (cliente), NOT NULL | Identificador del cliente de exportación (heredado de cliente). |
| **clienteExportacion** | idFiscalGlobal | VARCHAR(100) | NOT NULL | Identificador fiscal global para operaciones internacionales. |
| **clienteExportacion** | paisReceptor | VARCHAR(80) | NOT NULL | País de destino o receptor del cliente. |
| **pedido** | folio | CHAR(8) | PK, NOT NULL | Folio o identificador único del pedido. |
| **pedido** | numeroCliente | CHAR(7) | FK (cliente), NOT NULL | Cliente que realizó el pedido. |
| **pedido** | estatus | VARCHAR(20) | NOT NULL | Estado actual en el que se encuentra el pedido. |
| **pedido** | dia | SMALLINT | NULL | Día en que se registró el pedido (Parte de atributo compuesto fecha). |
| **pedido** | mes | SMALLINT | NULL | Mes en que se registró el pedido (Parte de atributo compuesto fecha). |
| **pedido** | anio | SMALLINT | NULL | Año en que se registró el pedido (Parte de atributo compuesto fecha). |
| **transportista** | claveTransportista | CHAR(5) | PK, NOT NULL | Identificador único de la empresa transportista. |
| **transportista** | nombreEmpresa | VARCHAR(100) | NOT NULL | Nombre comercial de la empresa transportista. |
| **transportista** | telefonoAtencion | VARCHAR(20) | NULL | Teléfono de atención a clientes o soporte. |
| **transportista** | email | VARCHAR(50) | NULL | Correo electrónico general del transportista. |
| **transportistaInternacional** | claveTransportista | CHAR(5) | PK, FK (transportista), NOT NULL | Identificador del transportista internacional (heredado). |
| **transportistaInternacional** | codigoAduanal | VARCHAR(20) | NOT NULL | Código aduanal autorizado para cruces internacionales. |
| **transportistaInternacional** | agenciaAduanal | VARCHAR(100) | NOT NULL | Nombre de la agencia aduanal asociada. |
| **transportistaNacional** | claveTransportista | CHAR(5) | PK, FK (transportista), NOT NULL | Identificador del transportista nacional (heredado). |
| **transportistaNacional** | rfc | VARCHAR(13) | NOT NULL | RFC del transportista de operaciones nacionales. |
| **sucursal** | numeroCliente | CHAR(7) | PK compuesta, FK (cliente), NOT NULL | Cliente al que pertenece la sucursal. |
| **sucursal** | claveSucursal | CHAR(5) | PK compuesta, NOT NULL | Identificador parcial o clave interna de la sucursal. |
| **sucursal** | nombrePlanta | VARCHAR(100) | NOT NULL | Nombre descriptivo de la planta o sucursal. |
| **sucursal** | telefonoEncargado | VARCHAR(20) | NOT NULL | Teléfono del responsable de la sucursal. |
| **sucursal** | codigoPostal | CHAR(5) | NULL | Código postal de la ubicación (Atributo compuesto). |
| **sucursal** | calle | VARCHAR(50) | NULL | Calle de la ubicación (Atributo compuesto). |
| **sucursal** | pais | VARCHAR(50) | NULL | País de la ubicación (Atributo compuesto). |
| **sucursal** | estado | VARCHAR(40) | NULL | Estado o provincia (Atributo compuesto). |
| **sucursal** | numero | VARCHAR(10) | NULL | Número exterior/interior (Atributo compuesto). |
| **sucursal** | ciudad | VARCHAR(50) | NULL | Ciudad o municipio (Atributo compuesto). |
| **producto** | claveProducto | CHAR(6) | PK, NOT NULL | Identificador único universal del producto. |
| **producto** | costoUnitarioUSD | DECIMAL(12,3) | NOT NULL | Costo unitario estándar de producción en dólares. |
| **producto** | precioUnitarioUSD | DECIMAL(12,3) | NOT NULL | Precio unitario estándar de venta en dólares. |
| **onmigold** | claveProducto | CHAR(6) | PK, FK (producto), NOT NULL | Identificador del producto especializado línea Onmigold. |
| **hyvolt** | claveProducto | CHAR(6) | PK, FK (producto), NOT NULL | Identificador del producto especializado línea Hyvolt. |
| **hyprene** | claveProducto | CHAR(6) | PK, FK (producto), NOT NULL | Identificador del producto especializado línea Hyprene. |
| **detalle** | folio | CHAR(8) | PK compuesta, FK (pedido), NOT NULL | Pedido al que pertenece esta línea de detalle. |
| **detalle** | claveParcial | SMALLINT | PK compuesta, NOT NULL | Consecutivo o renglón parcial dentro del pedido. |
| **detalle** | claveProducto | CHAR(6) | FK (producto), NOT NULL | Producto seleccionado en este renglón. |
| **detalle** | costoProduccion | DECIMAL(12,2) | NOT NULL | Costo de producción unitario al momento de la venta. |
| **detalle** | precioAplicado | DECIMAL(12,2) | NOT NULL | Precio de venta unitario aplicado al renglón. |
| **detalle** | cantidad | INT | NOT NULL | Unidades requeridas de este producto en el detalle. |
| **envio** | numeroGuia | CHAR(10) | PK, NOT NULL | Número de guía único para el rastreo del envío. |
| **envio** | folio | CHAR(8) | FK (pedido), NOT NULL | Pedido asociado al envío. |
| **envio** | claveTransportista | CHAR(5) | FK (transportista), NOT NULL | Transportista encargado de ejecutar el envío. |
| **envio** | numeroCliente | CHAR(7) | FK compuesta, NOT NULL | Parte de la llave foránea hacia la sucursal receptora. |
| **envio** | claveSucursal | CHAR(5) | FK compuesta, NOT NULL | Parte de la llave foránea hacia la sucursal receptora. |
| **envio** | costo | DECIMAL(12,2) | NOT NULL | Costo o flete total del servicio de envío. |
| **envio** | dia | SMALLINT | NULL | Día en que se ejecuta el envío. |
| **envio** | mes | SMALLINT | NULL | Mes en que se ejecuta el envío. |
| **envio** | anio | SMALLINT | NULL | Año en que se ejecuta el envío. |
