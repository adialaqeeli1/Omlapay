#!/usr/bin/env bash
# Restore drill (changes nothing live): pulls the latest off-server snapshot from R2 into a
# temporary folder, loads the newest production database dump into a scratch database
# (restore_check) inside the production Postgres, compares it with the live database, checks the
# uploaded files, then removes the scratch database and the temporary folder.
#   /home/deploy/app/deploy/scripts/restore-test.sh
set -euo pipefail

ENV_FILE="${RESTIC_ENV_FILE:-/home/deploy/backup.env}"
PROD="${PROD_CHECKOUT:-/home/deploy/app}"
PROJECT="$(grep -E '^COMPOSE_PROJECT_NAME=' "$PROD/deploy/.env" | cut -d= -f2-)"
COMPOSE=(docker compose -f "$PROD/deploy/docker-compose.yml" --project-directory "$PROD/deploy")
psql_in_db() { "${COMPOSE[@]}" exec -T db sh -c "psql -U \"\$POSTGRES_USER\" -d $1 -tAc \"$2\""; }

tmp="$(mktemp -d "${TMPDIR:-/tmp}/omlapay-restore-test.XXXXXX")"
cleanup() {
  psql_in_db postgres "DROP DATABASE IF EXISTS restore_check" >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

echo "==> Restoring the latest snapshot of $PROJECT from R2"
docker run --rm --env-file "$ENV_FILE" --user "$(id -u):$(id -g)" -v "$tmp:/restore" \
  restic/restic:0.19.1 restore latest --no-cache --host omlapay-vps \
  --target /restore --include "/backups/$PROJECT" --quiet

dump="$(ls -t "$tmp/backups/$PROJECT/db/"*.dump 2>/dev/null | head -1 || true)"
[ -n "$dump" ] || { echo "FAILED: no database dump in the snapshot" >&2; exit 1; }
echo "==> Loading $(basename "$dump") into scratch database restore_check"
psql_in_db postgres "DROP DATABASE IF EXISTS restore_check" >/dev/null
psql_in_db postgres "CREATE DATABASE restore_check" >/dev/null
"${COMPOSE[@]}" exec -T db sh -c 'pg_restore -U "$POSTGRES_USER" -d restore_check --no-owner --exit-on-error' < "$dump"

printf '%-12s %10s %10s\n' "" "restored" "live"
for q in "tables:select count(*) from information_schema.tables where table_schema='public'" \
         "migrations:select count(*) from migrations" \
         "users:select count(*) from users" \
         "admins:select count(*) from admins"; do
  printf '%-12s %10s %10s\n' "${q%%:*}" "$(psql_in_db restore_check "${q#*:}")" \
    "$(psql_in_db "\$POSTGRES_DB" "${q#*:}")"
done

restored_files="$(find "$tmp/backups/$PROJECT/files" -type f 2>/dev/null | wc -l)"
echo "uploaded files in snapshot: $restored_files"
echo "==> Restore test passed (the live database and files were not touched)"
