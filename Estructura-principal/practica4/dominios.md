# Ejercicio 1.1 y 1.2. Tipos de dato, dominios y restricciones

## Alcance

El proyecto representa ventas y envíos de tres líneas industriales: OMNIGOLD, HYVOLT y HYPRENE. El esquema relacional original está en esquema.sql. Los atributos que aparecen en el Excel pero no estaban en el DDL inicial se agregan mediante la migración 001-dominios.sql.

## Tipos de dato

| Tabla | Columna | Tipo y longitud/precisión | Justificación |
|---|---|---|---|
| cliente | numeroCliente | INTEGER | Identificador numérico del cliente. |
| cliente | razonSocial | VARCHAR(150) | Nombre o razón social de longitud variable. |
| cliente | correoCliente | correo_electronico (VARCHAR(100)) | Correo de contacto con formato validado. |
| cliente | telefonoCliente | telefono_contacto (VARCHAR(20)) | Texto para conservar prefijo + y separadores. |
| cliente | tipoCliente | VARCHAR(15) | Discriminador NACIONAL o EXPORTACION. |
| cliente | RFC | VARCHAR(13) | Identificador fiscal nacional. |
| cliente | regimenFiscal | VARCHAR(100) | Descripción del régimen fiscal. |
| cliente | estadoOrigen | VARCHAR(50) | Nombre del estado. |
| cliente | idFiscalGlobal | VARCHAR(30) | Identificador fiscal extranjero. |
| cliente | paisReceptor | VARCHAR(50) | País del cliente de exportación. |
| transportista | claveTransportista | VARCHAR(10) | Clave alfanumérica del transportista. |
| transportista | nombreEmpresa | VARCHAR(100) | Nombre comercial de longitud variable. |
| transportista | telefonoAtencion | telefono_contacto (VARCHAR(20)) | Teléfono opcional; puede ser NULL. |
| transportista | email | correo_electronico (VARCHAR(100)) | Correo opcional; puede ser NULL. |
| transportista | esNacional / esInternacional | BOOLEAN | Modalidades de servicio. |
| transportista | RFC | VARCHAR(13) | RFC nacional, si el transportista opera nacionalmente. |
| transportista | codigoAduanal | VARCHAR(20) | Código aduanal alfanumérico. |
| transportista | agenciaAduanal | VARCHAR(100) | Nombre de agencia aduanal. |
| producto | claveProducto | VARCHAR(10) | Clave corta alfanumérica del producto. |
| producto | modeloProducto | VARCHAR(30) | Modelo comercial añadido desde la fuente. |
| producto | costoUnitarioUSD | NUMERIC(12,2) | Importe monetario con dos decimales. |
| producto | precioUnitarioUSD | NUMERIC(12,2) | Precio de catálogo con precisión decimal. |
| producto | tipoProducto | VARCHAR(10) | Discriminador OMNIGOLD, HYVOLT o HYPRENE. |
| producto | provMaquinaria / provTransformador / provTransporte | VARCHAR(100) | Proveedor de la línea correspondiente. |
| sucursal | numeroCliente | INTEGER | Parte de la PK y FK a cliente. |
| sucursal | claveSucursal | VARCHAR(10) | Clave de sucursal dentro del cliente. |
| sucursal | nombrePlanta | VARCHAR(100) | Nombre de planta o sucursal. |
| sucursal | telefonoEncargado | telefono_contacto (VARCHAR(20)) | Teléfono opcional validado por formato. |
| sucursal | calle | VARCHAR(100) | Nombre de vialidad. |
| sucursal | numero | VARCHAR(10) | Número exterior/interior, puede contener letras. |
| sucursal | ciudad / estado / pais | VARCHAR(60) | Componentes de dirección. |
| sucursal | CP | VARCHAR(10) | Código postal como texto. |
| pedido | folio | INTEGER | Identificador del pedido. |
| pedido | numeroCliente | INTEGER | Cliente que realiza el pedido. |
| pedido | estatus | VARCHAR(20) | Estado del pedido; se valida con CHECK. |
| pedido | dia / mes / anio | SMALLINT | Componentes numéricos de la fecha. |
| pedido | activo | BOOLEAN | Borrado lógico; TRUE por omisión. |
| detalle | folio / claveParcial | INTEGER | PK compuesta para identificar cada renglón del pedido. |
| detalle | claveProducto | VARCHAR(10) | Producto vendido. |
| detalle | costoProduccion / precioAplicado | NUMERIC(12,2) | Importes monetarios con precisión decimal. |
| detalle | cantidad | INTEGER | Unidades del producto. |
| envio | numeroGuia | VARCHAR(20) | Identificador alfanumérico de rastreo. |
| envio | folio | INTEGER | Pedido al que corresponde el envío; UNIQUE. |
| envio | claveTransportista | VARCHAR(10) | Transportista asignado. |
| envio | numeroCliente / claveSucursal | INTEGER / VARCHAR(10) | Clave compuesta de la sucursal destino. |
| envio | costoFlete | NUMERIC(12,2) | Costo monetario del traslado. |
| envio | dia / mes / anio | SMALLINT | Componentes de la fecha del envío. |

Los identificadores alfanuméricos, teléfonos, códigos postales y números de dirección se almacenan como texto. Los importes utilizan NUMERIC y no punto flotante. Las fechas conservan los componentes del esquema original y se validan para garantizar que formen fechas reales.

## Dominios compartidos

Se declaran dos dominios con CREATE DOMAIN:

- correo_electronico: VARCHAR(100) con comprobación de formato; se aplica en cliente y transportista.
- telefono_contacto: VARCHAR(20) con comprobación de formato; se aplica en cliente, transportista y sucursal.

Los dominios permiten reutilizar la misma regla en varias tablas. En transportista y sucursal los atributos de contacto permiten NULL, porque la fuente contiene teléfonos o correos opcionales. En cliente correo y teléfono son obligatorios.

## Restricciones y reglas del dominio

| Restricción | Tabla / columna | Regla protegida |
|---|---|---|
| NOT NULL | cliente.razonSocial, correoCliente y telefonoCliente | Todo cliente debe tener nombre y medios de contacto. |
| UNIQUE / PK | cliente.numeroCliente | Cada cliente tiene identificador único. |
| UNIQUE | cliente.RFC | El RFC identifica a un cliente nacional. |
| UNIQUE | cliente.idFiscalGlobal | El identificador fiscal global identifica a un cliente extranjero. |
| CHECK | cliente.tipoCliente y datos fiscales | Los campos fiscales corresponden a NACIONAL o EXPORTACION. |
| CHECK de dominio | correo_electronico | El correo debe tener estructura válida. |
| UNIQUE | cliente.correoCliente | El correo de contacto no se repite. |
| CHECK de dominio | telefono_contacto | El teléfono solo contiene prefijo, dígitos y separadores permitidos. |
| CHECK | cliente.RFC | Cuando existe, el RFC debe tener formato nacional. |
| CHECK | transportista.esNacional / esInternacional | Cada transportista opera en al menos una modalidad. |
| CHECK | transportista.RFC | RFC presente para modalidad nacional y ausente si no aplica. |
| CHECK | transportista.codigoAduanal / agenciaAduanal | Los dos datos se requieren si opera internacionalmente. |
| UNIQUE | transportista.email y RFC | No se repiten correos ni RFC de transportistas; se admiten NULL. |
| CHECK | producto.tipoProducto | Solo existen las tres líneas comerciales. |
| CHECK | producto.modeloProducto | El modelo debe ser uno de los diez registrados en el archivo. |
| CHECK | producto.modeloProducto / tipoProducto | El prefijo del modelo corresponde a su línea; HYGOLD se asigna a OMNIGOLD. |
| CHECK | producto.proveedores | Se llena únicamente el proveedor que corresponde al tipo. |
| CHECK | producto.costounitariousd / preciounitariousd | El precio de catálogo no puede ser menor que el costo. |
| CHECK | sucursal.CP | Si se captura, el código postal contiene cinco dígitos. |
| PK compuesta | sucursal.numeroCliente / claveSucursal | La clave de sucursal es única dentro del cliente. |
| DEFAULT | pedido.estatus | Un pedido nuevo inicia como REGISTRADO. |
| DEFAULT | pedido.activo | Un pedido nuevo está activo. |
| CHECK | pedido.estatus | Solo se admiten REGISTRADO, EN PROCESO, ENVIADO, ENTREGADO y CANCELADO. |
| CHECK | pedido.fecha | Día, mes y año deben formar una fecha real. |
| PK compuesta | detalle.folio / claveParcial | No se repite el número de renglón dentro del pedido. |
| CHECK | detalle.cantidad | La cantidad debe ser positiva. |
| CHECK | detalle.costoProduccion / precioAplicado | El precio aplicado no puede quedar por debajo del costo de producción. |
| UNIQUE | envio.folio | Un pedido tiene como máximo un envío. |
| CHECK | envio.costoFlete | El flete no puede ser negativo. |
| CHECK | envio.fecha | La fecha del envío debe existir en el calendario. |

Las claves primarias y foráneas del esquema también evitan duplicados y referencias inexistentes. La clave primaria compuesta de sucursal permite que una claveSucursal se repita entre clientes diferentes, pero no dentro del mismo cliente.

## Ajustes entre el Excel y el esquema de la Práctica 3

El archivo fuente agrega dos atributos que no aparecían en el DDL original:

1. producto.modeloProducto: se incorpora mediante ALTER TABLE y se limita a los diez modelos del Excel.
2. pedido.activo: se incorpora como BOOLEAN NOT NULL DEFAULT TRUE, conservando los valores TRUE/FALSE de la fuente para permitir borrado lógico.

La fuente incluye cuatro estados observados (ENTREGADO, CANCELADO, ENVIADO y EN PROCESO). El diccionario de generación también contempla REGISTRADO como estado inicial, por eso se permite en el dominio y se establece como DEFAULT.

La comprobación del Excel encontró que los 1,500 detalles tienen precioAplicado mayor o igual al costoProduccion. Por eso se puede declarar el CHECK de precio mínimo sin rechazar filas de esta versión.
