# Ejercicio 1.3. Fuente de datos del proyecto propio

## Fuente seleccionada

La fuente principal es el archivo de Excel **base_datos_pedidos.xlsx**, proporcionado por el equipo para esta práctica. Contiene una base de datos sintética de pedidos de una empresa que comercializa tres líneas de productos industriales: OMNIGOLD, HYVOLT y HYPRENE.

El equipo partió de una base de datos relacional de una empresa privada que se utilizó como referencia para comprender el dominio y la estructura de las tablas. Como esa base no podía publicarse ni compartirse, se modificó y abstrajo su estructura para no utilizar los registros privados. Después se explicó a **Claude (Anthropic), como colaborador de IA generativa**, la organización de las entidades, sus atributos, las relaciones y las reglas del dominio. Claude apoyó la generación aleatoria y estructurada de los registros que integran el archivo entregado. El conjunto final es sintético: no debe presentarse como una exportación de ventas reales ni como un conjunto de datos público.

## Referencia y licencia

Referencia en formato APA 7 para identificar el archivo de trabajo:

Equipo del proyecto. (2026). *Base de datos sintética de pedidos* [Archivo de datos XLSX no publicado; generación asistida por Claude (Anthropic)].

No se trata de un conjunto publicado por una institución ni de un dataset con licencia abierta. La estructura de referencia proviene de un caso privado y no se redistribuye. El archivo sintético se utiliza únicamente como material académico del proyecto. La mención de Claude documenta el apoyo de IA en la generación de datos; no implica que Claude sea una fuente estadística externa ni que el archivo tenga una licencia de Anthropic.

## Formato, tamaño y contenido

- Archivo: base_datos_pedidos.xlsx
- Formato: Microsoft Excel (XLSX).
- Tamaño del archivo recibido: 606,594 bytes (aproximadamente 593 KiB).
- Hojas: siete hojas correspondientes a tablas y una hoja adicional llamada Notas.
- Registros: 1,500 en cada tabla; 10,500 registros en total.
- Columnas de las siete tablas: 59 en total.
- Periodo de pedidos: 2024-01-01 a 2026-09-30.
- Periodo de envíos: 2024-01-04 a 2026-10-09.

| Hoja / tabla | Registros | Columnas |
|---|---:|---|
| cliente | 1,500 | numeroCliente, razonSocial, correoCliente, telefonoCliente, tipoCliente, RFC, regimenFiscal, estadoOrigen, idFiscalGlobal, paisReceptor |
| transportista | 1,500 | claveTransportista, nombreEmpresa, telefonoAtencion, email, esNacional, esInternacional, RFC, codigoAduanal, agenciaAduanal |
| producto | 1,500 | claveProducto, modeloProducto, costoUnitarioUSD, precioUnitarioUSD, tipoProducto, provMaquinaria, provTransformador, provTransporte |
| sucursal | 1,500 | numeroCliente, claveSucursal, nombrePlanta, telefonoEncargado, calle, numero, ciudad, estado, pais, CP |
| pedido | 1,500 | folio, numeroCliente, estatus, dia, mes, anio, activo |
| detalle | 1,500 | folio, claveParcial, claveProducto, costoProduccion, precioAplicado, cantidad |
| envio | 1,500 | numeroGuia, folio, claveTransportista, numeroCliente, claveSucursal, costoFlete, dia, mes, anio |
| Notas | 11 filas de metadatos | Descripción de la generación y decisiones usadas para preparar las hojas; no se carga como tabla relacional. |

## Correspondencia entre la fuente y el esquema

La correspondencia es directa: las siete hojas de datos corresponden a las siete tablas relacionales y cada columna se carga en la columna homónima, normalizando los nombres a minúsculas porque PostgreSQL convierte los identificadores no delimitados a minúsculas. No se descartan campos de las siete hojas. La hoja Notas se conserva como documentación y no se importa.

| Hoja | Tabla destino | Correspondencia |
|---|---|---|
| cliente | cliente | Las diez columnas pasan a sus atributos homónimos. |
| transportista | transportista | Las nueve columnas pasan a sus atributos homónimos. |
| producto | producto | Las ocho columnas pasan a sus atributos homónimos; modeloProducto se incorporó mediante migración. |
| sucursal | sucursal | Las diez columnas pasan a sus atributos homónimos. |
| pedido | pedido | Las siete columnas pasan a sus atributos homónimos; activo se incorpora mediante migración. |
| detalle | detalle | Las seis columnas pasan a sus atributos homónimos. |
| envio | envio | Las nueve columnas pasan a sus atributos homónimos. |
| Notas | No se carga | Explica reglas de generación, campos opcionales y supuestos del conjunto. |

## Revisión de calidad y decisiones

La revisión se realizó sobre los 10,500 registros del archivo recibido. Los siguientes resultados describen esta versión concreta del Excel:

| Revisión | Resultado observado | Decisión |
|---|---|---|
| Claves identificadoras | No se encontraron duplicados en numeroCliente, claveTransportista, claveProducto, folio ni numeroGuia. Tampoco en las claves compuestas de sucursal y detalle. | Se conservan como PK simples o compuestas según el esquema. |
| Correos de cliente | 1,500 valores no nulos y distintos. | NOT NULL y UNIQUE. |
| RFC de cliente | 1,065 valores no nulos y distintos; 435 nulos corresponden a EXPORTACION. | Se conserva como opcional y se valida el formato cuando existe. |
| Identificador fiscal global | 435 valores no nulos; los 1,065 nulos corresponden a NACIONAL. | Se conserva como atributo opcional con UNIQUE. |
| Teléfonos | Los 1,500 clientes tienen teléfono; hay 199 teléfonos nulos en transportista y 321 en sucursal. | NOT NULL solo para cliente; en transportista y sucursal se permiten nulos. |
| Correos de transportista | 1,282 no nulos, sin duplicados; 218 nulos. | Se permite NULL y se valida formato cuando existe. |
| RFC de transportista | 1,117 no nulos y 383 nulos; los nulos corresponden a transportistas sin modalidad nacional. | Se valida el formato cuando existe y se conserva la regla de modalidad nacional. |
| Datos aduanales | 774 transportistas tienen modalidad internacional; sus campos aduanales están presentes. | Se conserva la regla de que código y agencia aduanal son obligatorios para esa modalidad. |
| Proveedor de producto | Solo se llena el campo de proveedor de la línea correspondiente: maquinaria, transformador o transporte. | Se conserva el CHECK del subtipo de producto. |
| Modelo y línea de producto | Hay diez modelos. HYGOLD se asignó a OMNIGOLD según las notas de la fuente. | Se incorpora modeloProducto y se restringe la combinación modelo/tipo. |
| Código postal | Los 1,500 valores son textos de cinco dígitos. Hay seis repeticiones legítimas. | Se valida el formato, pero no se declara UNIQUE. |
| Valores de pedido | 925 ENTREGADO, 575 ENVIADO; 1,420 activos y 80 inactivos. | CHECK con los dos estados observados; activo se conserva y tiene DEFAULT TRUE. |
| Fechas | Todas las fechas de pedido y envío forman fechas válidas. Los 1,500 envíos son posteriores a la fecha de su pedido. | Se valida el calendario con make_date y se documenta la relación temporal comprobada. |
| Claves foráneas | No se encontraron referencias huérfanas en las relaciones revisadas. Los 1,500 envíos apuntan al mismo cliente del pedido y a una sucursal de ese cliente. | Se declaran las FKs y una FK compuesta adicional en la migración 002. |
| Importes de catálogo | Los 1,500 productos tienen precioUnitarioUSD mayor o igual que costoUnitarioUSD. | Se conserva el CHECK en producto. |
| Importe aplicado | Tres detalles tienen precioAplicado menor que costoProduccion. Los 1,500 precios aplicados son distintos del precio de catálogo. | No se impone CHECK precioAplicado >= costoProduccion: la fuente contiene tres excepciones y el atributo representa el precio aplicado a la venta. Los datos no se alteran de forma silenciosa. |
| Cantidades y fletes | Cantidad va de 1 a 500; costoFlete es positivo. | Se mantienen CHECK de cantidad positiva y flete no negativo. |

Los NULL del archivo no se consideran errores automáticamente: representan atributos que no aplican a un subtipo de cliente o transportista, o datos opcionales de contacto. Los seis códigos postales repetidos no son duplicados de sucursal porque la clave de sucursal es numeroCliente + claveSucursal.

## Carga automatizada

El archivo fuente debe colocarse en:

    practica4/datos/base_datos_pedidos.xlsx

El programa practica4/poblar/poblar.py lee el libro, verifica las hojas y encabezados, y carga las tablas en orden de dependencia mediante COPY. La carga usa DATABASE_URL, que debe conectarse con usuario_app. Es transaccional: si una restricción rechaza una fila, no se confirma ninguna tabla. Una segunda ejecución no duplica registros y reporta cuántos ya existían.

El archivo fuente es necesario para ejecutar el script; no se debe reemplazar por una población aleatoria diferente. Las salidas reales del gestor y la comparación de tiempo COPY/INSERT se agregan después de ejecutar los programas en el equipo local.
