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
