phase_collect() {
  log_info "[collect] Validating environment and prerequisites"

  if ! check_dependencies; then
    log_error "[collect] Dependency check failed"
    return 1
  fi

  if ! validate_source_config "$CLAUDE_CONFIG_DIR"; then
    log_error "[collect] Source configuration invalid"
    return 1
  fi

  local missing_targets=0
  for target in "${SELECTED_TARGETS[@]}"; do
    if ! check_target_tool "$target"; then
      missing_targets=1
    fi
  done

  if [[ $missing_targets -ne 0 ]]; then
    log_error "[collect] One or more targets are unavailable"
    return 1
  fi

  local targets_csv components_csv
  targets_csv="$(IFS=,; printf '%s' "${SELECTED_TARGETS[*]}")"
  components_csv="$(IFS=,; printf '%s' "${SELECTED_COMPONENTS[*]}")"
  local collect_file="$RUN_METADATA_DIR/collect.json"

  if ! python3 -m config_sync.collect_phase "$collect_file" "$ACTION" "$targets_csv" "$components_csv" "$PLAN_FILE" "$RUN_ROOT"; then
    log_error "[collect] Failed to write metadata to $collect_file"
    return 1
  fi

  log_info "[collect] Metadata written to $collect_file"

  local qwen_selected=false
  local commands_selected=false

  for target in "${SELECTED_TARGETS[@]}"; do
    if [[ "$target" == "qwen" ]]; then
      qwen_selected=true
      break
    fi
  done

  for component in "${SELECTED_COMPONENTS[@]}"; do
    if [[ "$component" == "commands" ]]; then
      commands_selected=true
      break
    fi
  done

  if $qwen_selected && $commands_selected; then
    if ! python3 -m config_sync.toml_check >/dev/null 2>&1; then
      log_warning "[collect] Python module 'toml' not installed; qwen command verification will be skipped. Install via 'python3 -m pip install --user toml'."
    fi
  fi
}
