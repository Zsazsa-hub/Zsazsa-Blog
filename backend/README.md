# Zsazsa Backend

Minimal Node/Express backend used for examples and deployment.

Environment variables:
- `DATABASE_URL` — PostgreSQL connection string (optional)
- `PORT` — port to run (default 4000)

Run locally:

```bash
cd backend
npm install
DATABASE_URL=postgres://user:pass@localhost:5432/dbname node index.js
```
