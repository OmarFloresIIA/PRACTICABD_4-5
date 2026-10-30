# Evidencias de ejecución

Guardar aquí capturas auténticas de PostgreSQL y de los comandos ejecutados. No subir capturas simuladas ni registrar como exitoso un comando que no se haya ejecutado.

## Proyecto propio

1. `01-postgres-compose.png`: PostgreSQL levantado y esquema inicializado.
2. `02-migracion-dominios.png`: ejecución de `001-dominios.sql`.
3. `03-carga-propia-primera-ejecucion.png`: salida de `poblar.py`, conteos por tabla y rechazadas.
4. `04-carga-propia-segunda-ejecucion.png`: segunda ejecución; debe mostrar cero duplicados nuevos.
5. `05-copy-insert.png`: comparación real de INSERT individual y COPY.
6. `06-pruebas-dominio.png`: diez casos de `pruebas-dominio.sql`, con SQLSTATE y mensajes.
7. `07-permisos.png`: operaciones permitidas y negadas, incluido REVOKE.
8. `08-integridad-referencial.png`: CASCADE, RESTRICT, UPDATE CASCADE y conteos antes/después.
9. `09-dml-transacciones.png`: INSERT/UPDATE/DELETE, SAVEPOINT, ROLLBACK parcial y fallo a mitad de transacción.

## Proyecto asignado

10. `10-verificar-poblacion-articulo.png`: resultado de `--verificar`.
11. `11-carga-proyecto-asignado.png`: salida de `seed`, conteos, COPY/INSERT y tiempo.
12. `12-integridad-almacen.png`: conteos de huérfanos y pruebas de las tres restricciones en una copia.

## Revisión y entrega

13. `13-pull-request.png`: Pull Request de `practica4-5` revisado por otro integrante y fusionado.

Las capturas deben mostrar el comando, el resultado y, cuando corresponda, el nombre de la base utilizada. Ocultar cualquier contraseña o variable sensible.
