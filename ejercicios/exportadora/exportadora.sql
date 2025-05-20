CREATE DATABASE exportadora_db;

\c exportadora_db

DROP TABLE IF EXISTS commercial_invoices CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS sales_orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;

DROP TYPE IF EXISTS payment_status_enum CASCADE;
DROP TYPE IF EXISTS order_status_enum CASCADE;
DROP TYPE IF EXISTS unit_of_measure_enum CASCADE;

CREATE TYPE unit_of_measure_enum AS ENUM (
    'kg',
    'g',
    'mg',
    'l',
    'ml',
    'pieza',
    'docena',
    'paquete',
    'caja',
    'bolsa',
    'botella',
    'metro',
    'cm',
    'm2',
    'm3',
    'lb',
    'oz',
    'gal',
    'par',
    'juego',
    'rollo'
);

CREATE TYPE order_status_enum AS ENUM (
    'pending_confirmation',
    'confirmed',
    'processing',
    'ready_for_shipment',
    'partially_shipped',
    'shipped',
    'delivered',
    'completed',
    'cancelled',
    'on_hold'
);

CREATE TYPE payment_status_enum AS ENUM (
    'pending',
    'partially_paid',
    'paid',
    'overdue',
    'refunded'
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address TEXT,
    payment_terms VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_suppliers_email ON suppliers(email);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    cost_price DECIMAL(12, 2) NOT NULL CHECK (cost_price >= 0),
    unit_of_measure unit_of_measure_enum NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
    country_of_origin VARCHAR(100),
    hs_code VARCHAR(50),
    weight_per_unit DECIMAL(10, 3),
    dimension_l_cm DECIMAL(10, 2),
    dimension_w_cm DECIMAL(10, 2),
    dimension_h_cm DECIMAL(10, 2)
);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_supplier_id ON products(supplier_id);

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    billing_address TEXT,
    shipping_address TEXT,
    country VARCHAR(100) NOT NULL,
    tax_id VARCHAR(100),
    credit_limit DECIMAL(12, 2) DEFAULT 0.00,
    payment_terms_agreed VARCHAR(255)
);
CREATE INDEX IF NOT EXISTS idx_clients_company_name ON clients(company_name);
CREATE INDEX IF NOT EXISTS idx_clients_country ON clients(country);

CREATE TABLE sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status order_status_enum DEFAULT 'pending_confirmation',
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    total_amount DECIMAL(15, 2) DEFAULT 0.00,
    expected_ship_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_sales_orders_client_id ON sales_orders(client_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_order_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_sales_orders_status ON sales_orders(status);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    sales_order_id INTEGER NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00 CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    line_total DECIMAL(15, 2)
);
CREATE INDEX IF NOT EXISTS idx_order_items_sales_order_id ON order_items(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

CREATE TABLE shipments (
    id SERIAL PRIMARY KEY,
    shipment_number VARCHAR(100) UNIQUE,
    sales_order_id INTEGER REFERENCES sales_orders(id) ON DELETE SET NULL,
    ship_date DATE,
    carrier_name VARCHAR(255),
    tracking_number VARCHAR(255),
    port_of_loading VARCHAR(255),
    port_of_discharge VARCHAR(255),
    estimated_arrival_date DATE,
    actual_arrival_date DATE,
    status VARCHAR(100) DEFAULT 'pending_shipment',
    freight_cost DECIMAL(12, 2),
    insurance_cost DECIMAL(12, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_shipments_sales_order_id ON shipments(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_shipments_ship_date ON shipments(ship_date);
CREATE INDEX IF NOT EXISTS idx_shipments_tracking_number ON shipments(tracking_number);

CREATE TABLE commercial_invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    sales_order_id INTEGER REFERENCES sales_orders(id) ON DELETE SET NULL,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    total_amount DECIMAL(15, 2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    payment_status payment_status_enum DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_commercial_invoices_sales_order_id ON commercial_invoices(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_commercial_invoices_client_id ON commercial_invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_commercial_invoices_issue_date ON commercial_invoices(issue_date);
CREATE INDEX IF NOT EXISTS idx_commercial_invoices_payment_status ON commercial_invoices(payment_status);