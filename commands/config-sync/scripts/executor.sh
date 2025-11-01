#!/usr/bin/env bash
# Helper routines referenced by config-sync commands.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR%/scripts}/lib"

if [[ -f "$LIB_DIR/common.sh" ]]; then
  # Optional: load shell-specific helpers if provided.
  source "$LIB_DIR/common.sh"
fi

write_with_backup() {
  local src="$1"
  local dest="$2"
  local backup_dir="$3"

  if [[ -d "$backup_dir" ]]; then
    mkdir -p "$backup_dir"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    if [[ -f "$dest" ]]; then
      cp "$dest" "$backup_dir/$(basename "$dest").$timestamp.bak"
    fi
  fi

  cp "$src" "$dest"
}

render_template() {
  local template="$1"
  local output="$2"
  envsubst < "$template" > "$output"
}

copy_with_sanitization() {
  local src="$1"
  local dest="$2"
  # Placeholder for markdown sanitization or other transforms.
  cp "$src" "$dest"
}

echo "[executor] helper script loaded" >&2
