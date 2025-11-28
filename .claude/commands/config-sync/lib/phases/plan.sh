#!/usr/bin/env bash
set -euo pipefail

phase_plan() {
  if [[ ! -f "$PLAN_FILE" ]]; then
    log_error "[plan] Plan file not found at $PLAN_FILE"
    return 1
  fi

  local target_plan="$RUN_METADATA_DIR/plan.json"
  cp "$PLAN_FILE" "$target_plan"
  log_info "[plan] Snapshot copied to $target_plan"
}
