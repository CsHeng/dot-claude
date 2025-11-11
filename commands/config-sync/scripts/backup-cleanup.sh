#!/usr/bin/env bash
# Backup cleanup library for config-sync workflows.
# Provides configurable backup retention and cleanup functionality.

set -euo pipefail

# Source common functions if available
if [[ -f "${BASH_SOURCE[0]%/*}/../lib/common.sh" ]]; then
  source "${BASH_SOURCE[0]%/*}/../lib/common.sh"
fi

# Fallback function for numfmt (not available on macOS)
format_bytes() {
  local bytes="$1"
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec "$bytes"
  else
    # Simple fallback for macOS
    if [[ $bytes -lt 1024 ]]; then
      echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
      echo "$(( bytes / 1024 ))K"
    elif [[ $bytes -lt 1073741824 ]]; then
      echo "$(( bytes / 1048576 ))M"
    else
      echo "$(( bytes / 1073741824 ))G"
    fi
  fi
}

# Default retention settings
DEFAULT_MAX_RUNS=5
DEFAULT_ENABLED=true
DEFAULT_DRY_RUN=false

# Parse retention settings from settings.json
# Usage: parse_retention_settings <settings_path>
parse_retention_settings() {
  local settings_path="$1"
  local max_runs="$DEFAULT_MAX_RUNS"
  local enabled="$DEFAULT_ENABLED"
  local dry_run="$DEFAULT_DRY_RUN"

  if [[ ! -f "$settings_path" ]]; then
    log_warning "[cleanup] Settings file not found: $settings_path, using defaults"
    echo "$max_runs,$enabled,$dry_run"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_warning "[cleanup] python3 not available, using default retention settings"
    echo "$max_runs,$enabled,$dry_run"
    return 0
  fi

  local parsed
  if ! parsed="$(
    python3 - "$settings_path" <<'PY'
import json, sys
path = sys.argv[1]
defaults = {}
try:
    with open(path, "r", encoding="utf-8") as fh:
        config = json.load(fh)
        retention = config.get("backup", {}).get("retention", {})
        max_runs = retention.get("maxRuns", 5)
        enabled = retention.get("enabled", True)
        dry_run = retention.get("dryRun", False)

        print(str(max_runs))
        print(str(enabled).lower())
        print(str(dry_run).lower())

except (FileNotFoundError, json.JSONDecodeError, KeyError):
    print("5")
    print("true")
    print("false")
PY
  )"; then
    log_warning "[cleanup] Failed to parse retention settings, using defaults"
    echo "$max_runs,$enabled,$dry_run"
    return 0
  fi

  # Convert Python output (newlines) to comma-separated format
  local parsed_array=()
  mapfile -t parsed_array <<<"$parsed"

  local max_runs_val="${parsed_array[0]:-$DEFAULT_MAX_RUNS}"
  local enabled_val="${parsed_array[1]:-$DEFAULT_ENABLED}"
  local dry_run_val="${parsed_array[2]:-$DEFAULT_DRY_RUN}"

  echo "${max_runs_val},${enabled_val},${dry_run_val}"
}

# Get backup run information from manifests
# Usage: get_backup_runs <backup_root>
get_backup_runs() {
  local backup_root="$1"

  if [[ ! -d "$backup_root" ]]; then
    log_error "[cleanup] Backup root directory not found: $backup_root"
    return 1
  fi

  local runs=()
  for run_dir in "$backup_root"/run-????????-??????; do
    if [[ -d "$run_dir" ]]; then
      local run_name
      run_name="$(basename "$run_dir")"
      local manifest="$run_dir/backups/BACKUP_MANIFEST.json"

      if [[ -f "$manifest" ]]; then
        local timestamp size
        timestamp=$(jq -r '.backup_summary.timestamp // empty' "$manifest" 2>/dev/null || echo "")
        size=$(jq -r '.backup_summary.total_backup_size_bytes // 0' "$manifest" 2>/dev/null || echo "0")

        runs+=("$run_name|$timestamp|$size")
      else
        # Fallback: extract timestamp from directory name
        local dir_timestamp
        dir_timestamp="$(echo "$run_name" | sed 's/run-\([0-9]\{8\}\)-\([0-9]\{6\}\)/\1T\2/')"
        runs+=("$run_name|${dir_timestamp}Z|0")
      fi
    fi
  done

  # Sort by run_name (newest first) as fallback
  printf '%s\n' "${runs[@]}" | sort -t'|' -k1 -r
}

# Safely delete backup runs with verification
# Usage: delete_backup_runs <backup_root> <runs_to_delete_array> <dry_run_flag>
delete_backup_runs() {
  local backup_root="$1"
  local dry_run="$2"
  shift 2
  local runs_to_delete=("$@")

  if [[ ${#runs_to_delete[@]} -eq 0 ]]; then
    log_info "[cleanup] No runs to delete"
    return 0
  fi

  local deleted_size=0
  local deleted_count=0

  for run_name in "${runs_to_delete[@]}"; do
    local run_path="$backup_root/$run_name"

    if [[ ! -d "$run_path" ]]; then
      log_warning "[cleanup] Run directory not found: $run_path"
      continue
    fi

    # Get size before deletion
    local run_size
    run_size=$(du -s "$run_path" 2>/dev/null | cut -f1 || echo 0)

    if [[ "$dry_run" == "true" ]]; then
      log_info "[cleanup] DRY-RUN: Would delete $run_name ($(format_bytes "$run_size"))"
      ((deleted_size += run_size))
      ((deleted_count++))
    else
      log_info "[cleanup] Deleting $run_name ($(format_bytes "$run_size"))"

      # Verify manifest exists before deletion
      local manifest="$run_path/backups/BACKUP_MANIFEST.json"
      if [[ ! -f "$manifest" ]]; then
        log_warning "[cleanup] No manifest found for $run_name, proceeding with caution"
      fi

      # Remove the directory
      if rm -rf "$run_path"; then
        ((deleted_size += run_size))
        ((deleted_count++))
        log_info "[cleanup] Successfully deleted $run_name"
      else
        log_error "[cleanup] Failed to delete $run_name"
      fi
    fi
  done

  log_info "[cleanup] Deleted $deleted_count runs, freed $(format_bytes "$deleted_size")"

  # Also clean up orphaned plan files
  cleanup_orphaned_plans "$backup_root" "$dry_run"
}

# Clean up plan files that don't have corresponding run directories
# Usage: cleanup_orphaned_plans <backup_root> <dry_run_flag>
cleanup_orphaned_plans() {
  local backup_root="$1"
  local dry_run="$2"

  local plan_files=("$backup_root"/plan-*.json)
  local orphaned_count=0

  for plan_file in "${plan_files[@]}"; do
    if [[ ! -f "$plan_file" ]]; then
      continue
    fi

    local plan_name
    plan_name="$(basename "$plan_file")"
    local run_name
    run_name="${plan_name/plan-/run-}"
    run_name="${run_name/.json/}"

    if [[ ! -d "$backup_root/$run_name" ]]; then
      if [[ "$dry_run" == "true" ]]; then
        log_info "[cleanup] DRY-RUN: Would delete orphaned plan: $plan_name"
      else
        log_info "[cleanup] Deleting orphaned plan: $plan_name"
        rm -f "$plan_file"
      fi
      ((orphaned_count++))
    fi
  done

  if [[ $orphaned_count -gt 0 ]]; then
    log_info "[cleanup] Cleaned up $orphaned_count orphaned plan files"
  fi
}

# Main cleanup function
# Usage: cleanup_backups <backup_root> <settings_path> <dry_run_override>
cleanup_backups() {
  local backup_root="$1"
  local settings_path="$2"
  local dry_run_override="${3:-}"

  # Parse retention settings
  local retention_settings
  if ! retention_settings=$(parse_retention_settings "$settings_path"); then
    log_error "[cleanup] Failed to parse retention settings"
    return 1
  fi

  IFS=',' read -r max_runs enabled_str dry_run_str <<< "$retention_settings"

  # Override dry_run if provided
  if [[ -n "$dry_run_override" ]]; then
    dry_run_str="$dry_run_override"
  fi

  # Convert string values to boolean
  enabled=$([ "$enabled_str" = "true" ] && echo "true" || echo "false")
  dry_run=$([ "$dry_run_str" = "true" ] && echo "true" || echo "false")

  if [[ "$enabled" != "true" ]]; then
    log_info "[cleanup] Backup retention is disabled"
    return 0
  fi

  if [[ -z "$max_runs" || ! "$max_runs" =~ ^[0-9]+$ ]]; then
    log_warning "[cleanup] Invalid maxRuns value '$max_runs', defaulting to $DEFAULT_MAX_RUNS"
    max_runs="$DEFAULT_MAX_RUNS"
  fi

  local max_runs_int="$max_runs"
  if (( max_runs_int < 0 )); then
    max_runs_int=0
  fi

  log_info "[cleanup] Starting backup cleanup (maxRuns: $max_runs_int, dryRun: $dry_run)"

  # Get backup runs sorted by timestamp
  local backup_runs=()
  mapfile -t backup_runs < <(get_backup_runs "$backup_root")

  if [[ ${#backup_runs[@]} -eq 0 ]]; then
    log_info "[cleanup] No backup runs found"
    return 0
  fi

  log_info "[cleanup] Found ${#backup_runs[@]} backup runs"

  local runs_to_delete=()
  if (( ${#backup_runs[@]} > max_runs_int )); then
    for ((i=max_runs_int; i<${#backup_runs[@]}; i++)); do
      local entry="${backup_runs[$i]}"
      local run_name="${entry%%|*}"
      runs_to_delete+=("$run_name")
    done
  fi

  if [[ ${#runs_to_delete[@]} -eq 0 ]]; then
    log_info "[cleanup] No runs need to be deleted (within retention limit)"
    return 0
  fi

  log_info "[cleanup] Will delete ${#runs_to_delete[@]} runs (${#backup_runs[@]} total → $(( ${#backup_runs[@]} - ${#runs_to_delete[@]} )) kept)"

  # Delete the runs
  delete_backup_runs "$backup_root" "$dry_run" "${runs_to_delete[@]}"

  log_info "[cleanup] Backup cleanup completed"
}

# Show current backup status and what would be cleaned up
# Usage: show_backup_status <backup_root> <settings_path>
show_backup_status() {
  local backup_root="$1"
  local settings_path="$2"

  # Parse retention settings
  local retention_settings
  if ! retention_settings=$(parse_retention_settings "$settings_path"); then
    log_error "[cleanup] Failed to parse retention settings"
    return 1
  fi

  IFS=',' read -r max_runs enabled_str dry_run_str <<< "$retention_settings"

  if [[ -z "$max_runs" || ! "$max_runs" =~ ^[0-9]+$ ]]; then
    max_runs="$DEFAULT_MAX_RUNS"
  fi

  local max_runs_int="$max_runs"
  if (( max_runs_int < 0 )); then
    max_runs_int=0
  fi

  echo "=== Backup Status ==="
  echo "Backup Root: $backup_root"
  echo "Retention Settings:"
  echo "  - Max Runs: $max_runs_int"
  echo "  - Enabled: $enabled_str"
  echo "  - Dry Run Default: $dry_run_str"
  echo ""

  # Get backup runs
  local backup_runs=()
  mapfile -t backup_runs < <(get_backup_runs "$backup_root")

  if [[ ${#backup_runs[@]} -eq 0 ]]; then
    echo "No backup runs found."
    return 0
  fi

  echo "Current Backup Runs (${#backup_runs[@]} total):"
  local total_size=0
  for i in "${!backup_runs[@]}"; do
    local run_info="${backup_runs[$i]}"
    IFS='|' read -r run_name timestamp size <<< "$run_info"
    local status

    if [[ $i -lt $max_runs_int ]]; then
      status="KEEP"
    else
      status="DELETE"
    fi

    printf "  %-20s %s %s %s\n" "$run_name" "${timestamp:-unknown}" "$(format_bytes "$size")" "$status"
    ((total_size += size))
  done

  echo ""
  echo "Total Size: $(format_bytes "$total_size")"

  # Show what would be deleted
  local delete_count=$(( ${#backup_runs[@]} > max_runs_int ? ${#backup_runs[@]} - max_runs_int : 0 ))
  if [[ $delete_count -gt 0 ]]; then
    echo "Runs to delete: $delete_count"
  else
    echo "Runs to delete: 0 (within retention limit)"
  fi
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  # Script executed directly
  if [[ $# -eq 0 ]] || [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]]; then
    cat <<'EOF'
Usage: backup-cleanup.sh [--status] [--dry-run] [backup_root] [settings_path]

Options:
  --status      Show current backup status and what would be cleaned up
  --dry-run     Show what would be deleted without actually deleting
  --help, -h    Show this help message

Arguments:
  backup_root   Backup root directory (default: $HOME/.claude/backup)
  settings_path Settings file path (default: script_dir/../settings.json)

Examples:
  backup-cleanup.sh --status
  backup-cleanup.sh --dry-run
  backup-cleanup.sh
EOF
    exit 0
  fi

  action="cleanup"
  dry_run_flag=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --status)
        action="status"
        shift
        ;;
      --dry-run)
        dry_run_flag="true"
        shift
        ;;
      --*)
        log_error "Unknown option: $1"
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done

  backup_root="${1:-$HOME/.claude/backup}"
  settings_path="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../settings.json}"

  case "$action" in
    status)
      show_backup_status "$backup_root" "$settings_path"
      ;;
    cleanup)
      cleanup_backups "$backup_root" "$settings_path" "$dry_run_flag"
      ;;
  esac
fi
