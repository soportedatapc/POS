const express = require('express');
const { requireAuth, requireRoles } = require('../../middleware/auth');
const { medicamentos, lotes } = require('../inventario/service');

const router = express.Router();

router.get('/inventario-actual', requireAuth, requireRoles('ADMIN', 'FARMACIA', 'AUDITOR'), (_req, res) => {
  const reporte = medicamentos.map((m) => {
    const lotesMed = lotes.filter((l) => l.medicamentoId === m.id);
    const existencia = lotesMed.reduce((acc, l) => acc + l.cantidadDisponible, 0);
    return {
      medicamentoId: m.id,
      nombre: m.nombreComercial,
      existencia,
      valor: existencia * Number(m.precioCompra || 0),
    };
  });
  res.json(reporte);
});

module.exports = router;
