# Inventario del Modelo Entidad Relación Extendido
## Entidades Fuertes
+ CLIENTE:
    + Clave primaria: **numeroCliente**
    + Atributos:
        + telefonoCliente
        + correoCliente
        + razonSocial
+ PEDIDO:
    + Clave primaria: **folio**
    + Atributos:
        + estatus
        + utilidadTotalUSD
        + montoTotalUSD
        + fecha
+ PRODUCTO:
    + Clave primaria: **claveProducto**
    + Atributos:
        + costoUnitarioUSD
        + precioUnitarioUSD
+ TRANSPORTISTA:
    + Clave primaria: **claveTransportista**
    + Atributos:
        + nombreEmpresa
        + telefonoAtencion
        + email
## Entidades Débiles
+ SUCURSAL: depende de CLIENTE, ya que un CLIENTE **tiene** una o mas Sucursales, y una SUCURSAL pertenece a un solo CLIENTE
    + Clave primaria: **claveSucursal**
    + Atributos:
        + nombrePlanta
        + telefonoEncargado
        + direccion
+ DETALLE: depende de PEDIDO, ya que un PEDIDO **registra** muchos detalles, y un DETALLE pertenece a un solo PEDIDO
    + Clave primaria: **claveParcial**
    + Atributos:
        + subtotal
        + costoProduccion
        + precioAplicado
        + cantidad
## Relaciones
+ Realiza: Relaciona CLIENTE con PEDIDO, un CLIENTE puede o no **realizar** uno o más pedidos, y un PEDIDO lo realiza uno y solo un CLIENTE.
+ Registra: Relaciona PEDIDO y DETALLE, de un PEDIDO se **registran** uno o más DETALLES, y un DETALLE pertenece a un solo PEDIDO.
+ Aparece: Relaciona PRODUCTO CON DETALLE, un PRODUCTO puede **aparecer** o no en DETALLES, y en un renglon de DETALLE aparece un solo PRODUCTO.
+ Tiene: Relaciona CLIENTE con SUCURSAL, un CLIENTE **tiene** una o más SUCURSALES, y una SUCURSAL pertenece a un solo CLIENTE.

## Jerarquías
### PRODUCTO
Se hizo una especialización disjunta y total, de los cuáles surgieron: 
+ Hyvolt
    + Atributos
        + provTransformador
+ Omnigold
    + Atributos
        + provMaquinaria
+ Hyprene
    + Atributos
        + provTransporte
### CLIENTE
Se hizo una especialización disjunta y total, de los cuales surgieron:
+ clienteNacional
    + Atributos
        + RFC
        + regimenFiscal
        + estadoOrigen
+ clienteExportacion
    + Atributos
        + idFiscalGlobal
        + paisReceptor
### TRANSPORTISTA
Se hizo una especialización solapada y total, de los cuales surgieron:
+ transportistaNacional
    + Atributos
        + RFC 
+ transportistaInternacional
    + Atributos
        + codigoAduanal
        + agenciaAduanal
## Atributos Multivaluados
+ fecha: Atributo **compuesto** por:
    + dia
    + mes
    + año
+ dirección: Atributo **compuesto** por:
    + CP
    + calle
    + pais
    + estado
    + numero
    + ciudad
+ subtotal (**derivado**): $cantidad * precioAplicado$
+ utilidadTotalUSD (**derivado**): $\sum [(precioAplicado - costoProduccion) * cantidad]$
+ montoTotalUSD (**derivado**): $\sum subtotales$

## Relaciones Ternarias
+ Envío: Relaciona SUCURSAL, PEDIDO y TRANSPORTISTA, un PEDIDO puede o no ser **enviado** a una SUCURSAL, una SUCURSAL puede o no recibir muchos PEDIDOS, y un TRANSPORTISTA puede o no ejecutar muchos PEDIDOS.
    + Atributos
        + numeroGuia
        + costoFlete
        + fecha

## ¿Qué elementos van a requerir una tabla adicional?
La relación ternaria necesitara una tabla adicional para representar la relacion entre las 3 entidades.
## ¿Qué atributos se convertiran en una clave foránea?
+ numeroCliente
+ folio
+ claveTransportista
+ claveProducto
## ¿Qué decisión tendrá que tomar en cada jerarquía?
### Jerarquía de CLIENTE
Para la jerarquía de CLIENTE se tiene una jerarquía **disjunta y total** ya que un CLIENTE tiene que ser clienteNACIONAL o clienteExportacion, pero no ambos.
### Jerarquía de PRODUCTO
Para la jerarquía de PRODUCTO  se tienen una jerarquía **disjunta y total** ya que un PRODUCTO tiene que ser Hyvolt, Omnigold, o Hyprene, pero solo uno a la vez.
### Jerarquía TRANSPORTISTA
Para la jerarquía de TRANSPORTISTA se tiene una jerarquía **solapada y total** ya que un TRANSPORTISTA puede ser transportistaNacional y transportistaInternacional, ya que un transportistaInternacional, puede seguir transportando incluso dentro de territorio nacional. 