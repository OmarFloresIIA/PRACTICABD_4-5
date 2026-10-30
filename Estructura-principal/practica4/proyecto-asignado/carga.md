# Ejercicio 1.4 y 1.7. Carga del proyecto asignado

La carga se ejecuta en el fork `OmarFloresIIA/PublicMunicipalWorks_DWH`, rama `practica4-5`, mediante `scripts/generate_synthetic_data.py`.

## Preparación

Desde la raíz del repositorio:

```bash
cp .env.example .env
# Cambiar POSTGRES_PASSWORD y SECRET_KEY en .env
docker compose -f docker/compose.yml up -d --build
```

## Verificar cifras antes de conectarse

```bash
python scripts/generate_synthetic_data.py --verificar
```

Esta opción revisa la población calculada por el generador sin abrir conexión a PostgreSQL. No reemplaza los conteos de las tablas.

## Cargar la población completa

```bash
docker compose -f docker/compose.yml --profile tools run --rm seed
```

El servicio `seed` ejecuta el generador y después crea las cuentas de demostración. La conexión se toma de `DATABASE_URL`, que se construye con las variables de `.env`. El script no contiene contraseñas.

La carga se realiza dentro de una sola transacción. Antes de regenerar, limpia únicamente la población sintética de la base de práctica; conserva los catálogos fijos de tiempo y tipos de evento. Si alguna operación falla, la transacción revierte el conjunto completo.

## Carga masiva y comparación

La tabla `warehouse.fact_obra_mensual` se llena mediante `COPY`, con 29,928 registros esperados. El generador compara el tiempo de INSERT individual y COPY sobre el mismo lote de 3,000 filas en una tabla temporal. El programa imprime los tiempos reales y la relación entre ambos métodos; no se coloca un tiempo inventado en este documento.

## Conteos a registrar

El script muestra el total final por tabla y separa los catálogos precargados por el DDL. También informa las 3,421 evidencias representadas en los snapshots y el total de filas rechazadas. En una ejecución correcta, el generador indica cero filas rechazadas; cualquier error de restricción revierte toda la carga.

La captura de terminal debe mostrar:
1. La finalización de la carga.
2. Los conteos de tablas.
3. La comparación INSERT/COPY.
4. El tiempo total.
5. El mensaje de confirmación de la transacción.

La evidencia de ejecución real queda pendiente de tomar en el equipo local.
