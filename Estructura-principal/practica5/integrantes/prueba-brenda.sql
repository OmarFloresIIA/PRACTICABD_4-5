-- Prueba de la propuesta de Brenda: el envío permanece y la FK queda NULL.
BEGIN;

INSERT INTO cliente
 (numerocliente,razonsocial,correocliente,telefonocliente,tipocliente,rfc,regimenfiscal,estadoorigen)
VALUES
 (99400001,'Cliente prueba Brenda','brenda-prueba@example.test','+52 722 400 0002',
  'NACIONAL','BRE260101BR1','General','Estado de México');

INSERT INTO sucursal (numerocliente,clavesucursal,nombreplanta)
VALUES (99400001,'BR01','Sucursal de prueba Brenda');

INSERT INTO pedido (folio,numerocliente,estatus,dia,mes,anio)
VALUES (99400001,99400001,'REGISTRADO',2,2,2026);

INSERT INTO transportista
 (clavetransportista,nombreempresa,email,esnacional,esinternacional,rfc)
VALUES
 ('BR-TRANS','Transportista prueba Brenda','brenda-trans@example.test',
  TRUE,FALSE,'TRA260101TR1');

INSERT INTO envio
 (numeroguia,folio,clavetransportista,numerocliente,clavesucursal,costoflete,dia,mes,anio)
VALUES
 ('GUIA-BRENDA-01',99400001,'BR-TRANS',99400001,'BR01',500,3,2,2026);

DELETE FROM transportista WHERE clavetransportista='BR-TRANS';

SELECT numeroguia, folio, clavetransportista
FROM envio WHERE numeroguia='GUIA-BRENDA-01';
-- Esperado: el envío existe y clavetransportista es NULL.

ROLLBACK;
