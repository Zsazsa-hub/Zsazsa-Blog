#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/db/migrations"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "Please set DATABASE_URL environment variable (e.g. postgresql://user:pass@host:5432/db)" >&2
  exit 1
fi

for f in "$MIGRATIONS_DIR"/*.sql; do
  echo "Applying migration: $f"
  psql "$DATABASE_URL" -f "$f"
done

echo "Migrations applied."
