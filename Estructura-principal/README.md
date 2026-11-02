# Prácticas 4 y 5 — Proyecto propio y proyecto asignado

## Integrantes
- Brenda Roa Venegas
- Omar Flores Olivares

Grupo: 3BV1. Gestor del proyecto propio: PostgreSQL 17.

## Proyecto propio

El proyecto representa las ventas y los envíos de tres líneas industriales: OMNIGOLD, HYVOLT y HYPRENE. La población principal se encuentra en el Excel sintético base_datos_pedidos2.xlsx. El equipo adaptó la estructura de referencia de una base privada, explicó el modelo y sus reglas a Claude (Anthropic), y Claude colaboró en la generación aleatoria y controlada de los registros.

El Excel contiene 80 clientes, 30 transportistas, 40 productos, 100 sucursales, 500 pedidos, 1,500 detalles y 452 envíos (2,702 registros en total). Todos los registros son sintéticos; no son ventas reales ni datos de la empresa privada. La procedencia, correspondencia de campos y calidad se documentan en practica4/fuente.md.

### Preparar el entorno (Windows / PowerShell)

1. Entra a esta carpeta, Estructura-principal.
2. Copia .env.example como .env y cambia la contraseña del administrador local.
3. Inicia PostgreSQL:

    Copy-Item .env.example .env
    # Edita .env y cambia POSTGRES_PASSWORD
    docker compose up -d

El esquema base se crea al inicializar el volumen por primera vez. Si ya existía un volumen y necesitas reiniciar desde cero, ten presente que docker compose down -v elimina los datos locales de ese volumen.

### Colocar el archivo fuente

Copia el archivo recibido base_datos_pedidos2.xlsx en:

    practica4/datos/base_datos_pedidos2.xlsx

La carpeta practica4/datos/README.md explica las hojas y cantidades que espera el programa. El archivo binario debe agregarse a esa carpeta antes de ejecutar la carga; no se debe sustituir por una generación aleatoria distinta.

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
    py .\practica4\poblar\poblar.py
    py .\practica4\poblar\comparar-copy-insert.py

El primer comando carga las siete hojas en orden de dependencia usando COPY hacia tablas temporales y una transacción completa. El segundo comando comprueba la repetibilidad: las claves ya existentes se reportan como registros existentes, sin duplicarlos. El cargador valida los conteos de esta versión del Excel (80, 30, 40, 100, 500, 1,500 y 452) antes de conectarse a la base. Usa DATABASE_URL con usuario_app, no con el administrador. Si una restricción rechaza una fila, ejecuta ROLLBACK para no dejar una carga parcial.

El programa de comparación mide INSERT individual y COPY con los 1,500 renglones de detalle de la misma fuente. Los tiempos que se registran deben ser los de tu equipo; no se incluyen tiempos inventados.

### Ejecutar pruebas

    docker compose cp .\practica4\pruebas-dominio.sql db:/tmp/pruebas-dominio.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-dominio.sql

    docker compose cp .\practica5\pruebas-referenciales.sql db:/tmp/pruebas-referenciales.sql
    docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-referenciales.sql

Las pruebas usan transacciones y ROLLBACK para conservar la fuente sin cambios. Sigue los archivos MD para interpretar cada caso y guardar la salida real del gestor.

## Archivos principales

- esquema.sql: esquema relacional base de la Práctica 3.
- practica4/dominios.md: tipos, longitudes y restricciones.
- practica4/fuente.md: procedencia, colaboración de Claude, correspondencia y calidad del Excel.
- practica4/datos/: ubicación del archivo fuente.
- practica4/migraciones/001-dominios.sql: dominios y restricciones del proyecto propio.
- practica4/poblar/poblar.py: carga del Excel mediante COPY.
- practica4/poblar/comparar-copy-insert.py: benchmark de los 1,500 detalles.
- practica4/pruebas-dominio.md y .sql: once casos de restricciones.
- practica4/permisos.md y .sql: roles y privilegios.
- practica5/migraciones/002-referencias.sql: FK compuesta envío/pedido/cliente.
- practica5/referencias.md: relación y acción referencial por cada FK.
- practica5/pruebas-referenciales.md y .sql: integridad referencial.
- practica5/edicion-de-valores.md y sql/edicion-de-valores.sql: DML y transacciones.
- practica4/proyecto-asignado/ y practica5/integridad-almacen.md: proyecto asignado de obra pública municipal.
- evidencias/: capturas auténticas pendientes de obtener en el entorno local.

## Proyecto asignado

El proyecto asignado es Obra Pública Municipal. Su carga y análisis se mantienen separados: el Excel de pedidos no contiene datos de obras públicas. La documentación correspondiente permanece en practica4/proyecto-asignado/ y practica5/integridad-almacen.md.

## Evidencia y estado

Los archivos SQL y Python están preparados para ejecutarse. La carga real en PostgreSQL, la segunda ejecución, los tiempos INSERT/COPY, las capturas, la revisión del Pull Request y su fusión deben obtenerse/realizarse en el entorno del equipo. No se registran como ejecutados pasos que todavía no se han comprobado.
