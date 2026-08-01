#!/usr/bin/env bash
set -euo pipefail

# Backup Postgres database either via docker compose 'db' service or via DATABASE_URL
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

# Optional vars from .env
if [ -f .env ]; then
  set -a; . .env; set +a
fi

# Retention and optional S3 upload
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-14}
AWS_S3_BUCKET=${AWS_S3_BUCKET:-}
AWS_REGION=${AWS_REGION:-}

COMPOSE_FILES=(docker-compose.prod.yml)
if [ -f docker-compose.traefik.yml ]; then
  COMPOSE_FILES+=(docker-compose.traefik.yml)
fi
if [ -f docker-compose.proxy.yml ]; then
  COMPOSE_FILES+=(docker-compose.proxy.yml)
fi

DOCKER_COMPOSE_CMD=(docker compose)
for f in "${COMPOSE_FILES[@]}"; do
  DOCKER_COMPOSE_CMD+=( -f "$f" )
done

echo "Looking for 'db' service in compose..."
if "${DOCKER_COMPOSE_CMD[@]}" config --services | grep -q '^db$'; then
  echo "Found db service; performing pg_dump inside container"
  FILE="$BACKUP_DIR/db-$TIMESTAMP.sql"
  # Use exec -T to avoid tty issues
  "${DOCKER_COMPOSE_CMD[@]}" exec -T db pg_dump -U ${POSTGRES_USER:-zsazsa} ${POSTGRES_DB:-zsazsa} > "$FILE"
  echo "Backup saved to $FILE"

  # Optional GPG encryption
  UPLOAD_FILE="$FILE"
  if [ -n "${BACKUP_GPG_RECIPIENT:-}" ] || [ -n "${BACKUP_GPG_PUBKEY_PATH:-}" ]; then
    if ! command -v gpg >/dev/null 2>&1; then
      echo "gpg not found; cannot encrypt backup" >&2
    else
      echo "Encrypting backup with GPG..."
      if [ -n "${BACKUP_GPG_PUBKEY_PATH:-}" ]; then
        TMPGNUPGHOME=$(mktemp -d)
        export GNUPGHOME="$TMPGNUPGHOME"
        gpg --import "$BACKUP_GPG_PUBKEY_PATH" >/dev/null 2>&1 || echo "gpg import failed"
        RECIPIENT=$(gpg --list-keys --with-colons | awk -F: '/^pub/ {print $5; exit}') || true
        if [ -n "$RECIPIENT" ]; then
          gpg --batch --yes -e -r "$RECIPIENT" -o "$FILE.gpg" "$FILE" || echo "gpg encrypt failed"
          UPLOAD_FILE="$FILE.gpg"
        else
          echo "No recipient found in imported key; skipping encryption" >&2
        fi
        rm -rf "$TMPGNUPGHOME"
        unset GNUPGHOME
      elif [ -n "${BACKUP_GPG_RECIPIENT:-}" ]; then
        gpg --batch --yes -e -r "$BACKUP_GPG_RECIPIENT" -o "$FILE.gpg" "$FILE" || echo "gpg encrypt failed"
        UPLOAD_FILE="$FILE.gpg"
      fi

      if [ "${BACKUP_DELETE_PLAIN_AFTER_ENCRYPTION:-false}" = "true" ] && [ "$UPLOAD_FILE" = "$FILE.gpg" ]; then
        rm -f "$FILE" || true
      fi
    fi
  fi

  # Optionally upload to S3
  if [ -n "${AWS_S3_BUCKET:-}" ]; then
    if command -v aws >/dev/null 2>&1; then
      echo "Uploading $UPLOAD_FILE to s3://$AWS_S3_BUCKET/"
      if [ -n "$AWS_REGION" ]; then
        aws --region "$AWS_REGION" s3 cp "$UPLOAD_FILE" "s3://$AWS_S3_BUCKET/" || echo "S3 upload failed"
      else
        aws s3 cp "$UPLOAD_FILE" "s3://$AWS_S3_BUCKET/" || echo "S3 upload failed"
      fi
    else
      echo "aws CLI not found; skipping S3 upload" >&2
    fi
  fi

  # Rotate old backups
  echo "Removing local backups older than $BACKUP_RETENTION_DAYS days..."
  find "$BACKUP_DIR" -type f -mtime +$BACKUP_RETENTION_DAYS -print -delete || true

  exit 0
fi

if [ -n "${DATABASE_URL:-}" ]; then
  echo "No db service found; attempting pg_dump using DATABASE_URL"
  FILE="$BACKUP_DIR/db-$TIMESTAMP.sql"
  if command -v pg_dump >/dev/null 2>&1; then
    echo "Using pg_dump from PATH"
    pg_dump "$DATABASE_URL" -F p -f "$FILE"
    echo "Backup saved to $FILE"

    # Optional GPG encryption
    UPLOAD_FILE="$FILE"
    if [ -n "${BACKUP_GPG_RECIPIENT:-}" ] || [ -n "${BACKUP_GPG_PUBKEY_PATH:-}" ]; then
      if ! command -v gpg >/dev/null 2>&1; then
        echo "gpg not found; cannot encrypt backup" >&2
      else
        echo "Encrypting backup with GPG..."
        if [ -n "${BACKUP_GPG_PUBKEY_PATH:-}" ]; then
          TMPGNUPGHOME=$(mktemp -d)
          export GNUPGHOME="$TMPGNUPGHOME"
          gpg --import "$BACKUP_GPG_PUBKEY_PATH" >/dev/null 2>&1 || echo "gpg import failed"
          RECIPIENT=$(gpg --list-keys --with-colons | awk -F: '/^pub/ {print $5; exit}') || true
          if [ -n "$RECIPIENT" ]; then
            gpg --batch --yes -e -r "$RECIPIENT" -o "$FILE.gpg" "$FILE" || echo "gpg encrypt failed"
            UPLOAD_FILE="$FILE.gpg"
          else
            echo "No recipient found in imported key; skipping encryption" >&2
          fi
          rm -rf "$TMPGNUPGHOME"
          unset GNUPGHOME
        elif [ -n "${BACKUP_GPG_RECIPIENT:-}" ]; then
          gpg --batch --yes -e -r "$BACKUP_GPG_RECIPIENT" -o "$FILE.gpg" "$FILE" || echo "gpg encrypt failed"
          UPLOAD_FILE="$FILE.gpg"
        fi

        if [ "${BACKUP_DELETE_PLAIN_AFTER_ENCRYPTION:-false}" = "true" ] && [ "$UPLOAD_FILE" = "$FILE.gpg" ]; then
          rm -f "$FILE" || true
        fi
      fi
    fi

    # Optional: upload to S3
    if [ -n "$AWS_S3_BUCKET" ]; then
      if command -v aws >/dev/null 2>&1; then
        echo "Uploading $UPLOAD_FILE to s3://$AWS_S3_BUCKET/"
        if [ -n "$AWS_REGION" ]; then
          aws --region "$AWS_REGION" s3 cp "$UPLOAD_FILE" "s3://$AWS_S3_BUCKET/" || echo "S3 upload failed"
        else
          aws s3 cp "$UPLOAD_FILE" "s3://$AWS_S3_BUCKET/" || echo "S3 upload failed"
        fi
      else
        echo "aws CLI not found; skipping S3 upload" >&2
      fi
    fi

    # Rotate old backups
    echo "Removing local backups older than $BACKUP_RETENTION_DAYS days..."
    find "$BACKUP_DIR" -type f -mtime +$BACKUP_RETENTION_DAYS -print -delete || true

    exit 0
  else
    echo "pg_dump not found on PATH. Install postgresql-client or configure 'db' service." >&2
    exit 1
  fi
fi

echo "No db service and no DATABASE_URL; skipping backup." >&2
exit 1
