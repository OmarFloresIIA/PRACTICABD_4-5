# Ejercicio 2.4. Edición de valores y transacciones

Las operaciones ejecutables están en \`sql/edicion-de-valores.sql\`. Deben probarse sobre una copia de la base poblada.

1. **INSERT desde SELECT:** crea una sucursal de demostración copiando los datos de dirección de una sucursal existente. \`ON CONFLICT (numerocliente, clavesucursal) DO NOTHING\` evita duplicarla si el comando se repite.
2. **UPDATE con otra tabla:** actualiza el precio aplicado en cada detalle usando el precio de lista del producto asociado. La relación se establece con \`detalle.claveproducto = producto.claveproducto\`.
3. **UPDATE con CASE:** cambia a ENVIADO el estado de los pedidos que ya tienen un envío. Si el pedido está inactivo, lo clasifica como CANCELADO; en otro caso conserva el estado.
4. **DELETE con subconsulta:** elimina pedidos cancelados que no tengan envío. La FK de detalle a pedido usa CASCADE, por lo que también se eliminan sus renglones. La FK de pedido a cliente usa RESTRICT y no permite borrar al cliente con su historial.
5. **Borrado lógico:** \`activo = FALSE\` conserva el pedido y sus detalles. Conviene cuando se necesita mantener el historial; el borrado físico elimina el registro y, por CASCADE, sus detalles.
6. **Transacción con punto de recuperación:** inserta un pedido y su detalle. Después crea un SAVEPOINT, intenta añadir un envío y revierte solo esa parte. El pedido y su detalle se confirman.
7. **Fallo a mitad de transacción:** se inserta un pedido y después se intenta insertar un detalle con un producto inexistente. La FK provoca un error; ROLLBACK revierte también el pedido, lo que se comprueba con un COUNT de cero.

## Evidencia pendiente

La práctica requiere conservar la salida auténtica del gestor: número de filas afectadas, error de FK y comprobación posterior al ROLLBACK. Los scripts están preparados, pero esos mensajes deben capturarse al ejecutarlos localmente.
