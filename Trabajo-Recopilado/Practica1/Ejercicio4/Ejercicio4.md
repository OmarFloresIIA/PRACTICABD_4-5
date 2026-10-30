# Ejercicio 4. Estado del arte: tres artículos científicos

## Fichas Bibliográficas

### Artículo 1: Arquitectura de SGBD + Inteligencia Artificial / Aprendizaje Automático

1. **Cita APA (7ª ed.) con DOI:**
   Kraska, T., Beutel, A., Chi, E. H., Naughton, J., & Polyzotis, N. (2018). The case for learned index structures. En *Proceedings of the 2018 International Conference on Management of Data (SIGMOD '18)* (pp. 489–504). Association for Computing Machinery. https://doi.org/10.1145/3183713.3196909

2. **Problema que aborda:**
   El artículo surge de la necesidad de mejorar los métodos de indexación en bases de datos robustas para aplicaciones de Machine Learning. Los índices tradicionales como B-trees o tablas hash cumplen su función, pero empiezan a mostrar limitaciones cuando los volúmenes de datos crecen de manera masiva y las consultas requieren mayor velocidad. El problema central es cómo acceder más rápido a la información sin que el costo en memoria o en tiempo de búsqueda se dispare.

3. **Método o propuesta de los autores:**
   La propuesta es replantear los índices como modelos predictivos. En lugar de estructuras rígidas, se utilizan funciones aprendidas que predicen la posición de un dato en memoria. Es como tener un Porsche en calles amplias: si los datos siguen un patrón claro, el modelo puede acelerar al máximo y ubicar rápidamente la información. Pero cuando las “calles” son estrechas (datos irregulares o distribuciones caóticas), el Porsche no puede correr igual de rápido sin riesgo de errores.
   La solución que sugieren los autores es un enfoque híbrido: combinar lo mejor de ambos mundos. Sería como usar un coche compacto o incluso una moto, que puede moverse rápido tanto en calles amplias como en estrechas, adaptándose mejor a diferentes escenarios de datos.

4. **Resultado principal que reportan:**
   El resultado más importante es demostrar que los índices aprendidos pueden superar a los tradicionales en espacio y velocidad, siempre que los datos tengan patrones aprovechables. En escenarios con distribuciones claras, los modelos predictivos logran búsquedas más rápidas y eficientes. Sin embargo, también reconocen que no son una solución universal: en datos caóticos, los métodos clásicos siguen siendo más robustos. Por eso, la aportación clave es abrir el camino hacia sistemas híbridos que combinen modelos de ML con estructuras tradicionales, redefiniendo cómo pensamos la indexación en bases de datos modernas.

5. **Relación explícita con la Unidad I:**
   Se relaciona directamente con **1.3.3 Módulos componentes de un SGBD**, ya que impacta al motor de almacenamiento y al gestor de índices, proponiendo nuevas formas de organizar y localizar los datos.
   También conecta con **1.1.1 Fundamentos de Bases de Datos**, porque replantea los principios básicos de cómo se estructuran internamente las bases, pasando de métodos rígidos a modelos predictivos que aprenden patrones en la información.

6. **Aporte para el proyecto del curso:**
   Aporta una visión moderna sobre cómo la optimización del almacenamiento y consultas puede aprovechar el comportamiento de los datos para superar las limitaciones de rendimiento de los índices convencionales en bases de datos robustas.

---

### Artículo 2: Arquitectura y Clasificación de SGBD Analíticos Modernos

1. **Cita APA (7ª ed.) con DOI:**
   Raasveldt, M., & Mühleisen, H. (2019). DuckDB: An embeddable analytical database. En *Proceedings of the 2019 International Conference on Management of Data (SIGMOD '19)* (pp. 1981–1984). Association for Computing Machinery. https://doi.org/10.1145/3299869.3320212

2. **Problema que aborda:**
   El artículo busca resolver la dificultad de realizar análisis de datos complejos sin depender de sistemas pesados y difíciles de configurar. Los motores tradicionales como PostgreSQL o Spark son muy potentes, pero requieren infraestructura robusta y no siempre son prácticos para tareas locales o académicas. El problema central es cómo ofrecer consultas analíticas rápidas y eficientes en un entorno ligero y fácil de integrar.

3. **Método o propuesta de los autores:**
   La propuesta es DuckDB, un motor de base de datos embebido que se integra directamente en las aplicaciones como una librería. Está optimizado para OLAP y utiliza técnicas como vectorized execution, que procesan bloques completos de datos en lugar de fila por fila, logrando mayor velocidad.
   Podriamos verlo como que los grandes SGBD distribuidos son como camiones pesados, ideales para transportar toneladas de datos en producción. DuckDB, en cambio, es como una moto ágil, que se mueve rápido y con facilidad en entornos más pequeños, perfecta para prácticas, proyectos locales o análisis inmediatos.

4. **Resultado principal que reportan:**
   Demostraron que una arquitectura embebida orientada a columnas puede ejecutar consultas analíticas complejas órdenes de magnitud más rápido que SQLite y con un consumo de recursos significativamente menor que los motores de base de datos tradicionales.

5. **Relación explícita con la Unidad I:**
   Este artículo se conecta directamente con **1.4 Clasificación de los SGBD**, ya que DuckDB representa un ejemplo de arquitectura embebida, en contraste con los sistemas cliente-servidor tradicionales. También se relaciona con **1.2 Tipos de bases de datos**, al mostrar cómo los motores orientados a OLAP (procesamiento analítico, columnas) difieren de los orientados a OLTP (procesamiento transaccional, filas). En conjunto, el documento ayuda a entender cómo la clasificación y los tipos de bases de datos influyen en su diseño y aplicación práctica.

6. **Aporte para el proyecto del curso:**
   Proporciona un marco técnico claro para entender cuándo elegir un motor embebido frente a un servidor dedicado (como PostgreSQL en Docker), evaluando el impacto de la arquitectura interna en el tiempo de procesamiento de datos.

---

### Artículo 3: Arquitectura Interna del SGBD y Sistemas Operativos

1. **Cita APA (7ª ed.) con DOI:**
   Suresh, L., Yu, X., Zaharia, M., & Stonebraker, M. (2023). DBOS: A database-oriented operating system. *Proceedings of the VLDB Endowment*, 16(11), 3085–3097. https://doi.org/10.14778/3611540.3611560

2. **Problema que aborda:**
   El artículo busca resolver la dificultad de que un mismo sistema de base de datos pueda funcionar de manera eficiente tanto en modo individual (stand-alone) como en modo distribuido (cluster). En OceanBase, cuando se usaba en un solo servidor, los componentes distribuidos generaban sobrecarga innecesaria. El problema central es cómo lograr que un motor de base de datos sea flexible y adaptable, capaz de servir a pequeñas empresas con un solo servidor y, al mismo tiempo, escalar hacia grandes organizaciones con clusters distribuidos.

3. **Método o propuesta de los autores:**
   La propuesta es Paetica, una arquitectura híbrida que combina lo mejor de los enfoques Shared-Nothing (cada nodo independiente) y Shared-Everything (recursos compartidos). Paetica permite configurar el sistema de manera adaptativa:

   * En modo individual, elimina la sobrecarga de los componentes distribuidos.

   * En modo cluster, habilita ejecución paralela y escalabilidad.

   Podemos imaginarlo como un coche híbrido, OceanBase antes era como un camión pesado diseñado solo para grandes cargas (grandes empresas). Con Paetica, ahora puede transformarse en un coche compacto para moverse ágilmente en escenarios pequeños, y luego crecer de nuevo a un camión cuando la empresa lo requiera, sin necesidad de cambiar de vehículo.

4. **Resultado principal que reportan:**
   El resultado clave es que OceanBase con Paetica logra escalabilidad lineal en modo individual (aprovechando más núcleos de CPU) y supera a sistemas como MySQL y Greenplum en pruebas de rendimiento (Sysbench y TPC-H). Además, permite que una misma base de datos acompañe a una empresa desde sus primeras etapas hasta su crecimiento, sin necesidad de migrar a otro sistema. En otras palabras, OceanBase se convierte en una solución flexible que atiende tanto a pequeñas como a grandes organizaciones, adaptándose a sus necesidades con un solo motor.

5. **Relación explícita con la Unidad I:**
   Este artículo se relaciona con 1.1.2 Arquitectura ANSI-SPARC, porque extiende el principio de abstracción e independencia de datos más allá de las capas internas del SGBD, llevándolo hasta el nivel del sistema operativo.
   También conecta con **1.3 Arquitectura de tres esquemas de un SGBD**, ya que refuerza la separación entre los niveles externo, conceptual e interno, mostrando cómo la independencia de datos puede aplicarse de manera más amplia para mejorar la flexibilidad y el rendimiento del sistema.

6. **Aporte para el proyecto del curso:**
   Ayuda a comprender el alcance y la relevancia que tiene el motor transaccional del SGBD en el ecosistema de software actual, permitiendo argumentar la importancia de la integridad ACID y los modelos relacionales en arquitecturas de alto nivel.

---

## CIERRE

Después de analizar los tres artículos, llegamos a la conclusión de que todos comparten una misma premisa: los Sistemas Gestores de Bases de Datos tradicionales ya no son suficientes para los retos actuales de la nube, el análisis masivo y el procesamiento distribuido. Lo que antes era un diseño rígido ahora necesita ser flexible, adaptativo y capaz de integrar nuevas tecnologías como el aprendizaje automático.

Cada propuesta aborda el problema desde un ángulo distinto:

* Kraska et al. (2018) se enfocan en la microarquitectura interna, reemplazando algoritmos clásicos de índices por modelos predictivos. Es como cambiar el motor de un coche por uno más inteligente que aprende la ruta.

* Raasveldt & Mühleisen (2019) replantean la arquitectura de ejecución, eliminando el esquema cliente-servidor y ofreciendo un motor embebido para análisis local. Aquí la analogía es clara: en vez de depender de un camión pesado, nos dan una moto ágil que se mueve rápido en prácticas y proyectos pequeños.

* Suresh et al. (2023) llevan la discusión a la macroescala, convirtiendo al SGBD en el núcleo de un sistema operativo. Es como transformar el coche en toda la carretera: el gestor ya no es solo un componente, sino la base sobre la que corre todo el sistema.

Lo que nos queda claro es que no existe una única solución universal. Cada enfoque responde a un nivel distinto de abstracción y necesidad. En nuestra interpretación, el futuro de los SGBD será híbrido: habrá momentos en que necesitemos la potencia de un camión (clusters distribuidos), otros en que baste con la rapidez de una moto (bases embebidas), y quizá incluso escenarios donde el gestor se convierta en la infraestructura completa (como un sistema operativo).

Finalmente, identificamos un problema abierto: cómo mantener las propiedades ACID (consistencia, aislamiento, recuperabilidad) en tiempo real cuando se integran algoritmos adaptativos basados en aprendizaje automático. Resolverlo será clave para que estas propuestas no solo sean innovadoras, sino también confiables en entornos de producción altamente dinámicos.