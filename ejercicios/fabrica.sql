-- Script SQL para Sistema de Fábrica
-- MySQL 8.0 | Visual Studio Code

-- 1. Creación de la base de datos
DROP DATABASE IF EXISTS fabrica;
CREATE DATABASE fabrica;
USE fabrica;

-- 2. Tablas principales
CREATE TABLE proveedores (
    id_prov INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(15),
    email VARCHAR(100)
);

CREATE TABLE productos (
    id_prod INT AUTO_INCREMENT PRIMARY KEY,
    id_prov INT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    FOREIGN KEY (id_prov) REFERENCES proveedores(id_prov)
);

CREATE TABLE clientes (
    id_cli INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(15),
    email VARCHAR(100)
);

-- 3. Tablas de operaciones
CREATE TABLE vendedor (
    id_vend INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    comision DECIMAL(5,2) DEFAULT 0.05
);

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cli INT,
    id_vend INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2),
    FOREIGN KEY (id_cli) REFERENCES clientes(id_cli),
    FOREIGN KEY (id_vend) REFERENCES vendedor(id_vend)
);

CREATE TABLE detalle_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_prod INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE,
    FOREIGN KEY (id_prod) REFERENCES productos(id_prod)
);

-- 4. Datos de ejemplo
INSERT INTO proveedores (nombre, direccion) VALUES 
('Proveedor Industrial SA', 'Av. Manufactura 123'),
('Insumos Técnicos SL', 'Calle Almacén 456');

INSERT INTO productos (id_prov, nombre, precio, stock) VALUES
(1, 'Tornillo hexagonal 8mm', 0.75, 500),
(2, 'Arandela plana 8mm', 0.15, 1200);

-- 5. Consulta de verificación
SELECT 'Base de datos FÁBRICA creada exitosamente' AS resultado;