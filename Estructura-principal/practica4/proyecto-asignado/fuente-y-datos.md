# Ejercicio 1.7. Fuente de datos del proyecto asignado

## Procedencia

El proyecto asignado es el sistema de obras públicas municipales descrito en el artículo del repositorio. El propio artículo aclara que las cifras de la población provienen de un generador sintético y que no representan la ejecución real del municipio de Temascaltepec. Por eso, para esta práctica no se descarga ni se importa un CSV de registros municipales reales: se utiliza el generador que acompaña al proyecto.

**Referencia APA 7 del artículo:**

González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). *A dimensional data warehouse for geospatial monitoring of municipal public works, with an evolution path toward a lakehouse architecture* [Manuscrito del capítulo ICOKG 2026]. Repositorio PublicMunicipalWorks_DWH. https://github.com/OmarFloresIIA/PublicMunicipalWorks_DWH

**Referencia del generador:**

González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). `scripts/generate_synthetic_data.py` [Código fuente]. PublicMunicipalWorks_DWH. https://github.com/OmarFloresIIA/PublicMunicipalWorks_DWH/blob/practica4-5/scripts/generate_synthetic_data.py

## Formato y características

- **Formato de entrada:** no existe un archivo CSV/Excel externo que se importe. El script genera registros en Python y los inserta directamente en PostgreSQL.
- **Motor:** PostgreSQL 16 en Docker Compose.
- **Librería de generación:** Faker en configuración regional `es_MX`, además de listas de comunidades, obras, constructoras y fuentes de financiamiento.
- **Reproducibilidad:** el generador fija la semilla aleatoria en 42.
- **Licencia del código:** MIT, indicada en `LICENSE.md`. Las filas de la población son sintéticas y creadas para el escenario académico; el artículo no las presenta como un conjunto de datos municipales reales.

## Volumen que declara el artículo

| Elemento | Cantidad declarada |
|---|---:|
| Obras públicas | 1,247 |
| Comunidades | 55 |
| Eventos de auditoría generados directamente | 8,934 |
| Evidencias fotográficas representadas en snapshots | 3,421 |
| Presupuesto total | $127,400,000 MXN |
| Pobladores | 2,341 |
| Propuestas ciudadanas | 2,156 |
| Votos | 8,723 |
| Periodo de snapshots | 2024–2025, un registro por obra y mes |

El generador produce 1,247 × 24 = 29,928 registros en `warehouse.fact_obra_mensual`. La tabla `warehouse.fact_eventos_auditoria` puede contener más de los 8,934 eventos directos, porque los disparadores del esquema operacional también registran cambios. El artículo distingue entre los eventos generados directamente y los eventos adicionales producidos por la sincronización.

## Correspondencia con el esquema

El generador llena el esquema operacional (`public`) y las dimensiones y hechos del esquema `warehouse`. Los datos de obras se relacionan con región, constructora, supervisor y tiempo. Las propuestas y los votos se vinculan con pobladores y fechas. La carga mantiene las claves foráneas declaradas en el DDL del repositorio.

## Limpieza y validación

No se realiza limpieza de datos externos porque no se importa un conjunto externo. El generador crea los registros de demostración, usa claves relacionadas y fija valores dentro de los rangos definidos por el esquema. La opción:

```
python scripts/generate_synthetic_data.py --verificar
```

comprueba sin conexión a PostgreSQL las cifras principales previstas por el artículo. La carga completa informa conteos por tabla y compara INSERT individual con COPY en una tabla temporal. Si una etapa falla, la transacción revierte el conjunto completo.

**Advertencia:** `limpiar_datos_sinteticos()` elimina la población sintética anterior de las tablas operacionales y de las dimensiones cambiantes para permitir una nueva carga sin duplicados. Ejecutar únicamente en la base local dedicada a la práctica, nunca en una base con información real.

## Confirmación indicada en el enunciado

El PDF de la práctica pide consultar con el docente si ya existen datos reales para el proyecto de obra pública municipal. El repositorio y el artículo disponibles documentan una población sintética, pero no incluyen una confirmación del docente. Antes de entregar, el equipo debe confirmar si el profesor compartió un conjunto real adicional. Si no existe, se conserva esta justificación y se usa el generador del fork.
