#!/usr/bin/env bash
set -euo pipefail

# Production deploy helper
# Usage: place .env in repo root on remote server, then run this script

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

# Export variables from .env if present
if [ -f .env ]; then
  echo "Loading .env"
  set -a
  # shellcheck disable=SC1091
  . .env
  set +a
fi

COMPOSE_FILES=(docker-compose.prod.yml)
if [ -f docker-compose.traefik.yml ]; then
  COMPOSE_FILES+=(docker-compose.traefik.yml)
fi
if [ -f docker-compose.proxy.yml ]; then
  COMPOSE_FILES+=(docker-compose.proxy.yml)
fi

echo "Using compose files: ${COMPOSE_FILES[*]}"

DOCKER_COMPOSE_CMD=(docker compose)
for f in "${COMPOSE_FILES[@]}"; do
  DOCKER_COMPOSE_CMD+=( -f "$f" )
done

echo "Pulling images (if present in registry)..."
"${DOCKER_COMPOSE_CMD[@]}" pull || true

echo "Starting services..."
"${DOCKER_COMPOSE_CMD[@]}" up -d --remove-orphans

sleep 2
"${DOCKER_COMPOSE_CMD[@]}" ps

if "${DOCKER_COMPOSE_CMD[@]}" ps --services | grep -q backend; then
  echo "Running migrations inside backend container..."
  "${DOCKER_COMPOSE_CMD[@]}" exec -T backend sh -c 'npm run migrate' || echo "Migrations failed (continuing)"
fi

echo "Showing last 60 log lines for services"
"${DOCKER_COMPOSE_CMD[@]}" logs --tail=60

echo "Deploy complete."
