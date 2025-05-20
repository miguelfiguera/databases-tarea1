**Miguel Alejandro Figuera Quintero**
C.I: V-23.558.789
Seccion 8B

---

# Base de datos para una Aerolínea

---

## Tipos ENUM Definidos

Estos tipos sirven para restringir los valores que pueden tomar ciertas columnas a un conjunto predefinido, lo que ayuda a la integridad de los datos y a la claridad del esquema.

- **`replenished_status`**: Indica el estado de reabastecimiento de algo (probablemente suministros del avión).
  - Valores: '`pending`' (pendiente), '`replenished`' (reabastecido), '`empty`' (vacío), '`used`' (usado).
- **`fuel_status`**: Indica el estado del combustible.
  - Valores: '`refueled`' (repostado), '`pending`' (pendiente).
- **`maintenance_status`**: Indica el estado del mantenimiento.
  - Valores: '`pending`' (pendiente), '`performed`' (realizado).
- **`personel_rol`**: Define los roles del personal.
  - Valores: '`stewardess`' (azafata), '`copilot`' (copiloto), '`pilot`' (piloto), '`steward`' (asistente de vuelo, podría ser un sinónimo o un rol diferente).

---

## Descripción de cada Modelo (Tabla) y sus Relaciones

### 1. `planes` (Aviones)

- **Descripción:** Esta tabla almacena información sobre los aviones físicos que posee o opera la aerolínea. Cada fila representa un avión único.
- **Atributos Clave:**
  - `id` (identificador único del avión)
  - `model` (modelo del avión, ej. "Boeing 737")
- **Relaciones:**
  - **`has_many personel`**: Un avión `tiene muchos` miembros del personal, a través de la columna `personel.plane_id`. Esto sugiere que un miembro del personal puede estar asignado de forma principal o base a un avión específico.
  - **`has_many flights`**: Un avión `tiene muchos` vuelos, a través de la columna `flights.plane_id`. Un avión se utiliza para operar múltiples vuelos.
  - **`has_one plane_details`**: Un avión `tiene un` registro de detalles, a través de la columna `plane_details.plane_id` (que además es `UNIQUE NOT NULL`). Esto establece una relación uno-a-uno estricta: cada avión tiene exactamente un conjunto de detalles asociados, y si se borra el avión, sus detalles también se borran (`ON DELETE CASCADE`).

### 2. `passengers` (Pasajeros)

- **Descripción:** Almacena información sobre las personas que viajan o han viajado con la aerolínea.
- **Atributos Clave:**
  - `id` (identificador único del pasajero) Primary Key
  - `dni` (documento de identidad, único)
  - `name`
  - `last_name`
  - `email` (único)
  - `dob` (fecha de nacimiento)
  - `active` (si el registro del pasajero está activo)
  - `phone`
- **Relaciones:**
  - **`has_many tickets`**: Un pasajero `tiene muchos` boletos, a través de la columna `tickets.passenger_id`. Un pasajero puede comprar múltiples boletos para diferentes vuelos.

### 3. `personel` (Personal de la Aerolínea)

- **Descripción:** Contiene información sobre los empleados de la aerolínea que forman parte de la tripulación o tienen roles operativos relacionados con los vuelos/aviones.
- **Atributos Clave:**
  - `id` (identificador único del miembro del personal)
  - `name`
  - `last_name`
  - `dni` (documento de identidad, único)
  - `rol` (usando el ENUM `personel_rol`)
  - `plane_id` (a qué avión está asignado principalmente, puede ser `NULL`)
  - `flight_hours` (horas de vuelo acumuladas)
  - `years_of_service`
- **Relaciones:**
  - **`belongs_to plane`**: Un miembro del personal `pertenece a` un avión (opcionalmente), a través de la columna `personel.plane_id`. Indica una posible asignación base de este empleado a un avión en particular.
  - **Referenciado por `plane_details`**: Un miembro del personal `puede ser` capitán, copiloto o azafata en los detalles de un avión, a través de las columnas `captain_id`, `copilot_id`, `stewardess_one_id`, etc., en la tabla `plane_details`.

### 4. `flights` (Vuelos)

- **Descripción:** Registra la información de cada vuelo operado por la aerolínea, ya sea programado, en curso o completado.
- **Atributos Clave:**
  - `id` (identificador único del vuelo)
  - `city_of_arrival`
  - `city_of_departure`
  - `arrival_datetime` (fecha y hora de llegada)
  - `departure_datetime` (fecha y hora de salida)
  - `plane_id` (qué avión opera este vuelo)
- **Relaciones:**
  - **`belongs_to plane`**: Un vuelo `pertenece a` un avión, a través de la columna `flights.plane_id`. Cada vuelo es operado por un avión específico.
  - **`has_many tickets`**: Un vuelo `tiene muchos` boletos, a través de la columna `tickets.flight_id`. Múltiples boletos pueden ser vendidos para un mismo vuelo.

### 5. `tickets` (Boletos)

- **Descripción:** Representa los boletos o pasajes comprados por los pasajeros para vuelos específicos.
- **Atributos Clave:**
  - `id` (identificador único del boleto)
  - `passenger_id` (a qué pasajero pertenece)
  - `flight_id` (para qué vuelo es)
  - `created_at` (cuándo se emitió)
  - `amount` (precio)
  - `confirmed` (si está confirmado)
  - `seat_number` (número de asiento, único por vuelo: `UNIQUE INDEX idx_tickets_flight_seat`)
  - `luggage_kg` (peso del equipaje)
- **Relaciones:**
  - **`belongs_to passenger`**: Un boleto `pertenece a` un pasajero, a través de la columna `tickets.passenger_id`.
  - **`belongs_to flight`**: Un boleto `pertenece a` un vuelo, a través de la columna `tickets.flight_id`.

### 6. `plane_details` (Detalles del Avión)

- **Descripción:** Almacena información específica y detallada sobre un avión en particular, incluyendo su configuración de tripulación (para un vuelo o configuración tipo), capacidades, y estados de mantenimiento y suministros.
- **Atributos Clave:**
  - `id` (identificador único del registro de detalles)
  - `plane_id` (a qué avión pertenecen estos detalles, es `UNIQUE NOT NULL`)
  - `captain_id` (FK a `personel.id`)
  - `copilot_id` (FK a `personel.id`)
  - `stewardess_one_id` (FK a `personel.id`)
  - `stewardess_two_id` (FK a `personel.id`)
  - `stewardess_three_id` (FK a `personel.id`)
  - `vip_capacity`
  - `commercial_capacity`
  - `fuel_capacity_liters`
  - `extinguishers` (número de extintores)
  - `last_maintenance_date`
  - `last_replenish_date`
  - `last_refueled_date`
  - `replenish_status` (usa el ENUM `replenished_status`)
  - `fuel_level_status` (usa el ENUM `fuel_status`)
  - `maintenance_status` (usa el ENUM `maintenance_status`)
- **Relaciones:**
  - **`belongs_to plane`**: Los detalles del avión `pertenecen a` un avión, a través de la columna `plane_details.plane_id`. Es una relación **uno-a-uno** estricta.
  - **`has_one captain (from personel)`**: Los detalles del avión `tienen un` capitán (referencia a `personel`), a través de `plane_details.captain_id`.
  - **`has_one copilot (from personel)`**: Los detalles del avión `tienen un` copiloto (referencia a `personel`), a través de `plane_details.copilot_id`.
  - **`has_many stewardesses (represented as individual slots from personel)`**: Los detalles del avión `tienen varias` azafatas asignadas en "slots" individuales (cada una referencia a `personel`), a través de `stewardess_one_id`, `stewardess_two_id`, `stewardess_three_id`.

## Diagrama Entidad Relación para Aerolínea

![Diagrama aerolínea](<Screenshot from 2025-05-07 03-35-37.png>)

---

# Base de datos para una Empresa Exportadora

---

## Tipos ENUM Definidos

Estos tipos definen conjuntos de valores permitidos para ciertas columnas, lo que ayuda a mantener la consistencia de los datos.

- **`unit_of_measure_enum`**: Define diversas unidades de medida para los productos.
  - Ejemplos: '`kg`', '`pieza`', '`caja`', '`metro`', etc.
  - _Nota:_ Hay dos definiciones de `unit_of_measure_enum` en el esquema original; se asume que la primera, más detallada, es la correcta o que la segunda es un remanente.
- **`order_status_enum`**: Define los posibles estados de un pedido de venta.
  - Ejemplos: '`pending_confirmation`', '`shipped`', '`completed`', '`cancelled`'.
- **`payment_status_enum`**: Define los posibles estados de pago de una factura.
  - Ejemplos: '`pending`', '`paid`', '`overdue`'.

---

## Descripción de cada Modelo (Tabla) y sus Relaciones

### 1. `suppliers` (Proveedores)

- **Descripción:** Esta tabla almacena información sobre las empresas o individuos que suministran productos a la empresa que utiliza esta base de datos.
- **Atributos Clave:**
  - `id` (identificador único)
  - `name` (nombre del proveedor)
  - `contact_person`
  - `email` (único)
  - `phone`
  - `address`
  - `payment_terms` (condiciones de pago acordadas con el proveedor)
- **Relaciones:**
  - **`has_many products`**: Un `supplier` puede suministrar muchos `products`, a través de la columna `products.supplier_id`.
  - _Nota sobre índice:_ El `CREATE INDEX idx_suppliers_name ON suppliers(email);` crea un índice llamado `idx_suppliers_name` sobre la columna `email`. Sería más claro si el nombre del índice fuera `idx_suppliers_email` o si el índice estuviera en la columna `name` si esa es la intención.

### 2. `products` (Productos)

- **Descripción:** Contiene la información detallada de cada artículo o producto que la empresa maneja, ya sea para comprar o vender.
- **Atributos Clave:**
  - `id` (identificador único)
  - `sku` (Stock Keeping Unit, código único del producto)
  - `name` (nombre del producto)
  - `description`
  - `cost_price` (precio de costo)
  - `unit_of_measure` (usa el ENUM `unit_of_measure_enum`)
  - `supplier_id` (quién suministra este producto, FK a `suppliers.id`)
  - `country_of_origin`
  - `hs_code` (código del Sistema Armonizado para aduanas)
  - `weight_per_unit`
  - `dimension_l_cm`, `dimension_w_cm`, `dimension_h_cm`
- **Relaciones:**
  - **`belongs_to supplier`**: Un `product` `pertenece a` un `supplier`, a través de la columna `products.supplier_id`. Si el proveedor es eliminado, el campo `supplier_id` en los productos asociados se establecerá en `NULL` (`ON DELETE SET NULL`).
  - **`has_many order_items`**: Un `product` puede estar en muchas líneas de pedido (`order_items`), a través de la columna `order_items.product_id`.

### 3. `clients` (Clientes)

- **Descripción:** Almacena información sobre los clientes (empresas o individuos) a los que la empresa vende sus productos.
- **Atributos Clave:**
  - `id` (identificador único)
  - `company_name`
  - `contact_person`
  - `email` (único)
  - `phone`
  - `billing_address` (dirección de facturación)
  - `shipping_address` (dirección de envío)
  - `country`
  - `tax_id` (identificación fiscal)
  - `credit_limit` (límite de crédito)
  - `payment_terms_agreed` (condiciones de pago acordadas con el cliente)
- **Relaciones:**
  - **`has_many sales_orders`**: Un `client` puede realizar muchos `sales_orders` (pedidos de venta), a través de `sales_orders.client_id`.
  - **`has_many commercial_invoices`**: A un `client` se le pueden emitir muchas `commercial_invoices` (facturas), a través de `commercial_invoices.client_id`.

### 4. `sales_orders` (Pedidos de Venta)

- **Descripción:** Registra los pedidos realizados por los clientes. Cada fila es un pedido.
- **Atributos Clave:**
  - `id` (identificador único)
  - `order_number` (número de pedido, único)
  - `client_id` (a qué cliente pertenece el pedido, FK a `clients.id`)
  - `order_date` (fecha del pedido)
  - `status` (usa el ENUM `order_status_enum`)
  - `currency` (moneda del pedido)
  - `total_amount` (monto total, probablemente calculado)
  - `expected_ship_date` (fecha esperada de envío)
  - `notes`
  - `created_at`, `updated_at`
- **Relaciones:**
  - **`belongs_to client`**: Un `sales_order` `pertenece a` un `client`, a través de `sales_orders.client_id`. Si se intenta borrar un cliente que tiene pedidos, la operación fallará (`ON DELETE RESTRICT`).
  - **`has_many order_items`**: Un `sales_order` se compone de varias `order_items` (líneas de productos), a través de `order_items.sales_order_id`.
  - **`has_many shipments`**: Un `sales_order` puede tener uno o varios `shipments` (envíos), a través de `shipments.sales_order_id`.
  - **`has_many commercial_invoices`**: Un `sales_order` puede generar una o varias `commercial_invoices` (facturas), a través de `commercial_invoices.sales_order_id`.

### 5. `order_items` (Líneas de Pedido de Venta)

- **Descripción:** Detalla cada producto individual dentro de un pedido de venta, incluyendo la cantidad y el precio. Es una tabla de unión entre `sales_orders` y `products`.
- **Atributos Clave:**
  - `id` (identificador único)
  - `sales_order_id` (a qué pedido pertenece, FK a `sales_orders.id`)
  - `product_id` (qué producto es, FK a `products.id`)
  - `quantity` (cantidad pedida)
  - `unit_price` (precio unitario)
  - `discount_percentage` (porcentaje de descuento)
  - `line_total` (total de la línea, probablemente calculado)
- **Relaciones:**
  - **`belongs_to sales_order`**: Un `order_item` `pertenece a` un `sales_order`, a través de `order_items.sales_order_id`. Si el pedido de venta se elimina, todas sus líneas de pedido también se eliminan (`ON DELETE CASCADE`).
  - **`belongs_to product`**: Un `order_item` `pertenece a` un `product`, a través de `order_items.product_id`. Si se intenta borrar un producto que está en una línea de pedido, la operación fallará (`ON DELETE RESTRICT`).

### 6. `shipments` (Envíos/Embarques)

- **Descripción:** Almacena información sobre los envíos físicos de los productos a los clientes.
- **Atributos Clave:**
  - `id` (identificador único)
  - `shipment_number` (número de envío, único)
  - `sales_order_id` (pedido asociado, FK a `sales_orders.id`)
  - `ship_date` (fecha de envío)
  - `carrier_name` (nombre del transportista)
  - `tracking_number` (número de seguimiento)
  - `port_of_loading` (puerto de carga)
  - `port_of_discharge` (puerto de descarga)
  - `estimated_arrival_date`
  - `actual_arrival_date`
  - `status` (estado del envío)
  - `freight_cost` (costo del flete)
  - `insurance_cost` (costo del seguro)
  - `notes`
  - `created_at`, `updated_at`
- **Relaciones:**
  - **`belongs_to sales_order`**: Un `shipment` `pertenece a` un `sales_order`, a través de `shipments.sales_order_id`. Si el pedido asociado se elimina, el `sales_order_id` en el envío se establecerá en `NULL` (`ON DELETE SET NULL`), permitiendo que el registro del envío persista por razones históricas.

### 7. `commercial_invoices` (Facturas Comerciales)

- **Descripción:** Registra las facturas emitidas a los clientes por los productos o servicios vendidos.
- **Atributos Clave:**
  - `id` (identificador único)
  - `invoice_number` (número de factura, único)
  - `sales_order_id` (pedido que generó la factura, FK a `sales_orders.id`)
  - `client_id` (cliente al que se factura, FK a `clients.id`)
  - `issue_date` (fecha de emisión)
  - `due_date` (fecha de vencimiento)
  - `total_amount` (monto total de la factura)
  - `currency` (moneda)
  - `payment_status` (usa el ENUM `payment_status_enum`)
  - `notes`
  - `created_at`, `updated_at`
- **Relaciones:**
  - **`belongs_to sales_order`**: Una `commercial_invoice` `pertenece a` un `sales_order`, a través de `commercial_invoices.sales_order_id`. Si el pedido asociado se elimina, el `sales_order_id` en la factura se establecerá en `NULL` (`ON DELETE SET NULL`).
  - **`belongs_to client`**: Una `commercial_invoice` `pertenece a` un `client`, a través de `commercial_invoices.client_id`. Se prohíbe eliminar un cliente si tiene facturas asociadas (`ON DELETE RESTRICT`).

## Diagrama Entidad Relación para Empresa Exportadora

![Diagrama Entidad Relacion para exportadora](<Screenshot from 2025-05-07 03-44-31.png>)
