const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 4000;

let pool;
if (process.env.DATABASE_URL) {
  pool = new Pool({ connectionString: process.env.DATABASE_URL });
}

app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.get('/api/products', async (req, res) => {
  if (!pool) return res.json({ products: [] });
  try {
    const { rows } = await pool.query('SELECT id, name, price, stock FROM products LIMIT 50');
    res.json({ products: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error' });
  }
});

app.listen(port, () => console.log(`Backend listening on ${port}`));
