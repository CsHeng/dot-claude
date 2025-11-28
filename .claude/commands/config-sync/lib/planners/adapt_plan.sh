#!/usr/bin/env bash
set -euo pipefail

planner_build_adapt_plan() {
  local plan_path="$1"
  local action="$2"
  local targets_csv="$3"
  local components_csv="$4"
  local adapter="$5"
  local profile="$6"
  local phases_csv="$7"
  local from_phase="$8"
  local until_phase="$9"
  local dry_run="${10}"
  local force="${11}"
  local verify="${12}"
  local settings_path="${13}"
  local timestamp="${14}"
  local run_root="${15}"

  __config_sync_emit_plan "$plan_path" "$action" "$targets_csv" "$components_csv" \
    "$profile" "$phases_csv" "$from_phase" "$until_phase" "$dry_run" "$force" \
    "$verify" "$settings_path" "$timestamp" "$run_root" "$adapter"
}
