const express = require('express');
const { requireAuth, requireRoles } = require('../../middleware/auth');
const { auditEvent } = require('../../middleware/audit');
const { registrarMedicamento, registrarLote, alertasCaducidad, medicamentos, lotes } = require('./service');

const router = express.Router();

router.post('/medicamentos', requireAuth, requireRoles('ADMIN', 'FARMACIA'), (req, res) => {
  const creado = registrarMedicamento(req.body);
  auditEvent({ modulo: 'inventario', accion: 'crear', entidad: 'medicamento', entidadId: creado.id, nuevos: creado })(req);
  res.status(201).json(creado);
});

router.post('/lotes', requireAuth, requireRoles('ADMIN', 'FARMACIA'), (req, res) => {
  const creado = registrarLote(req.body);
  auditEvent({ modulo: 'inventario', accion: 'entrada', entidad: 'lote', entidadId: creado.id, nuevos: creado })(req);
  res.status(201).json(creado);
});

router.get('/medicamentos', requireAuth, (_req, res) => res.json(medicamentos));
router.get('/lotes', requireAuth, (_req, res) => res.json(lotes));
router.get('/alertas-caducidad', requireAuth, (_req, res) => res.json(alertasCaducidad()));

module.exports = router;
