# Ejercicio 2.6. Cambio individual — Omar Flores Olivares

## Relación seleccionada

**DETALLE pertenece a PEDIDO**: `detalle.folio` referencia a `pedido.folio`.

En el esquema original la acción es `ON DELETE CASCADE`. Se propone cambiarla a `ON DELETE RESTRICT` para proteger los renglones de una venta: si un pedido ya tiene detalles, no se puede borrar directamente. Primero se debe revisar y eliminar explícitamente cada detalle, y después el pedido. Se conserva `ON UPDATE CASCADE`.

## Cambio SQL

Archivo: `cambio-omar.sql`.

```sql
ALTER TABLE detalle DROP CONSTRAINT fk_detalle_pedido;

ALTER TABLE detalle
  ADD CONSTRAINT fk_detalle_pedido
  FOREIGN KEY (folio)
  REFERENCES pedido (folio)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
```

## Prueba

Archivo: `prueba-omar.sql`. Inserta un cliente, pedido y detalle temporales; comprueba que eliminar el pedido falla mientras exista el detalle; después elimina primero el detalle y luego el pedido. Todo termina en ROLLBACK para no dejar registros de prueba.

## Impacto

- **Ventaja:** evita borrar por accidente el detalle que explica qué productos y cantidades se vendieron.
- **Desventaja:** obliga a borrar los detalles manualmente antes de borrar un pedido.
- **Comparación con el original:** CASCADE facilita borrar una entidad débil junto con su padre; RESTRICT conserva la información hasta que el usuario decida eliminarla de manera explícita.

Aplicar únicamente en una copia de la base. La captura debe mostrar el error de FK y la eliminación en el orden correcto.
