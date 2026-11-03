#!/usr/bin/env bash
# One command to run Omlapay locally. See README.md.
#
#   ./run.sh                    backend + admin panel (+ local Postgres in Docker)
#   ./run.sh backend            backend only
#   ./run.sh admin              admin panel only
#   ./run.sh mobile [--release] Flutter app on a connected phone or emulator
#   ./run.sh create-admin <email> <password>   first admin login for the local admin panel
#   ./run.sh check              check tools and scan for malware, start nothing
#   ./run.sh stop-db            stop the local Postgres container
#
# Works on macOS and Linux. On Windows use Git Bash or WSL.

set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
DB_CONTAINER=omlapay-postgres
DB_VOLUME=omlapay-pgdata
DB_IMAGE=postgres:15-alpine
ADMIN_PORT=5173

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

# env_get <file> <KEY>: value of KEY in a .env file (empty if unset)
env_get() { grep -E "^$2=" "$1" 2>/dev/null | tail -1 | cut -d= -f2- | sed -e 's/^["'\'']//' -e 's/["'\'']$//'; }

# env_set <file> <KEY> <value>: replace or append KEY=value
env_set() {
  local tmp="$1.tmp.$$"
  if grep -qE "^$2=" "$1"; then
    awk -v k="$2" -v v="$3" 'BEGIN{FS=OFS="="} $1==k {print k "=" v; next} {print}' "$1" > "$tmp" && mv "$tmp" "$1"
  else
    printf '%s=%s\n' "$2" "$3" >> "$1"
  fi
}

random_hex() {
  if has openssl; then openssl rand -hex "$1"
  else node -e "console.log(require('crypto').randomBytes($1).toString('hex'))"; fi
}

# pnpm 10+ skips dependency install scripts (safer) but then refuses to run; these flags keep the
# skip without the error. Older pnpm ignores them.
PNPM_FLAGS="--config.strict-dep-builds=false --config.verify-deps-before-run=false"

pnpm_cmd() {
  # shellcheck disable=SC2086
  if has pnpm; then pnpm $PNPM_FLAGS "$@"
  elif has corepack; then corepack pnpm $PNPM_FLAGS "$@"
  else die "pnpm is missing. Install it with: npm install -g pnpm"; fi
}

# ---- checks ----------------------------------------------------------------------------------

malware_scan() {
  if [ -d "$ROOT/.git" ] && [ -f "$ROOT/scripts/security/scan-malware.sh" ]; then
    say "Scanning the code for the malware this repo was hit by"
    (cd "$ROOT" && bash scripts/security/scan-malware.sh HEAD) \
      || die "The scan failed. Do not run this code. Tell the development team."
    if [ -n "$(cd "$ROOT" && git status --porcelain --untracked-files=no 2>/dev/null)" ]; then
      (cd "$ROOT" && bash scripts/security/scan-malware.sh --cached) >/dev/null \
        || die "Staged changes fail the malware scan. Do not run this code."
    fi
  fi
}

need_node() {
  has node || die "Node.js is missing. Install Node.js 20 or 22 LTS from https://nodejs.org"
  local major; major=$(node -p 'process.versions.node.split(".")[0]')
  [ "$major" -ge 20 ] || die "Node.js $major is too old. Install Node.js 20 or 22 LTS."
  pnpm_cmd --version >/dev/null || exit 1
}

need_docker() {
  has docker || die "Docker is missing. Install Docker Desktop, or set POSTGRES_* in backend/.env to your own Postgres and use: ./run.sh backend --no-db"
  docker info >/dev/null 2>&1 || die "Docker is installed but not running. Start Docker Desktop and run this again."
}

# ---- setup -----------------------------------------------------------------------------------

setup_backend_env() {
  local f="$ROOT/backend/.env"
  if [ ! -f "$f" ]; then
    cp "$ROOT/backend/.env.example" "$f"
    say "Created backend/.env from backend/.env.example"
  fi
  case "$(env_get "$f" JWT_SECRET_KEY)" in ""|change-me) env_set "$f" JWT_SECRET_KEY "$(random_hex 32)"; say "Generated JWT_SECRET_KEY";; esac
  local fek; fek=$(env_get "$f" FIELD_ENCRYPTION_KEY)
  if [ ${#fek} -ne 64 ]; then env_set "$f" FIELD_ENCRYPTION_KEY "$(random_hex 32)"; say "Generated FIELD_ENCRYPTION_KEY (keep it: data encrypted with it needs it)"; fi
  case "$(env_get "$f" SWAGGER_PASSWORD)" in ""|change-me) env_set "$f" SWAGGER_PASSWORD "$(random_hex 8)"; say "Generated SWAGGER_PASSWORD (see backend/.env)";; esac
  [ -n "$(env_get "$f" SWAGGER_USER)" ] || env_set "$f" SWAGGER_USER admin
  # The backend refuses to start without S3 settings. Placeholders let it start locally;
  # file uploads only work once real keys are in backend/.env.
  local k missing=0
  for k in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY S3_BUCKET_NAME; do
    [ -n "$(env_get "$f" "$k")" ] || { env_set "$f" "$k" "not-configured"; missing=1; }
  done
  [ -n "$(env_get "$f" AWS_REGION)" ] || env_set "$f" AWS_REGION "me-south-1"
  if [ "$missing" = 1 ] || [ "$(env_get "$f" S3_BUCKET_NAME)" = "not-configured" ]; then
    warn "No AWS S3 keys in backend/.env: the app runs, but file uploads will fail until you add them."
  fi
}

setup_admin_env() {
  local f="$ROOT/admin/.env" port
  port=$(env_get "$ROOT/backend/.env" PORT); port=${port:-3000}
  if [ ! -f "$f" ]; then
    sed "s#localhost:3000#localhost:$port#g" "$ROOT/admin/.env.example" > "$f"
    say "Created admin/.env pointing at the local backend (port $port)"
  fi
}

install_deps() {  # install_deps <folder>
  say "Installing packages in $1 (first run takes a few minutes)"
  (cd "$ROOT/$1" && pnpm_cmd install --frozen-lockfile) || die "Package install failed in $1"
}

start_db() {
  need_docker
  local f="$ROOT/backend/.env" host port db user pass
  host=$(env_get "$f" POSTGRES_HOST); port=$(env_get "$f" POSTGRES_PORT)
  db=$(env_get "$f" POSTGRES_DB); user=$(env_get "$f" POSTGRES_USER); pass=$(env_get "$f" POSTGRES_PASSWORD)
  case "$host" in localhost|127.0.0.1) ;; *) say "POSTGRES_HOST is $host, so no local database is started"; return;; esac
  if [ -z "$(docker ps -aq -f name="^${DB_CONTAINER}$")" ]; then
    say "Starting Postgres in Docker on port $port (data kept in volume $DB_VOLUME)"
    docker run -d --name "$DB_CONTAINER" -p "127.0.0.1:$port:5432" \
      -e POSTGRES_DB="$db" -e POSTGRES_USER="$user" -e POSTGRES_PASSWORD="$pass" \
      -v "$DB_VOLUME:/var/lib/postgresql/data" "$DB_IMAGE" >/dev/null \
      || die "Could not start Postgres. Is port $port free? Change POSTGRES_PORT in backend/.env if not."
  else
    docker start "$DB_CONTAINER" >/dev/null || die "Could not start the $DB_CONTAINER container"
  fi
  local i
  for i in $(seq 1 30); do
    docker exec "$DB_CONTAINER" pg_isready -U "$user" -d "$db" >/dev/null 2>&1 && { say "Postgres is ready"; return; }
    sleep 1
  done
  die "Postgres did not become ready. Check: docker logs $DB_CONTAINER"
}

# ---- run -------------------------------------------------------------------------------------

# run_bg <label> <folder> <command...>: run with a [label] prefix on every log line
run_bg() {
  local label="$1" dir="$2"; shift 2
  (cd "$ROOT/$dir" && "$@" 2>&1 | awk -v p="[$label] " '{print p $0; fflush()}') &
}

wait_for_http() {  # wait_for_http <url> <seconds>
  local i code
  for i in $(seq 1 "$2"); do
    code=$(curl -s -o /dev/null -w '%{http_code}' "$1" 2>/dev/null)
    [ -n "$code" ] && [ "$code" != "000" ] && return 0
    sleep 1
  done
  return 1
}

run_stack() {  # run_stack <with_backend 0|1> <with_admin 0|1> <with_db 0|1>
  local backend=$1 admin=$2 db=$3 port
  malware_scan
  need_node
  if [ "$backend" = 1 ]; then
    setup_backend_env
    [ "$db" = 1 ] && start_db
    install_deps backend
  fi
  if [ "$admin" = 1 ]; then
    [ -f "$ROOT/backend/.env" ] || setup_backend_env
    setup_admin_env
    install_deps admin
  fi

  trap 'echo; say "Stopping"; trap - INT TERM; kill 0 2>/dev/null' INT TERM
  port=$(env_get "$ROOT/backend/.env" PORT); port=${port:-3000}
  [ "$backend" = 1 ] && run_bg backend backend pnpm_cmd start:dev
  [ "$admin" = 1 ] && run_bg admin admin pnpm_cmd dev --port "$ADMIN_PORT" --strictPort

  echo
  if [ "$backend" = 1 ]; then
    if wait_for_http "http://localhost:$port/docs" 180; then
      say "Backend:   http://localhost:$port   (API docs: http://localhost:$port/docs, login in backend/.env SWAGGER_USER / SWAGGER_PASSWORD)"
    else
      warn "Backend did not answer on port $port yet. Read the [backend] lines above."
    fi
  fi
  if [ "$admin" = 1 ] && wait_for_http "http://localhost:$ADMIN_PORT" 120; then
    say "Admin:     http://localhost:$ADMIN_PORT   (no admin login yet? ./run.sh create-admin you@example.com 'Password1!')"
  fi
  say "Press Ctrl+C to stop."
  wait
}

run_mobile() {
  malware_scan
  has flutter || die "Flutter is missing. Install Flutter $(cat "$ROOT/mobile-app/.flutter-version" 2>/dev/null) from https://docs.flutter.dev/get-started/install"
  say "The app talks to the API set in mobile-app/lib/core/constants/endpoints.dart ($(grep -oE "domain => '[^']+'" "$ROOT/mobile-app/lib/core/constants/endpoints.dart" | cut -d"'" -f2))"
  bash "$ROOT/mobile-app/scripts/run.sh" "$@"
}

create_admin() {
  local email="${1:-}" password="${2:-}" f="$ROOT/backend/.env" hash
  [ -n "$email" ] && [ -n "$password" ] || die "Usage: ./run.sh create-admin <email> <password>"
  [ -f "$f" ] || die "Run ./run.sh once first so the database and backend/.env exist."
  [ -d "$ROOT/backend/node_modules/bcryptjs" ] || install_deps backend
  need_docker
  docker exec "$DB_CONTAINER" true 2>/dev/null || start_db
  hash=$(cd "$ROOT/backend" && node -e "process.stdout.write(require('bcryptjs').hashSync(process.argv[1], 10))" "$password") \
    || die "Could not hash the password"
  docker exec "$DB_CONTAINER" psql -U "$(env_get "$f" POSTGRES_USER)" -d "$(env_get "$f" POSTGRES_DB)" -tAc \
    "SELECT 1 FROM information_schema.tables WHERE table_name='admins'" | grep -q 1 \
    || die "The admins table does not exist yet. Start the backend once (./run.sh backend) so it creates the tables."
  printf "%s\n" "INSERT INTO admins (email, password_hash, role, is_active) SELECT :'email', :'hash', 'SUPER_ADMIN', true WHERE NOT EXISTS (SELECT 1 FROM admins WHERE lower(email) = lower(:'email')) RETURNING email;" \
    | docker exec -i "$DB_CONTAINER" psql -q -v ON_ERROR_STOP=1 -U "$(env_get "$f" POSTGRES_USER)" -d "$(env_get "$f" POSTGRES_DB)" \
        -v email="$email" -v hash="$hash" -tA | grep -q . \
    && say "Admin $email created. Log in at http://localhost:$ADMIN_PORT. In development the one-time code is shown in the [backend] log and in the API response." \
    || die "Admin not created: an admin with that email may already exist."
}

case "${1:-all}" in
  all|"")       run_stack 1 1 1 ;;
  backend)      shift; if [ "${1:-}" = "--no-db" ]; then run_stack 1 0 0; else run_stack 1 0 1; fi ;;
  admin)        run_stack 0 1 0 ;;
  mobile)       shift; run_mobile "$@" ;;
  create-admin) shift; create_admin "$@" ;;
  check)        malware_scan; need_node; has docker && say "Docker: $(docker --version)"; has flutter && say "$(flutter --version 2>/dev/null | head -1)"; say "Checks done" ;;
  stop-db)      docker stop "$DB_CONTAINER" >/dev/null && say "Postgres stopped (data kept)" ;;
  -h|--help|help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//' ;;
  *)            die "Unknown command: $1. Try: ./run.sh help" ;;
esac
