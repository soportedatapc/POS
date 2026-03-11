const { medicamentos, lotes } = require('./store');

function registrarMedicamento(data) {
  const nuevo = { id: `m-${medicamentos.length + 1}`, ...data };
  medicamentos.push(nuevo);
  return nuevo;
}

function registrarLote(data) {
  const nuevo = {
    id: `l-${lotes.length + 1}`,
    bloqueado: false,
    cantidadDisponible: data.cantidadRecibida,
    ...data,
  };
  lotes.push(nuevo);
  return nuevo;
}

function lotesDisponiblesPorPEPS(medicamentoId) {
  const hoy = new Date();
  return lotes
    .filter((l) => l.medicamentoId === medicamentoId && !l.bloqueado && l.cantidadDisponible > 0 && new Date(l.fechaCaducidad) >= hoy)
    .sort((a, b) => new Date(a.fechaCaducidad) - new Date(b.fechaCaducidad));
}

function alertasCaducidad() {
  const hoy = new Date();
  return lotes.map((l) => {
    const dias = Math.ceil((new Date(l.fechaCaducidad) - hoy) / (1000 * 60 * 60 * 24));
    const alerta = dias <= 30 ? 'ROJA' : dias <= 60 ? 'NARANJA' : dias <= 90 ? 'AMARILLA' : 'NINGUNA';
    return { loteId: l.id, medicamentoId: l.medicamentoId, dias, alerta };
  });
}

module.exports = { registrarMedicamento, registrarLote, lotesDisponiblesPorPEPS, alertasCaducidad, medicamentos, lotes };
