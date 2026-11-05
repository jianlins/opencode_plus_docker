#!/usr/bin/env sh
set -eu

read_secret() {
  secret_path="$1"
  if [ ! -r "$secret_path" ]; then
    echo "Required secret is unavailable: $secret_path" >&2
    exit 1
  fi
  cat "$secret_path"
}

# Compose mounts these as read-only files. They are never printed.
export OH_SECRET_KEY="$(read_secret /run/secrets/openhands_secret_key)"
export OPENCODE_PASSWORD="$(read_secret /run/secrets/opencode_password)"

OPENCODE_URL="${PUBLIC_OPENCODE_URL:-http://localhost:4096}"
OPENHANDS_URL="${PUBLIC_OPENHANDS_URL:-http://localhost:8000/canvas}"

echo
echo "============================================"
echo "  Agent workspace is starting"
echo "  OpenCode:  ${OPENCODE_URL}"
echo "  OpenHands: ${OPENHANDS_URL}"
echo "============================================"
echo

exec supervisord -n -c /etc/supervisord.conf
