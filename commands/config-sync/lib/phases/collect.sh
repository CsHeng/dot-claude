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

  COLLECT_TARGETS="$targets_csv" \
  COLLECT_COMPONENTS="$components_csv" \
  COLLECT_ACTION="$ACTION" \
  COLLECT_PLAN="$PLAN_FILE" \
  COLLECT_RUNTIME="$RUN_ROOT" \
  python3 - "$collect_file" <<'PY'
import json, os, sys

report = {
    "action": os.environ.get("COLLECT_ACTION"),
    "targets": [t for t in os.environ.get("COLLECT_TARGETS", "").split(",") if t],
    "components": [c for c in os.environ.get("COLLECT_COMPONENTS", "").split(",") if c],
    "plan_file": os.environ.get("COLLECT_PLAN"),
    "runtime_dir": os.environ.get("COLLECT_RUNTIME"),
}

with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump(report, fh, indent=2)
PY

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
    if ! python3 - <<'PY' >/dev/null 2>&1
try:
    import toml  # noqa: F401
except ModuleNotFoundError:
    raise SystemExit(1)
PY
    then
      log_warning "[collect] Python module 'toml' not installed; qwen command verification will be skipped. Install via 'python3 -m pip install --user toml'."
    fi
  fi
}
