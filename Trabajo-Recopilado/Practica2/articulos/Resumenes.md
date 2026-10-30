# [Artículo 1. Datos Sísmicos](https://azcatl.azc.uam.mx/index.php/azcatl/article/view/75)
*Villa Vargas, J. M., Hurtado Avilés, G., &amp; Climent Hernández, J. A. (2026). Cuando México tiembla: la historia contada por los datos. Azcatl. Revista de divulgación en ciencias, ingeniería e innovación, 6, 28–33\. https://doi.org/10.24275/AZC2026E1004*
## El Problema
El **SSN** registra cada sismo en México, pero sus datos técnicos resultan poco accesibles para el público. El país, ubicado en el **Cinturón de Fuego del Pacífico** y rodeado por cinco placas tectónicas, vive bajo constante amenaza sísmica. La falta de herramientas visuales dificulta que los ciudadanos comprendan el riesgo, de ahí la necesidad de un sistema que traduzca tablas en mapas interactivos y reportes claros.

## Los Datos
El sistema se alimenta de fuentes oficiales:
1. **Recolección**:  
   * CSV del **SSN** con más de 300,000 sismos desde 1900.  
   * CSV del **INEGI**: Censo 2020 y Censos Económicos.  
2. **Depuración**: Un programa en Python valida y limpia registros, corrige coordenadas y exporta un archivo SQL unificado.  
3. **Almacenamiento**: El SQL se carga en **PostgreSQL**, listo para consultas rápidas.

## El diseño de los datos
Se implementó un **Data Warehouse** con modelo dimensional:  
* **Dimensiones**:  
  * *dim_sismos* (eventos), *dim_zonas* (territorio), *dim_tiempo* (fechas), *dim_economía* (censos).  
* **Hechos**:  
  * *fact_impacto_sismos_imputed* vincula magnitud, tiempo, zona y efectos socioeconómicos.  

Este diseño permite cruces inmediatos y reportes dinámicos sin saturar el servidor.

## Preguntas y Respuestas
El sistema responde a:  
* **Localidades expuestas**: Filtra sismos por magnitud y muestra poblaciones >50,000 habitantes con mapas de calor.  
* **Impacto histórico**: Ejemplo -> reportes interactivos de Jalisco en 2017 (magnitudes, profundidades, afectados).  
* **Planificación segura**: Gobiernos municipales identifican zonas de riesgo acumulado en 125 años para diseñar rutas y planes de contingencia.

## Limitaciones y futuro
La instalación técnica puede ser compleja, por lo que se empaquetó en un **contenedor Docker** que simplifica el despliegue. El proyecto es abierto y busca crecer con:  
* Visualizaciones 3D de profundidad sísmica.  
* Integración de datos en tiempo real.  
* Conexión con sistemas de alerta temprana.  


# [Artículo 2. Sistema Dimensional Geoespacial para la fiscalización de Obras Públicas Municipales](https://github.com/gabrielhuav/PublicMunicipalWorks_DWH/blob/TestDefinitivo/paper/Paper_37_1.pdf)
*González Casiano, U., Maldonado Mejía, M. T., &amp; Hurtado Avilés, G. (2026). A dimensional data warehouse for geospatial monitoring of municipal public works, with an evolution path toward a lakehouse architecture. Escuela Superior de Cómputo (ESCOM), Instituto Politécnico Nacional.*
## El Problema
La infraestructura pública en los municipios rurales y medianos sufre por la **fragmentación de la información**: contratos, presupuestos, supervisores, estimaciones, fotos y actas se guardan en hojas de cálculo o carpetas separadas. Lo que provoca:

* **Falta de organización de fechas**: imposible saber qué empresa o presupuesto estaba asignado en una fecha de auditoría.  
* **Detección tardía de sobrecostos y retrasos**: los problemas se descubren cuando la obra ya terminó o fue abandonada.  
* **Falta de participación ciudadana**: sin métodos claros para consultar avances o proponer proyectos.  

El caso de **Temascaltepec, Estado de México** muestra que la transparencia necesita de herramientas analíticas que verifiquen el ciclo completo de cada obra, sin depender de plataformas empresariales costosas.

## Los Datos
El sistema procesa distinta información de varios actores:  

* **Estructurada**: montos, coordenadas, fechas, estados y votos, capturados en formularios web y enviados mediante una API.  
* **No estructurada**: fotos (JPG/PNG) y reportes PDF almacenados en **Cloudflare R2** con rutas organizadas por obra y fecha.  

Los datos se registran en **PostgreSQL**, relacionando la evidencia y registros analíticos.  
El prototipo se probó con **datos sintéticos**: 1,247 obras simuladas, $127.4 millones de presupuesto, 8,934 eventos de auditoría, 3,421 fotos, 2,156 propuestas y 8,723 votos.

## El diseño de los datos
El modelo sigue un esquema en estrella con **2 tablas de hechos** y **10 dimensiones**:

* **fact_audit_events**: registra cada evento de auditoría, clasifica 17 tipos y se divide por año.  
* **fact_work_monthly**: reportes mensuales de cada obra (costo, saldo, avance físico, retraso).  

Las dimensiones:  
* **Tipo 2 (5)**: conservan historial completo (`dim_work`, `dim_region`, `dim_company`, `dim_staff`, `dim_budget`).  
* **Tipo 1 (3)**: sobrescriben valores (`dim_source`, `dim_citizen`, `dim_proposal`).  
* **Tipo 0 (2)**: catálogos fijos (`dim_time`, `dim_event_type`).  

La sincronización se logra con **banderitas en la base de datos**.

## Preguntas y Respuestas
El sistema responde a:  

1. **Obras con retrasos** (`v_delayed_works`).  
2. **Anomalías presupuestales o físicas-financieras** (`v_anomalies_detection`).  
3. **Estado exacto de un contrato en una fecha** (`v_work_traceability`).  
4. **Distribución de inversión por comunidad** (`v_budget_executed`).  
5. **Propuestas y votos ciudadanos** (`v_citizen_participation`).  


## Limitaciones y futuro
El prototipo presenta estos retos:  

* **Datos sintéticos**.  
* **Arquitectura centrada en Data Warehouse**.  
* **Cuellos de botella en la API**.  
* **Autenticación ligera**, adecuada solo para pruebas.  

**Evolución futura**: migrar hacia un **Lakehouse** con formatos abiertos (Iceberg, Parquet) y motores ligeros (DuckDB, Trino). Además, integrar visión por computadora para validar fotos, adoptar el estándar **OC4IDS** y publicar el esquema bajo ontologías OWL.  

# [Artículo 3. Almacen de Datos para la gestión del Agua en la CDMX](https://drive.google.com/drive/folders/1RLz5NjNSt2c0lkzcqEa5C5PJ8cML2wi7)
*Velázquez Arrieta, E. U., Pulido Morales, O. F., García López, E., Hernández Martínez, C. A., &amp; Hurtado Avilés, G. (2026). Territorial information retrieval from heterogeneous open data through the construction of a data warehouse for water management in Mexico City. Escuela Superior de Cómputo, Instituto Politécnico Nacional.*
## El Problema
La **CDMX** enfrenta una crisis hídrica marcada por la sobreexplotación de acuíferos, fugas y crecimiento poblacional. Aunque el **SACMEX** publica datos abiertos de consumo, estos presentan barreras:

* **Muchos tipos de datos dispersos**: CSV estructura clara.  
* **Falta de consulta interactiva**: archivos estáticos imposibles de filtrar sin programación avanzada.  
* **Disponibilidad frágil**: prototipos académicos suelen quedar inactivos.  

Para resolverlo, se diseñó un **Data Warehouse reproducible** que consolida registros y los vuelve consultables mediante mapas sin depender de servidores costosos.

## Los Datos
El sistema integra tres fuentes:  

1. **SACMEX**: 71,102 registros crudos de consumo por manzana (1er semestre 2019).  
2. **Open-Meteo**: 181 registros de clima (temperatura y precipitación).  
3. **OpenStreetMap**: capa cartográfica base.  

Que se procesan de la siguiente manera:
1. **Extracción**: lectura de CSV.  
2. **Validación/Limpieza**: solo 216 registros descartados.  
3. **Organización**: estructuración de dimensiones.  
4. **Tablas de Hechos**: `fact_consumo_agua` y `fact_clima`.  


## El Diseño de los datos
Dos representaciones:  

1. **Modelo en Estrella**:  
   * `fact_consumo_agua` (70,886 registros).  
   * `fact_clima` (181 registros).  
   * Dimensiones: tiempo, ubicación (1,553 registros), índice de desarrollo (4 categorías).  

2. **Grafo RDF**:  
   * 760,000 triplas(Sujeto y Objeto -> Nodos ; Predicado -> Arista).  
   * Colonias como entidades geográficas con relaciones de vecindad.   

## Preguntas y Respuestas
El sistema responde a:  

* **Consumo por alcaldía**: Cuauhtémoc y Miguel Hidalgo lideran.  
* **Patrones**: mayor consumo en Bimestre 2.  
* **Relación con desarrollo urbano**: colonias de índice Alto consumen más.  
* **Vecindad de consumo**: consultas SPARQL devuelven colonias cercanas.  
* **Rendimiento**: consultas por alcaldía en muy poco tiempo; por colonia y bimestre.

## Limitaciones y Futuro
* **Alcance temporal limitado**: solo primer semestre 2019.  
* **Geometría simplificada**: centroides en lugar de polígonos oficiales.  
* **Consumo total vs. per cápita**: riesgo de interpretaciones erróneas.  
* **Validación sintética**: anomalías probadas con datos simulados.  

### Evolución
* Materializar grafo en Triple Store con endpoint SPARQL.  
* Usar polígonos oficiales para relaciones topológicas precisas.  
* Reconciliar entidades con Wikidata/INEGI.  
* Extender metodología a otros dominios urbanos (movilidad, aire, sismos).  
