# Ejercicio 1.1 y 1.2. Tipos de dato, dominios y restricciones

## Alcance

El proyecto propio representa las ventas y los envíos de tres líneas de productos industriales: OMNIGOLD, HYVOLT y HYPRENE. El esquema relacional original de la Práctica 3 está en esquema.sql. La migración 001 agrega los atributos que vienen en el Excel y las restricciones que se revisan en esta práctica.

## Tipos de dato

| Tabla | Columna | Tipo y longitud/precisión | Justificación |
|---|---|---|---|
| cliente | numeroCliente | INTEGER | Identificador numérico del cliente. |
| cliente | razonSocial | VARCHAR(150) | Razón social de longitud variable. |
| cliente | correoCliente | correo_electronico (VARCHAR(100)) | Correo con formato validado mediante dominio compartido. |
| cliente | telefonoCliente | telefono_contacto (VARCHAR(20)) | Texto para conservar prefijo + y espacios. |
| cliente | tipoCliente | VARCHAR(15) | Discriminador NACIONAL o EXPORTACION. |
| cliente | RFC | VARCHAR(13) | Identificador fiscal nacional. |
| cliente | regimenFiscal | VARCHAR(100) | Descripción del régimen fiscal. |
| cliente | estadoOrigen | VARCHAR(50) | Nombre del estado. |
| cliente | idFiscalGlobal | VARCHAR(30) | Identificador fiscal extranjero. |
| cliente | paisReceptor | VARCHAR(50) | País del cliente de exportación. |
| transportista | claveTransportista | VARCHAR(10) | Clave alfanumérica del transportista. |
| transportista | nombreEmpresa | VARCHAR(100) | Nombre comercial de longitud variable. |
| transportista | telefonoAtencion | telefono_contacto (VARCHAR(20)) | Teléfono opcional con el mismo formato compartido. |
| transportista | email | correo_electronico (VARCHAR(100)) | Correo opcional con formato validado. |
| transportista | esNacional / esInternacional | BOOLEAN | Indican las modalidades en las que opera. |
| transportista | RFC | VARCHAR(13) | RFC, obligatorio cuando opera en modalidad nacional. |
| transportista | codigoAduanal | VARCHAR(20) | Código aduanal alfanumérico. |
| transportista | agenciaAduanal | VARCHAR(100) | Nombre de la agencia aduanal. |
| producto | claveProducto | VARCHAR(10) | Clave alfanumérica del producto. |
| producto | modeloProducto | VARCHAR(30) | Modelo comercial recibido en el Excel; se agrega mediante migración. |
| producto | costoUnitarioUSD | NUMERIC(12,2) | Importe monetario con dos decimales; no se usa punto flotante. |
| producto | precioUnitarioUSD | NUMERIC(12,2) | Precio de catálogo con precisión decimal. |
| producto | tipoProducto | VARCHAR(10) | Discriminador OMNIGOLD, HYVOLT o HYPRENE. |
| producto | provMaquinaria / provTransformador / provTransporte | VARCHAR(100) | Proveedor de la línea comercial correspondiente. |
| sucursal | numeroCliente | INTEGER | Parte de la clave primaria y referencia al cliente. |
| sucursal | claveSucursal | VARCHAR(10) | Clave de sucursal dentro del cliente. |
| sucursal | nombrePlanta | VARCHAR(100) | Nombre de planta o sucursal. |
| sucursal | telefonoEncargado | telefono_contacto (VARCHAR(20)) | Teléfono opcional; se guarda como texto. |
| sucursal | calle | VARCHAR(100) | Nombre de vialidad. |
| sucursal | numero | VARCHAR(10) | Número exterior/interior; puede incluir letras. |
| sucursal | ciudad / estado / pais | VARCHAR(60) | Componentes de dirección. |
| sucursal | CP | VARCHAR(10) | Código postal como texto para conservar ceros iniciales. |
| pedido | folio | INTEGER | Identificador numérico del pedido. |
| pedido | numeroCliente | INTEGER | Cliente que realiza el pedido. |
| pedido | estatus | VARCHAR(20) | Estado del pedido; la fuente contiene ENVIADO y ENTREGADO. |
| pedido | dia / mes / anio | SMALLINT | Componentes numéricos de la fecha del pedido. |
| pedido | activo | BOOLEAN | Campo recibido en el Excel; indica si el pedido está activo. |
| detalle | folio / claveParcial | INTEGER | Clave compuesta del renglón de pedido. |
| detalle | claveProducto | VARCHAR(10) | Producto incluido en el pedido. |
| detalle | costoProduccion / precioAplicado | NUMERIC(12,2) | Importes monetarios con precisión decimal. |
| detalle | cantidad | INTEGER | Unidades incluidas en el renglón. |
| envio | numeroGuia | VARCHAR(20) | Código alfanumérico de rastreo. |
| envio | folio | INTEGER | Pedido relacionado; UNIQUE limita a un envío por pedido. |
| envio | claveTransportista | VARCHAR(10) | Transportista encargado. |
| envio | numeroCliente / claveSucursal | INTEGER / VARCHAR(10) | Clave compuesta de la sucursal destino. |
| envio | costoFlete | NUMERIC(12,2) | Costo monetario del traslado. |
| envio | dia / mes / anio | SMALLINT | Componentes numéricos de la fecha de envío. |

Los identificadores alfanuméricos, los teléfonos, los códigos postales y los números de dirección se guardan como texto. Los importes se almacenan con NUMERIC(12,2) para evitar errores de representación de punto flotante. Las fechas se conservan con los tres atributos que aparecen en el esquema original y se comprueba que formen una fecha real.

## Dominios compartidos

Se definen dos dominios con CREATE DOMAIN:

- correo_electronico: VARCHAR(100) con una comprobación de formato. Se usa en cliente y transportista.
- telefono_contacto: VARCHAR(20) con una comprobación de formato. Se usa en cliente, transportista y sucursal.

La ventaja es declarar una sola vez una regla que se repite en varias tablas. Los atributos opcionales permiten NULL; el dominio valida el formato cuando el valor está presente.

## Restricciones y regla del dominio

| Restricción | Tabla / columna | Regla protegida |
|---|---|---|
| NOT NULL | cliente.razonSocial, correoCliente, telefonoCliente | El cliente debe tener nombre y medios de contacto. |
| UNIQUE / PK | cliente.numeroCliente | Cada cliente tiene un identificador distinto. |
| UNIQUE | cliente.RFC | Dos clientes nacionales no comparten RFC. |
| UNIQUE | cliente.idFiscalGlobal | Dos clientes de exportación no comparten identificador fiscal. |
| CHECK | cliente.tipoCliente | Solo se admiten NACIONAL y EXPORTACION. |
| CHECK | cliente (campos fiscales) | Los datos fiscales dependen del tipo de cliente. |
| CHECK de dominio | correo_electronico | Los correos deben respetar un formato básico válido. |
| UNIQUE | cliente.correoCliente | El correo identifica un contacto de cliente. |
| CHECK de dominio | telefono_contacto | Los teléfonos solo contienen prefijo, dígitos, espacios y separadores permitidos. |
| CHECK | cliente.RFC | Si existe RFC, debe tener formato de RFC nacional. |
| CHECK | transportista.esNacional / esInternacional | Todo transportista debe tener al menos una modalidad. |
| CHECK | transportista.RFC | El RFC debe existir si esNacional; debe ser NULL en caso contrario. |
| CHECK | transportista.codigoAduanal / agenciaAduanal | Ambos campos se requieren si esInternacional. |
| UNIQUE | transportista.email | Un correo no identifica a dos transportistas. |
| CHECK | producto.tipoProducto | Solo se admiten las tres líneas comerciales. |
| CHECK | producto.modeloProducto | El modelo debe pertenecer a los diez modelos de la fuente. |
| CHECK | producto.modeloProducto / tipoProducto | El prefijo del modelo debe corresponder a su línea; HYGOLD se asigna a OMNIGOLD. |
| CHECK | producto proveedores | Se llena únicamente el proveedor de la línea correspondiente. |
| CHECK | producto.costoUnitarioUSD / precioUnitarioUSD | Los importes no pueden ser negativos. |
| CHECK | producto.precioUnitarioUSD | En la fuente, el precio de catálogo es mayor o igual que el costo unitario. |
| CHECK | sucursal.CP | Si se captura, debe contener cinco dígitos. |
| PK compuesta | sucursal.numeroCliente / claveSucursal | La clave de sucursal es única dentro de cada cliente. |
| DEFAULT | pedido.activo | Un pedido nuevo inicia activo. |
| CHECK | pedido.estatus | La fuente contiene únicamente ENVIADO y ENTREGADO. |
| CHECK | pedido.dia / mes / anio | Los componentes deben formar una fecha válida. |
| PK compuesta | detalle.folio / claveParcial | No se repite el número de renglón dentro del mismo pedido. |
| CHECK | detalle.cantidad | La cantidad debe ser positiva. |
| CHECK | detalle.claveParcial | El número de renglón debe ser positivo. |
| CHECK | detalle.costoProduccion / precioAplicado | Los importes no pueden ser negativos. |
| UNIQUE | envio.folio | La fuente y el esquema contemplan un envío por pedido. |
| CHECK | envio.costoFlete | El costo de flete no puede ser negativo. |
| CHECK | envio.dia / mes / anio | Los componentes deben formar una fecha válida. |

El diseño no agrega un CHECK que obligue a precioAplicado >= costoProduccion. La inspección encontró tres detalles que no cumplen esa comparación, por lo que no se puede declarar como regla obligatoria sin decidir antes si esos casos son errores o excepciones comerciales. Se conservan sin modificarlos.

La hoja fuente contiene 1,500 pedidos y 1,500 detalles, pero la clave compuesta (folio, claveParcial) permite que un pedido tenga más de un renglón cuando el dominio lo necesite. La cantidad actual de renglones por pedido no debe confundirse con una restricción adicional del modelo.

## Ajustes entre la fuente y el esquema base

El Excel añade dos atributos que no estaban en el DDL original:

1. producto.modeloProducto: se incorpora mediante ALTER TABLE y se valida contra los diez modelos listados en la fuente.
2. pedido.activo: se incorpora como BOOLEAN NOT NULL DEFAULT TRUE para representar el borrado lógico.

La migración se aplica después de esquema.sql. No se modifica manualmente la base de datos; los cambios quedan versionados en archivos SQL.
