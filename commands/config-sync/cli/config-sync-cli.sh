#!/usr/bin/env bash

set -euo pipefail
trap 'echo "[ERROR] legacy config-sync-cli failed on line $LINENO" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[WARN] /config-sync:cli is deprecated; use /config-sync/sync-cli instead." >&2
exec "$SCRIPT_DIR/sync-cli.sh" "$@"
