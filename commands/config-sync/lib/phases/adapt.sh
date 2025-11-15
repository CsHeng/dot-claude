__phase_adapt_run_target_component() {
  local target="$1"
  local component="$2"
  local action="${3:-sync}"
  local adapter_script="$ADAPTERS_DIR/${target}.sh"

  if [[ ! -f "$adapter_script" ]]; then
    log_warning "[adapt] Adapter script missing for $target ($adapter_script); skipping"
    return 0
  fi

  local args=("--action=$action" "--component=$component")
  $DRY_RUN && args+=("--dry-run")
  $FORCE && args+=("--force")
  $VERBOSE && args+=("--verbose")

  log_info "[adapt] Running adapter for $target ($component)"
  if bash "$adapter_script" "${args[@]}"; then
    return 0
  fi

  log_error "[adapt] Adapter failed for $target ($component)"
  return 1
}

__phase_adapt_run_permissions() {
  local failures=0
  local script="$ADAPTERS_DIR/adapt-permissions.sh"
  if [[ ! -f "$script" ]]; then
    log_warning "[adapt] Permissions adapter missing; skipping"
    return 0
  fi

  for target in "${SELECTED_TARGETS[@]}"; do
    local args=("--target=$target")
    $DRY_RUN && args+=("--dry-run")
    $FORCE && args+=("--force")
    $VERBOSE && args+=("--verbose")

    log_info "[adapt] Updating permissions for $target"
    if ! bash "$script" "${args[@]}"; then
      log_error "[adapt] Permission adaptation failed for $target"
      failures=1
    fi
  done

  return $failures
}

__phase_adapt_run_memory() {
  local script="$ADAPTERS_DIR/sync-memory.sh"
  if [[ ! -f "$script" ]]; then
    log_warning "[adapt] Memory adapter missing; skipping"
    return 0
  fi

  local target_csv
  target_csv="$(IFS=,; printf '%s' "${SELECTED_TARGETS[*]}")"
  local args=("--target=$target_csv")
  $DRY_RUN && args+=("--dry-run")
  $FORCE && args+=("--force")
  $VERBOSE && args+=("--verbose")

  log_info "[adapt] Synchronizing memory for $target_csv"
  if bash "$script" "${args[@]}"; then
    return 0
  fi

  log_error "[adapt] Memory synchronization failed"
  return 1
}

phase_adapt() {
  local components=()
  if [[ "$ACTION" == "adapt" && -n "$ADAPTER_NAME" ]]; then
    components=("$ADAPTER_NAME")
  else
    components=("${SELECTED_COMPONENTS[@]}")
  fi

  local failures=0
  for component in "${components[@]}"; do
    case "$component" in
      permissions)
        __phase_adapt_run_permissions || failures=1
        ;;
      memory)
        __phase_adapt_run_memory || failures=1
        ;;
      rules|commands)
        for target in "${SELECTED_TARGETS[@]}"; do
          __phase_adapt_run_target_component "$target" "$component" || failures=1
        done
        ;;
      *)
        log_warning "[adapt] Component '$component' not supported in CLI"
        ;;
    esac
  done

  if [[ $failures -ne 0 ]]; then
    log_error "[adapt] Component adaptation failed"
    return 1
  fi

  log_info "[adapt] Component adaptation complete"
}
