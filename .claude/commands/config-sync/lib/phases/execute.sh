#!/usr/bin/env bash
set -euo pipefail

phase_execute() {
  if $DRY_RUN; then
    log_info "[execute] Dry-run mode enabled; no filesystem changes applied"
  else
    log_info "[execute] Target adapters already applied changes inline"
  fi

  local marker="$RUN_METADATA_DIR/execute.txt"
  {
    echo "dry_run=$DRY_RUN"
    echo "force=$FORCE"
    echo "timestamp=$(date +%Y-%m-%dT%H:%M:%S)"
  } >"$marker"

  log_info "[execute] Recorded execution metadata at $marker"
}
