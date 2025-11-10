#!/usr/bin/env bash
# Prepare phase: Create unified backups using backup.sh library

set -euo pipefail

# Source backup library - use absolute path based on CLI_ROOT
source "${CLI_ROOT}/scripts/backup.sh"

phase_prepare() {
  log_info "[prepare] Creating unified component backups under $RUN_ROOT/backups"

  local backup_root="$RUN_ROOT/backups"
  local failures=0

  # Get components once for all targets
  local components=($(get_components))
  log_info "[prepare] Will backup components for all targets: ${components[*]}"

  # Backup all targets using the backup library
  for target in "${SELECTED_TARGETS[@]}"; do
    if [[ "$PROFILE" == "fast" ]]; then
      local target_backup="$backup_root/$target"
      mkdir -p "$target_backup"
      printf 'fast profile - backup skipped\n' >"$target_backup/SKIPPED.txt"
      log_info "[prepare] Fast profile: recorded placeholder backup for $target"
      continue
    fi

    log_info "[prepare] Backing up $target components using backup library"

    # Use backup library for component-based backup
    backup_target_components "$target" "$backup_root" "${components[@]}"
    local backup_result=$?

    if [[ $backup_result -ne 0 ]]; then
      log_error "[prepare] Backup failed for $target"
      failures=1
    else
      log_info "[prepare] Backup completed successfully for $target"
    fi
  done

  # Create combined backup manifest for all targets
  log_info "[prepare] Creating combined backup manifest"
  create_backup_manifest "$backup_root" "${SELECTED_TARGETS[@]}"

  if [[ $failures -ne 0 ]]; then
    log_error "[prepare] One or more backups encountered errors"
    return 1
  fi

  log_info "[prepare] Unified component backups complete - all targets backed up via backup.sh"
}
