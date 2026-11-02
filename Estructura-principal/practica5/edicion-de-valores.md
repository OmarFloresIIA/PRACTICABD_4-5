# Ejercicio 2.4. Edición de valores y transacciones

Las operaciones ejecutables se encuentran en sql/edicion-de-valores.sql. Se basan en pedidos, detalles, productos, sucursales y envíos del conjunto sintético.

1. **INSERT desde SELECT:** crea una sucursal temporal de demostración copiando la dirección de una sucursal existente. Se repite la inserción con ON CONFLICT DO NOTHING para mostrar que la clave compuesta impide duplicados.
2. **UPDATE que usa otra tabla:** modifica un renglón de detalle para tomar el precio de catálogo desde producto, relacionando ambas tablas por claveProducto.
3. **UPDATE con CASE:** clasifica un pedido como ENVIADO si existe un registro relacionado en envio; en otro caso lo clasifica como ENTREGADO. Son los dos estados observados en la fuente.
4. **DELETE con subconsulta:** crea un pedido de demostración, un detalle y un envío. Como envio -> pedido usa RESTRICT, primero elimina el envío; después elimina el pedido mediante una subconsulta basada en detalle. La acción CASCADE elimina los detalles dependientes.
5. **Borrado lógico:** cambia activo a FALSE sin eliminar el pedido ni sus detalles. Es útil para conservar historial; el borrado físico elimina el pedido y, por CASCADE, sus detalles.
6. **Transacción con SAVEPOINT:** inserta pedido y detalle; después inserta un envío. ROLLBACK TO SAVEPOINT revierte solamente el envío, conserva pedido y detalle, y COMMIT confirma esa parte. Una transacción posterior elimina el pedido temporal y su detalle para dejar intacta la población original.
7. **Transacción fallida:** inserta un pedido y trata de crear un detalle con una claveProducto que no existe. PostgreSQL rechaza el detalle por la FK; ROLLBACK cancela también el pedido. La consulta final debe devolver cero.

## Relación con las reglas de la fuente

Los estados usados son ENVIADO y ENTREGADO, porque son los únicos presentes en la hoja pedido. La columna activo existe en el Excel y se conserva; la migración la agrega al DDL original. No se usa un precioAplicado arbitrario ni se impone la condición de que siempre sea mayor que costoProduccion, ya que tres detalles originales no cumplen esa comparación.

## Evidencia pendiente

Al ejecutar el archivo en PostgreSQL se deben guardar los mensajes y conteos reales, especialmente el detalle del rechazo por FK y la consulta que demuestra que el pedido de la transacción fallida no quedó guardado. Los ejemplos temporales se limpian para no alterar la población original. No se inventan tiempos ni salidas del gestor.
