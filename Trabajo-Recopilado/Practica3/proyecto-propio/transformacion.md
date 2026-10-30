# Transformacion de Relaciones 

## Relaciones UNO a MUCHOS 

"Regla 4. Relaciones uno a muchos. La clave primaria del lado uno se propaga como clave foránea a la tabla
del lado muchos. Si la cardinalidad mínima del lado muchos es 1, la clave foránea es NOT NULL; si es 0, admite
nulos."

+ PRODUCTO (1:1) -aparece-  DETALLE (0:N) 

|       | **Detalle**            |   
|-------|-------------------|
| PK    | folio    |  
| PK      | claveParcial  |  
| FK    | claveProducto | 

---

+ PEDIDO (1:1) -registra-  DETALLE (1:N)

|       | **Pedido**            |   
|-------|-------------------|
| PK    | folio   |  
| FK      | numeroCliente |  
|       | estatus| 
| | dia
| | mes
| | año

---

+ CLIENTE (1:1) -realiza- PEDIDO (0:N)


--- 

+ CLIENTE (1:1) -tiene- SUCURSAL (1:N)




## Relaciones de ORDEN SUPERIOR

"Regla 7. Relaciones de orden superior. Las relaciones ternarias o mayores se transforman en una tabla propia
que incluye las claves primarias de todas las entidades participantes, más los atributos propios de la relación."

+ sucursal (0:N) - transportista (0:N) - pedido (0:1)


|       | **Envio**               |
|-------|-------------------|
| PK    | numeroGuia      |
| FK1,UK| folio   |  
| FK2   | claveTransportista  |
|FK3| numeroCliente
||costoFlete
||dia
||mes
||año

## Entidades DEBILES 

"Regla 8. Entidades débiles. Si la dependencia es de identificación, la tabla resultante lleva una clave primaria
compuesta por la clave foránea de la entidad propietaria más el discriminador; la clave foránea es NOT NULL y
normalmente con ON DELETE CASCADE. Si la dependencia es solo de existencia, la tabla conserva su propia
clave primaria y agrega la clave foránea como NOT NULL."

+ La entidad debil DETALLE tiene dependencia por identificacion y existencia con PEDIDO

|       | **Detalle**            |   
|-------|-------------------|
| PK    | folio    |  
| PK      | claveParcial  |  
| FK    | claveProducto | 
| | costoProduccion
| | precioAplicado
| | cantidad

+ La entidad debil SUCURSAL tiene dependencia de identificacion con CLIENTE 

|       | **Sucursal**            |  
|-------|-------------------|
| PK, FK   | numeroCliente     |  
| PK      | claveSucursal  |  
|       | nombrePlanta| 
| |telefonoEncargado|
| |CP|
| | calle
| |pais|
|| estado
||numero
||ciudad

---

## JERARQUIAS

| Estrategia | Ventaja | Desventaja | Cuanto conviene|
|------------|---------| -----------|----------------|
|A. Tabla por supertipo y por subtipo| Sin redundancia ni valores nulos | Requiere combinaciones para consultar todo | Subtipos con muchos atributos propios |
| B. Tabla única con discriminador| Consultas simples y rápidas | Muchos valores nulos | Muchos valores nulos|
| C. Tabla por subtipo, sin supertipo | No requiere combinaciones | Repite los atributos comunes | Especialización total y disjunta | 



---

+ Se hizo una especialización disjunta y total de la entidad PRODUCTO
    
    De acuerdo a las estrategias de transformacion para Jerarquias, el mejor caso para PRODUCTO al tener subtipos con pocos atributos, fue hacer una sola tabla con discriminador. 

| **Producto**            | |
|-------|-------------------|
| PK    | claveProducto     |
|       | tipoProducto (discriminador: OMNIGOLD, HYVOLT o HYPRENE)|
|       | costoUnitarioUSD  |
|       | precioUnitarioUSD |
| | provMaquinaria (solo Omnigold)
| | provTransformador (solo Hyvolt)
| | provTransporte (solo Hyprene)

Se agrega la columna *tipoProducto* con el discriminador dependiendo de los tres tipos de productos posibles.



+ Se hizo una especialización solapada y total de la entidad TRANSPORTISTA 

     De acuerdo a las estrategias de transformacion para Jerarquias, el mejor caso para TRANSPORTISTA, fue hacer una sola tabla con discriminador. 

|       | **Transportista**            |   
|-------|-------------------|
| PK    | claveTransportista    |  
|       | nombreEmpresa  |  
|       | telefonoAtencion | 
|| email
|| esNacional|
|| esInternacional
|| RFC (solo Nacional)|
||codigoAduanal (solo Internacional)
||agenciaAduanal (solo Internacional)



+ Se hizo una especialización disjunta y total de la entidad CLIENTE
    
    De acuerdo a las estrategias de transformacion para Jerarquias, el mejor caso para CLIENTE al tener subtipos con pocos atributos, fue hacer una sola tabla con discriminador. 

|       | **Cliente**            |   
|-------|-------------------|
| PK    | numeroCliente     | 
|       | razonSocial  |  
|       | correoCliente | 
| | telefonoCliente
|| tipoCliente (discriminador: NACIONAL, EXPORTACION)
|| RFC (solo Nacional)
|| regimenFiscal (solo Nacional)
|| estadoOrigen (solo Nacional)
|| idFiscalGlobal (solo Exportacion)
|| paisReceptor (solo Exportacion)






