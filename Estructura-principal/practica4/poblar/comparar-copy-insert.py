"""Compara INSERT individual y COPY usando el mismo lote de prueba."""
import csv
import os
import time
from io import StringIO

import psycopg2

def main():
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        raise SystemExit("Define DATABASE_URL antes de ejecutar.")
    filas = [(i, f"Registro de prueba {i}") for i in range(1, 3001)]
    with psycopg2.connect(dsn) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TEMP TABLE comparacion_carga (
                    id integer PRIMARY KEY,
                    descripcion text NOT NULL
                ) ON COMMIT DROP
            """)
            inicio = time.perf_counter()
            for fila in filas:
                cur.execute(
                    "INSERT INTO comparacion_carga (id, descripcion) VALUES (%s, %s)",
                    fila
                )
            t_insert = time.perf_counter() - inicio

            cur.execute("TRUNCATE comparacion_carga")
            buffer = StringIO()
            writer = csv.writer(buffer, lineterminator="\n")
            writer.writerows(filas)
            buffer.seek(0)

            inicio = time.perf_counter()
            cur.copy_expert(
                "COPY comparacion_carga (id, descripcion) FROM STDIN WITH (FORMAT CSV)",
                buffer
            )
            t_copy = time.perf_counter() - inicio
            cur.execute("SELECT COUNT(*) FROM comparacion_carga")
            total = cur.fetchone()[0]

    print(f"Filas comprobadas: {total}")
    print(f"INSERT individual: {t_insert:.4f} segundos")
    print(f"COPY:              {t_copy:.4f} segundos")
    if t_copy:
        print(f"INSERT/COPY:       {t_insert / t_copy:.2f} veces")
    print("La tabla de comparación es temporal y no deja datos permanentes.")

if __name__ == "__main__":
    main()
