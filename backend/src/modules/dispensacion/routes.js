const express = require('express');
const { requireAuth, requireRoles } = require('../../middleware/auth');
const { auditEvent } = require('../../middleware/audit');
const { lotesDisponiblesPorPEPS, medicamentos } = require('../inventario/service');

const router = express.Router();

router.post('/', requireAuth, requireRoles('ADMIN', 'FARMACIA'), (req, res) => {
  const { medicamentoId, cantidad, recetaControlada } = req.body;
  const med = medicamentos.find((m) => m.id === medicamentoId);
  if (!med) return res.status(404).json({ error: 'Medicamento no encontrado' });

  if ((med.clasificacion === 'CONTROLADO' || med.clasificacion === 'PSICOTROPICO') && !recetaControlada?.folioReceta) {
    return res.status(400).json({ error: 'Medicamento regulado requiere receta capturada (RF-03)' });
  }

  const peps = lotesDisponiblesPorPEPS(medicamentoId);
  let restante = Number(cantidad);
  const asignaciones = [];

  for (const lote of peps) {
    if (restante <= 0) break;
    const tomar = Math.min(restante, lote.cantidadDisponible);
    if (tomar > 0) {
      lote.cantidadDisponible -= tomar;
      restante -= tomar;
      asignaciones.push({ loteId: lote.id, cantidad: tomar, caducidad: lote.fechaCaducidad });
    }
  }

  if (restante > 0) return res.status(400).json({ error: 'Stock insuficiente' });

  const resultado = { medicamentoId, cantidad, surtidoPorPEPS: asignaciones, responsable: req.user.sub };
  auditEvent({ modulo: 'dispensacion', accion: 'surtir', entidad: 'medicamento', entidadId: medicamentoId, nuevos: resultado })(req);
  return res.json(resultado);
});

module.exports = router;
