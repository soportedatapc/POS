const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../../config/env');

const router = express.Router();

const demoUsers = [
  { id: 'u-admin', email: 'admin@sigh.local', pass: bcrypt.hashSync('Admin123*', 8), rol: 'ADMIN' },
  { id: 'u-farmacia', email: 'farmacia@sigh.local', pass: bcrypt.hashSync('Farmacia123*', 8), rol: 'FARMACIA' },
  { id: 'u-caja', email: 'caja@sigh.local', pass: bcrypt.hashSync('Caja123*', 8), rol: 'CAJA' },
  { id: 'u-medico', email: 'medico@sigh.local', pass: bcrypt.hashSync('Medico123*', 8), rol: 'MEDICO' },
  { id: 'u-auditor', email: 'auditor@sigh.local', pass: bcrypt.hashSync('Auditor123*', 8), rol: 'AUDITOR' },
];

router.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = demoUsers.find((u) => u.email === email);
  if (!user || !bcrypt.compareSync(password, user.pass)) {
    return res.status(401).json({ error: 'Credenciales inválidas' });
  }

  const token = jwt.sign({ sub: user.id, rol: user.rol, email: user.email }, jwtSecret, { expiresIn: '8h' });
  return res.json({ token, rol: user.rol });
});

module.exports = router;
