# Deploying Omlapay to a VPS

One Ubuntu 24.04 server runs two separate stacks plus one Caddy proxy:

```
Internet ──443──> Caddy (automatic HTTPS)
                   ├─ api.omlapay.org      ─> omlapay-prod backend ─> prod Postgres
                   ├─ admin.omlapay.org    ─> omlapay-prod admin (static, nginx)
                   └─ api-dev.omlapay.org  ─> omlapay-dev backend  ─> dev Postgres
File uploads ─> Cloudflare R2: omlapay-prod-uploads / omlapay-dev-uploads
```

| | Production | Dev |
|---|---|---|
| Checkout | `/home/deploy/app` (branch `main`) | `/home/deploy/app-dev` (branch `develop`) |
| Settings | `/home/deploy/app/deploy/.env` | `/home/deploy/app-dev/deploy/.env` |
| Compose project | `omlapay-prod` | `omlapay-dev` |
| `NODE_ENV` | `production` | `staging` |
| Admin panel | yes (`COMPOSE_PROFILES=admin`) | no |

The stacks share nothing but the `omlapay-web` network that Caddy uses to reach them. Databases
are never exposed to the internet. Caddy runs from the production checkout
(`deploy/proxy/`, settings in `deploy/proxy/.env`).

## What Caddy blocks

On both APIs, until fixed in the code, Caddy answers 404 to:
- `/v1/admin/auth/create-super-admin` (creates a Super Admin without logging in)
- `/v1/dev-tools/*` (test tools, one of which wipes the database)

Webhooks (`/v1/user/webhooks/sumsub`, `/v1/user/webhooks/binance-kyc`) stay open. The API docs
(`/docs`) are protected by the app's own `SWAGGER_USER` / `SWAGGER_PASSWORD`.

To create the first admin while that route is blocked, see "First admin" below.

## Dev (staging) behaviour

`api-dev` runs with `NODE_ENV=staging`: OTP codes are not returned in API responses, and the app
does not send SMS outside production. Codes are written to the backend log instead:

```bash
cd /home/deploy/app-dev && docker compose -f deploy/docker-compose.yml logs -f backend | grep -i otp
```

Never set `NODE_ENV=development` on this server: that returns OTP codes in API responses.

## Cloudflare R2 (file uploads)

1. Cloudflare dashboard → **R2 Object Storage** → enable it (free tier: 10 GB).
2. **Create bucket** twice: `omlapay-prod-uploads` and `omlapay-dev-uploads`.
3. Each bucket → **Settings → Public access → Custom Domains → Connect domain**:
   `files.omlapay.org` for prod, `files-dev.omlapay.org` for dev. Cloudflare creates the DNS
   record itself. Uploaded files are reachable by anyone who has their (random) URL, as with
   the previous S3 setup.
4. R2 → **Manage API tokens → Create API token**, twice:
   permission **Object Read & Write**, **Apply to specific buckets only**: the prod bucket for one
   token, the dev bucket for the other. Copy the **Access Key ID** and **Secret Access Key**
   (shown once).
5. Your **Account ID** is on the R2 overview page.

Values for each `deploy/.env` (fill them in yourself on the server):

| Variable | Production | Dev |
|---|---|---|
| `AWS_REGION` | `auto` | `auto` |
| `S3_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` | same |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | prod token | dev token |
| `S3_BUCKET_NAME` | `omlapay-prod-uploads` | `omlapay-dev-uploads` |
| `S3_PUBLIC_URL` | `https://files.omlapay.org` | `https://files-dev.omlapay.org` |

## First-time setup

Server preparation (user `deploy`, Docker, firewall 22/80/443, fail2ban, automatic updates,
SSH keys only) is done once; the steps are recorded at the end of this file.

As `deploy`:

```bash
# 1. Read-only GitHub deploy key (add the .pub to GitHub → repo → Settings → Deploy keys)
ssh-keygen -t ed25519 -N '' -C 'omlapay-vps-deploy' -f ~/.ssh/github_deploy
cat >> ~/.ssh/config <<'EOF'
Host github.com
  IdentityFile ~/.ssh/github_deploy
  IdentitiesOnly yes
EOF
ssh-keyscan github.com >> ~/.ssh/known_hosts

# 2. Two checkouts
git clone -b main    git@github.com:adialaqeeli1/Omlapay.git /home/deploy/app
git clone -b develop git@github.com:adialaqeeli1/Omlapay.git /home/deploy/app-dev

# 3. Settings from the templates (then fill in every CHANGE_ME and empty value yourself)
install -m 600 /home/deploy/app/deploy/.env.example        /home/deploy/app/deploy/.env
install -m 600 /home/deploy/app-dev/deploy/.env.example    /home/deploy/app-dev/deploy/.env
install -m 600 /home/deploy/app/deploy/proxy/.env.example  /home/deploy/app/deploy/proxy/.env
```

In `app-dev/deploy/.env` change the lines marked `[dev]`: `COMPOSE_PROJECT_NAME=omlapay-dev`,
`STACK=dev`, `COMPOSE_PROFILES=` (empty), `NODE_ENV=staging`,
`API_BASE_URL=https://api-dev.omlapay.org`, `CORS_ORIGINS=` (empty), the dev bucket values.
Use different secrets for prod and dev. Keep `$` out of values (use `openssl rand -hex 32`).

```bash
# 4. Start: proxy first (it creates the shared network), then the stacks
cd /home/deploy/app     && docker compose -f deploy/proxy/docker-compose.yml up -d
cd /home/deploy/app     && deploy/scripts/deploy.sh
cd /home/deploy/app-dev && deploy/scripts/deploy.sh
```

`deploy.sh` pulls the branch, runs the malware scan, builds, starts, and waits until the
backend is healthy. Database migrations run automatically when the backend starts.

## First admin

`create-super-admin` is blocked on the internet. Create the first admin on the server instead
(type the password at the prompt; it never appears in shell history):

```bash
cd /home/deploy/app
read -rp 'Admin email: ' EMAIL; read -rsp 'Password: ' PASS; echo
HASH=$(docker compose -f deploy/docker-compose.yml exec -T -e P="$PASS" backend \
  node -e "process.stdout.write(require('bcryptjs').hashSync(process.env.P, 10))")
echo "INSERT INTO admins (email, password_hash, role, is_active) VALUES (:'e', :'h', 'SUPER_ADMIN', true);" |
  docker compose -f deploy/docker-compose.yml exec -T db sh -c \
  'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v e="$1" -v h="$2"' _ "$EMAIL" "$HASH"
unset PASS HASH
```

## Updating

Pushes to `main` and `develop` deploy automatically (`.github/workflows/deploy.yml`). By hand:

```bash
/home/deploy/app/deploy/scripts/deploy.sh        # production
/home/deploy/app-dev/deploy/scripts/deploy.sh    # dev
```

After changing a `deploy/.env`, run the same script (it recreates changed containers). After
changing the admin build values, it rebuilds the admin image. After editing
`deploy/proxy/caddy/Caddyfile`:
`docker compose -f deploy/proxy/docker-compose.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`

## Auto-deploy from GitHub Actions

The workflow scans the commit, then connects as `deploy` with a key that may run only
`deploy/scripts/ci-entry.sh`, which accepts only `deploy prod` or `deploy dev`.

On the server (as `deploy`):

```bash
ssh-keygen -t ed25519 -N '' -C 'github-actions' -f ~/ci_key
echo "restrict,command=\"/home/deploy/app/deploy/scripts/ci-entry.sh\" $(cat ~/ci_key.pub)" >> ~/.ssh/authorized_keys
cat ~/ci_key                      # -> secret DEPLOY_SSH_KEY, then: rm ~/ci_key ~/ci_key.pub
ssh-keyscan -t ed25519 localhost  # replace "localhost" with the server IP -> DEPLOY_KNOWN_HOSTS
```

GitHub → repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|---|---|
| `DEPLOY_HOST` | `31.97.32.246` |
| `DEPLOY_SSH_KEY` | the private CI key (whole file) |
| `DEPLOY_KNOWN_HOSTS` | `ssh-keyscan -t ed25519 31.97.32.246` output |

Jobs run in the GitHub environments `production` (main) and `development` (develop). To require
a manual approval before production deploys, add a required reviewer to the `production`
environment (Settings → Environments).

## Backups

Daily at 03:15 UTC (crontab of `deploy`):

```
15 3 * * * /home/deploy/app/deploy/scripts/backup-db.sh /home/deploy/app >> /home/deploy/backups/backup.log 2>&1
45 3 * * * /home/deploy/app-dev/deploy/scripts/backup-db.sh /home/deploy/app-dev >> /home/deploy/backups/backup.log 2>&1
```

Dumps go to `/home/deploy/backups/<project>/` and are kept 14 days (`KEEP_DAYS`). They are on the
same server, so also copy them elsewhere (for example a private R2 bucket) for real safety.

Restore (stops the app, replaces the database; production example):

```bash
cd /home/deploy/app
docker compose -f deploy/docker-compose.yml stop backend
docker compose -f deploy/docker-compose.yml exec -T db sh -c \
  'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists --no-owner' \
  < /home/deploy/backups/omlapay-prod/<file>.dump
docker compose -f deploy/docker-compose.yml start backend
```

`FIELD_ENCRYPTION_KEY` must be the same as when the backup was made, or encrypted fields are
unreadable. Keep a copy of each `deploy/.env` somewhere safe outside the server.

## Troubleshooting

```bash
docker ps                                                      # all containers and health
cd /home/deploy/app && docker compose -f deploy/docker-compose.yml logs --tail 100 backend
cd /home/deploy/app && docker compose -f deploy/proxy/docker-compose.yml logs --tail 100 caddy
```

- Certificates not issued: DNS must point at the server with the Cloudflare proxy off
  (grey cloud), and ports 80/443 must be open.
- Backend restarting: usually a missing or wrong value in `deploy/.env` (the log says which).

## Server preparation (done once)

- User `deploy` with the owner's SSH key, in groups `sudo` and `docker`.
- Docker Engine and the Compose plugin from Docker's apt repository.
- `ufw`: allow 22/tcp, 80/tcp, 443/tcp, 443/udp; deny everything else incoming.
- `fail2ban` with the `sshd` jail.
- `unattended-upgrades` for security updates.
- SSH: `PasswordAuthentication no`, `PermitRootLogin no` (set only after `ssh deploy@<IP>` was
  confirmed working).
