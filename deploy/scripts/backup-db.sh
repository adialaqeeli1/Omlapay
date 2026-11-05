#!/usr/bin/env bash
# Dump one stack's database to $BACKUP_DIR/<project>/db (default /home/deploy/backups) and keep
# the last KEEP_DAYS days locally (default 7; the off-server restic copy keeps longer history).
#   deploy/scripts/backup-db.sh /home/deploy/app        (production)
#   deploy/scripts/backup-db.sh /home/deploy/app-dev    (dev)
# Restore: see DEPLOY.md.
set -euo pipefail

ROOT="${1:?usage: backup-db.sh <checkout dir>}"
KEEP_DAYS="${KEEP_DAYS:-7}"
BACKUP_DIR="${BACKUP_DIR:-/home/deploy/backups}"
cd "$ROOT"

project="$(grep -E '^COMPOSE_PROJECT_NAME=' deploy/.env | cut -d= -f2-)"
dir="$BACKUP_DIR/${project:?COMPOSE_PROJECT_NAME missing in deploy/.env}/db"
mkdir -p "$dir"
chmod 700 "$BACKUP_DIR" "$BACKUP_DIR/$project" "$dir"

file="$dir/$project-$(date -u +%Y%m%d-%H%M%S).dump"
umask 077
docker compose -f deploy/docker-compose.yml exec -T db \
  sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' > "$file.partial"
mv "$file.partial" "$file"

find "$dir" -name "$project-*.dump" -mtime +"$KEEP_DAYS" -delete
echo "$(date -u +%FT%TZ) database ok: $file ($(du -h "$file" | cut -f1))"
