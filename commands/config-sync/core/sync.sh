#!/usr/bin/env bash
# Core configuration synchronization command

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTOR_SCRIPT="$SCRIPT_DIR/../scripts/executor.sh"

# Load executor functions
if [[ -f "$EXECUTOR_SCRIPT" ]]; then
  source "$EXECUTOR_SCRIPT"
else
  echo "[ERROR] Executor script not found: $EXECUTOR_SCRIPT" >&2
  exit 1
fi

# Parse arguments
TARGET_SPEC="all"
COMPONENT_SPEC="all"
DRY_RUN=false
FORCE=false
VERIFY=true
VERBOSE=false

usage() {
  cat << EOF
Usage: $0 --target=<droid,qwen,codex,opencode|all> --component=<rules,permissions,commands,settings,memory|all> [options]

Targets:
  droid      Factory/Droid CLI
  qwen       Qwen CLI
  codex      OpenAI Codex CLI
  opencode   OpenCode
  all        All target tools
  Comma list Select multiple targets (e.g., droid,qwen)

Components:
  rules        Development guidelines
  commands     Custom slash commands
  settings     Tool-specific settings
  permissions  Command permissions
  memory       Agent memory files
  all          All components
  Comma list   Select multiple components (e.g., rules,commands)

Options:
  --dry-run     Show what would be done without making changes
  --force       Force overwrite existing configurations
  --no-verify   Skip verification after sync
  --verbose     Show detailed output
  --help        Show this help message

WARNING:  CRITICAL: For Qwen CLI, use the adapter directly:
  /config-sync:adapters:qwen --action=sync --component=all
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --target=*)
      TARGET_SPEC="${1#--target=}"
      shift
      ;;
    --component=*)
      COMPONENT_SPEC="${1#--component=}"
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
      VERIFY=false
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Parse target/component selections into arrays
declare -a SELECTED_TARGETS=()
declare -a SELECTED_COMPONENTS=()

if ! mapfile -t SELECTED_TARGETS < <(parse_target_list "$TARGET_SPEC"); then
  log_error "Failed to parse --target value: $TARGET_SPEC"
  exit 1
fi

if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
  log_error "Failed to parse --component value: $COMPONENT_SPEC"
  exit 1
fi

join_by() {
  local sep="$1"
  shift
  local first=true
  for item in "$@"; do
    if $first; then
      printf '%s' "$item"
      first=false
    else
      printf '%s%s' "$sep" "$item"
    fi
  done
}

target_selected() {
  local needle="$1"
  for item in "${SELECTED_TARGETS[@]}"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

component_selected() {
  local needle="$1"
  for item in "${SELECTED_COMPONENTS[@]}"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

TARGET_LABEL="$(join_by ',' "${SELECTED_TARGETS[@]}")"
COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"

# Setup directories
CLAUDE_ROOT="$CLAUDE_CONFIG_DIR"
CONFIG_SYNC_DIR="$CLAUDE_ROOT/commands/config-sync"
ADAPTERS_DIR="$CONFIG_SYNC_DIR/adapters"

# Pre-flight checks
log_info "Starting configuration sync: target=$TARGET_LABEL, component=$COMPONENT_LABEL"

if ! check_dependencies; then
  log_error "Dependency check failed"
  exit 1
fi

if ! validate_source_config "$CLAUDE_ROOT"; then
  log_error "Source configuration validation failed"
  exit 1
fi

# Warn about Qwen settings impact
if component_selected "settings" && target_selected "qwen"; then
  if [[ "$FORCE" != "true" ]]; then
    log_warn "Qwen settings sync requires --force (skipping Qwen settings for safety)"
  else
    log_warn "Proceeding with Qwen settings sync (force mode enabled)"
  fi
fi

# Sync functions
run_adapter() {
  local target_tool="$1"
  local component_override="$2"
  local adapter_script="$ADAPTERS_DIR/${target_tool}.sh"

  if [[ -f "$adapter_script" ]]; then
    log_info "Running adapter for $target_tool..."

    local adapter_args=("--action=sync" "--component=$component_override")
    if [[ "$DRY_RUN" == "true" ]]; then
      adapter_args+=("--dry-run")
    fi
    if [[ "$VERBOSE" == "true" ]]; then
      adapter_args+=("--verbose")
    fi

    if bash "$adapter_script" "${adapter_args[@]}"; then
      log_info "✓ $target_tool sync completed"
      return 0
    else
      log_error "✗ $target_tool sync failed"
      return 1
    fi
  else
    log_warn "No adapter found for $target_tool, skipping"
    return 0
  fi
}

# Sync configuration by component
sync_rules() {
  local failed=0
  for target in "${SELECTED_TARGETS[@]}"; do
    if ! run_adapter "$target" "rules"; then
      ((failed += 1))
    fi
  done

  return $failed
}

sync_commands() {
  local failed=0
  for target in "${SELECTED_TARGETS[@]}"; do
    if ! run_adapter "$target" "commands"; then
      ((failed += 1))
    fi
  done

  return $failed
}

sync_settings() {
  local eligible_targets=()
  local skipped_qwen=false

  for target in "${SELECTED_TARGETS[@]}"; do
    if [[ "$target" == "qwen" && "$FORCE" != "true" ]]; then
      skipped_qwen=true
      continue
    fi
    eligible_targets+=("$target")
  done

  if [[ "$skipped_qwen" == true ]]; then
    log_warn "Skipping Qwen settings sync (use --force to override)"
  fi

  if [[ ${#eligible_targets[@]} -eq 0 ]]; then
    log_info "No eligible targets for settings sync"
    return 0
  fi

  local failed=0
  for target in "${eligible_targets[@]}"; do
    if ! run_adapter "$target" "settings"; then
      ((failed += 1))
    fi
  done

  return $failed
}

sync_permissions() {
  local script="$ADAPTERS_DIR/adapt-permissions.sh"
  if [[ ! -f "$script" ]]; then
    log_error "Permissions adapter script not found: $script"
    return 1
  fi

  local failed=0
  for target in "${SELECTED_TARGETS[@]}"; do
    log_info "Adapting permissions for $target..."
    local args=("--target=$target")
    if [[ "$DRY_RUN" == "true" ]]; then
      args+=("--dry-run")
    fi
    if [[ "$FORCE" == "true" ]]; then
      args+=("--force")
    fi
    if [[ "$VERBOSE" == "true" ]]; then
      args+=("--verbose")
    fi

    if ! bash "$script" "${args[@]}"; then
      log_error "✗ Permission adaptation failed for $target"
      ((failed += 1))
    else
      log_info "✓ Permissions adapted for $target"
    fi
  done

  return $failed
}

sync_memory() {
  local script="$ADAPTERS_DIR/sync-memory.sh"
  if [[ ! -f "$script" ]]; then
    log_error "Memory adapter script not found: $script"
    return 1
  fi

  local failed=0
  for target in "${SELECTED_TARGETS[@]}"; do
    log_info "Synchronizing memory for $target..."
    local args=("--target=$target")
    if [[ "$DRY_RUN" == "true" ]]; then
      args+=("--dry-run")
    fi
    if [[ "$FORCE" == "true" ]]; then
      args+=("--force")
    fi
    if [[ "$VERBOSE" == "true" ]]; then
      args+=("--verbose")
    fi

    if ! bash "$script" "${args[@]}"; then
      log_error "✗ Memory synchronization failed for $target"
      ((failed += 1))
    else
      log_info "✓ Memory synchronized for $target"
    fi
  done

  return $failed
}

# Execute sync
exit_code=0
failed_operations=0

for component in "${SELECTED_COMPONENTS[@]}"; do
  case "$component" in
    commands)
      sync_commands || ((failed_operations += 1))
      ;;
    rules)
      sync_rules || ((failed_operations += 1))
      ;;
    settings)
      sync_settings || ((failed_operations += 1))
      ;;
    permissions)
      sync_permissions || ((failed_operations += 1))
      ;;
    memory)
      sync_memory || ((failed_operations += 1))
      ;;
  esac
done

# Verification
if [[ "$VERIFY" == "true" && "$DRY_RUN" != "true" && $failed_operations -eq 0 ]]; then
  log_info "Running verification..."

  verify_failed=0
  verify_components=()

  if [[ "$COMPONENT_SPEC" == "all" ]]; then
    verify_components=("all")
  else
    verify_components=("${SELECTED_COMPONENTS[@]}")
  fi

  for target in "${SELECTED_TARGETS[@]}"; do
    adapter_script="$ADAPTERS_DIR/${target}.sh"
    if [[ -f "$adapter_script" ]]; then
      for component in "${verify_components[@]}"; do
        if [[ "$component" == "all" ]]; then
          log_info "Verifying $target..."
        else
          log_info "Verifying $target ($component)..."
        fi
        if ! bash "$adapter_script" "--action=verify" "--component=$component"; then
          ((verify_failed += 1))
        fi
      done
    fi
  done

  if [[ $verify_failed -gt 0 ]]; then
    log_error "Verification failed for $verify_failed targets"
    exit_code=1
  else
    log_info "✓ Verification passed for all targets"
  fi
fi

# Report results
if [[ $failed_operations -gt 0 ]]; then
  log_error "Sync completed with $failed_operations failed operations"
  exit_code=1
else
  log_info "✓ Sync completed successfully"
fi

exit $exit_code
