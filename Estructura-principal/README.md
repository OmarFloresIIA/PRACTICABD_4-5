# Prácticas 4 y 5 — Guía de instalación y ejecución

Este directorio reúne el trabajo de las prácticas 4 y 5 de Bases de Datos. Hay dos proyectos independientes:

1. **Proyecto propio:** ventas y envíos de productos industriales.
2. **Proyecto asignado:** Obra Pública Municipal, en otro repositorio y con otra base de datos.

Sigue primero la sección del proyecto propio. No mezcles sus datos con los del almacén de obras públicas.

## 1. Requisitos

Para trabajar en Windows necesitas:

- Docker Desktop instalado y abierto.
- Python instalado y disponible mediante el comando **py**.
- Git para descargar o actualizar los repositorios.
- El archivo Excel revisado **base_datos_pedidos2.xlsx**.

No necesitas instalar PostgreSQL directamente en Windows: Docker ejecuta el servidor de base de datos.

## 2. Proyecto propio: ventas industriales

### Paso 1. Abrir la carpeta de trabajo

Abre PowerShell en la carpeta raíz del repositorio PRACTICABD_4-5 y ejecuta:

~~~powershell
cd .\Estructura-principal
~~~

**Todos los comandos de esta sección se ejecutan desde Estructura-principal.** Si abres otra terminal, vuelve a entrar a esta carpeta.

### Paso 2. Colocar el archivo Excel

Copia el archivo recibido **base_datos_pedidos2.xlsx** dentro de esta ruta:

    practica4\datos\base_datos_pedidos2.xlsx

El cargador espera exactamente ese nombre y las siguientes cantidades:

| Hoja | Filas esperadas |
|---|---:|
| cliente | 80 |
| transportista | 30 |
| producto | 40 |
| sucursal | 100 |
| pedido | 500 |
| detalle | 1,500 |
| envio | 452 |
| **Total** | **2,702** |

Comprueba que el archivo exista en esa ubicación antes de continuar. Si no está, el programa de carga se detendrá con un error.

Los registros son sintéticos. El equipo modificó y abstrajo la estructura de referencia de una base privada, explicó el modelo a Claude (Anthropic) y Claude colaboró en la generación aleatoria y controlada de los registros. No se incluyen datos privados de la empresa original. La explicación completa está en practica4/fuente.md.

### Paso 3. Configurar PostgreSQL

Crea el archivo local .env a partir del ejemplo:

~~~powershell
Copy-Item .env.example .env
notepad .env
~~~

Dentro de .env, reemplaza el valor de POSTGRES_PASSWORD por una contraseña local que tú elijas. Guarda el archivo.

**No subas .env a GitHub ni compartas su contenido.** Está excluido mediante .gitignore.

### Paso 4. Iniciar el servidor de base de datos

Asegúrate de que Docker Desktop esté abierto. Desde Estructura-principal ejecuta:

~~~powershell
docker compose up -d
docker compose ps
~~~

El servicio de base de datos se llama db. Docker publica PostgreSQL en el puerto 5434 de tu computadora y crea la base ventas_industriales.

La primera vez que se crea el volumen, PostgreSQL ejecuta automáticamente esquema.sql y crea las siete tablas vacías. Comprueba que el servidor responda:

~~~powershell
docker compose exec db pg_isready -U postgres -d ventas_industriales
~~~

Debe aparecer un mensaje indicando que acepta conexiones.

**Importante sobre el volumen:** Docker conserva la base aunque detengas los contenedores. Si ya habías iniciado una base anterior, no vuelvas a aplicar el esquema manualmente. Las migraciones siguientes se ejecutan una sola vez sobre una base recién inicializada.

Para detener los contenedores sin borrar los datos:

~~~powershell
docker compose down
~~~

Solo si deseas borrar por completo la base local y empezar de cero, puedes eliminar también el volumen:

~~~powershell
docker compose down -v
~~~

Este último comando elimina los datos almacenados localmente. Úsalo únicamente si no necesitas conservarlos.

### Paso 5. Aplicar las migraciones

Las migraciones agregan dominios, restricciones y una relación referencial compuesta. Deben ejecutarse en este orden y una sola vez.

**Primera migración: dominios y restricciones**

~~~powershell
docker compose cp .\practica4\migraciones\001-dominios.sql db:/tmp/001-dominios.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/001-dominios.sql
~~~

**Segunda migración: integridad referencial**

~~~powershell
docker compose cp .\practica5\migraciones\002-referencias.sql db:/tmp/002-referencias.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/002-referencias.sql
~~~

Si PostgreSQL muestra un error, detente y revisa el mensaje antes de continuar. No ejecutes otra vez una migración que ya se aplicó correctamente: los archivos contienen instrucciones ALTER TABLE que no están diseñadas para repetirse.

### Paso 6. Crear los usuarios y permisos

La práctica utiliza tres usuarios: uno para cargar y modificar datos, uno de solo lectura y uno de administración de las tablas. Define tres contraseñas distintas en la sesión actual de PowerShell. Sustituye los textos de ejemplo por claves propias:

~~~powershell
$env:APP_DB_PASSWORD = "TU_CLAVE_PARA_USUARIO_APP"
$env:CONSULTA_DB_PASSWORD = "TU_CLAVE_PARA_USUARIO_CONSULTA"
$env:ADMIN_DB_PASSWORD = "TU_CLAVE_PARA_USUARIO_ADMIN"
~~~

Copia y ejecuta el script de permisos:

~~~powershell
docker compose cp .\practica4\permisos.sql db:/tmp/permisos.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v "APP_DB_PASSWORD=$env:APP_DB_PASSWORD" -v "CONSULTA_DB_PASSWORD=$env:CONSULTA_DB_PASSWORD" -v "ADMIN_DB_PASSWORD=$env:ADMIN_DB_PASSWORD" -f /tmp/permisos.sql
~~~

El script crea estos usuarios:

| Usuario | Función |
|---|---|
| usuario_app | Leer, insertar, actualizar y borrar registros. Es el usuario que utiliza el cargador. |
| usuario_consulta | Consultar las tablas, sin modificar información. |
| usuario_admin | Administrar las tablas y crear objetos en el esquema public, sin ser superusuario ni poder crear otros roles. |

La matriz completa está en practica4/permisos.md. Las contraseñas no se escriben en los archivos SQL ni en el repositorio.

### Paso 7. Preparar Python

En la misma ventana de PowerShell, crea y activa un entorno virtual e instala las dependencias:

~~~powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install --upgrade pip
py -m pip install -r .\practica4\poblar\requirements.txt
~~~

Si PowerShell impide activar el entorno virtual, puedes instalar las dependencias mediante la ruta del entorno:

~~~powershell
.\.venv\Scripts\python.exe -m pip install -r .\practica4\poblar\requirements.txt
~~~

### Paso 8. Configurar la conexión del cargador

El cargador utiliza por defecto el usuario usuario_app, la base ventas_industriales, el servidor localhost y el puerto 5434.

En la misma sesión de PowerShell donde definiste las contraseñas, confirma que está definida la contraseña de la aplicación:

~~~powershell
$env:APP_DB_PASSWORD = "LA_MISMA_CLAVE_PARA_USUARIO_APP"
~~~

Si anteriormente definiste una variable DATABASE_URL con otra conexión, elimínala para que el programa utilice APP_DB_PASSWORD:

~~~powershell
Remove-Item Env:DATABASE_URL -ErrorAction SilentlyContinue
~~~

No escribas la contraseña dentro de poblar.py ni en ningún archivo del repositorio.

### Paso 9. Cargar el Excel

Confirma que el archivo Excel está en practica4\datos y ejecuta:

~~~powershell
py .\practica4\poblar\poblar.py
~~~

El programa:

1. Comprueba que existan las siete hojas y que sus encabezados coincidan.
2. Comprueba que cada hoja tenga el número de filas esperado.
3. Carga primero las tablas padre y después las tablas que dependen de ellas.
4. Utiliza COPY mediante tablas temporales para realizar la carga masiva.
5. Inserta los datos definitivos dentro de una sola transacción.
6. Informa cuántos registros leyó, insertó y encontró ya existentes.

Si una fila incumple una restricción, el programa ejecuta ROLLBACK y no deja una carga parcial.

**Comprueba que la carga sea repetible:** ejecuta el mismo comando por segunda vez:

~~~powershell
py .\practica4\poblar\poblar.py
~~~

En esta segunda ejecución, las claves ya existentes deben aparecer como registros existentes y no deben duplicarse.

### Paso 10. Comparar INSERT contra COPY

Con el Excel y la conexión todavía disponibles, ejecuta:

~~~powershell
py .\practica4\poblar\comparar-copy-insert.py
~~~

El programa mide INSERT individual y COPY usando los mismos 1,500 renglones de la hoja detalle. Guarda los tiempos que muestre tu equipo: dependen del hardware y del entorno, por lo que no se incluyen valores inventados en los documentos.

### Paso 11. Ejecutar las pruebas de la Práctica 4

**Pruebas de dominio:**

~~~powershell
docker compose cp .\practica4\pruebas-dominio.sql db:/tmp/pruebas-dominio.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-dominio.sql
~~~

**Pruebas de permisos:**

~~~powershell
docker compose cp .\practica4\pruebas-permisos.sql db:/tmp/pruebas-permisos.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -f /tmp/pruebas-permisos.sql
~~~

Las pruebas de permisos se ejecutan como postgres porque retiran y restauran temporalmente privilegios mediante REVOKE y GRANT. Los mensajes de permiso denegado forman parte de las pruebas negativas esperadas.

### Paso 12. Ejecutar las pruebas de la Práctica 5

**Integridad referencial:**

~~~powershell
docker compose cp .\practica5\pruebas-referenciales.sql db:/tmp/pruebas-referenciales.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -v ON_ERROR_STOP=1 -f /tmp/pruebas-referenciales.sql
~~~

**Operaciones DML y transacciones:**

~~~powershell
docker compose cp .\practica5\sql\edicion-de-valores.sql db:/tmp/edicion-de-valores.sql
docker compose exec -T db psql -U postgres -d ventas_industriales -f /tmp/edicion-de-valores.sql
~~~

El archivo DML contiene INSERT, UPDATE, DELETE, borrado lógico, SAVEPOINT, ROLLBACK y una transacción que falla por una clave foránea inexistente. Revisa practica5/edicion-de-valores.md para conocer qué resultado debe observarse.

Las pruebas contienen operaciones temporales y bloques de ROLLBACK para no mezclar los datos de demostración con la población original. Aun así, ejecútalas únicamente sobre la base local dedicada a la práctica.

## 3. Proyecto asignado: Obra Pública Municipal

Este proyecto utiliza **otra base de datos y otro repositorio**. No cargues el Excel de ventas industriales en el almacén de obras públicas.

Repositorio: https://github.com/OmarFloresIIA/PublicMunicipalWorks_DWH

### Paso 1. Descargar el repositorio asignado

Abre otra ventana de PowerShell y clona la rama de trabajo:

~~~powershell
git clone --branch practica4-5 https://github.com/OmarFloresIIA/PublicMunicipalWorks_DWH.git
cd .\PublicMunicipalWorks_DWH
~~~

### Paso 2. Configurar Docker

Copia el archivo de ejemplo y edítalo:

~~~powershell
Copy-Item .env.example .env
notepad .env
~~~

Define valores propios para POSTGRES_PASSWORD y SECRET_KEY. Guarda .env y no lo subas al repositorio.

### Paso 3. Iniciar la base y la API

~~~powershell
docker compose -f .\docker\compose.yml up -d --build
docker compose -f .\docker\compose.yml ps
~~~

Este Compose utiliza PostgreSQL 16, la base obras_publicas y el puerto local 55432. La API publica el puerto 5000.

### Paso 4. Verificar los datos que generará el script

Antes de cargar la información, ejecuta la verificación:

~~~powershell
docker compose -f .\docker\compose.yml run --rm --entrypoint sh seed -c "pip install --quiet faker && python generate_synthetic_data.py --verificar"
~~~

Esta opción comprueba las cifras previstas por el generador sin conectarse a PostgreSQL. No inserta filas en la base.

### Paso 5. Cargar los datos sintéticos

~~~powershell
docker compose -f .\docker\compose.yml --profile tools run --rm seed
~~~

El generador carga la población sintética dentro de una transacción. Limpia únicamente la población sintética que administra antes de volver a insertarla. Ejecuta este comando solo en la base local destinada a la práctica, nunca en una base con información real.

El script informa los conteos finales y compara INSERT con COPY. Registra los tiempos y conteos que realmente aparezcan en tu terminal.

La documentación de este proyecto está en:

- practica4/proyecto-asignado/fuente-y-datos.md
- practica4/proyecto-asignado/carga.md
- practica5/integridad-almacen.md

### Paso 6. Integridad referencial del almacén

El SQL para revisar hechos huérfanos está en practica5/sql/comprobar-integridad-almacen.sql. La migración de las tres restricciones para probar en una copia está en practica5/sql/002-restricciones-almacen.sql.

**No apliques las restricciones directamente sobre una base que quieras conservar:** el enunciado pide probarlas en una copia.

## 4. Evidencias que debes guardar

Guarda capturas auténticas en la carpeta evidencias. Cada captura debe mostrar el comando ejecutado y el resultado. Oculta contraseñas y cualquier dato sensible.

| Evidencia | Qué debe mostrar |
|---|---|
| 01 | PostgreSQL del proyecto propio levantado. |
| 02 | Ejecución correcta de las migraciones 001 y 002. |
| 03 | Primera carga del Excel y conteos insertados por tabla. |
| 04 | Segunda carga y registros existentes, sin duplicados. |
| 05 | Comparación real de INSERT y COPY. |
| 06 | Pruebas de dominio. |
| 07 | Pruebas de permisos, operaciones permitidas/negadas y REVOKE. |
| 08 | Pruebas de integridad referencial y conteos antes/después. |
| 09 | Operaciones DML y transacciones. |
| 10 | Verificación de la población del proyecto asignado. |
| 11 | Carga y conteos del proyecto asignado. |
| 12 | Comprobaciones de integridad del almacén y pruebas de restricciones en una copia. |
| 13 | Pull Request revisado y fusionado. |

El archivo evidencias/README.md contiene la lista de capturas sugeridas.

## 5. Orden recomendado de trabajo

1. Coloca el Excel revisado en practica4\datos.
2. Inicia Docker y crea la base del proyecto propio.
3. Ejecuta la migración 001 y luego la 002.
4. Crea los usuarios y permisos.
5. Instala las dependencias de Python.
6. Ejecuta la carga del Excel dos veces.
7. Ejecuta la comparación INSERT/COPY.
8. Ejecuta las pruebas de dominio, permisos, integridad y DML.
9. Trabaja en el repositorio separado de Obra Pública Municipal.
10. Guarda las capturas y solicita revisión del Pull Request.

## 6. Documentación por ejercicio

| Archivo | Contenido |
|---|---|
| practica4/dominios.md | Tipos de dato, longitudes, dominios y reglas. |
| practica4/fuente.md | Fuente, colaboración de Claude, correspondencia y calidad de datos. |
| practica4/pruebas-dominio.md | Casos de prueba de restricciones. |
| practica4/permisos.md | Usuarios, roles y matriz de privilegios. |
| practica4/proyecto-asignado/ | Fuente, conteos y carga de Obra Pública Municipal. |
| practica5/referencias.md | Claves foráneas y acciones referenciales. |
| practica5/pruebas-referenciales.md | Pruebas de integridad referencial. |
| practica5/edicion-de-valores.md | DML y transacciones. |
| practica5/integridad-almacen.md | Integridad referencial del almacén asignado. |
| evidencias/README.md | Capturas que se deben obtener. |

## 7. Problemas frecuentes

**Docker no responde:** abre Docker Desktop, espera a que indique que está iniciado y vuelve a ejecutar docker compose ps.

**El puerto 5434 está ocupado:** revisa qué aplicación utiliza ese puerto. Si cambias el puerto publicado en compose.yaml, actualiza también DB_PORT en la sesión de PowerShell para que Python se conecte al nuevo puerto.

**El cargador no encuentra el Excel:** confirma que estás dentro de Estructura-principal y que el archivo se llama exactamente base_datos_pedidos2.xlsx dentro de practica4\datos.

**El cargador indica un conteo distinto:** comprueba que estás utilizando la versión revisada del archivo. No edites EXPECTED_ROWS para ocultar una diferencia; revisa primero la fuente y actualiza fuente.md si realmente cambió.

**Una migración indica que una columna o restricción ya existe:** probablemente ya la ejecutaste. No la vuelvas a correr sobre la misma base. Revisa el estado de la base antes de continuar.

**La contraseña no funciona:** comprueba que las variables APP_DB_PASSWORD, CONSULTA_DB_PASSWORD y ADMIN_DB_PASSWORD siguen definidas en la sesión de PowerShell en la que estás trabajando. Las variables de entorno se pierden al cerrar esa terminal.

**Necesitas iniciar el proyecto propio desde cero:** recuerda que docker compose down -v borra el volumen y todos los datos locales de esa base. Úsalo solo cuando hayas decidido que puedes perderlos.

---

## Estado de ejecución

Los archivos y comandos de esta guía describen el procedimiento que debe seguir el equipo. La carga real, los tiempos de rendimiento, las salidas de PostgreSQL y las capturas solo deben marcarse como completados después de ejecutarlos y comprobarlos en el equipo local.
