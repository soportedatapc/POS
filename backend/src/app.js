const express = require('express');

const authRoutes = require('./modules/auth/routes');
const inventarioRoutes = require('./modules/inventario/routes');
const dispensacionRoutes = require('./modules/dispensacion/routes');
const cajaRoutes = require('./modules/caja/routes');
const auditoriaRoutes = require('./modules/auditoria/routes');
const reportesRoutes = require('./modules/reportes/routes');

const app = express();
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true, service: 'SIGH API' }));
app.use('/api/auth', authRoutes);
app.use('/api/inventario', inventarioRoutes);
app.use('/api/dispensacion', dispensacionRoutes);
app.use('/api/caja', cajaRoutes);
app.use('/api/auditoria', auditoriaRoutes);
app.use('/api/reportes', reportesRoutes);

module.exports = app;
