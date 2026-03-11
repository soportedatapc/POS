# Trazabilidad de Requerimientos

## Requerimientos Funcionales

- **RF-01 Inventario por lote/caducidad:** `lotes`, `inventario_movimientos`, endpoints de entradas y dispensación.
- **RF-02 PEPS:** selección automática de lotes por caducidad ascendente en dispensación.
- **RF-03 Control regulado:** bloqueo sin receta válida en módulo de dispensación.
- **RF-04 Convenios:** motor de descuentos por empresa/convenio.
- **RF-05 Crédito:** `estado_cuenta_empresa` y `pagos_empresa` para consolidado mensual.
- **RF-06 CFDI:** módulo de facturación con integración PAC (stub en esta fase).
- **RF-07 Corte de caja:** restricción de apertura con turno previo pendiente.
- **RF-08 Auditoría:** middleware global + bitácora de cambios críticos.

## Requerimientos No Funcionales

- Disponibilidad mínima 99% (operación + monitoreo).
- Respaldo automático diario (script de BD recomendado).
- Tiempo de respuesta < 3s (índices y queries optimizadas).
- Soporte de 10 concurrentes (dimensionamiento inicial).

## Reglas de negocio implementadas en base

1. No venta sin stock.
2. No descuento manual sin autorización.
3. No eliminación de venta facturada.
4. Regulados requieren receta.
5. No nuevo turno sin cierre previo.
6. Empresa bloqueada no puede generar crédito.
7. Todo ajuste de inventario se audita.
