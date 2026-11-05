#!/usr/bin/env bash
# Copy one stack's uploads bucket (Garage) to $BACKUP_DIR/<project>/files, which the off-server
# restic backup then picks up. The copy mirrors the bucket; restic keeps the history.
#   deploy/scripts/backup-files.sh /home/deploy/app        (production)
#   deploy/scripts/backup-files.sh /home/deploy/app-dev    (dev)
set -euo pipefail

ROOT="${1:?usage: backup-files.sh <checkout dir>}"
BACKUP_DIR="${BACKUP_DIR:-/home/deploy/backups}"
cd "$ROOT"

project="$(grep -E '^COMPOSE_PROJECT_NAME=' deploy/.env | cut -d= -f2-)"
dir="$BACKUP_DIR/${project:?COMPOSE_PROJECT_NAME missing in deploy/.env}/files"
mkdir -p "$dir"
chmod 700 "$BACKUP_DIR" "$BACKUP_DIR/$project"

BACKUP_DIR="$BACKUP_DIR" docker compose -f deploy/docker-compose.yml run --rm -T \
  --user "$(id -u):$(id -g)" files-backup >/dev/null
echo "$(date -u +%FT%TZ) files ok: $dir ($(find "$dir" -type f | wc -l) files, $(du -sh "$dir" | cut -f1))"
