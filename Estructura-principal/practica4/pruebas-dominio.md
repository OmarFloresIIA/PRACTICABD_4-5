# Ejercicio 1.5. Pruebas de restricciones de dominio

Las pruebas se encuentran en \`pruebas-dominio.sql\`. Deben ejecutarse después de aplicar la migración \`001-dominios.sql\) y cargar los datos. Se usa una transacción que termina en ROLLBACK para no conservar registros de prueba.

| Caso | Operación intentada | Resultado esperado | SQLSTATE esperado | Regla protegida |
|---:|---|---|---|---|
| 1 | Insertar un cliente con correo NULL. | Rechazo por NOT NULL. | 23502 | Todo cliente debe tener un correo de contacto. |
| 2 | Insertar un pedido omitiendo estatus y activo. | Aceptado; muestra REGISTRADO y TRUE. | Sin error | Los valores iniciales se asignan con DEFAULT. |
| 3 | Insertar un cliente con un correo ya utilizado. | Rechazo por UNIQUE. | 23505 | Un correo identifica a un solo cliente. |
| 4 | Repetir la pareja numeroCliente/claveSucursal. | Rechazo por clave primaria compuesta. | 23505 | La sucursal se identifica dentro de su cliente. |
| 5 | Insertar un detalle con cantidad cero. | Rechazo por CHECK. | 23514 | Cada renglón representa al menos una unidad. |
| 6 | Insertar un correo sin arroba. | Rechazo por CHECK de formato. | 23514 | El correo debe tener estructura válida. |
| 7 | Registrar un producto cuyo precio sea menor que su costo. | Rechazo por CHECK entre columnas. | 23514 | El precio de lista cubre el costo unitario. |
| 8 | Insertar un pedido con estado PAGADO. | Rechazo por CHECK de lista. | 23514 | Solo se aceptan estados definidos por el proceso. |
| 9 | Insertar 31 de febrero. | Rechazo al construir la fecha. | 22008 | La fecha debe existir en el calendario. |
| 10 | Insertar un CP con letras. | Rechazo por CHECK de formato. | 23514 | El código postal, cuando existe, contiene cinco dígitos. |

## Mensajes del gestor

El archivo SQL captura el SQLSTATE y el texto real que devuelve PostgreSQL mediante \`RAISE NOTICE\`. No se inventa una salida de terminal: las líneas exactas se deben copiar de la ejecución local y adjuntar como evidencia. Si el SQLSTATE recibido no coincide con el esperado, el propio script detiene la prueba para señalar que algo debe revisarse.

## Ejecución

\`\`\`powershell
docker compose cp .\\practica4\\pruebas-dominio.sql db:/tmp/pruebas-dominio.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -f /tmp/pruebas-dominio.sql
\`\`\`
