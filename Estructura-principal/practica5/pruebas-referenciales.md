# Ejercicio 2.3. Pruebas de integridad referencial

El archivo ejecutable es pruebas-referenciales.sql. Se ejecuta después de crear el esquema, aplicar las migraciones 001-dominios.sql y 002-referencias.sql, y cargar el Excel.

## Relaciones revisadas

La fuente contiene 1,500 registros por tabla. Las claves primarias simples y compuestas no presentan duplicados. Las relaciones entre las siete tablas no presentan registros huérfanos. Además, los 1,500 envíos tienen el mismo numeroCliente que el pedido al que apuntan y una sucursal perteneciente a ese cliente.

La migración 002 declara una FK compuesta entre envio(folio, numeroCliente) y pedido(folio, numeroCliente). Esta regla es más fuerte que una FK solo por folio: impide que se relacione un pedido de un cliente con un envío registrado a nombre de otro cliente.

## Casos de prueba

| Prueba | Operación | Resultado esperado | Qué se comprueba |
|---|---|---|---|
| ON DELETE CASCADE | Eliminar un cliente de prueba que tiene sucursal. | Se elimina el cliente y su sucursal. | Antes y después muestra conteos. |
| ON DELETE RESTRICT | Eliminar un cliente que tiene pedido. | PostgreSQL rechaza el DELETE con SQLSTATE 23503. Cliente y pedido permanecen. | Se conserva el historial comercial. |
| ON UPDATE CASCADE | Cambiar la clave de un cliente de prueba. | Se actualizan numeroCliente en sucursal y pedido. | Los hijos siguen apuntando al nuevo identificador. |
| FK de transportista | Insertar un envío con transportista inexistente. | PostgreSQL rechaza el INSERT con SQLSTATE 23503. | No se permite un transportista inexistente. |
| FK compuesta pedido/cliente | Insertar envío con folio de un cliente y numeroCliente/sucursal de otro. | PostgreSQL rechaza el INSERT con SQLSTATE 23503. | El envío corresponde al mismo cliente del pedido. |
| Orden de carga | Insertar pedido antes de crear su cliente; después insertar cliente y pedido. | El primer INSERT falla; el segundo se acepta. | Primero se cargan las tablas padre y después las hijas. |

## Comprobaciones de integridad

Al final del SQL se consultan las relaciones y restricciones que deben estar limpias. En el Excel fuente, cada consulta de huérfanos debe devolver cero. También deben dar cero los correos de cliente duplicados, las claves compuestas de sucursal duplicadas y los clientes sin correo.

## Evidencia de ejecución

La práctica pide registrar conteos antes y después de las acciones, el texto del error del gestor y el resultado de las comprobaciones. Los SQLSTATE que se presentan en la tabla son los esperados de PostgreSQL; el texto exacto de cada mensaje y las salidas de conteos se obtienen al ejecutar el script localmente. No se han simulado capturas ni salidas.
