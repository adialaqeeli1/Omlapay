#!/usr/bin/env bash
# Encrypted off-server copy of $BACKUP_DIR (database dumps + uploaded files of both stacks) to the
# private Cloudflare R2 bucket omlapay-backups, using restic. Settings: /home/deploy/backup.env.
#   deploy/scripts/offsite-backup.sh init        once, creates the encrypted repository
#   deploy/scripts/offsite-backup.sh             nightly: backup, apply retention, weekly check
#   deploy/scripts/offsite-backup.sh snapshots   list what is stored
set -euo pipefail

ENV_FILE="${RESTIC_ENV_FILE:-/home/deploy/backup.env}"
BACKUP_DIR="${BACKUP_DIR:-/home/deploy/backups}"
HOST_TAG="omlapay-vps"

[ -f "$ENV_FILE" ] || { echo "$ENV_FILE is missing. See DEPLOY.md (Off-server backups)." >&2; exit 1; }
if grep -q 'CHANGE_ME' "$ENV_FILE"; then echo "$ENV_FILE still has CHANGE_ME placeholders." >&2; exit 1; fi

restic() {
  docker run --rm -i --env-file "$ENV_FILE" -e RESTIC_CACHE_DIR=/cache \
    -v "$BACKUP_DIR:/backups:ro" -v omlapay-restic-cache:/cache \
    restic/restic:0.19.1 "$@"
}

case "${1:-backup}" in
  init)
    restic init
    ;;
  snapshots)
    restic snapshots --host "$HOST_TAG"
    ;;
  backup)
    restic backup /backups --host "$HOST_TAG" --tag nightly --exclude '*.partial' --quiet
    restic forget --host "$HOST_TAG" --keep-daily 14 --keep-weekly 8 --keep-monthly 12 --prune --quiet
    # Sundays: verify the repository and re-read 5% of the stored data
    if [ "$(date -u +%u)" = 7 ]; then restic check --read-data-subset=5% --quiet; fi
    echo "$(date -u +%FT%TZ) offsite ok: $(restic snapshots --host "$HOST_TAG" --json --latest 1 | grep -o '"short_id":"[^"]*"' | head -1)"
    ;;
  *)
    echo "usage: offsite-backup.sh [init|backup|snapshots]" >&2; exit 2
    ;;
esac
