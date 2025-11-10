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

  local plan_dir
  plan_dir="$(dirname "$plan_path")"
  mkdir -p "$plan_dir"

  python3 - "$plan_path" "$action" "$targets_csv" "$components_csv" "$profile" \
    "$phases_csv" "$from_phase" "$until_phase" "$dry_run" "$force" \
    "$verify" "$settings_path" "$timestamp" "$run_root" "$adapter" <<'PY'
import json, os, sys

(plan_path, action, targets_csv, components_csv, profile, phases_csv,
 from_phase, until_phase, dry_run, force, verify,
 settings_path, timestamp, run_root, adapter) = sys.argv[1:]

def split_csv(value):
    return [item for item in value.split(",") if item]

def as_bool(value):
    return value.lower() == "true"

defaults = {}
if os.path.exists(settings_path or ""):
    try:
        with open(settings_path, "r", encoding="utf-8") as fh:
            defaults = json.load(fh).get("defaults", {})
    except Exception:
        defaults = {}

plan = {
    "version": "1.0",
    "action": action,
    "targets": split_csv(targets_csv),
    "components": split_csv(components_csv),
    "profile": profile,
    "phases": split_csv(phases_csv),
    "phase_window": {
        "from": from_phase or None,
        "until": until_phase or None,
    },
    "flags": {
        "dryRun": as_bool(dry_run),
        "force": as_bool(force),
        "verify": as_bool(verify),
    },
    "settings": {
        "path": settings_path,
        "defaults": defaults,
    },
    "generated_at": timestamp,
    "run_root": run_root,
    "artifacts": {
        "plan": plan_path,
        "logs_dir": os.path.join(run_root, "logs"),
        "metadata_dir": os.path.join(run_root, "metadata"),
        "backups_dir": os.path.join(run_root, "backups"),
    },
}

if adapter:
    plan["adapter"] = adapter

with open(plan_path, "w", encoding="utf-8") as fh:
    json.dump(plan, fh, indent=2)
PY
}

planner_build_sync_plan() {
  __config_sync_emit_plan "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" \
    "${10}" "${11}" "${12}" "${13}" "${14}" ""
}
