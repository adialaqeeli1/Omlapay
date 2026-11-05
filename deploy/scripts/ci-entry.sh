#!/usr/bin/env bash
# Forced command for the GitHub Actions SSH key (see DEPLOY.md). The key can run only this
# script, and this script only accepts "deploy prod" or "deploy dev".
set -euo pipefail

case "${SSH_ORIGINAL_COMMAND:-}" in
  "deploy prod") exec /home/deploy/app/deploy/scripts/deploy.sh ;;
  "deploy dev")  exec /home/deploy/app-dev/deploy/scripts/deploy.sh ;;
  *) echo "Not allowed: ${SSH_ORIGINAL_COMMAND:-<none>}" >&2; exit 1 ;;
esac
