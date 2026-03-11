# SIGH - Sistema Integral de Gestión Hospitalaria

Implementación base de un sistema web para clínica pequeña con enfoque en:

- Farmacia hospitalaria con trazabilidad por lote
- Órdenes médicas internas
- Punto de cobro
- Convenios empresariales y crédito
- Facturación CFDI 4.0 (integración PAC)
- Auditoría inmutable
- Corte de caja por turno

## Stack propuesto

- **Frontend:** React (pendiente en este repositorio)
- **Backend:** Node.js + Express API REST
- **BD:** PostgreSQL
- **Autenticación:** JWT + RBAC por roles
- **Seguridad:** HTTPS, hash de contraseñas, logs inmutables

## Estructura

- `database/schema.sql`: esquema relacional principal
- `docs/architecture.md`: arquitectura técnica y seguridad
- `docs/workflows.md`: flujos operativos integrados
- `docs/rf-traceability.md`: trazabilidad RF/RNF y reglas de negocio
- `backend/`: API base por módulos

## Puesta en marcha (backend)

```bash
cd backend
npm install
npm run dev
```

Variables de entorno sugeridas:

```bash
PORT=3000
JWT_SECRET=super-secret
DATABASE_URL=postgres://postgres:postgres@localhost:5432/sigh
```

## Estado del proyecto

Este repositorio entrega una **base funcional y extensible** con:

- Modelado de datos clave para inventario por lote y operación clínica
- API inicial con validación de reglas críticas (PEPS, regulados, corte de caja)
- Middleware de auditoría para eventos críticos
- Documentación técnica para completar frontend e integraciones SAT/PAC
