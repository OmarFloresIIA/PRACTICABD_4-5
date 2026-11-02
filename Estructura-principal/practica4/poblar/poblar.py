#!/usr/bin/env python3
"""Carga el Excel sintético del proyecto propio en PostgreSQL.

Fuente: practica4/datos/base_datos_pedidos.xlsx
Requisitos: psycopg2-binary, openpyxl y python-dotenv.
La carga es transaccional, usa COPY y puede repetirse sin duplicar claves.
"""
from __future__ import annotations

import argparse
import csv
import os
import sys
from io import StringIO
from pathlib import Path

import psycopg2
from psycopg2 import sql
from psycopg2.extensions import make_dsn
from dotenv import load_dotenv
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_FILE = ROOT / "practica4" / "datos" / "base_datos_pedidos.xlsx"

# Encabezados exactos del XLSX y nombres equivalentes en PostgreSQL.
TABLES = [
    ("cliente", "cliente",
     ["numerocliente", "razonsocial", "correocliente", "telefonocliente",
      "tipocliente", "rfc", "regimenfiscal", "estadoorigen",
      "idfiscalglobal", "paisreceptor"]),
    ("transportista", "transportista",
     ["clavetransportista", "nombreempresa", "telefonoatencion", "email",
      "esnacional", "esinternacional", "rfc", "codigoaduanal", "agenciaaduanal"]),
    ("producto", "producto",
     ["claveproducto", "modeloproducto", "costounitariousd", "preciounitariousd",
      "tipoproducto", "provmaquinaria", "provtransformador", "provtransporte"]),
    ("sucursal", "sucursal",
     ["numerocliente", "clavesucursal", "nombreplanta", "telefonoencargado",
      "calle", "numero", "ciudad", "estado", "pais", "cp"]),
    ("pedido", "pedido",
     ["folio", "numerocliente", "estatus", "dia", "mes", "anio", "activo"]),
    ("detalle", "detalle",
     ["folio", "claveparcial", "claveproducto", "costoproduccion",
      "precioaplicado", "cantidad"]),
    ("envio", "envio",
     ["numeroguia", "folio", "clavetransportista", "numerocliente",
      "clavesucursal", "costoflete", "dia", "mes", "anio"]),
]

def obtener_dsn() -> str:
    load_dotenv(ROOT / ".env")
    dsn = os.getenv("DATABASE_URL")
    if dsn:
        return dsn

    password = os.getenv("APP_DB_PASSWORD")
    if not password:
        raise RuntimeError(
            "Falta DATABASE_URL o APP_DB_PASSWORD. Revisa el archivo .env "
            "y las instrucciones de practica4/permisos.md."
        )
    return make_dsn(
        dbname=os.getenv("POSTGRES_DB", "ventas_industriales"),
        user=os.getenv("APP_DB_USER", "usuario_app"),
        password=password,
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5434"),
    )

def leer_excel(ruta: Path):
    if not ruta.is_file():
        raise FileNotFoundError(
            f"No se encontró el archivo fuente: {ruta}\n"
            "Coloca base_datos_pedidos.xlsx en practica4/datos/."
        )

    libro = load_workbook(ruta, read_only=True, data_only=True)
    datos = []
    try:
        hojas_requeridas = {hoja for hoja, _, _ in TABLES}
        faltantes = hojas_requeridas - set(libro.sheetnames)
        if faltantes:
            raise ValueError(f"Faltan hojas requeridas en el XLSX: {sorted(faltantes)}")

        for hoja, tabla, columnas in TABLES:
            ws = libro[hoja]
            filas = ws.iter_rows(values_only=True)
            encabezados = next(filas, None)
            if encabezados is None:
                raise ValueError(f"La hoja {hoja} está vacía.")
            encabezados = [str(x).strip() if x is not None else "" for x in encabezados]
            esperados = {
                "cliente": ["numeroCliente", "razonSocial", "correoCliente", "telefonoCliente",
                            "tipoCliente", "RFC", "regimenFiscal", "estadoOrigen",
                            "idFiscalGlobal", "paisReceptor"],
                "transportista": ["claveTransportista", "nombreEmpresa", "telefonoAtencion",
                                  "email", "esNacional", "esInternacional", "RFC",
                                  "codigoAduanal", "agenciaAduanal"],
                "producto": ["claveProducto", "modeloProducto", "costoUnitarioUSD",
                             "precioUnitarioUSD", "tipoProducto", "provMaquinaria",
                             "provTransformador", "provTransporte"],
                "sucursal": ["numeroCliente", "claveSucursal", "nombrePlanta",
                             "telefonoEncargado", "calle", "numero", "ciudad",
                             "estado", "pais", "CP"],
                "pedido": ["folio", "numeroCliente", "estatus", "dia", "mes", "anio", "activo"],
                "detalle": ["folio", "claveParcial", "claveProducto", "costoProduccion",
                            "precioAplicado", "cantidad"],
                "envio": ["numeroGuia", "folio", "claveTransportista", "numeroCliente",
                          "claveSucursal", "costoFlete", "dia", "mes", "anio"],
            }[hoja]
            if encabezados != esperados:
                raise ValueError(
                    f"Los encabezados de {hoja} no coinciden.\n"
                    f"Esperados: {esperados}\nRecibidos: {encabezados}"
                )

            registros = []
            for numero_fila, fila in enumerate(filas, start=2):
                fila = list(fila[:len(columnas)])
                if not fila or all(valor is None or valor == "" for valor in fila):
                    continue
                if len(fila) != len(columnas):
                    raise ValueError(f"{hoja}, fila {numero_fila}: número de columnas incorrecto.")
                registros.append(tuple(None if valor == "" else valor for valor in fila))

            if len(registros) < 200:
                raise ValueError(
                    f"La hoja {hoja} contiene {len(registros)} registros; "
                    "se esperaban al menos 200 para esta práctica."
                )
            datos.append((tabla, columnas, registros))
    finally:
        libro.close()
    return datos

def copiar_tabla(cur, tabla: str, columnas: list[str], filas):
    temporal = f"stg_{tabla}"
    cur.execute(
        sql.SQL("CREATE TEMP TABLE {} (LIKE public.{} INCLUDING DEFAULTS) ON COMMIT DROP")
        .format(sql.Identifier(temporal), sql.Identifier(tabla))
    )

    buffer = StringIO()
    escritor = csv.writer(buffer, lineterminator="\n")
    escritor.writerows(filas)
    buffer.seek(0)

    columnas_sql = sql.SQL(", ").join(sql.Identifier(c) for c in columnas)
    copy_stmt = sql.SQL(
        "COPY {} ({}) FROM STDIN WITH (FORMAT CSV, NULL '')"
    ).format(sql.Identifier(temporal), columnas_sql)
    cur.copy_expert(copy_stmt.as_string(cur), buffer)

    insert_stmt = sql.SQL(
        "INSERT INTO public.{} ({}) SELECT {} FROM {} ON CONFLICT DO NOTHING"
    ).format(
        sql.Identifier(tabla),
        columnas_sql,
        columnas_sql,
        sql.Identifier(temporal),
    )
    cur.execute(insert_stmt)
    insertadas = cur.rowcount
    return len(filas), insertadas, len(filas) - insertadas

def main() -> int:
    parser = argparse.ArgumentParser(description="Carga el Excel del proyecto propio.")
    parser.add_argument("--archivo", type=Path, default=DEFAULT_FILE,
                        help="Ruta al XLSX fuente (por defecto practica4/datos/base_datos_pedidos.xlsx).")
    args = parser.parse_args()

    conexion = None
    tabla_actual = "validación del archivo"
    try:
        datos = leer_excel(args.archivo)
        dsn = obtener_dsn()
        conexion = psycopg2.connect(dsn)
        conexion.autocommit = False

        resultados = []
        with conexion.cursor() as cur:
            for tabla, columnas, filas in datos:
                tabla_actual = tabla
                total, insertadas, existentes = copiar_tabla(cur, tabla, columnas, filas)
                resultados.append((tabla, total, insertadas, existentes))

        conexion.commit()
        print("Carga confirmada. Fuente:", args.archivo)
        print("| Tabla | Filas del Excel | Insertadas | Ya existentes | Rechazadas |")
        print("|---|---:|---:|---:|---:|")
        for tabla, total, insertadas, existentes in resultados:
            print(f"| {tabla} | {total} | {insertadas} | {existentes} | 0 |")
        print("Total de registros leídos:", sum(x[1] for x in resultados))
        print("La segunda ejecución debe mostrar los registros como ya existentes.")
        return 0

    except Exception as exc:
        if conexion is not None:
            conexion.rollback()
        print("ERROR: la carga completa fue revertida.", file=sys.stderr)
        print("Tabla/etapa:", tabla_actual, file=sys.stderr)
        print("Detalle:", exc, file=sys.stderr)
        if isinstance(exc, psycopg2.Error) and exc.diag is not None:
            if exc.diag.sqlstate:
                print("SQLSTATE:", exc.diag.sqlstate, file=sys.stderr)
            if exc.diag.constraint_name:
                print("Restricción:", exc.diag.constraint_name, file=sys.stderr)
            if exc.diag.message_detail:
                print("Detalle de PostgreSQL:", exc.diag.message_detail, file=sys.stderr)
        print("No se confirmó ninguna tabla; se ejecutó ROLLBACK.", file=sys.stderr)
        return 1
    finally:
        if conexion is not None:
            conexion.close()

if __name__ == "__main__":
    raise SystemExit(main())
