#!/usr/bin/env bash
# Unified config-sync CLI orchestrator.

set -euo pipefail

CLI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CLI_ROOT
SETTINGS_PATH="$CLI_ROOT/settings.json"
readonly SETTINGS_PATH
STATE_ROOT="${HOME}/.claude/backup"
mkdir -p "$STATE_ROOT"

source "$CLI_ROOT/lib/common.sh"
source "$CLI_ROOT/scripts/executor.sh"
source "$CLI_ROOT/scripts/backup-cleanup.sh"

PHASES_DIR="$CLI_ROOT/lib/phases"
PLANNERS_DIR="$CLI_ROOT/lib/planners"

source "$PHASES_DIR/collect.sh"
source "$PHASES_DIR/analyze.sh"
source "$PHASES_DIR/plan.sh"
source "$PHASES_DIR/prepare.sh"
source "$PHASES_DIR/adapt.sh"
source "$PHASES_DIR/execute.sh"
source "$PHASES_DIR/verify.sh"
source "$PHASES_DIR/report.sh"

source "$PLANNERS_DIR/sync_plan.sh"
source "$PLANNERS_DIR/adapt_plan.sh"

trap 'log_error "sync-cli failed on line $LINENO"; exit 1' ERR

ACTION="sync"
TARGET_SPEC=""
COMPONENT_SPEC=""
ADAPTER_NAME=""
PROFILE="full"
PLAN_FILE_OVERRIDE=""
FROM_PHASE=""
UNTIL_PHASE=""
FORMAT="markdown"
DRY_RUN=false
FORCE=false
NO_VERIFY=false
VERBOSE=false
DETAILED=false

DEFAULT_TARGET_SPEC="all"
DEFAULT_COMPONENT_SPEC="all"
DEFAULT_VERIFY=true
DEFAULT_DRY_RUN=false

declare -a SELECTED_TARGETS=()
declare -a SELECTED_COMPONENTS=()
declare -a ACTIVE_PHASES=()
declare -a PIPELINE_PHASES=()

declare -A PHASE_STATUS=()
declare -A PHASE_MESSAGE=()

PLAN_FILE=""
RUN_ROOT=""
RUN_LOG_DIR=""
RUN_METADATA_DIR=""
PLAN_TIMESTAMP=""
VERIFY_ENABLED=true

setup_plugin_environment
ADAPTERS_DIR="$CLI_ROOT/adapters"

usage() {
  cat <<'EOF'
Usage: sync-cli.sh [options]

Options:
  --action=<sync|analyze|verify|adapt|plan|report>
  --target=<droid,qwen,codex,opencode,amp|all>
  --components=<rules,permissions,commands,settings,memory|all>
  --adapter=<commands|permissions|rules|memory|settings>     (required for --action=adapt)
  --profile=<fast|full|custom>
  --plan-file=<path>
  --from-phase=<phase>
  --until-phase=<phase>
  --format=<markdown|table|json>
  --dry-run
  --force
  --no-verify
  --verbose
  --help
EOF
}

load_defaults() {
  if [[ ! -f "$SETTINGS_PATH" ]]; then
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_warning "python3 not available, falling back to hardcoded defaults"
    return
  fi

  local parsed
  if ! parsed="$(
    python3 -m config_sync.settings_loader "$SETTINGS_PATH"
  )"; then
    log_warning "Failed to parse settings.json; using fallback defaults"
    return
  fi

  local defaults_array=()
  mapfile -t defaults_array <<<"$parsed"

  local target_default="${defaults_array[0]:-}"
  local component_default="${defaults_array[1]:-}"
  local verify_default="${defaults_array[2]:-}"
  local dry_run_default="${defaults_array[3]:-}"

  if [[ -n "$target_default" ]]; then
    DEFAULT_TARGET_SPEC="$target_default"
  fi

  if [[ -n "$component_default" ]]; then
    DEFAULT_COMPONENT_SPEC="$component_default"
  fi

  if [[ "$verify_default" == "true" ]]; then
    DEFAULT_VERIFY=true
  else
    DEFAULT_VERIFY=false
  fi

  if [[ "$dry_run_default" == "true" ]]; then
    DEFAULT_DRY_RUN=true
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --action=*)
        ACTION="${1#--action=}"
        shift
        ;;
      --action)
        ACTION="$2"
        shift 2
        ;;
      --target=*|--targets=*)
        TARGET_SPEC="${1#*=}"
        shift
        ;;
      --target|--targets)
        TARGET_SPEC="$2"
        shift 2
        ;;
      --component=*|--components=*)
        COMPONENT_SPEC="${1#*=}"
        shift
        ;;
      --component|--components)
        COMPONENT_SPEC="$2"
        shift 2
        ;;
      --adapter=*)
        ADAPTER_NAME="${1#--adapter=}"
        shift
        ;;
      --adapter)
        ADAPTER_NAME="$2"
        shift 2
        ;;
      --profile=*)
        PROFILE="${1#--profile=}"
        shift
        ;;
      --profile)
        PROFILE="$2"
        shift 2
        ;;
      --plan-file=*)
        PLAN_FILE_OVERRIDE="${1#--plan-file=}"
        shift
        ;;
      --plan-file)
        PLAN_FILE_OVERRIDE="$2"
        shift 2
        ;;
      --from-phase=*)
        FROM_PHASE="${1#--from-phase=}"
        shift
        ;;
      --from-phase)
        FROM_PHASE="$2"
        shift 2
        ;;
      --until-phase=*)
        UNTIL_PHASE="${1#--until-phase=}"
        shift
        ;;
      --until-phase)
        UNTIL_PHASE="$2"
        shift 2
        ;;
      --format=*)
        FORMAT="${1#--format=}"
        shift
        ;;
      --format)
        FORMAT="$2"
        shift 2
        ;;
      --detailed)
        DETAILED=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --force)
        FORCE=true
        shift
        ;;
      --no-verify)
        NO_VERIFY=true
        shift
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done
}

validate_action() {
  case "$ACTION" in
    sync|analyze|verify|adapt|plan|report) ;;
    *)
      log_error "Unsupported --action value: $ACTION"
      exit 1
      ;;
  esac
}

validate_profile() {
  case "$PROFILE" in
    full|fast|custom) ;;
    *)
      log_error "Unsupported --profile value: $PROFILE"
      exit 1
      ;;
  esac
}

validate_format() {
  case "$FORMAT" in
    markdown|table|json) ;;
    *)
      log_error "Unsupported --format value: $FORMAT"
      exit 1
      ;;
  esac
}

resolve_selection_defaults() {
  [[ -n "$TARGET_SPEC" ]] || TARGET_SPEC="$DEFAULT_TARGET_SPEC"
  [[ -n "$COMPONENT_SPEC" ]] || COMPONENT_SPEC="$DEFAULT_COMPONENT_SPEC"

  if ! mapfile -t SELECTED_TARGETS < <(parse_target_list "$TARGET_SPEC"); then
    log_error "Failed to parse --target value: $TARGET_SPEC"
    exit 1
  fi

  if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
    log_error "Failed to parse --components value: $COMPONENT_SPEC"
    exit 1
  fi
}

configure_flags() {
  VERIFY_ENABLED="$DEFAULT_VERIFY"

  if [[ "$NO_VERIFY" == "true" ]]; then
    VERIFY_ENABLED=false
  fi

  if [[ "$ACTION" == "verify" ]]; then
    VERIFY_ENABLED=true
  fi

  if [[ "$PROFILE" == "fast" && "$ACTION" == "sync" ]]; then
    VERIFY_ENABLED=false
  fi

  if [[ "$DEFAULT_DRY_RUN" == "true" && "$DRY_RUN" == "false" ]]; then
    DRY_RUN=true
  fi
}

phase_exists() {
  local needle="$1"
  case "$needle" in
    collect|analyze|plan|prepare|adapt|execute|verify|cleanup|report) return 0 ;;
    *) return 1 ;;
  esac
}

select_phases() {
  ACTIVE_PHASES=()
  case "$ACTION" in
    sync)
      ACTIVE_PHASES=(prepare adapt execute)
      $VERIFY_ENABLED && ACTIVE_PHASES+=(verify)
      ACTIVE_PHASES+=(cleanup report)
      ;;
    analyze)
      ACTIVE_PHASES=(collect analyze report)
      ;;
    verify)
      ACTIVE_PHASES=(verify report)
      ;;
    adapt)
      ACTIVE_PHASES=(prepare adapt report)
      ;;
    plan)
      ACTIVE_PHASES=(plan)
      ;;
    report)
      ACTIVE_PHASES=(report)
      ;;
  esac

  if [[ -n "$FROM_PHASE" ]]; then
    if ! phase_exists "$FROM_PHASE"; then
      log_error "Unknown --from-phase value: $FROM_PHASE"
      exit 1
    fi
  fi

  if [[ -n "$UNTIL_PHASE" ]]; then
    if ! phase_exists "$UNTIL_PHASE"; then
      log_error "Unknown --until-phase value: $UNTIL_PHASE"
      exit 1
    fi
  fi

  if [[ -n "$FROM_PHASE" || -n "$UNTIL_PHASE" ]]; then
    local filtered=()
    local capturing=false
    for phase in "${ACTIVE_PHASES[@]}"; do
      if [[ -n "$FROM_PHASE" && "$phase" == "$FROM_PHASE" ]]; then
        capturing=true
      fi

      if [[ -z "$FROM_PHASE" ]]; then
        capturing=true
      fi

      if $capturing; then
        filtered+=("$phase")
      fi

      if [[ -n "$UNTIL_PHASE" && "$phase" == "$UNTIL_PHASE" ]]; then
        break
      fi
    done

    if [[ ${#filtered[@]} -eq 0 ]]; then
      log_error "Phase window produced an empty set"
      exit 1
    fi

    ACTIVE_PHASES=("${filtered[@]}")
  fi
}

ensure_runtime_paths() {
  PLAN_TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
  PLAN_FILE="$PLAN_FILE_OVERRIDE"
  if [[ -z "$PLAN_FILE" ]]; then
    PLAN_FILE="$STATE_ROOT/plan-$PLAN_TIMESTAMP.json"
  else
    if [[ "$PLAN_FILE_OVERRIDE" = /* ]]; then
      PLAN_FILE="$PLAN_FILE_OVERRIDE"
    else
      PLAN_FILE="$(cd "$(dirname "$PLAN_FILE_OVERRIDE")" && pwd -P)/$(basename "$PLAN_FILE_OVERRIDE")"
    fi
  fi

  RUN_ROOT="$STATE_ROOT/run-${PLAN_TIMESTAMP}"
  RUN_LOG_DIR="$RUN_ROOT/logs"
  RUN_METADATA_DIR="$RUN_ROOT/metadata"

  mkdir -p "$RUN_LOG_DIR" "$RUN_METADATA_DIR" "$RUN_ROOT/backups"
}

write_plan() {
  local targets_csv components_csv phases_csv
  targets_csv="$(IFS=,; printf '%s' "${SELECTED_TARGETS[*]}")"
  components_csv="$(IFS=,; printf '%s' "${SELECTED_COMPONENTS[*]}")"
  phases_csv="$(IFS=,; printf '%s' "${ACTIVE_PHASES[*]}")"

  case "$ACTION" in
    adapt)
      if [[ -z "$ADAPTER_NAME" ]]; then
        log_error "--adapter is required when --action=adapt"
        exit 1
      fi
      planner_build_adapt_plan \
        "$PLAN_FILE" \
        "$ACTION" \
        "$targets_csv" \
        "$components_csv" \
        "$ADAPTER_NAME" \
        "$PROFILE" \
        "$phases_csv" \
        "$FROM_PHASE" \
        "$UNTIL_PHASE" \
        "$DRY_RUN" \
        "$FORCE" \
        "$VERIFY_ENABLED" \
        "$SETTINGS_PATH" \
        "$PLAN_TIMESTAMP" \
        "$RUN_ROOT"
      ;;
    *)
      planner_build_sync_plan \
        "$PLAN_FILE" \
        "$ACTION" \
        "$targets_csv" \
        "$components_csv" \
        "$PROFILE" \
        "$phases_csv" \
        "$FROM_PHASE" \
        "$UNTIL_PHASE" \
        "$DRY_RUN" \
        "$FORCE" \
        "$VERIFY_ENABLED" \
        "$SETTINGS_PATH" \
        "$PLAN_TIMESTAMP" \
        "$RUN_ROOT"
      ;;
  esac
}

log_plan_context() {
  log_info "sync-cli plan: $PLAN_FILE"
  log_info "targets   : $(IFS=,; printf '%s' "${SELECTED_TARGETS[*]}")"
  log_info "components: $(IFS=,; printf '%s' "${SELECTED_COMPONENTS[*]}")"
  log_info "phases    : $(IFS=,; printf '%s' "${ACTIVE_PHASES[*]}")"
}

record_phase_status() {
  local phase="$1"
  local status="$2"
  local message="$3"
  PHASE_STATUS["$phase"]="$status"
  PHASE_MESSAGE["$phase"]="$message"
}

execute_phase() {
  local phase="$1"
  local func="phase_${phase}"
  local log_file="$RUN_LOG_DIR/${phase}.log"

  if ! declare -F "$func" >/dev/null 2>&1; then
    log_error "Missing implementation for phase: $phase"
    return 1
  fi

  log_info "=== Phase: $phase ==="
  if "$func" 2>&1 | tee -a "$log_file"; then
    record_phase_status "$phase" "success" "completed"
    return 0
  else
    local exit_code=$?
    record_phase_status "$phase" "failed" "error (code $exit_code)"
    return $exit_code
  fi
}

mark_remaining_skipped() {
  local start_index="$1"
  local phases=("${PIPELINE_PHASES[@]}")
  local total=${#phases[@]}
  local i="$start_index"
  while [[ $i -lt $total ]]; do
    local phase="${phases[$i]}"
    record_phase_status "$phase" "skipped" "skipped due to earlier failure"
    ((i++))
  done
}

run_pipeline() {
  PIPELINE_PHASES=()
  local report_requested=false
  for phase in "${ACTIVE_PHASES[@]}"; do
    if [[ "$phase" == "report" ]]; then
      report_requested=true
    else
      PIPELINE_PHASES+=("$phase")
    fi
  done

  local index=0
  local failure=false

  for phase in "${PIPELINE_PHASES[@]}"; do
    if ! execute_phase "$phase"; then
      failure=true
      ((index++))
      mark_remaining_skipped "$index"
      break
    fi
    ((index++))
  done

  if $report_requested; then
    execute_phase "report" || true
  fi

  $failure && return 1
  return 0
}

phase_cleanup() {
  log_info "Starting backup cleanup phase"

  # Run backup cleanup with current settings
  if ! cleanup_backups "$STATE_ROOT" "$SETTINGS_PATH"; then
    log_error "Backup cleanup phase failed"
    return 1
  fi

  log_info "Backup cleanup phase completed successfully"
  return 0
}

main() {
  load_defaults
  parse_args "$@"
  validate_action
  validate_profile
  validate_format
  resolve_selection_defaults
  configure_flags
  select_phases
  ensure_runtime_paths
  write_plan
  log_plan_context

  if ! run_pipeline; then
    exit 1
  fi
}

main "$@"
