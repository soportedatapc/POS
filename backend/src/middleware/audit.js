const auditStore = [];

function auditEvent({ modulo, accion, entidad, entidadId, anteriores, nuevos }) {
  return (req) => {
    auditStore.push({
      timestamp: new Date().toISOString(),
      usuario: req.user?.sub || 'sistema',
      ipEquipo: req.ip,
      modulo,
      accion,
      entidad,
      entidadId: entidadId || null,
      datosAnteriores: anteriores || null,
      datosNuevos: nuevos || null,
    });
  };
}

function getAuditStore() {
  return auditStore;
}

module.exports = { auditEvent, getAuditStore };
