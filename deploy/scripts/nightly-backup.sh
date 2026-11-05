#!/usr/bin/env bash
# Nightly backup, run from the deploy user's crontab (see DEPLOY.md):
#   1. database dump and uploads copy for production and, if present, dev
#   2. encrypted off-server copy of everything to Cloudflare R2 (restic)
# Exits non-zero if any step failed; each step logs one line.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
status=0

for checkout in ${CHECKOUTS:-/home/deploy/app /home/deploy/app-dev}; do
  [ -f "$checkout/deploy/.env" ] || continue
  "$SCRIPTS/backup-db.sh" "$checkout" || { echo "FAILED: database backup of $checkout" >&2; status=1; }
  "$SCRIPTS/backup-files.sh" "$checkout" || { echo "FAILED: files backup of $checkout" >&2; status=1; }
done

"$SCRIPTS/offsite-backup.sh" backup || { echo "FAILED: off-server backup" >&2; status=1; }
exit "$status"
