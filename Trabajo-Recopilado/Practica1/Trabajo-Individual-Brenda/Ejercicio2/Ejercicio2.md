# EL SISTEMA GESTOR EN UN CONTENEDOR: Docker

## CONTENEDOR VS MÁQUINA VIRTUAL

Los contenedores virtualizan el sistema operativo para que la aplicación se pueda ejecutar de forma independiente en cualquier plataforma. Las máquinas virtuales van más allá y virtualizan máquinas físicas para que pueda usar los recursos de hardware de manera eficaz.

### Arranque
Los contenedores inician de forma casi instantánea al compartir el kernel del sistema operativo anfitrión, mientras que las máquinas virtuales tienen un arranque más lento debido a la necesidad de cargar un sistema operativo huésped completo.

### Tamaño
Los archivos de imagen de las máquinas virtuales tienen un mayor tamaño (varios GB), ya que contienen su propio sistema operativo. Los archivos de contenedor son más ligeros y se pueden medir en MB. En los contenedores solo se empaquetan los recursos necesarios para ejecutar una única aplicación.

### Aislamiento
En aislamiento, los contenedores aprovechan el kernel del sistema operativo anfitrión para segmentar la ejecución de los procesos en entornos aislados. Por el contrario, las máquinas virtuales utilizan un hipervisor para virtualizar hardware completo, lo que permite a cada VM ejecutar su propio sistema operativo dedicado e independiente de las demás.

---

## DEFINICIONES

### Imagen
Una imagen de contenedor es un archivo que empaqueta todo lo necesario para ejecutar una aplicación: código, librerías y configuraciones del sistema. Gracias a su portabilidad, las imágenes en entornos como Docker se pueden compartir y utlizar en diferentes ubicaiones.

### Contenedor
Es una instancia ejecutable y aislada de una imagen. Funciona como un paquete ligero que ejecuta la aplicación compartiendo el kernel del sistema operativo base.

### Volumen
Los volúmenes son el mecanismo para guardar información generada y usada por el contenedor. Permite guardar, compartir y conservar los datos creados o modificados por la aplicación, incluso si el contenedor se destruye o se reinicia.

### Puerto publicado
La publicación de puertos es la creación de un mapeo entre un puerto de la máquina anfitriona y un puerto dentro del contenedor. Al publicar un puerto, se configura la red del host para reenviar el tráfico del puerto del host especificado al puerto del contenedor correspondiente.

---

## IMPORTANCIA DEL VOLUMEN

La creación de un volumen es fundamental, ya que el almacenamiento predeterminado de un contenedor es efímero. Sin un volumen, los datos generados sólo existen mientras el contenedor permanece activo.

Si no se declara un volumen, al eliminar el contenedor se perderán de forma irreversible todos sus datos. Asimismo, al actualizar la imagen de la aplicación (lo que exige destruir el contenedor actual para desplegar uno nuevo) la información acumulada no se conservará. Adicionalmente, escribir datos directamente en la capa de almacenamiento del contenedor impacta negativamente el rendimiento y genera un consumo ineficiente del sistema de archivos.

---

## LEVANTAR SGBD CON DOCKER

- Creación del contenedor en Docker.
- Creación del contenedor `pg-practica1`.
- Eliminación del contenedor `pg-practica1`.
- Creación nuevamente del contenedor sin pérdida de volumen `pg-practica1`.

Las capturas de terminal correspondientes a este proceso se encuentran anexadas en la carpeta Evidencias 

- Conexión al SGBD con pgAdmin.
- Conexión cuando el contenedor es eliminado.

Las capturas de pantalla de la interfaz de pgAdmin correspondientes a este proceso se encuentran anexadas en la carpeta Evidencias

- Conexión cuando el contenedor es restablecido.

Las capturas de pantalla del estado restablecido se encuentran anexadas en la carpeta Evidencias 

---

## REFERENCIAS

- Atlassian. (s. f.). *Contenedores frente a máquinas virtuales*. https://www.atlassian.com/es/microservices/cloud-computing/containers-vs-vms
- Amazon Web Services. (s. f.-a). *¿Cuál es la diferencia entre los contenedores y las máquinas virtuales?* https://aws.amazon.com/es/compare/the-difference-between-containers-and-virtual-machines/#amsc4--1yxm2ah
- Amazon Web Services. (s. f.-b). *¿Cuál es la diferencia entre las imágenes de Docker y los contenedores?* https://aws.amazon.com/es/compare/the-difference-between-docker-images-and-containers/
- DataCamp. (s. f.). *Cómo exponer un puerto Docker*. https://www.datacamp.com/es/tutorial/how-to-expose-a-docker-port
- Docker Docs. (s. f.-a). *Container images*. Kubernetes. https://kubernetes.io/docs/concepts/containers/images/
- Docker Docs. (s. f.-b). *Publishing ports*. https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/
- Docker Docs. (s. f.-c). *Volumes*. https://docs.docker.com/engine/storage/volumes/
- Docker Docs. (s. f.-d). *What is a container?* https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/
- Docker Docs. (s. f.-e). *What is an image?* https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/
- Google Cloud. (s. f.). *Contenedores en comparación con máquinas virtuales*. https://cloud.google.com/discover/containers-vs-vms?hl=es-419
- IBM. (2024a, 20 de agosto). *Imágenes de contenedores*. https://www.ibm.com/mx-es/think/topics/container-images
- IBM. (2024b, 21 de agosto). *Contenedores frente a máquinas virtuales (VM)*. https://www.ibm.com/mx-es/think/topics/containers-vs-vms
- Nubity. (2022, 11 de agosto). *Guía rápida para empezar a usar Docker*. https://nubity.com/guia-rapida-para-empezar-a-usar-docker/