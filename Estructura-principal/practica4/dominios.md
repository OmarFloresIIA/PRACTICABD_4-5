# Ejercicio 1.1 y 1.2. Tipos de dato, dominios y restricciones

## Alcance

El proyecto propio representa las ventas y envíos de una empresa que comercializa tres líneas de productos industriales: OMNIGOLD, HYVOLT y HYPRENE. El esquema relacional de referencia está en `schema.sql`; las restricciones adicionales se aplican mediante `migraciones/001-dominios.sql`.

## Tipos de dato

| Tabla | Columna | Tipo y longitud/precisión | Justificación |
|---|---|---:|---|
| cliente | numeroCliente | INTEGER | Identificador numérico del cliente. |
| cliente | razonSocial | VARCHAR(150) | Nombre comercial de longitud variable. |
| cliente | correoCliente | correo_electronico (dominio sobre VARCHAR(100)) | Correo de contacto con formato validado por un dominio compartido. |
| cliente | telefonoCliente | telefono_contacto (dominio sobre VARCHAR(20)) | Texto para conservar prefijos, + y ceros iniciales; formato validado por dominio. |
| cliente | tipoCliente | VARCHAR(15) | Discriminador NACIONAL o EXPORTACION. Se amplía a 15 porque EXPORTACION tiene 11 caracteres. |
| cliente | RFC | VARCHAR(13) | Identificador fiscal nacional de longitud conocida. |
| cliente | regimenFiscal | VARCHAR(100) | Descripción del régimen fiscal. |
| cliente | estadoOrigen | VARCHAR(50) | Nombre del estado. |
| cliente | idFiscalGlobal | VARCHAR(30) | Identificador fiscal extranjero, de formato variable. |
| cliente | paisReceptor | VARCHAR(50) | Nombre del país. |
| transportista | claveTransportista | VARCHAR(10) | Clave alfanumérica del transportista. |
| transportista | nombreEmpresa | VARCHAR(100) | Razón o nombre comercial. |
| transportista | telefonoAtencion | telefono_contacto (dominio sobre VARCHAR(20)) | Teléfono opcional con el mismo formato que el de cliente y sucursal. |
| transportista | email | correo_electronico (dominio sobre VARCHAR(100)) | Correo electrónico opcional con formato validado. |
| transportista | esNacional / esInternacional | BOOLEAN | Indican las modalidades de operación. |
| transportista | RFC | VARCHAR(13) | RFC nacional; solo aplica si esNacional es verdadero. |
| transportista | codigoAduanal | VARCHAR(20) | Código alfanumérico de aduana. |
| transportista | agenciaAduanal | VARCHAR(100) | Nombre de la agencia. |
| producto | claveProducto | VARCHAR(10) | Identificador alfanumérico del producto. |
| producto | costoUnitarioUSD | NUMERIC(12,2) | Importe monetario con dos decimales; no se usa punto flotante. |
| producto | precioUnitarioUSD | NUMERIC(12,2) | Importe monetario con dos decimales. |
| producto | tipoProducto | VARCHAR(10) | Discriminador OMNIGOLD, HYVOLT o HYPRENE. |
| producto | provMaquinaria / provTransformador / provTransporte | VARCHAR(100) | Nombre del proveedor correspondiente al subtipo. |
| sucursal | numeroCliente | INTEGER | Parte de la clave primaria y referencia al cliente. |
| sucursal | claveSucursal | VARCHAR(10) | Discriminador de sucursal dentro del cliente. |
| sucursal | nombrePlanta | VARCHAR(100) | Nombre descriptivo de la planta. |
| sucursal | telefonoEncargado | telefono_contacto (dominio sobre VARCHAR(20)) | Teléfono opcional con formato compartido. |
| sucursal | calle | VARCHAR(100) | Componente textual de dirección. |
| sucursal | numero | VARCHAR(10) | Número exterior/interior; puede contener letras. |
| sucursal | ciudad / estado / pais | VARCHAR(60) | Componentes de dirección de longitud variable. |
| sucursal | CP | VARCHAR(10) | Código postal como texto para conservar ceros iniciales. |
| pedido | folio | INTEGER | Identificador del pedido. |
| pedido | numeroCliente | INTEGER | Cliente que realiza el pedido. |
| pedido | estatus | VARCHAR(20) | Estado textual del pedido, limitado por CHECK. |
| pedido | dia / mes | SMALLINT | Componentes numéricos de la fecha. |
| pedido | anio | SMALLINT | Año del pedido. |
| pedido | activo | BOOLEAN | Indica si el registro sigue activo; permite borrado lógico. |
| detalle | folio / claveParcial | INTEGER | Clave compuesta: pedido y número de renglón. |
| detalle | claveProducto | VARCHAR(10) | Producto vendido. |
| detalle | costoProduccion / precioAplicado | NUMERIC(12,2) | Importes monetarios con dos decimales. |
| detalle | cantidad | INTEGER | Número entero de unidades. |
| envio | numeroGuia | VARCHAR(20) | Identificador alfanumérico de rastreo. |
| envio | folio | INTEGER | Pedido enviado; UNIQUE permite un envío por pedido. |
| envio | claveTransportista | VARCHAR(10) | Transportista asignado. |
| envio | numeroCliente / claveSucursal | INTEGER / VARCHAR(10) | Clave compuesta de la sucursal destino. |
| envio | costoFlete | NUMERIC(12,2) | Importe monetario con dos decimales. |
| envio | dia / mes / anio | SMALLINT | Fecha del envío descompuesta en componentes. |

Los identificadores que pueden contener letras se guardan como texto. Los importes usan `NUMERIC`, porque son cantidades monetarias y requieren precisión decimal. Los teléfonos y códigos postales también se guardan como texto para no perder símbolos ni ceros iniciales.

## Dominios repetidos

Se definen dos dominios compartidos con `CREATE DOMAIN`: `correo_electronico` (VARCHAR(100) con una comprobación de formato) y `telefono_contacto` (VARCHAR(20) con una comprobación de formato). Se usan en cliente, transportista y sucursal. La ventaja es que la misma regla se declara una sola vez y se aplica de forma uniforme en varias tablas. RFC y código postal conservan CHECK propios porque sus reglas son diferentes.

## Restricciones de dominio declaradas

| Restricción | Tabla / columna | Regla del dominio |
|---|---|---|
| NOT NULL | cliente.razonSocial, correoCliente y telefonoCliente | Todo cliente debe tener nombre y medios de contacto. |
| UNIQUE | cliente.RFC | Dos clientes nacionales no comparten RFC. |
| UNIQUE | cliente.idFiscalGlobal | Dos clientes de exportación no comparten identificador fiscal. |
| CHECK | cliente.tipoCliente | Solo se admiten NACIONAL y EXPORTACION. |
| CHECK | cliente (campos fiscales) | Los datos fiscales corresponden únicamente al subtipo indicado. |
| CHECK de dominio | correo_electronico | El mismo formato de correo se aplica a cliente y transportista. |
| UNIQUE | cliente.correocliente | Cada correo de contacto identifica un cliente. |
| CHECK de dominio | telefono_contacto | El mismo formato telefónico se aplica a cliente, transportista y sucursal. |
| CHECK | cliente.rfc | Si existe, el RFC debe tener formato nacional. |
| CHECK | transportista.esNacional / esInternacional | Todo transportista opera al menos en una modalidad. |
| CHECK | transportista.RFC | RFC obligatorio para modalidad nacional y nulo si no aplica. |
| CHECK | transportista.codigoAduanal / agenciaAduanal | Ambos datos son obligatorios para modalidad internacional. |
| UNIQUE | transportista.email | Un correo no identifica a dos transportistas. |
| CHECK | producto.tipoProducto | Solo se admiten las tres líneas comerciales del proyecto. |
| CHECK | producto (proveedores) | Cada producto tiene únicamente el proveedor que corresponde a su línea. |
| CHECK | producto.costoUnitarioUSD / precioUnitarioUSD | Los importes no pueden ser negativos. |
| CHECK | producto.precioUnitarioUSD | El precio de lista no debe ser menor que el costo unitario. |
| CHECK | sucursal.CP | Si se captura, debe contener cinco dígitos. |
| CHECK | pedido.dia / mes / anio | La fecha debe existir en el calendario. |
| DEFAULT | pedido.estatus | Un pedido nuevo inicia como REGISTRADO. |
| DEFAULT | pedido.activo | Un pedido nuevo está activo. |
| CHECK | pedido.estatus | Solo se admiten los estados definidos para el proceso de venta. |
| CHECK | detalle.cantidad | Cada renglón debe contener una cantidad positiva. |
| CHECK | detalle.claveParcial | El número de renglón dentro del pedido debe ser positivo. |
| CHECK | detalle.costoProduccion / precioAplicado | Los importes no pueden ser negativos. |
| CHECK | envio.costoFlete | El costo de envío no puede ser negativo. |
| CHECK | envio.dia / mes / anio | La fecha de envío debe existir en el calendario. |

La PK compuesta de `sucursal(numeroCliente, claveSucursal)` y la de `detalle(folio, claveParcial)` también impiden repetir la combinación que identifica a cada sucursal o renglón. `envio.folio` es UNIQUE porque el modelo del proyecto contempla como máximo un envío por pedido.

## Observación sobre el esquema anterior

El DDL recopilado declaraba `tipoCliente VARCHAR(10)`, pero el valor `EXPORTACION` tiene 11 caracteres. Se corrigió el tamaño antes de cargar los datos. Además, el diccionario de datos indicaba correo y teléfono obligatorios para cliente, mientras que el DDL permitía nulos; la migración hace coincidir la implementación con esa regla.
