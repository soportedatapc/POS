const express = require('express');
const { requireAuth, requireRoles } = require('../../middleware/auth');
const { auditEvent } = require('../../middleware/audit');

const router = express.Router();
const cortes = [];

router.post('/abrir', requireAuth, requireRoles('ADMIN', 'CAJA'), (req, res) => {
  const abierto = cortes.find((c) => c.usuarioId === req.user.sub && c.estatus === 'ABIERTO');
  if (abierto) {
    return res.status(400).json({ error: 'Debe cerrar turno anterior antes de abrir uno nuevo (RF-07)' });
  }

  const corte = {
    id: `c-${cortes.length + 1}`,
    usuarioId: req.user.sub,
    turno: req.body.turno,
    estatus: 'ABIERTO',
    totales: { efectivo: 0, tarjeta: 0, transferencia: 0 },
    incidencias: [],
    openedAt: new Date().toISOString(),
  };
  cortes.push(corte);
  auditEvent({ modulo: 'caja', accion: 'abrir_turno', entidad: 'corte', entidadId: corte.id, nuevos: corte })(req);
  res.status(201).json(corte);
});

router.post('/cerrar/:id', requireAuth, requireRoles('ADMIN', 'CAJA'), (req, res) => {
  const corte = cortes.find((c) => c.id === req.params.id && c.usuarioId === req.user.sub);
  if (!corte || corte.estatus !== 'ABIERTO') return res.status(404).json({ error: 'Corte abierto no encontrado' });

  corte.estatus = 'CERRADO';
  corte.efectivoEsperado = req.body.efectivoEsperado || 0;
  corte.diferencia = (corte.totales.efectivo || 0) - corte.efectivoEsperado;
  corte.closedAt = new Date().toISOString();

  auditEvent({ modulo: 'caja', accion: 'cerrar_turno', entidad: 'corte', entidadId: corte.id, nuevos: corte })(req);
  res.json(corte);
});

router.get('/cortes', requireAuth, requireRoles('ADMIN', 'CAJA', 'AUDITOR'), (_req, res) => {
  res.json(cortes);
});

module.exports = router;
