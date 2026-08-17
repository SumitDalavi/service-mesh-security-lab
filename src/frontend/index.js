const express = require('express');
const axios = require('axios');
const app = express();
const port = 3000;

const ORDERS_URL = process.env.ORDERS_URL || 'http://orders.default.svc.cluster.local:3000';

app.get('/frontend', async (req, res) => {
  try {
    const response = await axios.get(`${ORDERS_URL}/orders`);
    res.json({ message: 'Hello from Frontend!', ordersResponse: response.data });
  } catch (error) {
    console.error('Error calling orders:', error.message);
    res.status(500).json({ error: 'Failed to communicate with orders service' });
  }
});

app.listen(port, () => {
  console.log(`Frontend service listening at http://localhost:${port}`);
});
