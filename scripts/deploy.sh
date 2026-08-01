#!/usr/bin/env bash
set -euo pipefail

# Simple deploy script: build image, optionally push, and bring up compose
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

IMAGE_NAME=${IMAGE_NAME:-zsazsa-blog-web}
TAG=${TAG:-latest}

echo "Building Docker image $IMAGE_NAME:$TAG..."
docker build -t "$IMAGE_NAME:$TAG" .

if [ -n "${DOCKER_PUSH:-}" ]; then
  if [ -z "${DOCKER_USER:-}" ]; then
    echo "DOCKER_USER not set, skipping push" >&2
  else
    docker tag "$IMAGE_NAME:$TAG" "$DOCKER_USER/$IMAGE_NAME:$TAG"
    docker push "$DOCKER_USER/$IMAGE_NAME:$TAG"
  fi
fi

echo "Starting containers with docker compose..."
docker compose up --build -d

echo "Containers status:"
docker compose ps

echo "Done."
