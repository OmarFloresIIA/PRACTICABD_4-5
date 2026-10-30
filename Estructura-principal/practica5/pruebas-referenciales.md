# Ejercicio 2.3. Pruebas de integridad referencial

El archivo ejecutable es `pruebas-referenciales.sql`. Debe ejecutarse después de cargar el proyecto propio y aplicar las restricciones de la Práctica 4. La prueba usa registros temporales y termina con ROLLBACK.

| Prueba | Operación | Resultado esperado | Conteos que muestra |
|---|---|---|---|
| ON DELETE CASCADE | Eliminar un cliente que tiene una sucursal de prueba. | Se elimina el cliente y también su sucursal. | Cliente y sucursal antes y después. |
| ON DELETE RESTRICT | Intentar eliminar un cliente que tiene un pedido. | PostgreSQL rechaza el DELETE con violación de FK (SQLSTATE 23503); ambos registros permanecen. | Cliente y pedido antes y después del intento. |
| ON UPDATE CASCADE | Cambiar el número de un cliente que tiene sucursal y pedido. | La nueva clave se propaga a sucursal y pedido. | Cliente, sucursal y pedido antes y después. |
| FK inexistente | Insertar un pedido con un número de cliente que no existe. | PostgreSQL rechaza el INSERT (SQLSTATE 23503). | Mensaje del gestor mediante NOTICE. |
| Orden de carga | Insertar primero un pedido cuyo cliente todavía no existe; luego crear cliente y pedido. | El primer INSERT falla; al cargar primero el padre, el segundo se acepta. | Conteo de cliente y pedido. |

## Comprobaciones finales

Las últimas consultas del SQL deben devolver cero para:

- sucursales sin cliente;
- pedidos sin cliente;
- detalles sin pedido;
- detalles sin producto;
- envíos sin pedido;
- envíos sin transportista;
- envíos sin sucursal;
- correos duplicados;
- sucursales duplicadas;
- clientes sin correo.

El archivo comprueba las relaciones de la base propia. Para el almacén asignado se ejecuta `practica5/sql/comprobar-integridad-almacen.sql`, que revisa las referencias de las dos tablas de hechos hacia sus dimensiones.

## Mensajes reales y evidencia

Las pruebas de RESTRICT y FK inexistente capturan el texto real del gestor junto con el SQLSTATE. No se ha inventado una salida de PostgreSQL. Falta ejecutar el archivo en el equipo local y guardar la captura en `evidencias/`.
