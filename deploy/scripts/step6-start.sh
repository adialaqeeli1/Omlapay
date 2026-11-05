#!/usr/bin/env bash
# First start of the whole server (DEPLOY.md, step 6): checks, then Caddy, the production stack and
# the dev stack, then HTTPS and route checks. Safe to run again. Output also goes to ~/step6.log.
#   bash /home/deploy/app/deploy/scripts/step6-start.sh
# Build takes several minutes; run it inside tmux so a dropped SSH connection does not stop it.
set -uo pipefail

SERVER_IP="${SERVER_IP:-2.24.57.218}"
DOMAINS="api.omlapay.org api-dev.omlapay.org admin.omlapay.org files.omlapay.org files-dev.omlapay.org"
PROD="${PROD_CHECKOUT:-/home/deploy/app}"
DEV="${DEV_CHECKOUT:-/home/deploy/app-dev}"
LOG="${STEP6_LOG:-$HOME/step6.log}"

exec > >(tee -a "$LOG") 2>&1
echo "######## step6-start $(date -u +%FT%TZ)"

stop() { echo "STOP: $*"; echo "Nothing was started by this run."; exit 1; }
[ "${STEP6_SKIP_HOST_CHECK:-}" = 1 ] || [ "$(hostname)" = srv2131878 ] || stop "wrong server $(hostname)"

echo "== 1/5 Checks before starting"
for f in "$PROD/deploy/.env" "$DEV/deploy/.env" "$PROD/deploy/proxy/.env"; do
  [ -f "$f" ] || stop "$f is missing (step 5)"
  n=$(grep -c CHANGE_ME "$f" || true); p=$(stat -c %a "$f")
  echo "  $f: CHANGE_ME $n, perms $p"
  [ "$n" = 0 ] || stop "$f still has CHANGE_ME (run deploy/scripts/fill-env.sh)"
  [ "$p" = 600 ] || chmod 600 "$f"
done
for d in $DOMAINS; do
  v4=$(getent ahostsv4 "$d" | awk '{print $1}' | sort -u | tr '\n' ' ')
  v6=$(getent ahostsv6 "$d" 2>/dev/null | awk '$1 !~ /^::ffff:/ {print $1}' | sort -u | tr '\n' ' ')
  echo "  DNS $d -> ${v4:-none}${v6:+ (IPv6: $v6)}"
  [ "$v4" = "$SERVER_IP " ] || stop "$d must point only to $SERVER_IP (Cloudflare: A record, DNS only / grey cloud)"
  [ -z "$v6" ] || stop "$d has an IPv6 (AAAA) record; delete it in Cloudflare (certificates would fail)"
done
# Ports 80/443 must be free, unless our own Caddy already holds them (a re-run)
if ! docker ps --format '{{.Names}}' | grep -qx omlapay-proxy-caddy-1; then
  if ss -tlnH '( sport = :80 or sport = :443 )' | grep -q .; then stop "something else already listens on port 80/443"; fi
fi
echo "  memory: $(free -h | awk '/Mem:/{print $2" RAM, "$7" available"}'), swap: $(free -h | awk '/Swap:/{print $2}'), disk free: $(df -h / | awk 'NR==2{print $4}')"

echo "== 2/5 Caddy (HTTPS proxy)"
(cd "$PROD" && docker compose -f deploy/proxy/docker-compose.yml up -d) || stop "Caddy did not start"

echo "== 3/5 Production stack (build, start, migrations; several minutes)"
(cd "$PROD" && deploy/scripts/deploy.sh) || { echo "FAILED: production deploy (see the lines above)"; exit 1; }

echo "== 4/5 Dev stack"
(cd "$DEV" && deploy/scripts/deploy.sh) || { echo "FAILED: dev deploy (see the lines above)"; exit 1; }

echo "== 5/5 Checks"
db_count() {  # db_count <checkout> <sql>
  (cd "$1" && docker compose -f deploy/docker-compose.yml exec -T -e Q="$2" db \
    sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "$Q"') 2>/dev/null
}
for dir in "$PROD" "$DEV"; do
  echo "  $(basename "$dir") database: migrations $(db_count "$dir" 'select count(*) from migrations'), tables $(db_count "$dir" "select count(*) from information_schema.tables where table_schema='public'")"
done
echo "  waiting for HTTPS certificates (up to 3 minutes)..."
for _ in $(seq 1 36); do
  ok=0; for d in $DOMAINS; do curl -s -m 5 -o /dev/null "https://$d/" && ok=$((ok + 1)); done
  [ "$ok" = 5 ] && break; sleep 5
done

c() { curl -s -m 10 -o /dev/null -w '%{http_code}' "$@"; }
check() {  # check <label> <expected code> <curl args...>
  local label="$1" want="$2" got; shift 2
  got="$(c "$@")"
  printf '  %-4s %-48s expect %s, got %s\n' "$([ "$got" = "$want" ] && echo OK || echo FAIL)" "$label" "$want" "$got"
}
echo "== Summary"
check "https://api.omlapay.org/v1/"                 200 https://api.omlapay.org/v1/
check "https://api-dev.omlapay.org/v1/"             200 https://api-dev.omlapay.org/v1/
check "https://admin.omlapay.org/"                  200 https://admin.omlapay.org/
check "admin page refresh (/dashboard)"             200 https://admin.omlapay.org/dashboard
check "https://files.omlapay.org/ (no listing)"     404 https://files.omlapay.org/
check "https://files-dev.omlapay.org/ (no listing)" 404 https://files-dev.omlapay.org/
check "http -> https redirect"                      308 http://api.omlapay.org/v1/
check "/docs needs a login"                         401 https://api.omlapay.org/docs
check "prod dev-tools blocked"                      404 -X POST https://api.omlapay.org/v1/dev-tools/seed
check "dev dev-tools blocked"                       404 -X POST https://api-dev.omlapay.org/v1/dev-tools/seed
check "prod create-super-admin blocked"             404 -X POST https://api.omlapay.org/v1/admin/auth/create-super-admin
check "prod coins/sync blocked"                     404 -X POST https://api.omlapay.org/v1/coins/sync
for d in $DOMAINS; do
  printf '  certificate %-22s %s\n' "$d" "$(echo | openssl s_client -connect "$d:443" -servername "$d" 2>/dev/null \
    | openssl x509 -noout -issuer -enddate 2>/dev/null | tr '\n' ' ' | sed 's/issuer=//')"
done
docker ps --format '  {{.Names}}: {{.Status}}' | sort
echo "Full log: $LOG"
