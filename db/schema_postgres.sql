-- PostgreSQL schema example for Zsazsa Blog / Store
-- Run these statements in your database to create basic tables.

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(255),
  phone VARCHAR(32),
  role VARCHAR(32) DEFAULT 'customer',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  sku VARCHAR(128) UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(12,2) NOT NULL,
  stock INTEGER DEFAULT 0,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  status VARCHAR(32) DEFAULT 'pending',
  total_amount NUMERIC(12,2) NOT NULL,
  shipping_address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price NUMERIC(12,2) NOT NULL
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES orders(id),
  provider VARCHAR(64),
  provider_txn_id VARCHAR(255),
  amount NUMERIC(12,2),
  currency VARCHAR(8) DEFAULT 'IDR',
  status VARCHAR(32),
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE technicians (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  phone VARCHAR(32),
  rating NUMERIC(2,1),
  notes TEXT
);

CREATE TABLE service_requests (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  technician_id INTEGER REFERENCES technicians(id),
  product_info TEXT,
  issue_description TEXT,
  status VARCHAR(32) DEFAULT 'requested',
  scheduled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE referrals (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  code VARCHAR(128) UNIQUE,
  source VARCHAR(128),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes and basic optimizations
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
