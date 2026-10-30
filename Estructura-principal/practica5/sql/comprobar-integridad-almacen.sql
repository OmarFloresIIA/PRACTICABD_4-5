-- Consultas de integridad referencial del almacén asignado.
-- Ejecutar sobre la base poblada del proyecto PublicMunicipalWorks_DWH.

-- fact_eventos_auditoria: las dos dimensiones obligatorias.
SELECT COUNT(*) AS eventos_sin_tiempo
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_tiempo d ON d.tiempo_key=f.tiempo_key
WHERE d.tiempo_key IS NULL;

SELECT COUNT(*) AS eventos_sin_tipo
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_tipo_evento d ON d.tipo_evento_key=f.tipo_evento_key
WHERE d.tipo_evento_key IS NULL;

-- Referencias opcionales: si contienen valor, la dimensión debe existir.
SELECT COUNT(*) AS eventos_con_obra_huerfana
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_obra d ON d.obra_key=f.obra_key
WHERE f.obra_key IS NOT NULL AND d.obra_key IS NULL;

SELECT COUNT(*) AS eventos_con_region_huerfana
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_region d ON d.region_key=f.region_key
WHERE f.region_key IS NOT NULL AND d.region_key IS NULL;

SELECT COUNT(*) AS eventos_con_personal_huerfano
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_personal d ON d.personal_key=f.personal_key
WHERE f.personal_key IS NOT NULL AND d.personal_key IS NULL;

SELECT COUNT(*) AS eventos_con_constructora_huerfana
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_constructora d ON d.constructora_key=f.constructora_key
WHERE f.constructora_key IS NOT NULL AND d.constructora_key IS NULL;

SELECT COUNT(*) AS eventos_con_fuente_huerfana
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_fuente d ON d.fuente_key=f.fuente_key
WHERE f.fuente_key IS NOT NULL AND d.fuente_key IS NULL;

SELECT COUNT(*) AS eventos_con_presupuesto_huerfano
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_presupuesto d ON d.presupuesto_key=f.presupuesto_key
WHERE f.presupuesto_key IS NOT NULL AND d.presupuesto_key IS NULL;

SELECT COUNT(*) AS eventos_con_poblador_huerfano
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_poblador d ON d.poblador_key=f.poblador_key
WHERE f.poblador_key IS NOT NULL AND d.poblador_key IS NULL;

SELECT COUNT(*) AS eventos_con_propuesta_huerfana
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_propuesta d ON d.propuesta_key=f.propuesta_key
WHERE f.propuesta_key IS NOT NULL AND d.propuesta_key IS NULL;

-- fact_obra_mensual: ambas referencias son obligatorias.
SELECT COUNT(*) AS hechos_mensuales_sin_tiempo
FROM warehouse.fact_obra_mensual f
LEFT JOIN warehouse.dim_tiempo d ON d.tiempo_key=f.tiempo_key
WHERE d.tiempo_key IS NULL;

SELECT COUNT(*) AS hechos_mensuales_sin_obra
FROM warehouse.fact_obra_mensual f
LEFT JOIN warehouse.dim_obra d ON d.obra_key=f.obra_key
WHERE d.obra_key IS NULL;

-- Duplicados en las claves que identifican los granos de las tablas de hechos.
SELECT COUNT(*) AS claves_evento_duplicadas
FROM (
  SELECT tiempo_key, evento_key
  FROM warehouse.fact_eventos_auditoria
  GROUP BY tiempo_key, evento_key HAVING COUNT(*)>1
) q;

SELECT COUNT(*) AS claves_obra_mes_duplicadas
FROM (
  SELECT tiempo_key, obra_key
  FROM warehouse.fact_obra_mensual
  GROUP BY tiempo_key, obra_key HAVING COUNT(*)>1
) q;

-- Referencias obligatorias nulas.
SELECT COUNT(*) AS eventos_sin_claves_obligatorias
FROM warehouse.fact_eventos_auditoria
WHERE tiempo_key IS NULL OR tipo_evento_key IS NULL;

SELECT COUNT(*) AS hechos_mensuales_sin_claves_obligatorias
FROM warehouse.fact_obra_mensual
WHERE tiempo_key IS NULL OR obra_key IS NULL;
