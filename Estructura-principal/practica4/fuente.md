# Ejercicio 1.3. Fuente de datos del proyecto propio

## Decisión

No se encontró un conjunto publicado que represente el caso de la empresa del proyecto: ventas de tres líneas específicas de productos industriales, clientes nacionales y de exportación, sucursales, transportistas, pedidos, detalles y envíos. Por ello se utilizarán datos sintéticos generados mediante un script reproducible. No se presentarán como ventas reales ni se mezclarán registros de otro negocio.

## Búsqueda documentada

Se revisaron repositorios académicos y conjuntos de datos de comercio y ventas. Entre los términos de búsqueda utilizados se encuentran:

- \`industrial sales orders dataset customers products shipments transporters public CSV\`
- \`manufacturing sales orders dataset freight shipping branches open data\`
- \`public industrial equipment sales dataset invoice product quantity unit price customer\`
- \`UCI Online Retail II\`
- \`online retail transactional dataset invoice customer product country\`

### Candidato revisado y descartado: Online Retail II

**Referencia APA 7:**

Chen, D. (2012). *Online Retail II* [Conjunto de datos]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D

- **Institución:** UCI Machine Learning Repository.
- **Autor:** Daqing Chen.
- **Consulta:** 30 de octubre de 2026.
- **Formato y tamaño:** libro de Excel \`online_retail_II.xlsx\`, aproximadamente 43.5 MB.
- **Volumen:** 1,067,371 transacciones.
- **Periodo:** 1 de diciembre de 2009 a 9 de diciembre de 2011.
- **Campos:** \`InvoiceNo\`, \`StockCode\`, \`Description\`, \`Quantity\`, \`InvoiceDate\`, \`UnitPrice\`, \`CustomerID\` y \`Country\`.
- **Licencia:** Creative Commons Attribution 4.0 International (CC BY 4.0), que permite compartir y adaptar los datos con atribución.

La ficha oficial informa que el conjunto corresponde a una tienda británica en línea que vende artículos de regalo. También advierte que contiene valores faltantes. No se importó porque no representa una empresa fabricante o distribuidora de equipo industrial mexicano: no contiene sucursales, transportistas, guías, costos de flete, RFC, régimen fiscal, ni la clasificación OMNIGOLD/HYVOLT/HYPRENE. Sus precios están expresados en libras esterlinas. Adaptarlo requeriría inventar la mayor parte de las relaciones y atributos del proyecto, por lo que no sería una fuente apropiada para poblar este esquema.

**Fuente consultada:** UCI Machine Learning Repository, ficha oficial de [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii).

También se revisó el conjunto *Online Retail*, con 541,909 registros y seis campos de negocio equivalentes, pero presenta el mismo problema de dominio: comercio minorista británico de regalos, no ventas industriales con transporte y sucursales. Se descartó por la misma razón.

## Datos que se generarán

El script \`poblar/poblar.py\` genera registros ficticios con semilla fija. Las tablas principales tendrán como mínimo 200 filas:

| Tabla | Registros planeados | Relación principal |
|---|---:|---|
| cliente | 200 | Clientes nacionales y de exportación. |
| transportista | 220 | Transportistas nacionales, internacionales o de ambas modalidades. |
| producto | 240 | Productos repartidos entre las tres líneas. |
| sucursal | 240 | Una o más sucursales por cliente. |
| pedido | 600 | Pedidos asociados a clientes. |
| detalle | 1,200 | Dos renglones por pedido, asociados a productos. |
| envio | 300 | Envíos asociados a pedidos, transportistas y sucursales del mismo cliente. |

Los identificadores, nombres, correos del dominio reservado \`.test\`, RFC de demostración y teléfonos serán ficticios. La semilla permite repetir los mismos datos en cada ejecución. La carga utiliza \`COPY\` hacia tablas temporales y después inserta en las tablas definitivas en orden de dependencia.

## Calidad y limpieza

Como no se importará el conjunto UCI, no hay filas externas que limpiar. El generador evita desde el origen:

- identificadores repetidos;
- correos duplicados;
- clientes sin datos de contacto obligatorios;
- combinaciones de atributos fiscales incompatibles con el tipo de cliente;
- transportistas sin modalidad válida;
- productos sin proveedor correspondiente a su línea;
- cantidades e importes negativos;
- fechas inexistentes;
- envíos que apuntan a una sucursal de otro cliente.

Si el gestor rechaza una fila por una restricción, la carga completa se revierte y el error debe revisarse antes de volver a ejecutarla.

## Licencia y uso

Los registros sintéticos fueron creados para esta práctica y no reproducen datos personales ni transacciones de una empresa real. La ficha UCI se cita como fuente revisada y descartada; sus datos no se copian al repositorio.
