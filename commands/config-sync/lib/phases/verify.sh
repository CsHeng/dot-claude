phase_verify() {
  if [[ "$ACTION" != "verify" && "$VERIFY_ENABLED" != true ]]; then
    log_info "[verify] Verification disabled; skipping"
    return 0
  fi

  local failures=0
  for target in "${SELECTED_TARGETS[@]}"; do
    local adapter_script="$ADAPTERS_DIR/${target}.sh"
    if [[ ! -f "$adapter_script" ]]; then
      log_warning "[verify] Adapter script missing for $target; skipping"
      continue
    fi

    for component in "${SELECTED_COMPONENTS[@]}"; do
      if [[ "$component" == "permissions" ]]; then
        local perm_script="$ADAPTERS_DIR/adapt-permissions.sh"
        if [[ ! -f "$perm_script" ]]; then
          log_warning "[verify] Permissions adapter missing; skipping"
          continue
        fi
        log_info "[verify] Verifying permissions for $target"
        if ! bash "$perm_script" "--target=$target" "--mode=verify"; then
          log_error "[verify] Permissions verification failed for $target"
          failures=1
        fi
        continue
      fi
      log_info "[verify] Verifying $target ($component)"
      if ! bash "$adapter_script" "--action=verify" "--component=$component"; then
        log_error "[verify] Verification failed for $target ($component)"
        failures=1
      fi
    done
  done

  if [[ $failures -ne 0 ]]; then
    log_error "[verify] Verification stage reported failures"
    return 1
  fi

  log_info "[verify] Verification complete"
}
