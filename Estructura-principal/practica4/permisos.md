# Ejercicio 1.6. Usuarios y permisos

## Roles

Se crean tres roles de grupo sin inicio de sesión y un usuario para cada uno:

- **rol_aplicacion / usuario_app:** la aplicación y el script de carga. Puede consultar, insertar, actualizar y borrar registros de las siete tablas del proyecto.
- **rol_consulta / usuario_consulta:** consultas de lectura; no puede insertar, actualizar ni borrar.
- **rol_administracion / usuario_admin:** administra las tablas del proyecto y puede crear objetos en el esquema public.

Las contraseñas se reciben como variables de psql desde el entorno local. No se guardan en SQL, Python, Compose ni en Git.

## Matriz de permisos

| Tabla | Aplicación | Consulta | Administración |
|---|---|---|---|
| cliente | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| transportista | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| producto | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| sucursal | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| pedido | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| detalle | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| envio | SELECT, INSERT, UPDATE, DELETE | SELECT | ALL |
| Esquema public | USAGE | USAGE | USAGE, CREATE |

La administración recibe la propiedad de las tablas del proyecto. La aplicación y consulta no reciben permiso para crear tablas ni modificar la estructura.

## Crear los usuarios

En PowerShell, define tres contraseñas distintas en la sesión actual:

\`\`\`powershell
$env:APP_DB_PASSWORD = "CLAVE_LOCAL_APP"
$env:CONSULTA_DB_PASSWORD = "CLAVE_LOCAL_CONSULTA"
$env:ADMIN_DB_PASSWORD = "CLAVE_LOCAL_ADMIN"
docker compose cp .\\practica4\\permisos.sql db:/tmp/permisos.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v APP_DB_PASSWORD="$env:APP_DB_PASSWORD" -v CONSULTA_DB_PASSWORD="$env:CONSULTA_DB_PASSWORD" -v ADMIN_DB_PASSWORD="$env:ADMIN_DB_PASSWORD" -f /tmp/permisos.sql
\`\`\`

Después de crear los usuarios, el script de carga debe conectarse con usuario_app, por medio de DATABASE_URL:

\`\`\`powershell
$env:DATABASE_URL = "postgresql://usuario_app:$env:APP_DB_PASSWORD@localhost:5434/ventas_industriales"
py .\\practica4\\poblar\\poblar.py
\`\`\`

## Pruebas

El archivo pruebas-permisos.sql ejecuta operaciones permitidas y negadas para los tres usuarios. También retira temporalmente INSERT de rol_aplicacion, comprueba que el gestor lo rechaza y vuelve a otorgarlo para no dejar inutilizado el script de carga.

\`\`\`powershell
docker compose cp .\\practica4\\pruebas-permisos.sql db:/tmp/pruebas-permisos.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -f /tmp/pruebas-permisos.sql
\`\`\`

Los mensajes de permiso denegado son resultados esperados en las pruebas negativas. Deben conservarse en la captura de terminal. La evidencia todavía requiere ejecución local.
