#!/usr/bin/env python3
"""Compara INSERT por renglón contra COPY con 1,500 pedidos del XLSX fuente."""
from __future__ import annotations

import csv
import os
import time
from io import StringIO
from pathlib import Path

import psycopg2
from dotenv import load_dotenv
from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parents[2]
ARCHIVO = ROOT / "practica4" / "datos" / "base_datos_pedidos.xlsx"

def obtener_dsn():
    load_dotenv(ROOT / ".env")
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        raise RuntimeError("Define DATABASE_URL con usuario_app en .env o en la sesión.")
    return dsn

def leer_pedidos():
    if not ARCHIVO.is_file():
        raise FileNotFoundError(f"No se encontró el Excel: {ARCHIVO}")
    libro = load_workbook(ARCHIVO, read_only=True, data_only=True)
    try:
        ws = libro["pedido"]
        filas = list(ws.iter_rows(values_only=True))
        encabezados = list(filas[0])
        esperados = ["folio", "numeroCliente", "estatus", "dia", "mes", "anio", "activo"]
        if encabezados != esperados:
            raise ValueError(f"Encabezados inesperados en pedido: {encabezados}")
        datos = [tuple(None if v == "" else v for v in fila) for fila in filas[1:]
                 if any(v is not None and v != "" for v in fila)]
        if len(datos) < 200:
            raise ValueError("La hoja pedido tiene menos de 200 registros.")
        return datos
    finally:
        libro.close()

def main():
    filas = leer_pedidos()
    dsn = obtener_dsn()
    insert_sql = (
        "INSERT INTO bench_insert (folio, numerocliente, estatus, dia, mes, anio, activo) "
        "VALUES (%s, %s, %s, %s, %s, %s, %s)"
    )
    with psycopg2.connect(dsn) as conn:
        with conn.cursor() as cur:
            columnas = """(
                folio INTEGER,
                numerocliente INTEGER,
                estatus VARCHAR(20),
                dia SMALLINT,
                mes SMALLINT,
                anio SMALLINT,
                activo BOOLEAN
            )"""
            cur.execute("CREATE TEMP TABLE bench_insert " + columnas)
            cur.execute("CREATE TEMP TABLE bench_copy " + columnas)

            inicio = time.perf_counter()
            for fila in filas:
                cur.execute(insert_sql, fila)
            tiempo_insert = time.perf_counter() - inicio

            buffer = StringIO()
            escritor = csv.writer(buffer, lineterminator="\n")
            escritor.writerows(filas)
            buffer.seek(0)
            inicio = time.perf_counter()
            cur.copy_expert(
                "COPY bench_copy (folio, numerocliente, estatus, dia, mes, anio, activo) "
                "FROM STDIN WITH (FORMAT CSV, NULL '')",
                buffer
            )
            tiempo_copy = time.perf_counter() - inicio

            cur.execute("SELECT COUNT(*) FROM bench_insert")
            total_insert = cur.fetchone()[0]
            cur.execute("SELECT COUNT(*) FROM bench_copy")
            total_copy = cur.fetchone()[0]

    if total_insert != len(filas) or total_copy != len(filas):
        raise RuntimeError("Los dos métodos no cargaron el mismo número de filas.")

    print(f"Fuente: hoja pedido de {ARCHIVO.name}")
    print(f"Registros comparados: {len(filas)}")
    print(f"INSERT individual: {tiempo_insert:.6f} segundos ({total_insert} filas)")
    print(f"COPY:              {tiempo_copy:.6f} segundos ({total_copy} filas)")
    if tiempo_copy > 0:
        print(f"Relación INSERT/COPY: {tiempo_insert / tiempo_copy:.2f}x")
    if tiempo_insert > 0:
        print(f"Reducción de tiempo con COPY: {(1 - tiempo_copy / tiempo_insert) * 100:.2f}%")

if __name__ == "__main__":
    main()
