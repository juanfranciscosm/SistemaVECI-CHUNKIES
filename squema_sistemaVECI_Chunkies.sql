
-- ========================================================================
-- sistemaVECI_chunkies.sql – Modelo T-SQL adaptado para Azure SQL Database
-- ========================================================================

-- Desactivar comprobación de claves externas temporalmente
ALTER DATABASE CURRENT SET ANSI_NULLS ON;
-- ALTERADO DESDE LOCAL
ALTER DATABASE CURRENT SET QUOTED_IDENTIFIER ON;



-- =============================
-- Solo si se van hacer cambios justo despues de haber ejecutado el squema, se debe ejecutar antes el 
---Script para eliminar FOREIGN KEY constraints para poder eliminar tablas
-- =============================

--  DROP TABLE 
IF OBJECT_ID('tipos_clientes', 'U') IS NOT NULL DROP TABLE tipos_clientes;
IF OBJECT_ID('clientes', 'U') IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('productos', 'U') IS NOT NULL DROP TABLE productos;
IF OBJECT_ID('ventas', 'U') IS NOT NULL DROP TABLE ventas;
IF OBJECT_ID('ventas_detalles', 'U') IS NOT NULL DROP TABLE ventas_detalles;
IF OBJECT_ID('proveedores_beneficiarios', 'U') IS NOT NULL DROP TABLE proveedores_beneficiarios;
IF OBJECT_ID('compras', 'U') IS NOT NULL DROP TABLE compras;
IF OBJECT_ID('compras_detalle', 'U') IS NOT NULL DROP TABLE compras_detalle;
IF OBJECT_ID('ingresos', 'U') IS NOT NULL DROP TABLE ingresos;
IF OBJECT_ID('egresos', 'U') IS NOT NULL DROP TABLE egresos;


-- =============================
-- Tablas de Catálogo ENUM
-- =============================
-- Catalogo: Tipo de clientes
IF OBJECT_ID('cat_tipo_clientes', 'U') IS NOT NULL DROP TABLE cat_tipo_clientes;
CREATE TABLE cat_tipo_clientes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'CLIENTE FINAL', 'PUNTO DE VENTA',  'SALA DE EVENTOS'
);
-- Catalogo: Categoria de clientes
IF OBJECT_ID('cat_categoria_clientes', 'U') IS NOT NULL DROP TABLE cat_categoria_clientes;
CREATE TABLE cat_categoria_clientes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'REGULAR', 'FRECUENTE',  'ESPECIAL'
);
-- Catalogo: Tipo de producto 
IF OBJECT_ID('cat_tipo_producto', 'U') IS NOT NULL DROP TABLE cat_tipo_producto;
CREATE TABLE cat_tipo_producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'GALLETA 90GR', 'GALLETA 300GR'
);
-- Catalogo: Estado de pago (ventas y compras)
IF OBJECT_ID('cat_estado_pago', 'U') IS NOT NULL DROP TABLE cat_estado_pago;
CREATE TABLE cat_estado_pago (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Cancelado', 'Saldo Pendiente'
);
-- Catalogo: Tipo de documento (ventas y compras)
IF OBJECT_ID('cat_tipo_documento', 'U') IS NOT NULL DROP TABLE cat_tipo_documento;
CREATE TABLE cat_tipo_documento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Factura', 'Nota de Venta'
);
-- Catalogo: Tipo de beneficiario
IF OBJECT_ID('cat_tipo_beneficiario', 'U') IS NOT NULL DROP TABLE cat_tipo_beneficiario;
CREATE TABLE cat_tipo_beneficiario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'socio', 'proveedor', 'colaborador'
);
-- Catalogo: Items de compra
IF OBJECT_ID('cat_item_compra', 'U') IS NOT NULL DROP TABLE cat_item_compra;
CREATE TABLE cat_item_compra (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'harina de trigo', 'esencia de vainilla', etc.
);
-- Catalogo: Unidad de medida
IF OBJECT_ID('cat_unidad_medida', 'U') IS NOT NULL DROP TABLE cat_unidad_medida;
CREATE TABLE cat_unidad_medida (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'GRAMOS', 'MILILITROS', etc.
);
-- Catalogo: Forma de pago aceptados para ingresos
IF OBJECT_ID('cat_forma_pago_ing', 'U') IS NOT NULL DROP TABLE cat_forma_pago_ing;
CREATE TABLE cat_forma_pago_ing (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Transferencia BANCO GUAYAQUIL', 'Efectivo'
);
-- Catalogo: Forma de pago disponibles para egresos
IF OBJECT_ID('cat_forma_pago_eg', 'U') IS NOT NULL DROP TABLE cat_forma_pago_eg;
CREATE TABLE cat_forma_pago_eg (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Transferencia', 'Efectivo','Tarjeta'
);
-- Catalogo: Categoria de ingresos
IF OBJECT_ID('cat_categoria_ingreso', 'U') IS NOT NULL DROP TABLE cat_categoria_ingreso;
CREATE TABLE cat_categoria_ingreso (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE -- Ej: 'Ventas', 'Aportes de capital', 'Otros'
);
-- Catalogo: Categoria de egresos
IF OBJECT_ID('cat_categoria_egreso', 'U') IS NOT NULL DROP TABLE cat_categoria_egreso;
CREATE TABLE cat_categoria_egreso (
    id INT IDENTITY(1,1) PRIMARY KEY,
    eliminado BIT DEFAULT 0,
    nombre VARCHAR(50) NOT NULL UNIQUE
);



-- ========================================
-- 1. Catálogo de tipos de cliente
-- ========================================

CREATE TABLE tipos_clientes (
    eliminado BIT DEFAULT 0,
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo_categoria VARCHAR(50),
    cat_tipo_cliente_id INT FOREIGN KEY REFERENCES cat_tipo_clientes(id),
    cat_categoria_cliente_id INT FOREIGN KEY REFERENCES cat_categoria_clientes(id),
    descuento DECIMAL(5,2) DEFAULT 0
);

-- ========================================
-- 2. Clientes
-- ========================================
CREATE TABLE clientes (
    eliminado BIT DEFAULT 0,
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    ruc_cedula VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(120) UNIQUE,
    direccion TEXT,
    tipo_cliente_id INT FOREIGN KEY REFERENCES tipos_clientes(id),
    fecha_registro DATE DEFAULT GETDATE()
);

-- ========================================
-- 3. Productos
-- ========================================
CREATE TABLE productos (
    eliminado BIT DEFAULT 0,
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_comercial VARCHAR(120) NOT NULL,
    descripcion TEXT,
    nombre_interno VARCHAR(120),
    precio_unitario_pvp DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2),
    tipo_producto_id INT FOREIGN KEY REFERENCES cat_tipo_producto(id)
);

-- ========================================
-- 4. Ventas
-- ========================================

CREATE TABLE ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT FOREIGN KEY REFERENCES clientes(id),
    fecha DATE DEFAULT GETDATE(),
    estado_pago_venta_id INT FOREIGN KEY REFERENCES cat_estado_pago(id),
    total_venta DECIMAL(12,2) NOT NULL,
    tipo_documento_venta_id INT FOREIGN KEY REFERENCES cat_tipo_documento(id),
    documento_nro VARCHAR(40)
);

-- ========================================
-- 5. Ventas Detalles
-- ========================================
CREATE TABLE ventas_detalles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT FOREIGN KEY REFERENCES ventas(id) ON DELETE CASCADE,
    producto_id INT FOREIGN KEY REFERENCES productos(id),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento_detalle DECIMAL(10,2) DEFAULT 0,
    aplica_iva BIT DEFAULT 0,
    porcentaje_iva DECIMAL(5,2) DEFAULT 0.15
);

-- ========================================
-- 6. Proveedores/Beneficiarios
-- ========================================
CREATE TABLE proveedores_beneficiarios (
    eliminado BIT DEFAULT 0,
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    tipo_beneficiario_id INT FOREIGN KEY REFERENCES cat_tipo_beneficiario(id),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(120) UNIQUE
);

-- ========================================
-- 7. Compras
-- ========================================
CREATE TABLE compras (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha_compra DATE DEFAULT GETDATE(),
    proveedor_id INT FOREIGN KEY REFERENCES proveedores_beneficiarios(id),
    total_compra DECIMAL(12,2) NOT NULL,
    estado_pago_compra_id INT FOREIGN KEY REFERENCES cat_estado_pago(id),
    tipo_documento_compra_id INT FOREIGN KEY REFERENCES cat_tipo_documento(id),
    documento_nro VARCHAR(40),
    observaciones TEXT
);

-- ========================================
-- 8. Compras Detalle
-- ========================================
CREATE TABLE compras_detalle (
    id INT IDENTITY(1,1) PRIMARY KEY,
    compra_id INT FOREIGN KEY REFERENCES compras(id) ON DELETE CASCADE,
    item_id INT FOREIGN KEY REFERENCES cat_item_compra(id),
    descripcion TEXT,
    unidad_medida_id INT FOREIGN KEY REFERENCES cat_unidad_medida(id),
    cantidad_por_unidad DECIMAL(12,3) NOT NULL,
    cantidad_de_unidades DECIMAL(12,3) NOT NULL,
    precio_unitario_bruto DECIMAL(10,2) NOT NULL,
    descuento_detalle DECIMAL(5,2) DEFAULT 0,
    aplica_iva BIT DEFAULT 0,
    porcentaje_iva DECIMAL(5,2) DEFAULT 0
);

-- ========================================
-- 9. Ingresos
-- ========================================
CREATE TABLE ingresos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(12,2) NOT NULL,
    metodo_pago_in_id INT FOREIGN KEY REFERENCES cat_forma_pago_ing(id),
    categoriaIngreso_id INT FOREIGN KEY REFERENCES cat_categoria_ingreso(id),
    descripcion TEXT,
    comprobante_nro VARCHAR(40),
    venta_id INT NULL FOREIGN KEY REFERENCES ventas(id) ON DELETE CASCADE
);

-- ========================================
-- 10. Egresos
-- ========================================

CREATE TABLE egresos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE DEFAULT GETDATE(),
    monto DECIMAL(12,2) NOT NULL,
    categoriaEgreso_id INT FOREIGN KEY REFERENCES cat_categoria_egreso(id),
    metodo_pago_eg_id INT FOREIGN KEY REFERENCES cat_forma_pago_eg(id),
    proveedor_beneficiario_id INT FOREIGN KEY REFERENCES proveedores_beneficiarios(id),
    compra_id INT NULL FOREIGN KEY REFERENCES compras(id) ON DELETE CASCADE,
    comprobante_nro VARCHAR(40),
    descripcion TEXT
);















