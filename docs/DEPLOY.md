# Deploy (production)

Use `scripts/deploy_prod.sh` to deploy the application on a server that has Docker and Docker Compose.

Steps:

1. Copy `.env.example` to `.env` and fill in real values (domain, Postgres credentials, JWT secret, deploy path, etc.).

2. Push repository to the server or copy files via `scp`/`rsync` into the deploy path.

3. On the server, run:

```bash
cd /path/to/repo
chmod +x scripts/deploy_prod.sh
./scripts/deploy_prod.sh
```

Notes:
- The script will include `docker-compose.prod.yml` plus optional `docker-compose.traefik.yml` and `docker-compose.proxy.yml` if they exist.
- Traefik requires domain DNS pointing to the server and ports 80/443 open for ACME challenge.
- The deploy workflow in GitHub Actions can also perform this remotely if you set the SSH secrets: `SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_PATH`.
 - The deploy workflow in GitHub Actions can also perform this remotely if you set the SSH secrets: `SSH_PRIVATE_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_PATH`.

S3 Upload & Rotation
- To enable automatic upload of backups to S3 (or S3-compatible storage), set the following in `.env`:
	- `AWS_S3_BUCKET` (e.g. `my-bucket/backups`)
	- `AWS_REGION` (optional)
	- Ensure `aws` CLI is installed on the server and credentials (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`) are available in the environment or instance profile.
- The deploy script will call `scripts/backup_db.sh` which uploads the newly created backup to S3 and deletes local backup files older than `BACKUP_RETENTION_DAYS` (default 14 days).

GPG Encryption for Backups
- You can encrypt backups before upload for extra security. Two modes are supported:
	- `BACKUP_GPG_RECIPIENT`: a GPG key recipient (key ID or email) already present in the server's GPG keyring.
	- `BACKUP_GPG_PUBKEY_PATH`: path to an ASCII-armored public key file; the script will import it into a temporary keyring and use it to encrypt the backup.
- Set one of the above in `.env`. Optionally set `BACKUP_DELETE_PLAIN_AFTER_ENCRYPTION=true` to remove the plaintext dump after successful encryption.
- The script requires `gpg` to be installed on the server for encryption to work.
Backup & preflight:
- The deploy script now runs `scripts/backup_db.sh` before migrations. This will try to create a dump using the `db` service (`pg_dump` inside container) or using `DATABASE_URL` with `pg_dump` on the host.
- Ensure `pg_dump` is available on the server if you use an external `DATABASE_URL`.
