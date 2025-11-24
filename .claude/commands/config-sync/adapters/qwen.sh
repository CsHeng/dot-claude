#!/usr/bin/env bash
# Qwen CLI configuration synchronization (Simplified with Python modules)

set -euo pipefail

# Setup environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Parse arguments
ACTION="sync"
COMPONENT_SPEC="all"
DRY_RUN=false
VERBOSE=false

declare -a SELECTED_COMPONENTS=()
COMPONENT_LABEL=""

usage() {
  cat << EOF
Usage: $0 --action=<sync|analyze|verify> --component=<commands|all> [options]

Actions:
  sync      Synchronize configuration to Qwen
  analyze   Analyze current configuration state
  verify    Verify synchronization completeness

Components (comma-separated):
  commands   Custom slash commands
  all        All supported components (default: commands)

Options:
  --dry-run    Show what would be done without making changes
  --verbose    Show detailed output
  --help       Show this help message
EOF
}

# Parse command line arguments
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
    --component=*)
      COMPONENT_SPEC="${1#--component=}"
      shift
      ;;
    --component)
      COMPONENT_SPEC="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
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
      log_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

# Validate arguments
case "$ACTION" in
  sync|analyze|verify) ;;
  *)
    log_error "Invalid action: $ACTION"
    usage
    exit 1
    ;;
esac

# Parse and validate components using common.sh functions
if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
  log_error "Invalid component selection: $COMPONENT_SPEC"
  exit 1
fi

# Restrict to commands only for this adapter
declare -a SUPPORTED_COMPONENTS=()
for component in "${SELECTED_COMPONENTS[@]}"; do
  if [[ "$component" == "commands" ]]; then
    SUPPORTED_COMPONENTS+=("commands")
  else
    log_warning "Component '$component' is not handled by Qwen adapter (commands-only); skipping"
  fi
done

if [[ ${#SUPPORTED_COMPONENTS[@]} -eq 0 ]]; then
  log_info "No supported components selected for Qwen adapter - nothing to do"
  exit 0
fi

COMPONENT_LABEL="$(IFS=,; printf '%s' "${SUPPORTED_COMPONENTS[@]}")"

# Get paths using manifest helpers
CLAUDE_ROOT="$CLAUDE_CONFIG_DIR"  # Claude root directory
QWEN_ROOT="$(get_target_config_dir qwen)"

# Pre-flight checks
log_info "Starting Qwen configuration $ACTION for $COMPONENT_LABEL"

if ! check_dependencies; then
  log_error "Dependency check failed"
  exit 1
fi

if ! check_target_tool "qwen"; then
  log_error "Qwen target check failed"
  exit 1
fi

if ! validate_source_config "$CLAUDE_ROOT"; then
  log_error "Source configuration validation failed"
  exit 1
fi

# Ensure target directories exist
mkdir -p "$QWEN_ROOT/commands" "$QWEN_ROOT/rules"

# Sync functions
sync_commands() {
  local source_commands
  local target_commands
  source_commands="$(get_source_path commands)"
  target_commands="$(get_target_path qwen commands)"

  if [[ ! -d "$source_commands" ]]; then
    log_warning "Source commands directory not found: $source_commands"
    return 0
  fi

  log_info "Syncing commands to Qwen (Markdown → TOML)..."

  local processed=0
  local failed=0

  # Remove excluded config-sync directory
  local excluded_dir="$target_commands/config-sync"
  if [[ -d "$excluded_dir" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "Would remove excluded module: $excluded_dir"
    else
      log_info "Removing excluded module: $excluded_dir"
      rm -rf "$excluded_dir"
    fi
  fi

  # Convert each Markdown command to TOML for Qwen
  while IFS= read -r -d '' cmd_file; do
    local rel_path="${cmd_file#$source_commands/}"

    # Skip config-sync commands (managed separately)
    if [[ "$rel_path" == config-sync/* ]]; then
      if [[ "$VERBOSE" == "true" ]]; then
        log_info "Skipping config-sync command: $rel_path"
      fi
      continue
    fi

    local target_file="$target_commands/${rel_path%.md}.toml"
    mkdir -p "$(dirname "$target_file")"

    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "Would convert: $cmd_file -> $target_file"
      ((processed += 1))
      continue
    fi

    if python3 -m config_sync.markdown_to_toml convert "$cmd_file" "$target_file" --target-tool qwen 1>/dev/null; then
      if [[ "$VERBOSE" == "true" ]]; then
        log_info "✓ Converted: $rel_path -> ${rel_path%.md}.toml"
      fi
      ((processed += 1))
    else
      log_error "✗ Failed to convert: $rel_path"
      ((failed += 1))
    fi
  done < <(find "$source_commands" -type f -name "*.md" -print0)

  # Delete stale TOML files that no longer have a source Markdown command
  if [[ "$DRY_RUN" != "true" && -d "$target_commands" ]]; then
    while IFS= read -r -d '' toml_file; do
      local rel_toml="${toml_file#$target_commands/}"
      local source_md="$source_commands/${rel_toml%.toml}.md"
      if [[ ! -f "$source_md" ]]; then
        log_info "Removing stale command TOML: $toml_file (no source for $source_md)"
        rm -f "$toml_file"
      fi
    done < <(find "$target_commands" -type f -name "*.toml" -print0)
  fi

  log_info "Commands sync: $processed converted, $failed failed"
  return $failed
}

sync_rules() {
  local source_rules
  local target_rules
  source_rules="$(get_source_path rules)"
  target_rules="$(get_target_path qwen rules)"

  if [[ ! -d "$source_rules" ]]; then
    log_warning "Source rules directory not found: $source_rules"
    return 0
  fi

  log_info "Syncing rules to Qwen..."

  local processed=0
  local failed=0

  # Use rsync if available
  if command -v rsync >/dev/null 2>&1; then
    log_info "Using rsync for rules sync"

    local rsync_args=("-av" "--delete")
    if [[ "$DRY_RUN" == "true" ]]; then
      rsync_args+=("--dry-run")
    fi

    if rsync "${rsync_args[@]}" "$source_rules/" "$target_rules/"; then
      local count
      count=$(find "$source_rules" -name "*.md" -type f | wc -l)
      processed=$count
      log_info "✓ Rules synced successfully ($count files)"
    else
      log_error "✗ Rules sync failed"
      failed=1
    fi
  else
    log_info "Using file-sync fallback for rules (rsync not available)"
    while IFS= read -r -d '' rule_file; do
      local rel_path="${rule_file#$source_rules/}"
      local target_file="$target_rules/$rel_path"

      mkdir -p "$(dirname "$target_file")"

      if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would sync: $rule_file -> $target_file"
        ((processed += 1))
      else
        if sync_with_verification "$rule_file" "$target_file"; then
          if [[ "$VERBOSE" == "true" ]]; then
            log_info "✓ Synced: $rel_path"
          fi
          ((processed += 1))
        else
          log_error "✗ Failed to sync: $rel_path"
          ((failed += 1))
        fi
      fi
    done < <(find "$source_rules" -type f -name "*.md" -print0)
  fi

  log_info "Rules sync: $processed processed, $failed failed"
  return $failed
}

# Analyze function
analyze_configuration() {
  log_info "Analyzing Qwen configuration..."

  # Use Python module for target configuration check
  if python3 -m config_sync.config_validator check-target --target qwen; then
    log_info "✓ Qwen configuration analysis completed"
  else
    log_warning "Qwen configuration has issues"
  fi
}

# Verify function - Use Python modules instead of inline Python
verify_configuration() {
  log_info "Verifying Qwen configuration..."

  local commands_dir
  local rules_dir
  commands_dir="$(get_target_path qwen commands)"
  rules_dir="$(get_target_path qwen rules)"

  # Use Python validation modules
  local issues=0

  # Verify commands using Python module
  if ! python3 -m config_sync.config_validator validate-commands --dir "$commands_dir"; then
    ((issues += 1))
  fi

  # Verify manifest structure
  if ! python3 -m config_sync.config_validator validate-manifest; then
    ((issues += 1))
  fi

  if [[ $issues -eq 0 ]]; then
    log_info "✓ Configuration verification passed"
  else
    log_error "✗ Configuration verification failed with $issues issues"
    return 1
  fi
}

# Execute action components
run_sync_components() {
  local failures=0

  for component in "${SUPPORTED_COMPONENTS[@]}"; do
    case "$component" in
      commands)
        if ! sync_commands; then
          ((failures += 1))
        fi
        ;;
      *)
        log_error "Unexpected component '$component' during sync"
        return 1
        ;;
    esac
  done

  if (( failures > 0 )); then
    return 1
  fi

  return 0
}

# Execute action
case "$ACTION" in
  sync)
    if ! run_sync_components; then
      log_error "Qwen sync encountered errors"
      exit 1
    fi
    ;;
  analyze)
    analyze_configuration
    ;;
  verify)
    verify_configuration
    ;;
esac

log_info "Qwen $ACTION for $COMPONENT_LABEL completed"
