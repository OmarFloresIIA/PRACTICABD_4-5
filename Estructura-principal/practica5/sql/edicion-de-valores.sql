-- Ejercicio 2.4. Operaciones DML y transacciones.
-- Ejecutar después de cargar los datos. Algunas sentencias modifican registros
-- existentes; para la evidencia se recomienda ejecutar en una copia.

-- 1. INSERT que toma valores de una consulta.
INSERT INTO sucursal
 (numerocliente, clavesucursal, nombreplanta, telefonoencargado, calle, numero, ciudad, estado, pais, cp)
SELECT numerocliente, 'S-COPIA-01', 'Sucursal de demostración',
       telefonoencargado, calle, numero, ciudad, estado, pais, cp
FROM sucursal
ORDER BY numerocliente
LIMIT 1
ON CONFLICT (numerocliente, clavesucursal) DO NOTHING;

-- Inserción que resuelve el caso de que la sucursal ya exista.
INSERT INTO sucursal (numerocliente, clavesucursal, nombreplanta)
SELECT numerocliente, 'S-COPIA-01', 'Sucursal de demostración'
FROM sucursal
ORDER BY numerocliente
LIMIT 1
ON CONFLICT (numerocliente, clavesucursal) DO NOTHING;

-- 2. UPDATE que depende de otra tabla: actualiza el precio aplicado usando
-- el precio de lista del producto relacionado.
UPDATE detalle d
SET precioaplicado = p.preciounitariousd
FROM producto p
WHERE p.claveproducto = d.claveproducto
  AND d.precioaplicado <> p.preciounitariousd;

-- UPDATE con CASE: clasifica pedidos que ya tienen envío.
UPDATE pedido p
SET estatus = CASE
    WHEN EXISTS (SELECT 1 FROM envio e WHERE e.folio = p.folio) THEN 'ENVIADO'
    WHEN p.activo = FALSE THEN 'CANCELADO'
    ELSE p.estatus
END;

-- 3. Borrado lógico: conserva el pedido y sus detalles, pero lo marca inactivo.
UPDATE pedido
SET activo = FALSE
WHERE folio = 20000001 AND activo = TRUE;

-- DELETE con subconsulta: elimina pedidos cancelados que no tienen envío.
-- La FK pedido -> cliente es RESTRICT; detalle -> pedido es CASCADE.
-- Por ello se borran los detalles del pedido eliminado, pero no se borra el cliente.
DELETE FROM pedido p
WHERE p.estatus = 'CANCELADO'
  AND NOT EXISTS (SELECT 1 FROM envio e WHERE e.folio = p.folio);

-- 4. Transacción que modifica dos tablas; el punto de recuperación revierte
-- únicamente el envío de demostración, pero conserva pedido y detalle.
BEGIN;
DELETE FROM envio WHERE folio = 99200001;
DELETE FROM pedido WHERE folio = 99200001;
INSERT INTO pedido (folio, numerocliente, estatus, dia, mes, anio)
SELECT 99200001, c.numerocliente, 'REGISTRADO', 10, 1, 2026
FROM cliente c
JOIN sucursal s ON s.numerocliente = c.numerocliente
ORDER BY c.numerocliente
LIMIT 1;

INSERT INTO detalle (folio, claveparcial, claveproducto, costoproduccion, precioaplicado, cantidad)
SELECT 99200001, 1, claveproducto, costounitariousd, preciounitariousd, 2
FROM producto
ORDER BY claveproducto
LIMIT 1;

SAVEPOINT antes_del_envio;
INSERT INTO envio
 (numeroguia, folio, clavetransportista, numerocliente, clavesucursal,
  costoflete, dia, mes, anio)
SELECT 'GUIA-99200001', p.folio, t.clavetransportista, p.numerocliente,
       s.clavesucursal, 850.00, 12, 1, 2026
FROM pedido p
JOIN sucursal s ON s.numerocliente = p.numerocliente
CROSS JOIN LATERAL (SELECT clavetransportista FROM transportista LIMIT 1) t
WHERE p.folio = 99200001
LIMIT 1;

ROLLBACK TO SAVEPOINT antes_del_envio;
SELECT
  (SELECT COUNT(*) FROM pedido WHERE folio=99200001) AS pedido_conservado,
  (SELECT COUNT(*) FROM detalle WHERE folio=99200001) AS detalle_conservado,
  (SELECT COUNT(*) FROM envio WHERE folio=99200001) AS envio_revertido;
COMMIT;

-- 5. Fallo a mitad de transacción: el detalle apunta a un producto inexistente.
-- El segundo INSERT debe fallar; ROLLBACK elimina también el pedido inicial.
\set ON_ERROR_STOP off
BEGIN;
INSERT INTO pedido (folio, numerocliente, estatus, dia, mes, anio)
SELECT 99200002, MIN(numerocliente), 'REGISTRADO', 13, 1, 2026 FROM cliente;
INSERT INTO detalle (folio, claveparcial, claveproducto, costoproduccion, precioaplicado, cantidad)
VALUES (99200002, 1, 'PRODUCTO-INEXISTENTE', 10, 20, 1);
ROLLBACK;
SELECT COUNT(*) AS pedido_no_conservado_tras_fallo
FROM pedido WHERE folio=99200002;
\set ON_ERROR_STOP on
