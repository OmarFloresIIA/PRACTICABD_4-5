-- Migración 001: dominios y restricciones del proyecto propio.
-- Motor: PostgreSQL 17. Ejecutar después de schema.sql, como administrador.
BEGIN;

-- EXPORTACION tiene 11 caracteres; el VARCHAR(10) del esquema anterior era insuficiente.
ALTER TABLE cliente ALTER COLUMN tipocliente TYPE VARCHAR(15);

-- Dominios compartidos: la misma regla se aplica a varias tablas.
CREATE DOMAIN correo_electronico AS VARCHAR(100)
  CHECK (VALUE ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$');

CREATE DOMAIN telefono_contacto AS VARCHAR(20)
  CHECK (VALUE ~ '^\+?[0-9][0-9 ()-]{7,18}$');

-- Datos de contacto necesarios para identificar y atender a cada cliente.
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

ALTER TABLE sucursal
  ADD CONSTRAINT ck_sucursal_cp_formato
  CHECK (cp IS NULL OR cp ~ '^[0-9]{5}$');

ALTER TABLE producto
  ADD CONSTRAINT ck_producto_precio_cubre_costo
  CHECK (preciounitariousd >= costounitariousd);

ALTER TABLE pedido
  ALTER COLUMN estatus SET DEFAULT 'REGISTRADO';

ALTER TABLE pedido
  ADD COLUMN activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE pedido
  ADD CONSTRAINT ck_pedido_estatus
  CHECK (estatus IN ('REGISTRADO', 'EN_PROCESO', 'ENVIADO', 'ENTREGADO', 'CANCELADO'));

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
