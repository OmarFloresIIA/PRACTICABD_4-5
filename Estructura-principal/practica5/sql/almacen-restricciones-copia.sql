-- Aplicar únicamente en una COPIA de la base del proyecto asignado.
-- Ejecutar después de cargar el esquema y los datos sintéticos.
BEGIN;

-- Antes de agregar las restricciones, comprobar si los datos existentes las cumplen.
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

-- Prueba negativa: el CHECK debe rechazar un porcentaje de 101.
DO $$
DECLARE v_tiempo integer; v_obra bigint;
BEGIN
  SELECT tiempo_key INTO v_tiempo FROM warehouse.dim_tiempo ORDER BY tiempo_key LIMIT 1;
  SELECT obra_key INTO v_obra FROM warehouse.dim_obra ORDER BY obra_key LIMIT 1;
  BEGIN
    INSERT INTO warehouse.fact_obra_mensual
      (tiempo_key, obra_key, avance_fisico_acumulado)
    VALUES (v_tiempo, v_obra, 101);
    RAISE EXCEPTION 'La restricción no rechazó el porcentaje 101.';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'OK: PostgreSQL rechazó el porcentaje 101: %', SQLERRM;
  END;
END $$;

ROLLBACK;
