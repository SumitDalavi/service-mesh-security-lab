const express = require('express');
const app = express();
const port = 3000;

app.get('/payments', (req, res) => {
  res.json({ message: 'Payment successful.' });
});

app.listen(port, () => {
  console.log(`Payments service listening at http://localhost:${port}`);
});
