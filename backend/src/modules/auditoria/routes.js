const express = require('express');
const { requireAuth, requireRoles } = require('../../middleware/auth');
const { getAuditStore } = require('../../middleware/audit');

const router = express.Router();

router.get('/bitacora', requireAuth, requireRoles('ADMIN', 'AUDITOR'), (_req, res) => {
  res.json(getAuditStore());
});

module.exports = router;
