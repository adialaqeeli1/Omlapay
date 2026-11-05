#!/usr/bin/env bash
# Set up this stack's Garage (safe to run again): cluster layout, the uploads bucket, the app's
# access key (from deploy/.env) and public read-only website access for the bucket.
#   deploy/scripts/garage-init.sh            (run by deploy.sh after the stack starts)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
COMPOSE=(docker compose -f deploy/docker-compose.yml)
env_get() { grep -E "^$1=" deploy/.env | tail -1 | cut -d= -f2-; }
g() { "${COMPOSE[@]}" exec -T garage /garage "$@" 2>&1 | grep -v ' INFO '; return "${PIPESTATUS[0]}"; }

bucket="$(env_get S3_BUCKET_NAME)"
key_id="$(env_get AWS_ACCESS_KEY_ID)"
key_secret="$(env_get AWS_SECRET_ACCESS_KEY)"
capacity="$(env_get GARAGE_CAPACITY)"; capacity="${capacity:-20G}"
[[ "$key_id" =~ ^GK[0-9a-f]{24}$ ]] || { echo "AWS_ACCESS_KEY_ID must be GK + 24 hex characters (see DEPLOY.md)." >&2; exit 1; }
[[ "$key_secret" =~ ^[0-9a-f]{64}$ ]] || { echo "AWS_SECRET_ACCESS_KEY must be 64 hex characters (see DEPLOY.md)." >&2; exit 1; }

echo "==> Waiting for Garage"
for _ in $(seq 1 30); do g status >/dev/null && break; sleep 2; done
g status >/dev/null

if ! g layout show | grep -qE 'Current cluster layout version: [1-9]'; then
  node_id="$(g node id -q | cut -c1-16)"
  echo "==> Creating the storage layout (capacity $capacity)"
  g layout assign -z dc1 -c "$capacity" "$node_id" >/dev/null
  g layout apply --version 1 >/dev/null
fi

g bucket info "$bucket" >/dev/null 2>&1 || { echo "==> Creating bucket $bucket"; g bucket create "$bucket" >/dev/null; }
g key info "$key_id" >/dev/null 2>&1 || { echo "==> Importing the app's access key"; g key import --yes -n app "$key_id" "$key_secret" >/dev/null; }
g bucket allow --read --write --owner "$bucket" --key "$key_id" >/dev/null
g bucket website --allow "$bucket" >/dev/null
echo "==> Garage ready: bucket $bucket (public read via Caddy, write with the app key only)"
