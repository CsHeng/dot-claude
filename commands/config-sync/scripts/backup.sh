#!/usr/bin/env bash
# Backup library for config-sync workflows.
# Provides unified backup functionality for all components.

set -euo pipefail

# Source common functions if available
if [[ -f "${BASH_SOURCE[0]%/*}/../lib/common.sh" ]]; then
  source "${BASH_SOURCE[0]%/*}/../lib/common.sh"
fi

# Create backup of a specific file or directory
# Usage: create_backup <source_path> <backup_dest>
create_backup() {
  local source_path="$1"
  local backup_dest="$2"

  if [[ ! -e "$source_path" ]]; then
    return 0
  fi

  # Create backup directory if needed
  mkdir -p "$(dirname "$backup_dest")"

  if [[ -d "$source_path" ]]; then
    mkdir -p "$backup_dest"
    rsync -a --quiet "$source_path"/ "$backup_dest"/
  else
    rsync -a --quiet "$source_path" "$backup_dest"
  fi

  log_info "[backup] created $backup_dest"
}

# Backup components for a target tool
# Usage: backup_target_components <target> <backup_root> <components_array>
backup_target_components() {
  local target="$1"
  local backup_root="$2"
  shift 2
  local components=("$@")

  local target_dir
  target_dir=$(get_target_config_dir "$target")
  local target_backup="$backup_root/$target"

  if [[ ! -d "$target_dir" ]]; then
    log_warning "[backup] target directory not found: $target_dir"
    return 0
  fi

  mkdir -p "$target_backup"

  local files_backed_up=0

  # Backup rules directory if selected
  if [[ " ${components[*]} " =~ " rules " ]]; then
    if [[ -d "$target_dir/rules" ]]; then
      if ! rsync -a --quiet "$target_dir/rules/" "$target_backup/rules/"; then
        log_error "[backup] Failed to backup rules directory for $target"
        return 1
      else
        log_info "[backup] Backed up rules directory for $target"
        ((files_backed_up += 1))
      fi
    fi
  fi

  # Backup commands directory if selected (excluding config-sync for non-opencode tools)
  if [[ " ${components[*]} " =~ " commands " ]]; then
    if [[ -d "$target_dir/commands" ]]; then
      # For non-opencode tools, exclude config-sync directory
      local rsync_args=("$target_dir/commands/" "$target_backup/commands/")
      if [[ "$target" != "opencode" ]]; then
        rsync_args=("--exclude=config-sync" "$target_dir/commands/" "$target_backup/commands/")
      fi

      if ! rsync -a --quiet "${rsync_args[@]}"; then
        log_error "[backup] Failed to backup commands directory for $target"
        return 1
      else
        log_info "[backup] Backed up commands directory for $target"
        ((files_backed_up += 1))
      fi
    fi
  fi

  # Backup memory-related files if included in components
  if [[ " ${components[*]} " =~ " memory " ]]; then
    # Backup AGENTS.md (universal)
    if [[ -f "$target_dir/AGENTS.md" ]]; then
      if ! create_backup "$target_dir/AGENTS.md" "$target_backup/AGENTS.md"; then
        log_error "[backup] Failed to backup AGENTS.md for $target"
        return 1
      else
        log_info "[backup] Backed up AGENTS.md for $target"
        ((files_backed_up += 1))
      fi
    fi

    # Backup tool-specific memory file
    local memory_filename
    memory_filename=$(get_tool_memory_filename "$target")
    if [[ "$target" != "opencode" ]] && [[ -f "$target_dir/$memory_filename" ]]; then
      if ! create_backup "$target_dir/$memory_filename" "$target_backup/$memory_filename"; then
        log_error "[backup] Failed to backup $memory_filename for $target"
        return 1
      else
        log_info "[backup] Backed up $memory_filename for $target"
        ((files_backed_up += 1))
      fi
    fi
  fi

  # Backup settings files if included in components
  if [[ " ${components[*]} " =~ " settings " ]]; then
    # Look for common settings file names
    local settings_files=("settings.json" "config.json" "config.toml")
    for settings_file in "${settings_files[@]}"; do
      if [[ -f "$target_dir/$settings_file" ]]; then
        if ! create_backup "$target_dir/$settings_file" "$target_backup/$settings_file"; then
          log_error "[backup] Failed to backup $settings_file for $target"
          return 1
        else
          log_info "[backup] Backed up $settings_file for $target"
          ((files_backed_up += 1))
        fi
      fi
    done
  fi

  # Create backup manifest
  local backup_manifest="$target_backup/BACKUP_MANIFEST.json"
  cat > "$backup_manifest" << EOF
{
  "backup_info": {
    "target": "$target",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "original_path": "$target_dir",
    "backup_path": "$target_backup",
    "backup_type": "component",
    "components": [$(printf '"%s",' "${components[@]}" | sed 's/,$//')]
  },
  "files_backed_up": $files_backed_up,
  "backup_size_bytes": $(du -s "$target_backup" 2>/dev/null | cut -f1 || echo 0)
}
EOF

  log_info "[backup] backup manifest created: $backup_manifest"
  return 0
}

# Create a backup manifest for multiple targets
# Usage: create_backup_manifest <backup_root> <targets_array> <components_array>
create_backup_manifest() {
  local backup_root="$1"
  shift 1
  local targets=("$@")

  local manifest_file="$backup_root/BACKUP_MANIFEST.json"
  local total_size=0
  local total_files=0
  local targets_json=""

  # Collect info from individual target manifests
  for target in "${targets[@]}"; do
    local target_manifest="$backup_root/$target/BACKUP_MANIFEST.json"
    if [[ -f "$target_manifest" ]]; then
      local target_size target_files
      target_size=$(jq -r '.files_backed_up' "$target_manifest" 2>/dev/null || echo 0)
      target_files=$(jq -r '.backup_size_bytes' "$target_manifest" 2>/dev/null || echo 0)
      ((total_files += target_files))
      ((total_size += target_size))

      if [[ -n "$targets_json" ]]; then
        targets_json+=","
      fi
      targets_json+=$(jq -c '.' "$target_manifest" 2>/dev/null || echo "{}")
    fi
  done

  # Create combined manifest
  cat > "$manifest_file" << EOF
{
  "backup_summary": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "backup_root": "$backup_root",
    "targets": [$(printf '"%s",' "${targets[@]}" | sed 's/,$//')],
    "total_files_backed_up": $total_files,
    "total_backup_size_bytes": $total_size
  },
  "targets_detail": [$targets_json]
}
EOF

  log_info "[backup] combined backup manifest created: $manifest_file"
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  echo "[backup] backup library loaded - use source to import functions"
fi
