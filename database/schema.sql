CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(60) UNIQUE NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rol_id UUID NOT NULL REFERENCES roles(id),
  nombre VARCHAR(120) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE proveedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(150) NOT NULL,
  rfc VARCHAR(13),
  telefono VARCHAR(30),
  email VARCHAR(120),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE medicamentos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre_generico VARCHAR(150) NOT NULL,
  nombre_comercial VARCHAR(150) NOT NULL,
  presentacion VARCHAR(100) NOT NULL,
  concentracion VARCHAR(80) NOT NULL,
  forma_farmaceutica VARCHAR(80) NOT NULL,
  fraccion_arancelaria VARCHAR(20),
  clasificacion VARCHAR(30) NOT NULL CHECK (clasificacion IN ('ANTIBIOTICO','ANALGESICO','CONTROLADO','PSICOTROPICO','OTRO')),
  requiere_receta BOOLEAN NOT NULL DEFAULT FALSE,
  requiere_receta_retenida BOOLEAN NOT NULL DEFAULT FALSE,
  codigo_barras VARCHAR(40) UNIQUE,
  precio_compra NUMERIC(12,2) NOT NULL,
  precio_venta NUMERIC(12,2) NOT NULL,
  margen NUMERIC(6,2) GENERATED ALWAYS AS (((precio_venta - precio_compra) / NULLIF(precio_compra,0)) * 100) STORED,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE lotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  medicamento_id UUID NOT NULL REFERENCES medicamentos(id),
  numero_lote VARCHAR(80) NOT NULL,
  fecha_caducidad DATE NOT NULL,
  proveedor_id UUID REFERENCES proveedores(id),
  factura_compra VARCHAR(80),
  cantidad_recibida INTEGER NOT NULL CHECK (cantidad_recibida > 0),
  cantidad_disponible INTEGER NOT NULL CHECK (cantidad_disponible >= 0),
  usuario_ingreso_id UUID NOT NULL REFERENCES usuarios(id),
  bloqueado BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (medicamento_id, numero_lote)
);

CREATE TABLE empresas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(150) NOT NULL,
  rfc VARCHAR(13) UNIQUE,
  estatus VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' CHECK (estatus IN ('ACTIVA','BLOQUEADA')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE convenios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  descuento_pct NUMERIC(5,2) NOT NULL CHECK (descuento_pct >= 0 AND descuento_pct <= 100),
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE ordenes_medicas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  paciente_id UUID,
  medico_id UUID NOT NULL REFERENCES usuarios(id),
  estatus VARCHAR(20) NOT NULL DEFAULT 'ABIERTA' CHECK (estatus IN ('ABIERTA','SURTIDA','CANCELADA')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE orden_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  orden_id UUID NOT NULL REFERENCES ordenes_medicas(id) ON DELETE CASCADE,
  medicamento_id UUID NOT NULL REFERENCES medicamentos(id),
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  surtida BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE ventas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  paciente_id UUID,
  empresa_id UUID REFERENCES empresas(id),
  tipo_venta VARCHAR(20) NOT NULL CHECK (tipo_venta IN ('DIRECTA','ORDEN','CONVENIO','CREDITO')),
  metodo_pago VARCHAR(20) CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA','MIXTO')),
  subtotal NUMERIC(12,2) NOT NULL,
  descuento NUMERIC(12,2) NOT NULL DEFAULT 0,
  total NUMERIC(12,2) NOT NULL,
  facturada BOOLEAN NOT NULL DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES usuarios(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE venta_detalle (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id UUID NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
  medicamento_id UUID NOT NULL REFERENCES medicamentos(id),
  lote_id UUID NOT NULL REFERENCES lotes(id),
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(12,2) NOT NULL,
  descuento_unitario NUMERIC(12,2) NOT NULL DEFAULT 0
);

CREATE TABLE inventario_movimientos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('ENTRADA_COMPRA','ENTRADA_DEVOLUCION','ENTRADA_AJUSTE','ENTRADA_TRASPASO','SALIDA_DISPENSACION','SALIDA_VENTA','SALIDA_AJUSTE','MERMA')),
  medicamento_id UUID NOT NULL REFERENCES medicamentos(id),
  lote_id UUID REFERENCES lotes(id),
  cantidad INTEGER NOT NULL,
  costo_unitario NUMERIC(12,2),
  referencia_tipo VARCHAR(30),
  referencia_id UUID,
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE recetas_controladas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id UUID REFERENCES ventas(id),
  medicamento_id UUID NOT NULL REFERENCES medicamentos(id),
  medico_nombre VARCHAR(150) NOT NULL,
  medico_cedula VARCHAR(30) NOT NULL,
  paciente_id UUID,
  folio_receta VARCHAR(60) NOT NULL,
  fecha_receta DATE NOT NULL,
  created_by UUID NOT NULL REFERENCES usuarios(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE estado_cuenta_empresa (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id UUID NOT NULL REFERENCES empresas(id),
  periodo VARCHAR(7) NOT NULL,
  total_cargos NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_abonos NUMERIC(12,2) NOT NULL DEFAULT 0,
  saldo NUMERIC(12,2) NOT NULL DEFAULT 0,
  estatus VARCHAR(20) NOT NULL DEFAULT 'ABIERTO' CHECK (estatus IN ('ABIERTO','CERRADO')),
  UNIQUE (empresa_id, periodo)
);

CREATE TABLE pagos_empresa (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  estado_cuenta_id UUID NOT NULL REFERENCES estado_cuenta_empresa(id),
  monto NUMERIC(12,2) NOT NULL CHECK (monto > 0),
  metodo_pago VARCHAR(20),
  referencia VARCHAR(120),
  created_by UUID NOT NULL REFERENCES usuarios(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE cortes_caja (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID NOT NULL REFERENCES usuarios(id),
  turno VARCHAR(20) NOT NULL CHECK (turno IN ('MATUTINO','VESPERTINO','NOCTURNO')),
  fecha DATE NOT NULL,
  estatus VARCHAR(20) NOT NULL DEFAULT 'ABIERTO' CHECK (estatus IN ('ABIERTO','CERRADO')),
  total_efectivo NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_tarjeta NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_transferencia NUMERIC(12,2) NOT NULL DEFAULT 0,
  efectivo_esperado NUMERIC(12,2) NOT NULL DEFAULT 0,
  diferencia NUMERIC(12,2) NOT NULL DEFAULT 0,
  incidencias TEXT,
  opened_at TIMESTAMP NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMP
);

CREATE TABLE bitacora_auditoria (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID REFERENCES usuarios(id),
  modulo VARCHAR(50) NOT NULL,
  accion VARCHAR(50) NOT NULL,
  entidad VARCHAR(80) NOT NULL,
  entidad_id UUID,
  datos_anteriores JSONB,
  datos_nuevos JSONB,
  ip_equipo VARCHAR(80),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lotes_peps ON lotes (medicamento_id, fecha_caducidad, cantidad_disponible);
CREATE INDEX idx_movimientos_medicamento ON inventario_movimientos (medicamento_id, created_at);
CREATE INDEX idx_auditoria_modulo ON bitacora_auditoria (modulo, created_at);
