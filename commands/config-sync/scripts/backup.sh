#!/usr/bin/env bash
# Backup helpers for config-sync workflows.

set -euo pipefail

create_backup() {
  local source_path="$1"
  local backup_root="$2"

  if [[ ! -e "$source_path" ]]; then
    return 0
  fi

  mkdir -p "$backup_root"
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  local name
  name="$(basename "$source_path")"
  local backup_path="$backup_root/${name}.${timestamp}.bak"

  if [[ -d "$source_path" ]]; then
    cp -a "$source_path" "$backup_path"
  else
    cp "$source_path" "$backup_path"
  fi

  echo "[backup] created $backup_path" >&2
}

echo "[backup] helper script loaded" >&2
