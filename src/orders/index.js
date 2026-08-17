const express = require('express');
const axios = require('axios');
const app = express();
const port = 3000;

const PAYMENTS_URL = process.env.PAYMENTS_URL || 'http://payments.default.svc.cluster.local:3000';

app.get('/orders', async (req, res) => {
  try {
    const response = await axios.get(`${PAYMENTS_URL}/payments`);
    res.json({ message: 'Orders processed.', paymentsResponse: response.data });
  } catch (error) {
    console.error('Error calling payments:', error.message);
    res.status(500).json({ error: 'Failed to communicate with payments service' });
  }
});

app.listen(port, () => {
  console.log(`Orders service listening at http://localhost:${port}`);
});
