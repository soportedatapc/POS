const app = require('./app');
const { port } = require('./config/env');

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`SIGH API escuchando en puerto ${port}`);
});
