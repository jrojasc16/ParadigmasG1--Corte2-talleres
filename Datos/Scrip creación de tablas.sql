PRAGMA foreign_keys = on;

-- ------------------------------------------------------------
-- 1. MESA-- estado: 'disponible' | 'ocupada' | 'reservada'
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mesas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero INTEGER NOT NULL UNIQUE,
    capacidad INTEGER NOT NULL DEFAULT 4,
    ubicacion TEXT NOT NULL,-- 'interior', 'terraza', 'privado', etc.
    estado TEXT NOT NULL DEFAULT 'disponible' CHECK (estado IN ('disponible', 'ocupada', 'reservada') )
);


-- ------------------------------------------------------------
-- 2. CLIENTE-- 
------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    telefono TEXT,
    email TEXT,
    preferencias TEXT,-- notas libres (alergias, gustos)
    visitas INTEGER NOT NULL DEFAULT 0,
    descuento REAL NOT NULL DEFAULT 0.0-- porcentaje (0.0 - 100.0)
);

-- ------------------------------------------------------------
-- 3. CATEGORIA (del menú)-- Ejemplos: Entradas, Platos fuertes, Bebidas, Postres
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE
);

-- ------------------------------------------------------------
-- 4. PRODUCTO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS productos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio REAL NOT NULL CHECK (precio >= 0),
    id_categoria INTEGER NOT NULL REFERENCES categoria (id),
    estado TEXT NOT NULL DEFAULT 'disponible' CHECK (estado IN ('disponible', 'no disponible') ),
    precio_especial REAL-- precio del día (NULL = usa precio normal)
);

-- ------------------------------------------------------------
-- 5. PEDIDO-- estado: 'pendiente' | 'en_preparacion' | 'servido' | 'facturado'
-- cliente_id puede ser NULL (cliente anónimo)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_mesa INTEGER NOT NULL REFERENCES mesa (id),
    id_cliente INTEGER REFERENCES cliente (id),
    notas TEXT,
    fecha_hora DATETIME NOT NULL DEFAULT (datetime('now', 'localtime') ),
    impuesto REAL NOT NULL DEFAULT 0.19,-- 19 % IVA Colombia
    estado TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_preparacion', 'servido', 'facturado') ) 
);

-- ------------------------------------------------------------
-- 6. DETALLE_PEDIDO-- comensal_num permite dividir cuenta (1, 2, 3 … N)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_pedidos (
    id_pedido INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario REAL NOT NULL CHECK (precio_unitario >= 0),
    
    -- Claves foráneas
    FOREIGN KEY (id_pedido) REFERENCES pedido (id) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES producto (id),

    -- Clave primaria compuesta
    PRIMARY KEY (id_pedido, id_producto)
);

-- ------------------------------------------------------------
-- 7. FACTURA-- metodo_pago: 'efectivo' | 'tarjeta' | 'transferencia'
-- Un pedido genera exactamente una factura
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS facturas (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    id_pedido INTEGER  NOT NULL UNIQUE REFERENCES pedido (id),
    numero_factura TEXT NOT NULL UNIQUE,-- ej. "FAC-2024-00001"
    metodo_pago TEXT NOT NULL CHECK (metodo_pago IN ('efectivo', 'tarjeta', 'transferencia')),
    subtotal REAL NOT NULL CHECK (subtotal >= 0),
    propina REAL NOT NULL DEFAULT 0,    
    descuento REAL NOT NULL DEFAULT 0,
    impuesto REAL NOT NULL DEFAULT 0,
    total REAL NOT NULL CHECK (total >= 0),
    email_enviado  TEXT,-- NULL = no enviada; valor = destinatario
    creada_en DATETIME NOT NULL DEFAULT (datetime('now', 'localtime') ) 
);
