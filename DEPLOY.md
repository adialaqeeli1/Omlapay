# Deploying Omlapay to a VPS

One Ubuntu 24.04 server (Hostinger `srv2131878`, `2.24.57.218`, used only for OmlaPay) runs two
separate stacks plus one Caddy proxy:

```
Internet ──443──> Caddy (automatic HTTPS)
                   ├─ api.omlapay.org       ─> omlapay-prod backend ─> prod Postgres, prod Garage
                   ├─ admin.omlapay.org     ─> omlapay-prod admin (static, nginx)
                   ├─ files.omlapay.org     ─> prod Garage (uploaded files, read-only)
                   ├─ api-dev.omlapay.org   ─> omlapay-dev backend  ─> dev Postgres, dev Garage
                   └─ files-dev.omlapay.org ─> dev Garage (read-only)
Nightly: database dumps + uploaded files ─> encrypted restic backup ─> Cloudflare R2 (omlapay-backups)
```

| | Production | Dev |
|---|---|---|
| Checkout | `/home/deploy/app` (branch `main`) | `/home/deploy/app-dev` (branch `develop`) |
| Settings | `/home/deploy/app/deploy/.env` | `/home/deploy/app-dev/deploy/.env` |
| Compose project | `omlapay-prod` | `omlapay-dev` |
| `NODE_ENV` | `production` | `staging` |
| Admin panel | yes (`COMPOSE_PROFILES=admin`) | no |
| Uploads bucket | `omlapay-prod-uploads` | `omlapay-dev-uploads` |

The stacks share nothing but the `omlapay-web` network that Caddy uses to reach them. Databases
and Garage's S3 API are never exposed to the internet. Caddy runs from the production checkout
(`deploy/proxy/`, settings in `deploy/proxy/.env`).

## DNS (Cloudflare, DNS only / grey cloud)

A records pointing at `2.24.57.218`: `api`, `api-dev`, `admin`, `files`, `files-dev`
(all `.omlapay.org`). Caddy gets the certificates itself once the records resolve.

## What Caddy blocks

On both APIs, Caddy answers 404 to:
- `/v1/admin/auth/create-super-admin` (creates a Super Admin without logging in)
- `/v1/dev-tools/*` (test tools, one of which wipes the database)
- `/v1/coins/sync` (resets coin fees and limits; also admin-only in the code)

Webhooks (`/v1/user/webhooks/sumsub`, `/v1/user/webhooks/binance-kyc`) stay open; the backend
rejects any webhook without a valid signature (except with `NODE_ENV=development`). The API docs
(`/docs`) are protected by the app's own `SWAGGER_USER` / `SWAGGER_PASSWORD`.

To create the first admin while that route is blocked, see "First admin" below.

## Phone numbers and rate limits

- Only Saudi mobile numbers (`+9665XXXXXXXX`) can receive OTP codes or be set on an account
  (`ALLOWED_PHONE_COUNTRY_CODES=966`). `05…`, `5…`, `9665…` and `+9665…` are accepted and
  normalized; anything else gets a 400 with `code: PHONE_NOT_ALLOWED`, `message` (English) and
  `message_ar` (Arabic).
- Rate limits per client IP: 120 requests/minute in general, 3/minute on routes that send a code,
  5/minute on code/passcode/password checks, 10/minute on check-user. Over the limit: HTTP 429.
  `TRUST_PROXY_HOPS=1` makes the backend see the real client IP behind Caddy.

## Dev (staging) behaviour

`api-dev` runs with `NODE_ENV=staging`: OTP codes are not returned in API responses, and the app
does not send SMS outside production. Codes are written to the backend log instead. Without an
email provider (Postmark), emails are written to the same log, with their codes:

```bash
cd /home/deploy/app-dev && docker compose -f deploy/docker-compose.yml logs -f backend | grep -i otp
```

Never set `NODE_ENV=development` on this server: that returns OTP codes in API responses and
accepts unsigned webhooks.

## File storage (Garage)

Each stack runs its own [Garage](https://garagehq.deuxfleurs.fr/) (S3-compatible, single node),
with its data in Docker volumes on the server. The backend uploads over the stack's internal
network; Caddy serves the files read-only at `files.omlapay.org` / `files-dev.omlapay.org`
(no listing, no uploads, no deletes from the internet). `deploy.sh` runs
`deploy/scripts/garage-init.sh`, which creates the layout, the bucket and the app's key, and is
safe to run again.

Values in each `deploy/.env` (generate them on the server):

| Variable | How to generate | Prod | Dev |
|---|---|---|---|
| `GARAGE_RPC_SECRET` | `openssl rand -hex 32` | own value | own value |
| `AWS_ACCESS_KEY_ID` | `echo GK$(openssl rand -hex 12)` | own value | own value |
| `AWS_SECRET_ACCESS_KEY` | `openssl rand -hex 32` | own value | own value |
| `S3_BUCKET_NAME` | fixed | `omlapay-prod-uploads` | `omlapay-dev-uploads` |
| `S3_PUBLIC_URL` | fixed | `https://files.omlapay.org` | `https://files-dev.omlapay.org` |
| `GARAGE_CAPACITY` | disk space Garage may use | e.g. `20G` | e.g. `5G` |

The bucket names must match the `Host` lines in `deploy/proxy/caddy/Caddyfile`.

Moving to Cloudflare R2 later needs no code change: copy the files with
`docker compose -f deploy/docker-compose.yml run --rm files-backup …`, then set `S3_ENDPOINT`,
`AWS_REGION=auto` and R2 keys in `deploy/.env` and remove the two `S3_ENDPOINT`/`AWS_REGION`
lines under `backend:` in `deploy/docker-compose.yml`.

## Email (Postmark)

The backend sends email through Postmark's API when `POSTMARK_SERVER_TOKEN` is set (Mailgun is
still supported and used only when the Postmark token is empty). Values in each `deploy/.env`:

| Variable | Where to find it in Postmark |
|---|---|
| `POSTMARK_SERVER_TOKEN` | **Servers** → your server → **API Tokens** → Server API token (use a separate Postmark server for dev if you want dev mail kept apart) |
| `MAIL_FROM_EMAIL` | An address on a domain verified under **Sender Signatures** → **Domains** (DKIM and Return-Path DNS records added in Cloudflare), e.g. `noreply@omlapay.org` |
| `MAIL_FROM_NAME` | Display name, e.g. `OmlaPay` |
| `POSTMARK_MESSAGE_STREAM` | **Servers** → your server → **Message Streams**: the transactional stream's ID (`outbound` by default) |

A new Postmark account starts in test mode and can only send to addresses on its own verified
domain until Postmark approves it; request approval under **Account**.

### Email switched off

Leave `POSTMARK_SERVER_TOKEN` and the three `MAILGUN_*` values empty. The backend then starts
normally and only logs "Email not configured" instead of sending. Until email is on, in
production:
- Admins cannot get a login code by email. Give the admin a Saudi mobile number (see "First
  admin") and log in with that number: the code goes by SMS (Taqnyat must be configured).
- Changing fees in the admin panel and the admin's own email/phone changes need an emailed code,
  so they are not possible.
- Users with 2FA turned on cannot reset their passcode (it needs an email code); users without 2FA
  are not affected.
- Ticket replies and account-block notifications are not emailed.

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
install -m 600 /home/deploy/app/deploy/backup.env.example  /home/deploy/backup.env
```

Fill in the settings with the guided script: for every value still empty or `CHANGE_ME` it says
what it is and where to find it, asks for it with hidden input (Enter skips), generates the random
secrets, and writes values safely (any characters; the Binance private key can be pasted as is):
`bash /home/deploy/app/deploy/scripts/fill-env.sh`. It never prints a value and can be run again.

In `app-dev/deploy/.env` change the lines marked `[dev]`: `COMPOSE_PROJECT_NAME=omlapay-dev`,
`STACK=dev`, `COMPOSE_PROFILES=` (empty), `NODE_ENV=staging`,
`API_BASE_URL=https://api-dev.omlapay.org`, `CORS_ORIGINS=` (empty), `S3_BUCKET_NAME` and
`S3_PUBLIC_URL`. Use different secrets for prod and dev. Keep `$` out of values (use
`openssl rand -hex 32`).

```bash
# 4. Start: proxy first (it creates the shared network), then the stacks
cd /home/deploy/app     && docker compose -f deploy/proxy/docker-compose.yml up -d
cd /home/deploy/app     && deploy/scripts/deploy.sh
cd /home/deploy/app-dev && deploy/scripts/deploy.sh
```

`deploy.sh` pulls the branch, runs the malware scan, builds, starts, sets up Garage and waits
until the backend is healthy. Database migrations run automatically when the backend starts.

For the first start, `deploy/scripts/step6-start.sh` does all of the above in one go: it first
checks the settings files and that every domain points only to this server (no AAAA records),
then starts Caddy and both stacks, and ends with HTTPS, certificate and blocked-route checks
(log in `~/step6.log`). Run it inside `tmux`:
`tmux new -s deploy`, then `bash /home/deploy/app/deploy/scripts/step6-start.sh`.

## First admin

`create-super-admin` is blocked on the internet. Create the first admin on the server instead
(type the password at the prompt; it never appears in shell history). The mobile number is
optional, but needed to log in by SMS code while email is switched off; write it as
`+9665XXXXXXXX`:

```bash
cd /home/deploy/app
read -rp 'Admin email: ' EMAIL; read -rp 'Admin mobile (+9665XXXXXXXX, or empty): ' PHONE
read -rsp 'Password: ' PASS; echo
HASH=$(docker compose -f deploy/docker-compose.yml exec -T -e P="$PASS" backend \
  node -e "process.stdout.write(require('bcryptjs').hashSync(process.env.P, 10))")
echo "INSERT INTO admins (email, phone_number, password_hash, role, is_active) VALUES (:'e', NULLIF(:'p', ''), :'h', 'SUPER_ADMIN', true);" |
  docker compose -f deploy/docker-compose.yml exec -T db sh -c \
  'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v e="$1" -v p="$2" -v h="$3"' _ "$EMAIL" "$PHONE" "$HASH"
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
| `DEPLOY_HOST` | `2.24.57.218` |
| `DEPLOY_SSH_KEY` | the private CI key (whole file) |
| `DEPLOY_KNOWN_HOSTS` | `ssh-keyscan -t ed25519 2.24.57.218` output |

Jobs run in the GitHub environments `production` (main) and `development` (develop). To require
a manual approval before production deploys, add a required reviewer to the `production`
environment (Settings → Environments).

## Backups

Every night `deploy/scripts/nightly-backup.sh`:
1. dumps each stack's database to `/home/deploy/backups/<project>/db/` (kept 7 days locally),
2. copies each stack's uploads bucket to `/home/deploy/backups/<project>/files/`,
3. sends everything in `/home/deploy/backups` to the private R2 bucket `omlapay-backups`, encrypted
   with restic, keeping 14 daily, 8 weekly and 12 monthly snapshots; on Sundays it also verifies
   the repository and re-reads 5% of the stored data.

Production and dev are both included (dev is small).

### Cloudflare setup (once)

1. Cloudflare dashboard → **R2 Object Storage** → **Create bucket** → name `omlapay-backups`,
   location Automatic. Leave **Public access** off (no custom domain, no r2.dev URL).
2. R2 → **Manage API tokens** → **Create API token**:
   - Token name: `omlapay-vps-backups`
   - Permissions: **Object Read & Write**
   - Specify bucket(s): **Apply to specific buckets only** → `omlapay-backups`
   - TTL: Forever
   Copy the **Access Key ID** and **Secret Access Key** (shown once).
3. Your **Account ID** is on the R2 overview page (also part of the S3 endpoint shown there).

### Settings (fill in yourself on the server)

In `/home/deploy/backup.env` (created from `deploy/backup.env.example`, `chmod 600`):

| Variable | Value |
|---|---|
| `RESTIC_REPOSITORY` | `s3:https://<ACCOUNT_ID>.r2.cloudflarestorage.com/omlapay-backups` |
| `RESTIC_PASSWORD` | `openssl rand -hex 32`; **also store it in your password manager**: without it the backups cannot be read |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | from the `omlapay-vps-backups` token |
| `AWS_DEFAULT_REGION` | `auto` |

Then, as `deploy`:

```bash
/home/deploy/app/deploy/scripts/offsite-backup.sh init      # once: creates the encrypted repository
/home/deploy/app/deploy/scripts/nightly-backup.sh           # first run by hand
crontab -e                                                  # add the line below
```

```
15 3 * * * /home/deploy/app/deploy/scripts/nightly-backup.sh >> /home/deploy/backups/backup.log 2>&1
```

Check `/home/deploy/backups/backup.log`: every step writes one `ok` line; failures start with
`FAILED`. List stored snapshots: `deploy/scripts/offsite-backup.sh snapshots`.

The server holds a token that can also delete from `omlapay-backups`. If the server were taken
over, an attacker could remove the backups; see "Protecting backups from deletion" below.

### Protecting backups from deletion (10-day R2 bucket lock)

Recommended: an **R2 bucket lock** on `omlapay-backups` that keeps every backup file for
**10 days**, plus one restic setting so the nightly cleanup never tries to delete anything that
young. It stays fully automatic: no second machine, no manual steps.

Trade-off: even someone with full control of the server (or of the R2 token) cannot delete the
last 10 days of backups; older history (weekly/monthly) is still deletable, and nobody, including
you, can remove a backup file before it is 10 days old. The repository also grows slightly,
because partly-used data is no longer repacked.

How it works with restic:
- restic never changes a stored file; it only adds and deletes. The lock covers the folders that
  hold the backup itself: `data/` (file contents), `snapshots/` (the list of backups), `keys/`
  and `config` (encryption setup).
- `locks/` (restic's run-time lock files, created and deleted on every run) and `index/` (a
  lookup table restic rewrites when it cleans up; rebuildable with `restic repair index`) are
  not locked.
- restic keeps every nightly snapshot for 14 days, so anything it deletes is older than 14 days,
  which is past the 10-day lock.
- `--max-unused unlimited` on the prune stops restic from rewriting partly-used data files, so it
  only ever deletes data files that no remaining backup uses (all older than 14 days).
- If a nightly run is ever interrupted, the half-written data it left behind cannot be deleted
  for 10 days; the log shows `FAILED` on the cleanup step until then. The backups themselves are
  not affected.

To enable:
1. Cloudflare dashboard → R2 → `omlapay-backups` → **Settings** → **Bucket lock rules** →
   **Add rule**, four times, each with **Retention: 10 days** and these prefixes:
   `data/`, `snapshots/`, `keys/`, `config`
   (or with Wrangler: `npx wrangler r2 bucket lock add omlapay-backups --name restic-data
   --prefix data/ --retention-days 10`, and the same for the other three prefixes).
2. `deploy/scripts/offsite-backup.sh` already prunes with `--max-unused unlimited` (done).
3. Run `deploy/scripts/nightly-backup.sh` once and check the log ends with `offsite ok`.

Note: a bucket with lock rules cannot be emptied or deleted until the rules are removed.

### Restore test (monthly)

```bash
/home/deploy/app/deploy/scripts/restore-test.sh
```

It restores the latest R2 snapshot to a temporary folder, loads the newest production dump into a
scratch database (`restore_check`), prints the restored and live counts of tables, migrations,
users and admins, counts the uploaded files in the snapshot, and then removes the scratch
database and the temporary folder. It does not touch the live database or files.

### Restoring for real

Database (stops the app, replaces the database; production example):

```bash
cd /home/deploy/app
docker compose -f deploy/docker-compose.yml stop backend
docker compose -f deploy/docker-compose.yml exec -T db sh -c \
  'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists --no-owner' \
  < /home/deploy/backups/omlapay-prod/db/<file>.dump
docker compose -f deploy/docker-compose.yml start backend
```

Uploaded files (copies `/home/deploy/backups/omlapay-prod/files` back into the bucket):

```bash
cd /home/deploy/app
docker compose -f deploy/docker-compose.yml run --rm files-backup \
  copy /backup/files :s3:omlapay-prod-uploads
```

If the local backup folder is gone too (new server), first fetch it from R2:

```bash
docker run --rm --env-file /home/deploy/backup.env --user "$(id -u):$(id -g)" \
  -v /home/deploy:/restore restic/restic:0.19.1 restore latest --no-cache \
  --host omlapay-vps --target /restore
# files land in /home/deploy/backups/...; then use the two commands above
```

`FIELD_ENCRYPTION_KEY` must be the same as when the backup was made, or encrypted fields are
unreadable. Keep a copy of each `deploy/.env` and of `backup.env` in your password manager.

## Troubleshooting

```bash
docker ps                                                      # all containers and health
cd /home/deploy/app && docker compose -f deploy/docker-compose.yml logs --tail 100 backend
cd /home/deploy/app && docker compose -f deploy/docker-compose.yml logs --tail 100 garage
cd /home/deploy/app && docker compose -f deploy/proxy/docker-compose.yml logs --tail 100 caddy
```

- Certificates not issued: DNS must point at the server with the Cloudflare proxy off
  (grey cloud), and ports 80/443 must be open.
- Backend restarting: usually a missing or wrong value in `deploy/.env` (the log says which).
- Uploads failing: run `deploy/scripts/garage-init.sh` and check `AWS_ACCESS_KEY_ID` is `GK` +
  24 hex characters and the secret 64 hex characters.

## Before store release (mobile app)

Check these on real phones (one iPhone, one Android) with the release build before each store
submission. Builds made from this repo can't be tested on a phone in CI.

- [ ] **Login tokens in secure storage** (Keychain / Android Keystore, PR #19), on both phones:
  1. Log in (SMS code + passcode).
  2. Close the app completely (swipe it away), open it again: still logged in.
  3. Log out: back on the login screen.
  4. Log in again, then delete the app and reinstall it: it starts logged out.
- [ ] **iOS:** after the first build on a Mac, commit the updated `mobile-app/ios/Podfile.lock`
  (`pod install` adds the secure-storage plugin).
- [ ] **HTTPS only:** the app talks to `https://api.omlapay.org` normally (login, wallets, prices).
  Plain HTTP is turned off on Android (`usesCleartextTraffic="false"`) and iOS (no
  `NSAllowsArbitraryLoads`), so a build pointed at an `http://` server won't connect.
- [ ] A new native plugin or permission means a store build; a Shorebird patch can only change
  Dart code.

## Known issues (to fix before or soon after launch)

Mobile app (Flutter): the API address (`--env=dev|prod`, see `mobile-app/README.md`), the
Saudi-only phone field, Arabic server messages and the "too many attempts" message are done. The
app no longer stores the passcode.
- The session tokens and the remembered-device token are kept in the phone's secure storage
  (iOS Keychain "this device only", Android Keystore) and no longer in SharedPreferences. This
  adds a native plugin (`flutter_secure_storage`), so it needs a new store build: a Shorebird patch
  cannot deliver it.

Backend:
- Done: login of an existing user (`/v1/auth/login/send-otp`, `/login/resend-otp`,
  `/login/verify-otp`, `/login/passcode` for remembered devices only) and account deletion
  (`/v1/user/settings/request-deletion`: passcode, no funds or activity in progress, 7-day grace
  period, then personal data is erased and records are kept), and change passcode
  (`/v1/user/settings/change-passcode`: current passcode, obvious passcodes refused, other phones
  logged out, SMS alert), and push-notification devices (`/v1/notifications/devices`: the app's
  FCM token per phone and session; removed on logout), and adding an email to the account
  (`/v1/user/email/request` + `/verify`: 6-digit code by email, valid 5 minutes; an email verified
  on another account is refused). **Needs Postmark** (see "Email (Postmark)"): without it,
  production answers "email verification is not available right now", and the dev server writes
  the email (with the code) to the backend log, like SMS codes.
- **The backend does not send push notifications yet:** it stores the phones' tokens, but nothing
  calls Firebase. Sending needs a Firebase service-account key (a secret, added to `deploy/.env`)
  and a sender that skips phones whose session has ended.
- **The app still calls API routes that this backend does not have**, so these app features fail
  against `api.omlapay.org` / `api-dev.omlapay.org` until the routes exist:
  - Change phone / change email: `/v1/user/settings/change-phone/step1…5` and
    `/v1/user/settings/change-email/step1…5` (must use the same phone rule,
    `normalizeAllowedPhone`).
  - KYC: `/v1/user/kyc/rejection-details`, `/v1/user/kyc/resubmit`.
  - Send / swap: `/v1/send/validate-address`, `/v1/swap/quote/stream`.
  - Support without an account: `/v1/guest/support-requests` (+ `/:id`).
  The app was most likely built against a newer backend than the one in this repository.
- `create-super-admin`, `dev-tools` and `coins/sync` are blocked in Caddy; remove or protect them
  in the code too.
- Invite SMS (`POST /v1/user/invite`) still accepts +966 and +91 numbers (it is neither a code
  nor the account's own number).

Backups:
- The backup token can delete from `omlapay-backups`. Fix: the 10-day R2 bucket lock (four rules
  to add in Cloudflare, then a manual backup run), see "Protecting backups from deletion".
