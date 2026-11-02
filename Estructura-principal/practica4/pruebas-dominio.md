# Ejercicio 1.5. Pruebas de restricciones de dominio

El archivo ejecutable es pruebas-dominio.sql. Se ejecuta después de esquema.sql y de la migración 001-dominios.sql, con los datos cargados. Las operaciones que fallan se capturan mediante una función temporal que muestra el SQLSTATE y el mensaje real de PostgreSQL. La transacción termina con ROLLBACK para no conservar datos de prueba.

| Núm. | Tipo de restricción | Operación | Resultado esperado | Regla |
|---:|---|---|---|---|
| 1 | NOT NULL | Insertar cliente sin correo. | Rechazo SQLSTATE 23502. | Todo cliente debe tener correo. |
| 2 | DEFAULT | Insertar pedido sin indicar activo. | El SELECT muestra TRUE. | Un pedido nuevo inicia activo. |
| 3 | UNIQUE simple | Repetir correo de otro cliente. | Rechazo SQLSTATE 23505. | Un correo identifica a un cliente. |
| 4 | UNIQUE compuesta | Repetir numeroCliente + claveSucursal. | Rechazo SQLSTATE 23505. | La clave de sucursal no se repite dentro del cliente. |
| 5 | CHECK de rango | Insertar detalle con cantidad 0. | Rechazo SQLSTATE 23514. | La cantidad debe ser positiva. |
| 6 | CHECK de formato | Insertar correo sin arroba. | Rechazo SQLSTATE 23514. | El correo debe cumplir el dominio correo_electronico. |
| 7 | CHECK entre columnas | Insertar producto con precio unitario menor que costo. | Rechazo SQLSTATE 23514. | El precio de catálogo cubre el costo unitario. |
| 8 | CHECK de lista | Insertar pedido con estatus PAGADO. | Rechazo SQLSTATE 23514. | Los estados presentes en la fuente son ENVIADO y ENTREGADO. |
| 9 | CHECK de fecha | Insertar pedido fechado el 31 de febrero. | Rechazo por fecha fuera de rango (SQLSTATE 22008). | Los componentes deben formar una fecha real. |
| 10 | CHECK de formato | Insertar sucursal con CP ABC12. | Rechazo SQLSTATE 23514. | El CP debe contener cinco dígitos. |

## Consideración sobre los datos de origen

No se añadió un CHECK que exija precioAplicado >= costoProduccion. En el Excel hay tres registros que incumplen esa comparación. Se mantienen para no modificar silenciosamente el archivo fuente. La regla de precio mayor o igual que costo se aplica al precio de catálogo del producto, condición que sí cumplen los 1,500 productos.

## Evidencia pendiente

Los SQLSTATE de la tabla son los esperados para PostgreSQL. El texto exacto del mensaje y la salida de cada SELECT deben copiarse después de ejecutar el archivo en el equipo local. No se simulan mensajes ni capturas.
