# Prácticas 4 y 5 — Proyecto propio y proyecto asignado

## Integrantes
- Brenda Roa Venegas
- Omar Flores Olivares

Grupo: 3BV1. Gestor del proyecto propio: PostgreSQL 17.

## Proyecto propio

El proyecto representa ventas y envíos de tres líneas industriales: OMNIGOLD, HYVOLT y HYPRENE. La población principal proviene del archivo sintético base_datos_pedidos.xlsx, elaborado a partir de una estructura relacional modificada y abstraída de una base privada. El equipo describió esa estructura a Claude (Anthropic), que colaboró en la generación aleatoria y estructurada de los registros.

Los registros del Excel son sintéticos; no son ventas reales ni deben presentarse como datos de la empresa privada. La documentación de procedencia, campos, nulos y calidad está en practica4/fuente.md.

### Preparar el entorno (Windows / PowerShell)

1. Entra a esta carpeta, Estructura-principal.
2. Copia .env.example como .env y cambia la contraseña del administrador local.
3. Inicia PostgreSQL:

    Copy-Item .env.example .env
    # Edita .env y cambia POSTGRES_PASSWORD
    docker compose up -d

El esquema base se crea al inicializar el volumen por primera vez. Si ya existía un volumen y necesitas reiniciar desde cero, ten presente que docker compose down -v elimina los datos locales de ese volumen.

### Colocar el archivo fuente

Copia el archivo base_datos_pedidos.xlsx en:

    practica4/datos/base_datos_pedidos.xlsx

El archivo se puede obtener del chat donde se entregó. La carpeta practica4/datos/README.md explica las hojas que espera el programa. El binario no se incluye en este commit y no se debe sustituir por una generación aleatoria distinta.

### Aplicar dominios y restricciones

    docker compose cp .\practica4\migraciones\001-dominios.sql db:/tmp/001-dominios.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/001-dominios.sql

### Aplicar integridad referencial compuesta

    docker compose cp .\practica5\migraciones\002-referencias.sql db:/tmp/002-referencias.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/002-referencias.sql

### Crear roles y usuarios

Sigue practica4/permisos.md. El usuario de carga es usuario_app. Las contraseñas se definen en el entorno local y no se guardan en SQL, Python, Compose ni Git.

### Instalar y ejecutar la carga

    py -m venv .venv
    .\.venv\Scripts\Activate.ps1
    pip install -r .\practica4\poblar\requirements.txt
    $env:DATABASE_URL = "postgresql://usuario_app:TU_CLAVE@localhost:5434/ventas_industriales"
    py .\practica4\poblar\poblar.py
    py .\practica4\poblar\comparar-copy-insert.py

El script lee las siete hojas relacionales, valida encabezados y carga las tablas en orden de dependencia mediante COPY. Usa DATABASE_URL con el rol usuario_app, no con el administrador. La transacción es de todo o nada: si una fila incumple una restricción, se ejecuta ROLLBACK. El programa informa filas leídas, insertadas y ya existentes; una segunda ejecución no duplica registros. La comparación INSERT/COPY mide los 1,500 pedidos de la misma fuente y reporta los tiempos reales de tu equipo.

### Ejecutar pruebas

    docker compose cp .\practica4\pruebas-dominio.sql db:/tmp/pruebas-dominio.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-dominio.sql

    docker compose cp .\practica5\pruebas-referenciales.sql db:/tmp/pruebas-referenciales.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-referenciales.sql

Las pruebas usan transacciones y ROLLBACK para conservar la fuente sin cambios. Sigue los archivos MD para interpretar cada caso y capturar la salida real del gestor.

## Archivos principales

- esquema.sql: esquema relacional base de la Práctica 3.
- practica4/dominios.md: tipos, longitudes y restricciones.
- practica4/fuente.md: procedencia, correspondencia y calidad del Excel sintético.
- practica4/datos/: ubicación local del archivo fuente.
- practica4/migraciones/001-dominios.sql: dominios y restricciones del proyecto propio.
- practica4/poblar/poblar.py: carga desde Excel mediante COPY.
- practica4/poblar/comparar-copy-insert.py: benchmark de los 1,500 pedidos.
- practica4/pruebas-dominio.md y .sql: casos de restricciones.
- practica4/permisos.md y .sql: roles y privilegios.
- practica5/migraciones/002-referencias.sql: FK compuesta envío/pedido/cliente.
- practica5/referencias.md: relación y acción referencial por cada FK.
- practica5/pruebas-referenciales.md y .sql: integridad referencial.
- practica5/edicion-de-valores.md y sql/edicion-de-valores.sql: DML y transacciones.
- practica4/proyecto-asignado/ y practica5/integridad-almacen.md: proyecto asignado de obra pública municipal.
- evidencias/: capturas auténticas pendientes de obtener en el entorno local.

## Proyecto asignado

El proyecto asignado es Obra Pública Municipal. Su carga y análisis se mantienen separados del proyecto propio porque el Excel de pedidos no contiene datos de obras públicas. La documentación correspondiente permanece en practica4/proyecto-asignado/ y practica5/integridad-almacen.md.

## Evidencia y estado

Los archivos SQL y Python quedan preparados para ejecutarse, pero la salida real de PostgreSQL, las capturas y la revisión/fusión del Pull Request deben obtenerse en el entorno del equipo. No se registran como ejecutados pasos que todavía no se han comprobado.
