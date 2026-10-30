# Prácticas 4 y 5 — Proyecto propio y proyecto asignado

## Integrantes
- Brenda Roa Venegas
- Omar Flores Olivares

Grupo: 3BV1. Gestor del proyecto propio: PostgreSQL 17.

## Proyecto propio
El proyecto representa las ventas y los envíos de tres líneas de productos industriales: OMNIGOLD, HYVOLT y HYPRENE.

### Preparación del entorno (Windows / PowerShell)

1. Entra a esta carpeta (\`Estructura-principal\`).
2. Copia \`.env.example\` como \`.env\` y cambia la contraseña local.
3. Inicia PostgreSQL:

\`\`\`powershell
Copy-Item .env.example .env
# Edita .env y cambia POSTGRES_PASSWORD
docker compose up -d
\`\`\`

El esquema base se crea al inicializar el volumen por primera vez. Si ya existía un volumen anterior y necesitas recrearlo, ten presente que \`docker compose down -v\` elimina los datos locales de ese volumen.

### Aplicar dominios y restricciones

\`\`\`powershell
docker compose cp .\\practica4\\migraciones\\001-dominios.sql db:/tmp/001-dominios.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/001-dominios.sql
\`\`\`

### Instalar y ejecutar la carga

\`\`\`powershell
py -m venv .venv
.\\.venv\\Scripts\\Activate.ps1
pip install -r .\\practica4\\poblar\\requirements.txt
$env:DATABASE_URL = "postgresql://usuario_app:TU_CLAVE@localhost:5434/ventas_industriales"
py .\\practica4\\poblar\\poblar.py
\`\`\`

El usuario \`usuario_app\` se crea mediante el script de permisos. No se guardan contraseñas en los archivos del repositorio. La carga usa \`COPY\` hacia tablas temporales, inserta en orden de dependencia y confirma todo al final. Si una fila falla, la transacción completa se revierte. Al ejecutarla otra vez, las restricciones UNIQUE/PK y \`ON CONFLICT DO NOTHING\` evitan duplicados; el reporte muestra filas insertadas y ya existentes.

## Archivos de la práctica

- \`schema.sql\`: esquema relacional base recopilado de la Práctica 3.
- \`practica4/dominios.md\`: tipos de dato y reglas del dominio.
- \`practica4/fuente.md\`: búsqueda de datos públicos y justificación de datos sintéticos.
- \`practica4/migraciones/001-dominios.sql\`: restricciones adicionales.
- \`practica4/poblar/poblar.py\`: carga repetible con COPY.
- \`practica4/pruebas-dominio.md\` y \`practica4/pruebas-dominio.sql\`: pruebas de restricciones.
- \`practica4/permisos.md\` y \`practica4/permisos.sql\`: roles y privilegios.
- \`practica5/\`: claves foráneas, acciones referenciales, DML y transacciones.
- \`evidencias/\`: capturas auténticas de ejecución, pendientes de obtener en el equipo local.

## Proyecto asignado
El proyecto asignado es Obra Pública Municipal. La carga debe respetar el esquema del fork y los datos sintéticos declarados en el artículo. La documentación correspondiente está en \`practica4/proyecto-asignado/\` y \`practica5/integridad-almacen.md\`.

## Evidencia
Los archivos SQL y Python quedan preparados para ejecutarse, pero la salida real de PostgreSQL, las capturas y la revisión del Pull Request deben obtenerse en el entorno del equipo. No se registran como ejecutados pasos que todavía no se han comprobado.
