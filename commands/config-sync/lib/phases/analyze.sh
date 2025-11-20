phase_analyze() {
  log_info "[analyze] Building capability report for targets (${FORMAT})"

  local matrix=""
  for target in "${SELECTED_TARGETS[@]}"; do
    local config_dir commands_dir rules_dir
    config_dir="$(get_target_config_dir "$target")"
    commands_dir="$(get_target_commands_dir "$target")"
    rules_dir="$(get_target_rules_dir "$target")"
    matrix+="$target|$config_dir|$commands_dir|$rules_dir"$'\n'
  done

  local report_file="$RUN_METADATA_DIR/analyze.json"
  TARGET_MATRIX="$matrix" ANALYZE_FORMAT="$FORMAT" ANALYZE_DETAILED="$DETAILED" \
    python3 -m config_sync.analyze_phase "$report_file"

  log_info "[analyze] Report written to $report_file"
}
