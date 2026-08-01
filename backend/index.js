const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const port = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET || 'changeme_jwt_secret';

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

// Basic auth: register and login (demo only)
app.post('/api/register', async (req, res) => {
  const { email, password, full_name } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'missing' });
  const hash = await bcrypt.hash(password, 10);
  if (!pool) return res.status(500).json({ error: 'no db' });
  try {
    const { rows } = await pool.query('INSERT INTO users (email, password_hash, full_name) VALUES ($1,$2,$3) RETURNING id,email,full_name', [email, hash, full_name || null]);
    const user = rows[0];
    const token = jwt.sign({ sub: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ user, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error' });
  }
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'missing' });
  if (!pool) return res.status(500).json({ error: 'no db' });
  try {
    const { rows } = await pool.query('SELECT id, email, password_hash, full_name FROM users WHERE email=$1', [email]);
    const user = rows[0];
    if (!user) return res.status(401).json({ error: 'invalid' });
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: 'invalid' });
    const token = jwt.sign({ sub: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ user: { id: user.id, email: user.email, full_name: user.full_name }, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error' });
  }
});

// Protected route: return current user info from JWT
function authenticateJWT(req, res, next) {
  const auth = req.headers['authorization'];
  if (!auth || !auth.startsWith('Bearer ')) return res.status(401).json({ error: 'missing_token' });
  const token = auth.slice(7);
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch (e) {
    return res.status(401).json({ error: 'invalid_token' });
  }
}

app.get('/api/me', authenticateJWT, async (req, res) => {
  const payload = req.user || {};
  // Optionally load more user data from DB
  if (pool && payload.sub) {
    try {
      const { rows } = await pool.query('SELECT id, email, full_name FROM users WHERE id=$1', [payload.sub]);
      if (rows[0]) return res.json({ user: rows[0] });
    } catch (e) {
      console.error('me route db error', e);
    }
  }
  // Fallback: return token payload
  res.json({ user: payload });
});

// Payment endpoints (mock)
app.post('/api/payments/create', async (req, res) => {
  const { order_id, method, amount, currency } = req.body || {};
  // For demo, create a mock transaction and return payment instructions
  const txn = {
    id: `txn_${Date.now()}`,
    order_id: order_id || null,
    method: method || 'qris',
    amount: amount || 0,
    currency: currency || 'IDR',
    status: 'pending',
    created_at: new Date().toISOString()
  };

  // In production, insert into transactions table
  if (pool) {
    try {
      await pool.query('INSERT INTO transactions (order_id, provider, amount, currency, status, metadata) VALUES ($1,$2,$3,$4,$5,$6)', [txn.order_id, txn.method, txn.amount, txn.currency, txn.status, JSON.stringify({ mock: true })]);
    } catch (e) {
      console.error('insert txn error', e);
    }
  }

  // Return mock payment data for client
  if (txn.method === 'crypto') {
    txn.address = '0xDEADBEEF...';
    txn.qr = null;
  } else if (txn.method === 'qris') {
    txn.qr = 'data:image/png;base64,iVBORw0K...';
  } else if (txn.method === 'ewallet') {
    txn.redirect_url = 'https://ewallet.example/checkout/' + txn.id;
  }

  res.json({ transaction: txn });
});

app.post('/api/payments/webhook', express.raw({ type: '*/*' }), async (req, res) => {
  // A generic webhook endpoint: verify signature in production
  try {
    const body = req.body.length ? req.body.toString() : '';
    console.log('webhook received', body.substring(0, 200));
    // Update transaction status in DB if possible (demo only)
    res.status(200).send('ok');
  } catch (e) {
    console.error('webhook error', e);
    res.status(500).send('error');
  }
});

app.listen(port, () => console.log(`Backend listening on ${port}`));
