-- Ejercicio 2.4. Edición de valores y transacciones.
-- Ejecutar con psql después de aplicar las migraciones y cargar el Excel.
-- El bloque de ejemplos y DELETE se revierte para no alterar la fuente.
-- El ejemplo SAVEPOINT sí se confirma y después se limpia; al final se
-- demuestra una transacción fallida y su ROLLBACK.

-- 1. INSERT desde una consulta y manejo del caso duplicado.
BEGIN;

INSERT INTO sucursal
 (numerocliente,clavesucursal,nombreplanta,telefonoencargado,calle,numero,ciudad,estado,pais,cp)
SELECT numerocliente,'S-DEM-01','Sucursal de demostración',
       telefonoencargado,calle,numero,ciudad,estado,pais,cp
FROM sucursal
ORDER BY numerocliente,clavesucursal
LIMIT 1
ON CONFLICT (numerocliente,clavesucursal) DO NOTHING;

-- Ejecutar la misma inserción de nuevo: no duplica el renglón.
INSERT INTO sucursal
 (numerocliente,clavesucursal,nombreplanta)
SELECT numerocliente,'S-DEM-01','Sucursal de demostración'
FROM sucursal
ORDER BY numerocliente,clavesucursal
LIMIT 1
ON CONFLICT (numerocliente,clavesucursal) DO NOTHING;

SELECT COUNT(*) AS sucursales_demostracion
FROM sucursal WHERE clavesucursal='S-DEM-01';

-- 2. UPDATE que depende de otra tabla: precio aplicado toma el precio
-- del producto relacionado. Se actualiza un solo renglón de detalle.
UPDATE detalle d
SET precioaplicado=p.preciounitariousd
FROM producto p
WHERE p.claveproducto=d.claveproducto
  AND (d.folio,d.claveparcial)=(
      SELECT folio,claveparcial FROM detalle
      ORDER BY folio,claveparcial LIMIT 1
  )
RETURNING d.folio,d.claveparcial,d.precioaplicado;

-- UPDATE con CASE: clasifica un pedido a partir de si ya tiene envío.
-- La fuente solo contempla ENVIADO y ENTREGADO.
UPDATE pedido p
SET estatus=CASE
    WHEN EXISTS (SELECT 1 FROM envio e WHERE e.folio=p.folio)
      THEN 'ENVIADO'
    ELSE 'ENTREGADO'
END
WHERE p.folio=(SELECT MIN(folio) FROM pedido)
RETURNING p.folio,p.estatus;

-- Borrado lógico: conserva el pedido y sus detalles, pero cambia activo.
UPDATE pedido
SET activo=FALSE
WHERE folio=(SELECT MIN(folio) FROM pedido WHERE activo=TRUE)
RETURNING folio,activo;

-- 3. DELETE con subconsulta sobre un pedido de demostración.
-- Primero se crea pedido/detalle/envío de prueba con claves válidas.
INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
SELECT 99200010,c.numerocliente,'ENVIADO',10,10,2026
FROM cliente c
WHERE c.numerocliente=(SELECT MIN(numerocliente) FROM cliente);

INSERT INTO detalle
 (folio,claveparcial,claveproducto,costoproduccion,precioaplicado,cantidad)
SELECT 99200010,1,claveproducto,costounitariousd,preciounitariousd,2
FROM producto
ORDER BY claveproducto LIMIT 1;

INSERT INTO envio
 (numeroguia,folio,clavetransportista,numerocliente,clavesucursal,costoflete,dia,mes,anio)
SELECT 'GUIA-99200010',p.folio,
       (SELECT clavetransportista FROM transportista ORDER BY clavetransportista LIMIT 1),
       p.numerocliente,s.clavesucursal,800.00,12,10,2026
FROM pedido p
JOIN sucursal s ON s.numerocliente=p.numerocliente
WHERE p.folio=99200010
ORDER BY s.clavesucursal
LIMIT 1;

-- Se elimina el envío porque su FK hacia pedido es RESTRICT.
DELETE FROM envio
WHERE folio IN (
    SELECT p.folio FROM pedido p
    WHERE p.folio=99200010
      AND EXISTS (SELECT 1 FROM detalle d WHERE d.folio=p.folio)
);

-- DELETE usa una subconsulta correlacionada. Por CASCADE se eliminan
-- los renglones detalle asociados con el pedido.
DELETE FROM pedido p
WHERE p.folio IN (
    SELECT d.folio FROM detalle d
    WHERE d.folio=p.folio
)
AND p.folio=99200010;

SELECT
  (SELECT COUNT(*) FROM pedido WHERE folio=99200010) AS pedido_restante,
  (SELECT COUNT(*) FROM detalle WHERE folio=99200010) AS detalles_restantes,
  (SELECT COUNT(*) FROM envio WHERE folio=99200010) AS envios_restantes;

-- La sucursal de demostración, la edición de precio, la clasificación y
-- el borrado lógico son ejemplos temporales; se recupera el Excel original.
ROLLBACK;

-- 4. Transacción de dos tablas con SAVEPOINT, reversión parcial y COMMIT.
-- Se confirma pedido y detalle, se revierte solo el envío creado después
-- del SAVEPOINT, se verifica y se limpia la demostración.
BEGIN;

INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
SELECT 99200011,c.numerocliente,'ENVIADO',15,10,2026
FROM cliente c
WHERE c.numerocliente=(SELECT MIN(numerocliente) FROM cliente);

INSERT INTO detalle
 (folio,claveparcial,claveproducto,costoproduccion,precioaplicado,cantidad)
SELECT 99200011,1,claveproducto,costounitariousd,preciounitariousd,1
FROM producto
ORDER BY claveproducto LIMIT 1;

SAVEPOINT antes_del_envio;

INSERT INTO envio
 (numeroguia,folio,clavetransportista,numerocliente,clavesucursal,costoflete,dia,mes,anio)
SELECT 'GUIA-99200011',p.folio,
       (SELECT clavetransportista FROM transportista ORDER BY clavetransportista LIMIT 1),
       p.numerocliente,s.clavesucursal,850.00,17,10,2026
FROM pedido p
JOIN sucursal s ON s.numerocliente=p.numerocliente
WHERE p.folio=99200011
ORDER BY s.clavesucursal
LIMIT 1;

ROLLBACK TO SAVEPOINT antes_del_envio;

SELECT
  (SELECT COUNT(*) FROM pedido WHERE folio=99200011) AS pedido_conservado,
  (SELECT COUNT(*) FROM detalle WHERE folio=99200011) AS detalle_conservado,
  (SELECT COUNT(*) FROM envio WHERE folio=99200011) AS envio_revertido;

COMMIT;

-- Eliminar la demostración confirmada; detalle se elimina por CASCADE.
BEGIN;
DELETE FROM pedido WHERE folio=99200011;
COMMIT;

-- 5. Fallo a mitad de la transacción por FK inexistente.
-- La primera inserción sí se ejecuta dentro de la transacción; la segunda
-- falla por producto inexistente y ROLLBACK revierte también el pedido.
\set ON_ERROR_STOP off
BEGIN;

INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
SELECT 99200012,MIN(numerocliente),'ENVIADO',20,10,2026
FROM cliente;

INSERT INTO detalle
 (folio,claveparcial,claveproducto,costoproduccion,precioaplicado,cantidad)
VALUES
 (99200012,1,'PRODUCTO-INEXISTENTE',10.00,15.00,1);

ROLLBACK;

SELECT COUNT(*) AS pedido_no_conservado_tras_fallo
FROM pedido WHERE folio=99200012;
\set ON_ERROR_STOP on
