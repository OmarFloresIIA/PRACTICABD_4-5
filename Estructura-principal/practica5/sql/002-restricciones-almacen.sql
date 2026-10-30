-- Aplicar únicamente en una COPIA de la base del proyecto asignado.
-- Ejecutar después de cargar el esquema y los datos sintéticos.

-- 1. Revisar si los datos existentes cumplen las reglas propuestas.
SELECT COUNT(*) AS montos_negativos
FROM warehouse.fact_obra_mensual
WHERE presupuesto_total < 0 OR costo_acumulado < 0 OR saldo_presupuesto < 0;

SELECT COUNT(*) AS avances_mensuales_fuera_de_rango
FROM warehouse.fact_obra_mensual
WHERE (avance_fisico_acumulado IS NOT NULL AND avance_fisico_acumulado NOT BETWEEN 0 AND 100)
   OR (avance_presup_acumulado IS NOT NULL AND avance_presup_acumulado NOT BETWEEN 0 AND 100);

SELECT COUNT(*) AS avances_evento_fuera_de_rango
FROM warehouse.fact_eventos_auditoria
WHERE (porcentaje_avance_fisico IS NOT NULL AND porcentaje_avance_fisico NOT BETWEEN 0 AND 100)
   OR (porcentaje_avance_presup IS NOT NULL AND porcentaje_avance_presup NOT BETWEEN 0 AND 100);

-- 2. Aplicar las tres restricciones a la copia y conservarlas.
BEGIN;

ALTER TABLE warehouse.fact_obra_mensual
  ADD CONSTRAINT ck_fact_obra_mensual_montos_no_negativos
  CHECK (
    (presupuesto_total IS NULL OR presupuesto_total >= 0)
    AND (costo_acumulado IS NULL OR costo_acumulado >= 0)
    AND (saldo_presupuesto IS NULL OR saldo_presupuesto >= 0)
  );

ALTER TABLE warehouse.fact_obra_mensual
  ADD CONSTRAINT ck_fact_obra_mensual_avances_rango
  CHECK (
    (avance_fisico_acumulado IS NULL OR avance_fisico_acumulado BETWEEN 0 AND 100)
    AND (avance_presup_acumulado IS NULL OR avance_presup_acumulado BETWEEN 0 AND 100)
  );

ALTER TABLE warehouse.fact_eventos_auditoria
  ADD CONSTRAINT ck_fact_eventos_auditoria_avances_rango
  CHECK (
    (porcentaje_avance_fisico IS NULL OR porcentaje_avance_fisico BETWEEN 0 AND 100)
    AND (porcentaje_avance_presup IS NULL OR porcentaje_avance_presup BETWEEN 0 AND 100)
  );

COMMIT;

-- 3. Pruebas negativas: cada inserción debe ser rechazada por CHECK.
DO $$
DECLARE v_tiempo integer; v_obra bigint;
BEGIN
  SELECT d.tiempo_key INTO v_tiempo
  FROM warehouse.dim_tiempo d
  WHERE d.anio=2024 AND d.dia=2
    AND NOT EXISTS (
      SELECT 1 FROM warehouse.fact_obra_mensual f
      WHERE f.tiempo_key=d.tiempo_key AND f.obra_key=(SELECT MIN(obra_key) FROM warehouse.dim_obra)
    )
  ORDER BY d.tiempo_key LIMIT 1;
  SELECT MIN(obra_key) INTO v_obra FROM warehouse.dim_obra;

  BEGIN
    INSERT INTO warehouse.fact_obra_mensual
      (tiempo_key, obra_key, presupuesto_total)
    VALUES (v_tiempo, v_obra, -1);
    RAISE EXCEPTION 'No se rechazó el presupuesto negativo.';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK: montos negativos rechazados: %', SQLERRM;
  END;

  BEGIN
    INSERT INTO warehouse.fact_obra_mensual
      (tiempo_key, obra_key, avance_fisico_acumulado)
    VALUES (v_tiempo, v_obra, 101);
    RAISE EXCEPTION 'No se rechazó el avance mensual de 101.';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK: avance mensual fuera de rango rechazado: %', SQLERRM;
  END;

  BEGIN
    INSERT INTO warehouse.fact_eventos_auditoria
      (tiempo_key, tipo_evento_key, porcentaje_avance_fisico)
    SELECT v_tiempo, tipo_evento_key, 101
    FROM warehouse.dim_tipo_evento
    ORDER BY tipo_evento_key
    LIMIT 1;
    RAISE EXCEPTION 'No se rechazó el avance del evento de 101.';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK: avance de evento fuera de rango rechazado: %', SQLERRM;
  END;
END $$;
