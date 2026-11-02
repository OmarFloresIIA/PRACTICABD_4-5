-- Migración 001: dominios y restricciones del proyecto propio.
-- Ejecutar una sola vez, después de esquema.sql y antes de cargar el Excel.
-- Motor: PostgreSQL 17.
BEGIN;

-- El esquema base ya contempla VARCHAR(15), suficiente para EXPORTACION.
ALTER TABLE cliente ALTER COLUMN tipocliente TYPE VARCHAR(15);

-- Dominios compartidos: mismo formato para los atributos de contacto.
CREATE DOMAIN correo_electronico AS VARCHAR(100)
  CHECK (VALUE ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$');

CREATE DOMAIN telefono_contacto AS VARCHAR(20)
  CHECK (VALUE ~ '^\+?[0-9][0-9 ()-]{7,18}$');

-- En el archivo fuente los 1,500 clientes tienen correo y teléfono.
ALTER TABLE cliente ALTER COLUMN correocliente SET NOT NULL;
ALTER TABLE cliente ALTER COLUMN telefonocliente SET NOT NULL;

ALTER TABLE cliente
  ALTER COLUMN correocliente TYPE correo_electronico
  USING correocliente::correo_electronico;
ALTER TABLE transportista
  ALTER COLUMN email TYPE correo_electronico
  USING email::correo_electronico;
ALTER TABLE cliente
  ALTER COLUMN telefonocliente TYPE telefono_contacto
  USING telefonocliente::telefono_contacto;
ALTER TABLE transportista
  ALTER COLUMN telefonoatencion TYPE telefono_contacto
  USING telefonoatencion::telefono_contacto;
ALTER TABLE sucursal
  ALTER COLUMN telefonoencargado TYPE telefono_contacto
  USING telefonoencargado::telefono_contacto;

ALTER TABLE cliente
  ADD CONSTRAINT uq_cliente_correo UNIQUE (correocliente);

ALTER TABLE cliente
  ADD CONSTRAINT ck_cliente_rfc_formato
  CHECK (rfc IS NULL OR rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$');

ALTER TABLE transportista
  ADD CONSTRAINT uq_transportista_email UNIQUE (email);

ALTER TABLE transportista
  ADD CONSTRAINT ck_transportista_rfc_formato
  CHECK (rfc IS NULL OR rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$');

ALTER TABLE sucursal
  ADD CONSTRAINT ck_sucursal_cp_formato
  CHECK (cp IS NULL OR cp ~ '^[0-9]{5}$');

-- El archivo incluye un modelo comercial adicional que no estaba en el DDL
-- inicial. HYGOLD se asigna a OMNIGOLD según la nota del propio conjunto.
ALTER TABLE producto
  ADD COLUMN modeloproducto VARCHAR(30) NOT NULL;

ALTER TABLE producto
  ADD CONSTRAINT ck_producto_modelo
  CHECK (modeloproducto IN (
    'HYGOLD 100',
    'HYGOLD 5000BS',
    'HYGOLD L-2000',
    'HYPRENE BO150',
    'HYPRENE L2000',
    'HYPRENE P150 BS',
    'HYVOLT II',
    'OMNIGOLD A12',
    'OMNIGOLD P100N',
    'OMNIGOLD P220N'
  ));

ALTER TABLE producto
  ADD CONSTRAINT ck_producto_modelo_tipo
  CHECK (
    (modeloproducto LIKE 'HYGOLD%' OR modeloproducto LIKE 'OMNIGOLD%')
      AND tipoproducto = 'OMNIGOLD'
    OR modeloproducto LIKE 'HYVOLT%' AND tipoproducto = 'HYVOLT'
    OR modeloproducto LIKE 'HYPRENE%' AND tipoproducto = 'HYPRENE'
  );

-- Todos los precios de catálogo de la fuente son mayores o iguales al costo.
ALTER TABLE producto
  ADD CONSTRAINT ck_producto_precio_cubre_costo
  CHECK (preciounitariousd >= costounitariousd);

-- La fuente tiene dos estatus: ENVIADO y ENTREGADO. No se inventa un estatus
-- por omisión; activo sí tiene un valor inicial natural.
ALTER TABLE pedido
  ADD COLUMN activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE pedido
  ALTER COLUMN estatus DROP DEFAULT;

ALTER TABLE pedido
  ADD CONSTRAINT ck_pedido_estatus
  CHECK (estatus IN ('ENVIADO', 'ENTREGADO'));

ALTER TABLE pedido
  ADD CONSTRAINT ck_pedido_fecha_valida
  CHECK (make_date(anio, mes, dia) IS NOT NULL);

ALTER TABLE envio
  ADD CONSTRAINT ck_envio_fecha_valida
  CHECK (make_date(anio, mes, dia) IS NOT NULL);

ALTER TABLE detalle
  ADD CONSTRAINT ck_detalle_clave_parcial_positiva
  CHECK (claveparcial > 0);

COMMIT;
