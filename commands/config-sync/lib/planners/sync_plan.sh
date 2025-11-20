#!/usr/bin/env bash

__config_sync_emit_plan() {
  local plan_path="$1"
  local action="$2"
  local targets_csv="$3"
  local components_csv="$4"
  local profile="$5"
  local phases_csv="$6"
  local from_phase="$7"
  local until_phase="$8"
  local dry_run="$9"
  local force="${10}"
  local verify="${11}"
  local settings_path="${12}"
  local timestamp="${13}"
  local run_root="${14}"
  local adapter="${15:-}"

  python3 -m config_sync.sync_plan_builder \
    "$plan_path" \
    "$action" \
    "$targets_csv" \
    "$components_csv" \
    "$profile" \
    "$phases_csv" \
    "$from_phase" \
    "$until_phase" \
    "$dry_run" \
    "$force" \
    "$verify" \
    "$settings_path" \
    "$timestamp" \
    "$run_root" \
    "$adapter"
}

planner_build_sync_plan() {
  __config_sync_emit_plan "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" \
    "${10}" "${11}" "${12}" "${13}" "${14}" ""
}
