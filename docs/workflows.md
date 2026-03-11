# Flujos Operativos Integrados

## Flujo principal E2E

1. Se recibe medicamento y se registra por lote/caducidad/proveedor.
2. Médico genera orden médica interna.
3. Farmacia valida stock y dispensa con estrategia PEPS.
4. Si aplica convenio, se calcula descuento empresarial automático.
5. Recepción cobra (efectivo/tarjeta/transferencia/mixto).
6. Se emite CFDI 4.0.
7. Inventario se impacta por lote específico.
8. Se escribe evento en bitácora de auditoría.
9. Venta impacta al corte de caja activo del turno.
10. Si es crédito empresarial, se agrega al estado de cuenta mensual.

## Controlados

- Venta/dispensación bloqueada si no existe receta válida.
- Captura obligatoria de:
  - Médico
  - Cédula profesional
  - Paciente
  - Folio de receta
- Registro en bitácora especial no editable.

## Corte de caja

- Un turno activo por caja.
- No se permite abrir turno nuevo con turno previo sin cerrar.
- Al cierre:
  - Total por método de pago
  - Efectivo esperado
  - Diferencias
  - Incidencias
  - Reporte histórico (PDF en implementación futura)
