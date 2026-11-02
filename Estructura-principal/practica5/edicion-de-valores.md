# Ejercicio 2.4. Edición de valores y transacciones

Las operaciones se encuentran en sql/edicion-de-valores.sql. Se basan en la relación entre clientes, sucursales, pedidos, detalles, productos y envíos de la fuente sintética revisada.

1. **INSERT desde SELECT:** crea una sucursal temporal copiando la dirección de una sucursal existente. La segunda inserción repite la misma clave compuesta y usa ON CONFLICT DO NOTHING para evitar duplicados.
2. **UPDATE que depende de otra tabla:** actualiza el precio aplicado de un detalle a partir del precio de catálogo en producto, mediante claveProducto.
3. **UPDATE con CASE:** clasifica el pedido según su estado y la existencia de un envío relacionado. Conserva CANCELADO, mantiene ENVIADO cuando corresponde, clasifica como ENTREGADO si existe envío y como EN PROCESO cuando todavía no existe.
4. **DELETE con subconsulta:** crea un pedido temporal, un detalle y un envío. Primero elimina el envío porque la FK envio -> pedido usa RESTRICT. Después elimina el pedido mediante una subconsulta basada en detalle. Como detalle -> pedido usa CASCADE, el renglón hijo también desaparece.
5. **Borrado lógico:** cambia activo a FALSE sin eliminar el pedido ni sus detalles. Permite conservar el historial. La primera transacción termina con ROLLBACK para recuperar la población del Excel.
6. **Transacción con SAVEPOINT:** inserta pedido y detalle; guarda un punto de recuperación; inserta temporalmente un envío y actualiza el estatus. ROLLBACK TO SAVEPOINT revierte el envío y el cambio posterior, pero conserva el pedido y el detalle. COMMIT confirma el bloque restante; después se elimina el pedido de demostración y sus detalles por CASCADE.
7. **Transacción fallida:** inserta un pedido y después intenta crear un detalle que referencia un producto inexistente. PostgreSQL rechaza el segundo INSERT por FK y ROLLBACK revierte también el pedido. La consulta final debe mostrar cero.

## Reglas de la fuente utilizadas

La fuente contiene los estados ENTREGADO, CANCELADO, ENVIADO y EN PROCESO. Las notas del archivo contemplan REGISTRADO como estado inicial, por lo que la migración lo permite y lo usa como DEFAULT. Los 1,500 detalles cumplen precioAplicado >= costoProduccion; la migración impide que se inserten nuevos detalles por debajo del costo.

## Evidencia pendiente

Al ejecutar el SQL en PostgreSQL deben guardarse los conteos reales, los mensajes de FK y el resultado que demuestra que el pedido de la transacción fallida no quedó almacenado. Los ejemplos temporales se limpian y no cambian la población original. No se inventan salidas del gestor.
