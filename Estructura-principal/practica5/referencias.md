# Ejercicio 2.1 y 2.2. Claves foráneas y acciones referenciales

El esquema relacional de la Práctica 3 declara siete claves foráneas. Todas son NOT NULL porque, según el modelo EER, cada registro hijo debe pertenecer a un registro padre.

| Tabla hija / FK | Tabla padre / columna | Relación del EER | ¿Admite NULL? | ON DELETE | ON UPDATE | Justificación |
|---|---|---|---|---|---|---|
| sucursal.numerocliente | cliente.numerocliente | CLIENTE tiene SUCURSAL | No | CASCADE | CASCADE | La sucursal depende del cliente para identificarse; si se elimina el cliente, sus sucursales dejan de tener sentido. |
| pedido.numerocliente | cliente.numerocliente | CLIENTE realiza PEDIDO | No | RESTRICT | CASCADE | No se elimina un cliente con pedidos registrados; los pedidos deben conservarse como historial de venta. |
| detalle.folio | pedido.folio | PEDIDO registra DETALLE | No | CASCADE | CASCADE | El detalle es una entidad débil identificada por el pedido y no tiene sentido sin él. |
| detalle.claveproducto | producto.claveproducto | PRODUCTO aparece en DETALLE | No | RESTRICT | CASCADE | No se elimina un producto que aparece en ventas históricas. |
| envio.folio | pedido.folio | PEDIDO es enviado | No | RESTRICT | CASCADE | El envío conserva el vínculo con el pedido y no debe desaparecer por un borrado accidental. |
| envio.clavetransportista | transportista.clavetransportista | TRANSPORTISTA ejecuta ENVÍO | No | RESTRICT | CASCADE | No se elimina un transportista con envíos registrados. |
| envio(numerocliente, clavesucursal) | sucursal(numerocliente, clavesucursal) | SUCURSAL recibe PEDIDO por ENVÍO | No | RESTRICT | CASCADE | La sucursal destino debe conservarse mientras existan envíos que la referencien. |

## Correspondencia con el modelo

- Las relaciones uno a muchos se implementan propagando la clave primaria del lado uno como clave foránea del lado muchos.
- \`detalle\` usa la clave compuesta \`(folio, claveparcial)\`, por lo que el pedido participa en su identificación.
- \`envio\` contiene la clave compuesta de \`sucursal\` para asegurar que el destino existe.
- La FK de \`envio.folio\` es UNIQUE: el modelo permite como máximo un envío por pedido.
- Las claves foráneas admiten nulos solo cuando la participación mínima del hijo es cero. En este modelo todas las relaciones listadas son obligatorias desde el lado hijo; por eso no admiten NULL.

## Acciones referenciales elegidas

Se usan CASCADE cuando el hijo depende del padre para existir (\`sucursal\` y \`detalle\`). Se usa RESTRICT para conservar el historial comercial cuando eliminar al padre podría borrar información útil (\`pedido\`, \`producto\`, \`transportista\` y \`sucursal\` referenciada por un envío). ON UPDATE CASCADE mantiene las referencias si cambia una clave primaria.
