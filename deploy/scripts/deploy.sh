#!/usr/bin/env bash
# Update one stack to the latest commit of its branch and restart it.
#   /home/deploy/app/deploy/scripts/deploy.sh       (production, branch main)
#   /home/deploy/app-dev/deploy/scripts/deploy.sh   (dev, branch develop)
# Also run by GitHub Actions through deploy/scripts/ci-entry.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
COMPOSE=(docker compose -f deploy/docker-compose.yml)

[ -f deploy/.env ] || { echo "deploy/.env is missing in $ROOT. See DEPLOY.md." >&2; exit 1; }
if grep -q 'CHANGE_ME' deploy/.env; then
  echo "deploy/.env still has CHANGE_ME placeholders. Fill them in first." >&2
  exit 1
fi

# Fetch first, then re-run the updated copy of this script so a changed script never runs half old.
if [ "${OMLAPAY_DEPLOY_UPDATED:-}" != 1 ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "==> Updating $ROOT ($branch)"
  git fetch --quiet origin "$branch"
  git merge --ff-only "origin/$branch"
  OMLAPAY_DEPLOY_UPDATED=1 exec bash "$0" "$@"
fi

echo "==> Malware scan of $(git rev-parse --short HEAD)"
bash scripts/security/scan-malware.sh HEAD

echo "==> Building and starting"
"${COMPOSE[@]}" build --pull
"${COMPOSE[@]}" up -d --remove-orphans
bash deploy/scripts/garage-init.sh

# Migrations run when the backend starts; wait until it reports healthy.
echo "==> Waiting for the backend"
cid="$("${COMPOSE[@]}" ps -q backend)"
for _ in $(seq 1 60); do
  status="$(docker inspect -f '{{.State.Health.Status}}' "$cid" 2>/dev/null || echo unknown)"
  [ "$status" = healthy ] && { echo "==> Backend healthy"; docker image prune -f >/dev/null; exit 0; }
  sleep 5
done
echo "Backend did not become healthy. Logs:" >&2
"${COMPOSE[@]}" logs --tail 80 backend >&2
exit 1
