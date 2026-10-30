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
docker compose -f docker/compose.yml run --rm --entrypoint sh seed -c "pip install --quiet faker && python generate_synthetic_data.py --verificar"
```

Esta opción revisa la población calculada por el generador sin abrir conexión a PostgreSQL. No reemplaza los conteos de las tablas.

## Cargar la población completa

```bash
docker compose -f docker/compose.yml --profile tools run --rm seed
```

El servicio `seed` ejecuta únicamente el generador de la práctica. La conexión se toma de `DATABASE_URL`, que se construye con las variables de `.env`. El script no contiene contraseñas. La utilidad opcional `seed_demo_users.py` queda separada y no forma parte de esta carga.

La carga se realiza dentro de una sola transacción. Antes de regenerar, limpia únicamente la población sintética de la base de práctica; conserva los catálogos fijos de tiempo y tipos de evento. Si alguna operación falla, la transacción revierte el conjunto completo.

## Carga masiva y comparación

La tabla `warehouse.fact_obra_mensual` se llena mediante `COPY`, con 29,928 registros esperados. El generador compara el tiempo de INSERT individual y COPY sobre el mismo lote de 3,000 filas en una tabla temporal. El programa imprime los tiempos reales y la relación entre ambos métodos; no se coloca un tiempo inventado en este documento.

## Conteos a registrar

El script muestra el total final por tabla y separa los catálogos precargados por el DDL. También informa las 3,421 evidencias representadas en los snapshots y el total de filas rechazadas. En una ejecución correcta, el generador indica cero filas rechazadas; cualquier error de restricción revierte toda la carga.

## Comparación con el artículo

| Indicador | Artículo / generador | Resultado de la base | Estado |
|---|---:|---:|---|
| Obras públicas | 1,247 | Pendiente de ejecución | Por comprobar |
| Comunidades | 55 | Pendiente de ejecución | Por comprobar |
| Eventos de auditoría generados directamente | 8,934 | Pendiente de ejecución | Por comprobar |
| Evidencias representadas en snapshots | 3,421 | Pendiente de ejecución | Por comprobar |
| Presupuesto total | $127,400,000 MXN | Pendiente de ejecución | Por comprobar |
| Pobladores | 2,341 | Pendiente de ejecución | Por comprobar |
| Propuestas | 2,156 | Pendiente de ejecución | Por comprobar |
| Votos | 8,723 | Pendiente de ejecución | Por comprobar |
| Snapshots obra-mes | 29,928 | Pendiente de ejecución | Por comprobar |

El artículo indica que los 8,934 eventos son los generados directamente por el escenario; los disparadores del sistema operacional pueden agregar más eventos a la tabla de hechos. Por eso no debe compararse el total final de esa tabla como si solo contuviera los 8,934 eventos directos. La población mensual sí se calcula como 1,247 obras por 24 meses, es decir, 29,928 filas.

La captura de terminal debe mostrar:
1. La finalización de la carga.
2. Los conteos de tablas.
3. La comparación INSERT/COPY.
4. El tiempo total.
5. El mensaje de confirmación de la transacción.

La evidencia de ejecución real queda pendiente de tomar en el equipo local.
