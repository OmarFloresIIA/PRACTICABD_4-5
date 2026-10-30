#!/usr/bin/env python3
"""Carga repetible y transaccional de datos sintéticos del proyecto propio.

Requiere DATABASE_URL y psycopg2-binary. Usa COPY hacia tablas temporales
y después inserta en las tablas definitivas en orden de dependencia.
"""
import csv
import os
import random
import sys
from datetime import date, timedelta
from io import StringIO

import psycopg2

SEED = 20261030


def fecha_partes(fecha):
    return fecha.day, fecha.month, fecha.year


def cargar_con_copy(cur, tabla, columnas, filas):
    """Carga una tabla temporal con COPY y transfiere sin duplicar claves."""
    if not filas:
        return 0, 0
    temporal = f"stg_{tabla}"
    cols = ", ".join(columnas)
    cur.execute(
        f"CREATE TEMP TABLE {temporal} "
        f"(LIKE public.{tabla} INCLUDING DEFAULTS) ON COMMIT DROP"
    )
    buffer = StringIO()
    writer = csv.writer(buffer, lineterminator="\n")
    writer.writerows(filas)
    buffer.seek(0)
    cur.copy_expert(
        f"COPY {temporal} ({cols}) FROM STDIN WITH (FORMAT CSV)",
        buffer
    )
    cur.execute(
        f"INSERT INTO public.{tabla} ({cols}) "
        f"SELECT {cols} FROM {temporal} ON CONFLICT DO NOTHING"
    )
    insertadas = cur.rowcount
    return len(filas), insertadas


def generar_datos():
    r = random.Random(SEED)
    clientes, transportistas, productos = [], [], []
    sucursales, pedidos, detalles, envios = [], [], [], []

    # 200 clientes: 100 nacionales y 100 de exportación.
    for i in range(1, 201):
        numero = 100000 + i
        correo = f"cliente{i:04d}@example.test"
        telefono = f"+52 722 000 {i:04d}"
        if i <= 100:
            clientes.append((
                numero, f"Cliente Industrial Nacional {i:03d}", correo,
                telefono, "NACIONAL", f"AAA{i:06d}AA1",
                "General de Ley Personas Morales", "Estado de México",
                None, None
            ))
        else:
            clientes.append((
                numero, f"Cliente Industrial Exportación {i:03d}", correo,
                telefono, "EXPORTACION", None, None, None,
                f"TAX-{i:06d}-MX", r.choice(["Estados Unidos", "Alemania", "Japón", "Canadá"])
            ))

    # 220 transportistas: nacionales, internacionales o ambas modalidades.
    for i in range(1, 221):
        nacional = r.choice([True, False])
        internacional = r.choice([True, False])
        if not nacional and not internacional:
            internacional = True
        transportistas.append((
            f"TR{i:04d}", f"Transportes Industriales {i:03d}",
            f"+52 722 100 {i:04d}", f"contacto{i:04d}@transportes.example.test",
            nacional, internacional,
            f"BBB{i:06d}BB2" if nacional else None,
            f"ADU-{i:05d}" if internacional else None,
            f"Agencia Aduanal {i:03d}" if internacional else None
        ))

    # 240 productos, 80 por línea industrial.
    for i in range(1, 241):
        if i <= 80:
            tipo, proveedor = "OMNIGOLD", f"Proveedor de maquinaria {i:03d}"
            otros = (None, None)
        elif i <= 160:
            tipo, proveedor = "HYVOLT", f"Proveedor de transformadores {i:03d}"
            otros = (None, None)
        else:
            tipo, proveedor = "HYPRENE", f"Proveedor de transporte {i:03d}"
            otros = (None, None)
        costo = round(r.uniform(100, 12000), 2)
        precio = round(costo * r.uniform(1.08, 1.65), 2)
        if tipo == "OMNIGOLD":
            prov_maquinaria, prov_transformador, prov_transporte = proveedor, None, None
        elif tipo == "HYVOLT":
            prov_maquinaria, prov_transformador, prov_transporte = None, proveedor, None
        else:
            prov_maquinaria, prov_transformador, prov_transporte = None, None, proveedor
        productos.append((
            f"PR{i:05d}", costo, precio, tipo,
            prov_maquinaria, prov_transformador, prov_transporte
        ))

    # 240 sucursales; cada cliente tiene al menos una.
    sucursales_por_cliente = {}
    for i in range(1, 241):
        numero_cliente = 100001 + ((i - 1) % 200)
        clave = f"S{i:04d}"
        sucursal = (
            numero_cliente, clave, f"Planta o sucursal {i:03d}",
            f"+52 722 200 {i:04d}", f"Avenida Industrial {i}",
            str(100 + i), f"Ciudad Industrial {i:02d}",
            r.choice(["Estado de México", "Querétaro", "Nuevo León", "Jalisco"]),
            "México", f"{50000 + i:05d}"
        )
        sucursales.append(sucursal)
        sucursales_por_cliente.setdefault(numero_cliente, []).append(clave)

    # 600 pedidos asociados a clientes existentes.
    pedidos_por_folio = {}
    fecha_base = date(2024, 1, 1)
    estados = ["REGISTRADO", "EN_PROCESO", "ENVIADO", "ENTREGADO", "CANCELADO"]
    for i in range(1, 601):
        folio = 20000000 + i
        cliente = r.randint(100001, 100200)
        fecha = fecha_base + timedelta(days=r.randint(0, 900))
        dia, mes, anio = fecha_partes(fecha)
        estado = r.choice(estados)
        pedidos.append((folio, cliente, estado, dia, mes, anio))
        pedidos_por_folio[folio] = (cliente, fecha)

    # 1,200 detalles: dos productos por pedido.
    for i in range(1, 601):
        folio = 20000000 + i
        for parcial in (1, 2):
            producto = r.choice(productos)
            clave_producto = producto[0]
            costo = round(float(producto[1]) * r.uniform(0.95, 1.05), 2)
            precio = round(float(producto[2]) * r.uniform(0.92, 1.04), 2)
            cantidad = r.randint(1, 30)
            detalles.append((folio, parcial, clave_producto, costo, precio, cantidad))

    # 300 envíos: la sucursal siempre pertenece al cliente del pedido.
    for i, folio in enumerate(r.sample(list(pedidos_por_folio), 300), 1):
        cliente, fecha_pedido = pedidos_por_folio[folio]
        clave_sucursal = r.choice(sucursales_por_cliente[cliente])
        fecha_envio = fecha_pedido + timedelta(days=r.randint(1, 20))
        dia, mes, anio = fecha_partes(fecha_envio)
        transportista = r.choice(transportistas)[0]
        envios.append((
            f"GUIA-{i:06d}", folio, transportista, cliente, clave_sucursal,
            round(r.uniform(250, 8500), 2), dia, mes, anio
        ))

    return [
        ("cliente", ["numerocliente", "razonsocial", "correocliente", "telefonocliente",
                     "tipocliente", "rfc", "regimenfiscal", "estadoorigen",
                     "idfiscalglobal", "paisreceptor"], clientes),
        ("transportista", ["clavetransportista", "nombreempresa", "telefonoatencion",
                           "email", "esnacional", "esinternacional", "rfc",
                           "codigoaduanal", "agenciaaduanal"], transportistas),
        ("producto", ["claveproducto", "costounitario_usd", "preciounitario_usd",
                      "tipoproducto", "provmaquinaria", "provtransformador",
                      "provtransporte"], productos),
        ("sucursal", ["numerocliente", "clavesucursal", "nombreplanta",
                      "telefonoencargado", "calle", "numero", "ciudad", "estado",
                      "pais", "cp"], sucursales),
        ("pedido", ["folio", "numerocliente", "estatus", "dia", "mes", "anio"], pedidos),
        ("detalle", ["folio", "claveparcial", "claveproducto", "costoproduccion",
                     "precioaplicado", "cantidad"], detalles),
        ("envio", ["numeroguia", "folio", "clavetransportista", "numerocliente",
                   "clavesucursal", "costoflete", "dia", "mes", "anio"], envios),
    ]


def main():
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        print("ERROR: define DATABASE_URL con la conexión de PostgreSQL.", file=sys.stderr)
        return 2

    conexion = None
    try:
        conexion = psycopg2.connect(dsn)
        conexion.autocommit = False
        resultados = []
        with conexion.cursor() as cur:
            for tabla, columnas, filas in generar_datos():
                total, insertadas = cargar_con_copy(cur, tabla, columnas, filas)
                resultados.append((tabla, total, insertadas, total - insertadas, 0))
        conexion.commit()

        print("Carga terminada correctamente. Semilla:", SEED)
        print("| Tabla | Filas del lote | Insertadas | Ya existentes | Rechazadas |")
        print("|---|---:|---:|---:|---:|")
        for tabla, total, insertadas, existentes, rechazadas in resultados:
            print(f"| {tabla} | {total} | {insertadas} | {existentes} | {rechazadas} |")
        print("\nSi una fila incumple una restricción, PostgreSQL cancela la transacción completa.")
        return 0
    except Exception as exc:
        if conexion is not None:
            conexion.rollback()
        print("ERROR: la carga completa fue revertida.", file=sys.stderr)
        print(f"Detalle del gestor: {exc}", file=sys.stderr)
        return 1
    finally:
        if conexion is not None:
            conexion.close()


if __name__ == "__main__":
    raise SystemExit(main())
