#!/usr/bin/env bash
# Install local git hooks that block commits and pushes containing the injected malware.
#
#   bash scripts/security/install-hooks.sh
#
# The scanner is copied into .git/hooks, so later changes to the tracked copy (for example by
# someone who has pushed to the repo) are never run automatically. Re-run this script after you
# have reviewed an update to scripts/security/scan-malware.sh.

set -eu

root=$(git rev-parse --show-toplevel)
hooks=$(git rev-parse --git-path hooks)
case "$hooks" in /*) ;; *) hooks="$root/$hooks" ;; esac
mkdir -p "$hooks"

if [ -n "$(git config --get core.hooksPath || true)" ]; then
  echo "core.hooksPath is set to '$(git config --get core.hooksPath)'. Unset it first:"
  echo "  git config --unset core.hooksPath"
  exit 1
fi

cp "$root/scripts/security/scan-malware.sh" "$hooks/scan-malware.sh"
chmod 755 "$hooks/scan-malware.sh"

for name in pre-commit pre-push; do
  if [ -e "$hooks/$name" ] && ! grep -q 'scan-malware.sh' "$hooks/$name"; then
    echo "$hooks/$name already exists and is not ours. Merge it by hand."
    exit 1
  fi
done

cat > "$hooks/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Installed by scripts/security/install-hooks.sh
bash "$(git rev-parse --git-path hooks)/scan-malware.sh" --cached && exit 0
echo "Commit blocked: the staged files contain injected malware or its leftovers (see above)."
exit 1
EOF

cat > "$hooks/pre-push" <<'EOF'
#!/usr/bin/env bash
# Installed by scripts/security/install-hooks.sh
scanner="$(git rev-parse --git-path hooks)/scan-malware.sh"
status=0
while read -r local_ref local_sha remote_ref remote_sha; do
  case "$local_sha" in *[!0]*) ;; *) continue ;; esac   # branch deletion
  bash "$scanner" "$local_sha" || status=1
done
[ $status -eq 0 ] && exit 0
echo "Push blocked: the commit being pushed contains injected malware or its leftovers (see above)."
exit 1
EOF

chmod 755 "$hooks/pre-commit" "$hooks/pre-push"
echo "Installed pre-commit and pre-push malware checks in $hooks"
