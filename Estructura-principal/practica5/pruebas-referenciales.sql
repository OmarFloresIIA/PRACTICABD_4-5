-- Ejercicio 2.3. Pruebas de integridad referencial.
-- Ejecutar después de la carga de datos y de aplicar las migraciones.
BEGIN;

CREATE TEMP TABLE _inicializar_pg_temp (id integer) ON COMMIT DROP;

CREATE OR REPLACE FUNCTION pg_temp.esperar_error(
    p_nombre text, p_sql text, p_sqlstate text
) RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_estado text; v_mensaje text;
BEGIN
  BEGIN
    EXECUTE p_sql;
    RAISE EXCEPTION USING ERRCODE='P0001',
      MESSAGE='La operación no fue rechazada por la FK esperada.';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_estado=RETURNED_SQLSTATE, v_mensaje=MESSAGE_TEXT;
    IF v_estado='P0001' THEN RAISE; END IF;
    IF v_estado<>p_sqlstate THEN
      RAISE EXCEPTION 'Prueba %: se esperaba %, se recibió % (%).',
        p_nombre,p_sqlstate,v_estado,v_mensaje;
    END IF;
    RAISE NOTICE 'OK - % - SQLSTATE %, mensaje: %',p_nombre,v_estado,v_mensaje;
  END;
END;
$$;

-- A. ON DELETE CASCADE: eliminar cliente elimina sus sucursales.
INSERT INTO cliente
 (numerocliente,razonsocial,correocliente,telefonocliente,tipocliente,rfc,regimenfiscal,estadoorigen)
VALUES
 (99100001,'Cliente prueba CASCADE','cascade@example.test','+52 722 300 0001',
  'NACIONAL','CAS260101CA1','General','Estado de México');
INSERT INTO sucursal (numerocliente,clavesucursal,nombreplanta)
VALUES (99100001,'CAS01','Sucursal que debe eliminarse');
SELECT 'Antes de DELETE CASCADE' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100001) AS clientes,
       (SELECT COUNT(*) FROM sucursal WHERE numerocliente=99100001) AS sucursales;
DELETE FROM cliente WHERE numerocliente=99100001;
SELECT 'Después de DELETE CASCADE' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100001) AS clientes,
       (SELECT COUNT(*) FROM sucursal WHERE numerocliente=99100001) AS sucursales;

-- B. ON DELETE RESTRICT: no permite borrar un cliente que tiene pedidos.
INSERT INTO cliente
 (numerocliente,razonsocial,correocliente,telefonocliente,tipocliente,rfc,regimenfiscal,estadoorigen)
VALUES
 (99100002,'Cliente prueba RESTRICT','restrict@example.test','+52 722 300 0002',
  'NACIONAL','RES260101RE1','General','Estado de México');
INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
VALUES (99100002,99100002,'REGISTRADO',2,1,2026);
SELECT 'Antes de DELETE RESTRICT' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100002) AS clientes,
       (SELECT COUNT(*) FROM pedido WHERE numerocliente=99100002) AS pedidos;
SELECT pg_temp.esperar_error(
 'RESTRICT de cliente con pedido',
 'DELETE FROM cliente WHERE numerocliente=99100002',
 '23503'
);
SELECT 'Después del intento RESTRICT' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100002) AS clientes,
       (SELECT COUNT(*) FROM pedido WHERE numerocliente=99100002) AS pedidos;

-- C. ON UPDATE CASCADE: la nueva clave del cliente pasa a sucursal y pedido.
INSERT INTO cliente
 (numerocliente,razonsocial,correocliente,telefonocliente,tipocliente,rfc,regimenfiscal,estadoorigen)
VALUES
 (99100003,'Cliente prueba UPDATE','update@example.test','+52 722 300 0003',
  'NACIONAL','UPD260101UP1','General','Estado de México');
INSERT INTO sucursal (numerocliente,clavesucursal,nombreplanta)
VALUES (99100003,'UPD01','Sucursal para UPDATE CASCADE');
INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
VALUES (99100003,99100003,'REGISTRADO',3,1,2026);
SELECT 'Antes de UPDATE CASCADE' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100003) AS clientes,
       (SELECT COUNT(*) FROM sucursal WHERE numerocliente=99100003) AS sucursales,
       (SELECT COUNT(*) FROM pedido WHERE numerocliente=99100003) AS pedidos;
UPDATE cliente SET numerocliente=99100004 WHERE numerocliente=99100003;
SELECT 'Después de UPDATE CASCADE' AS momento,
       (SELECT COUNT(*) FROM sucursal WHERE numerocliente=99100004) AS sucursales_con_nueva_clave,
       (SELECT COUNT(*) FROM pedido WHERE numerocliente=99100004) AS pedidos_con_nueva_clave;

-- D. Una FK inexistente es rechazada.
SELECT pg_temp.esperar_error(
 'INSERT con cliente inexistente',
 'INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
  VALUES (99100005,999999999,''REGISTRADO'',5,1,2026)',
 '23503'
);

-- E. Orden de carga: el hijo falla antes del padre; después se acepta.
SELECT pg_temp.esperar_error(
 'pedido antes que cliente',
 'INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
  VALUES (99100006,99100006,''REGISTRADO'',6,1,2026)',
 '23503'
);
INSERT INTO cliente
 (numerocliente,razonsocial,correocliente,telefonocliente,tipocliente,rfc,regimenfiscal,estadoorigen)
VALUES
 (99100006,'Cliente para orden de carga','orden@example.test','+52 722 300 0006',
  'NACIONAL','ORD260101OR1','General','Estado de México');
INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
VALUES (99100006,99100006,'REGISTRADO',6,1,2026);
SELECT 'Después de insertar padre e hijo' AS momento,
       (SELECT COUNT(*) FROM cliente WHERE numerocliente=99100006) AS clientes,
       (SELECT COUNT(*) FROM pedido WHERE folio=99100006) AS pedidos;

-- F. Comprobaciones de integridad: todas las consultas deben devolver cero.
SELECT COUNT(*) AS sucursales_sin_cliente
FROM sucursal s LEFT JOIN cliente c USING (numerocliente)
WHERE c.numerocliente IS NULL;

SELECT COUNT(*) AS pedidos_sin_cliente
FROM pedido p LEFT JOIN cliente c USING (numerocliente)
WHERE c.numerocliente IS NULL;

SELECT COUNT(*) AS detalles_sin_pedido
FROM detalle d LEFT JOIN pedido p USING (folio)
WHERE p.folio IS NULL;

SELECT COUNT(*) AS detalles_sin_producto
FROM detalle d LEFT JOIN producto pr USING (claveproducto)
WHERE pr.claveproducto IS NULL;

SELECT COUNT(*) AS envios_sin_pedido
FROM envio e LEFT JOIN pedido p USING (folio)
WHERE p.folio IS NULL;

SELECT COUNT(*) AS envios_sin_transportista
FROM envio e LEFT JOIN transportista t USING (clavetransportista)
WHERE t.clavetransportista IS NULL;

SELECT COUNT(*) AS envios_sin_sucursal
FROM envio e LEFT JOIN sucursal s
  ON s.numerocliente=e.numerocliente AND s.clavesucursal=e.clavesucursal
WHERE s.numerocliente IS NULL;

-- Duplicados y nulos en columnas protegidas.
SELECT COUNT(*) AS correos_duplicados
FROM (SELECT correocliente FROM cliente GROUP BY correocliente HAVING COUNT(*)>1) q;
SELECT COUNT(*) AS sucursales_duplicadas
FROM (SELECT numerocliente,clavesucursal FROM sucursal
      GROUP BY numerocliente,clavesucursal HAVING COUNT(*)>1) q;
SELECT COUNT(*) AS clientes_sin_correo
FROM cliente WHERE correocliente IS NULL;

ROLLBACK;
