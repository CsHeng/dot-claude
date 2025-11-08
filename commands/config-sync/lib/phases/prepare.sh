phase_prepare() {
  log_info "[prepare] Creating backups under $RUN_ROOT/backups"

  local backup_root="$RUN_ROOT/backups"
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"

  local failures=0
  for target in "${SELECTED_TARGETS[@]}"; do
    local target_dir
    target_dir="$(get_target_config_dir "$target")"
    local target_backup="$backup_root/$target/$timestamp"
    mkdir -p "$target_backup"

    if [[ "$PROFILE" == "fast" ]]; then
      printf 'fast profile - backup skipped\n' >"$target_backup/SKIPPED.txt"
      log_info "[prepare] Fast profile: recorded placeholder backup for $target"
      continue
    fi

    if [[ ! -d "$target_dir" ]]; then
      log_warning "[prepare] Target directory missing for $target ($target_dir)"
      continue
    fi

    if command -v rsync >/dev/null 2>&1; then
      if ! rsync -a --quiet "$target_dir/" "$target_backup/"; then
        log_error "[prepare] rsync backup failed for $target"
        failures=1
      fi
    else
      if ! cp -R "$target_dir/." "$target_backup/"; then
        log_error "[prepare] copy backup failed for $target"
        failures=1
      fi
    fi
  done

  if [[ $failures -ne 0 ]]; then
    log_error "[prepare] Backup step encountered errors"
    return 1
  fi

  log_info "[prepare] Backups complete"
}
