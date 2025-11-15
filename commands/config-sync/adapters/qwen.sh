#!/usr/bin/env bash
# Qwen CLI configuration synchronization with TOML conversion

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
ACTION="sync"
COMPONENT_SPEC="all"
DRY_RUN=false
VERBOSE=false

declare -a SELECTED_COMPONENTS=()
COMPONENT_LABEL=""

usage() {
  cat << EOF
Usage: $0 --action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all> [options]

Actions:
  sync      Synchronize configuration to Qwen
  analyze   Analyze current configuration state
  verify    Verify synchronization completeness

Components (comma-separated):
  rules      Development guidelines
  commands   Custom slash commands
  settings   Qwen settings and preferences
  memory     Memory and context files
  all        All supported components (default)

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
    --component=*)
      COMPONENT_SPEC="${1#--component=}"
      shift
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
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Validate arguments
case "$ACTION" in
  sync|analyze|verify) ;;
  *)
    echo "[ERROR] Invalid action: $ACTION" >&2
    usage
    exit 1
    ;;
esac

if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
  log_error "Invalid component selection: $COMPONENT_SPEC"
  exit 1
fi

join_by() {
  local sep="$1"
  shift
  local out=""
  for item in "$@"; do
    if [[ -z "$out" ]]; then
      out="$item"
    else
      out+="$sep$item"
    fi
  done
  printf '%s' "$out"
}

filtered_components=()
skip_permissions_warning=false
for component in "${SELECTED_COMPONENTS[@]}"; do
  case "$component" in
    commands|rules|settings|memory)
      filtered_components+=("$component")
      ;;
    permissions)
      if [[ "$skip_permissions_warning" == false ]]; then
        log_warn "Component 'permissions' is not supported for Qwen adapter; skipping"
        skip_permissions_warning=true
      fi
      ;;
    *)
      log_error "Component '$component' is not supported for Qwen adapter"
      exit 1
      ;;
  esac
done

if [[ ${#filtered_components[@]} -eq 0 ]]; then
  log_error "No supported components selected for Qwen adapter"
  exit 1
fi

SELECTED_COMPONENTS=("${filtered_components[@]}")
COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"

# Setup directories
CLAUDE_ROOT="$CLAUDE_CONFIG_DIR"
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
  local source_commands="$CLAUDE_ROOT/commands"
  local target_commands="$QWEN_ROOT/commands"

  if [[ ! -d "$source_commands" ]]; then
    log_warn "Source commands directory not found: $source_commands"
    return 0
  fi

  log_info "Syncing commands to Qwen TOML format (excluding config-sync)..."

  if [[ "$DRY_RUN" == "true" ]]; then
    local count
    count=$(find "$source_commands" -type f -name "*.md" ! -path "$source_commands/config-sync/*" | wc -l | tr -d ' ')
    log_info "Would stage full command tree (except config-sync) and convert $count markdown files to TOML."
    return 0
  fi

  local staging_dir
  staging_dir="$(mktemp -d)"

  # Copy supporting assets excluding config-sync and markdown definitions
  if command -v rsync >/dev/null 2>&1; then
    if rsync -a --exclude 'config-sync/**' --exclude '*.md' "$source_commands/" "$staging_dir/"; then
      log_info "Staged non-Markdown assets for Qwen commands"
    else
      log_error "Failed to stage supporting assets for commands"
      rm -rf "$staging_dir"
      return 1
    fi
  else
    log_warn "rsync unavailable; using cp fallback for supporting assets"
    if ! cp -R "$source_commands/" "$staging_dir/"; then
      log_error "Failed to copy supporting assets for commands"
      rm -rf "$staging_dir"
      return 1
    fi
    # Remove config-sync and markdown files from staging
    rm -rf "$staging_dir/config-sync"
    find "$staging_dir" -type f -name "*.md" -delete
  fi

  local processed=0
  local failed=0

  while IFS= read -r -d '' cmd_file; do
    local rel_path="${cmd_file#$source_commands/}"
    if [[ "$rel_path" == config-sync/* ]]; then
      continue
    fi
    local rel_path_no_ext="${rel_path%.md}"
    local toml_file="$staging_dir/${rel_path_no_ext}.toml"
    mkdir -p "$(dirname "$toml_file")"

    if convert_markdown_to_toml "$cmd_file" "$toml_file" "qwen"; then
      if [[ "$VERBOSE" == "true" ]]; then
        log_info "✓ Converted: ${rel_path_no_ext}"
      fi
      ((processed += 1))
    else
      log_error "✗ Failed to convert: ${rel_path_no_ext}"
      ((failed += 1))
    fi
  done < <(find "$source_commands" -type f -name "*.md" -print0)

  if [[ $failed -ne 0 ]]; then
    log_error "Command conversion failed for $failed file(s)"
    rm -rf "$staging_dir"
    return 1
  fi

  if rsync -a --delete "$staging_dir/" "$target_commands/"; then
    log_info "✓ Commands synchronized to Qwen (staged tree applied)"
  else
    log_error "Failed to apply staged commands to Qwen directory"
    rm -rf "$staging_dir"
    return 1
  fi

  rm -rf "$staging_dir"

  log_info "Commands sync: $processed processed, $failed failed"
  return $failed
}

sync_rules() {
  local source_rules="$CLAUDE_ROOT/rules"
  local target_rules="$QWEN_ROOT/rules"

  if [[ ! -d "$source_rules" ]]; then
    log_warn "Source rules directory not found: $source_rules"
    return 0
  fi

  log_info "Syncing rules to Qwen..."

  local processed=0
  local failed=0

  # Use rsync if available, otherwise fall back to local sync
  if command -v rsync >/dev/null 2>&1; then
    log_info "Using rsync for rules sync"
    if [[ "$DRY_RUN" == "true" ]]; then
      rsync --dry-run -av --delete "$source_rules/" "$target_rules/"
    else
      if rsync -av --delete "$source_rules/" "$target_rules/"; then
        log_info "✓ Rules synced successfully"
        processed=$(find "$source_rules" -name "*.md" | wc -l)
      else
        log_error "✗ Rules sync failed"
        failed=1
      fi
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

sync_settings() {
  log_info "Qwen settings are user-managed; skipping settings sync"
  return 0
}

# Analyze function
analyze_configuration() {
  log_info "Analyzing Qwen configuration..."

  local missing_components=()

  # Check commands
  if [[ ! -d "$QWEN_ROOT/commands" ]] || [[ -z "$(find "$QWEN_ROOT/commands" -name "*.toml" -type f 2>/dev/null)" ]]; then
    missing_components+=("commands (no TOML files found)")
  fi

  # Check rules
  if [[ ! -d "$QWEN_ROOT/rules" ]] || [[ -z "$(find "$QWEN_ROOT/rules" -name "*.md" -type f 2>/dev/null)" ]]; then
    missing_components+=("rules (no markdown files found)")
  fi

  # Check settings
  if [[ ! -f "$QWEN_ROOT/settings.json" ]]; then
    missing_components+=("settings.json")
  fi

  if [[ ${#missing_components[@]} -eq 0 ]]; then
    log_info "✓ Qwen configuration appears complete"
  else
    log_warn "Missing or incomplete components:"
    for component in "${missing_components[@]}"; do
      log_warn "  - $component"
    done
  fi

  # Show statistics
  if [[ -d "$QWEN_ROOT/commands" ]]; then
    local toml_count
    toml_count=$(find "$QWEN_ROOT/commands" -name "*.toml" -type f | wc -l)
    log_info "Commands: $toml_count TOML files"
  fi

  if [[ -d "$QWEN_ROOT/rules" ]]; then
    local rules_count
    rules_count=$(find "$QWEN_ROOT/rules" -name "*.md" -type f | wc -l)
    log_info "Rules: $rules_count markdown files"
  fi
}

# Verify function
verify_configuration() {
  log_info "Verifying Qwen configuration..."

  local issues=0

  # Verify commands can be parsed
  if [[ -d "$QWEN_ROOT/commands" ]]; then
    while IFS= read -r -d '' toml_file; do
      if ! python3 -c "
import sys
try:
    import toml
    with open('$toml_file', 'r') as f:
        toml.load(f)
    print(f'✓ Valid TOML: $toml_file')
except ImportError:
    print(f'WARNING: Cannot verify TOML (toml module not installed): $toml_file')
except Exception as e:
    print(f'✗ Invalid TOML: $toml_file - {e}')
    sys.exit(1)
" 2>/dev/null; then
        ((issues += 1))
      fi
    done < <(find "$QWEN_ROOT/commands" -name "*.toml" -type f -print0)
  fi

  # Verify settings are valid JSON
  if [[ -f "$QWEN_ROOT/settings.json" ]]; then
    if jq empty "$QWEN_ROOT/settings.json" 2>/dev/null; then
      log_info "✓ Valid settings.json"
    else
      log_error "✗ Invalid settings.json"
      ((issues += 1))
    fi
  fi

  if [[ $issues -eq 0 ]]; then
    log_info "✓ Configuration verification passed"
  else
    log_error "✗ Configuration verification failed with $issues issues"
    return 1
  fi
}

sync_memory() {
  log_info "Syncing memory files to Qwen..."

  local memory_file="$QWEN_ROOT/QWEN.md"
  local agents_file="$QWEN_ROOT/AGENTS.md"
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would copy CLAUDE.md to $memory_file and regenerate $agents_file"
    return 0
  fi

  sync_claude_memory_file "$memory_file" "$FORCE"

  # Create AGENTS.md - universal agent capabilities with Qwen-specific notes
  log_info "Creating AGENTS.md with Qwen-specific integration notes..."
  cat > "$agents_file" <<EOF
# QWEN Agent Capabilities

## Available Agents

### File Operations Agent
- QWEN Integration: Native file read/write/edit operations
- Scope: User file system permissions
- Safety: User confirmation for destructive operations
- Format Support: TOML, Markdown, JSON, configuration files

### Configuration Management Agent
- QWEN Integration: Settings.json and TOML command management
- Permission Control: User confirmation-based permission system
- Rule Synchronization: Automatic rule loading and adaptation
- Environment Setup: Development environment configuration

### Development Workflow Agent
- QWEN Integration: Command execution with user confirmation
- Build Automation: Support for build tools and scripts
- Testing Orchestration: Test execution and reporting
- Code Quality: Linting and analysis tool integration

### Command Processing Agent
- QWEN Integration: TOML command definition processing
- Prompt Engineering: Trusted prompt system management
- Context Management: Project-specific context preservation
- Command Adaptation: Markdown to TOML conversion

## QWEN-Specific Features

### Permission System Integration
- User Confirmation: Required for shell execution
- File System Access: Same permissions as user account
- Safety Validation: Pre-execution user prompts
- Trust Management: Project-based trusted prompts

### Command Format Handling
- TOML Definitions: Native TOML command format support
- Markdown Conversion: Automatic conversion from Claude format
- Prompt Structure: Structured prompt definitions
- Parameter Validation: Command parameter validation

### Context Management
- Project Context: Automatic project context detection
- Memory Preservation: Context preservation across sessions
- Trusted Prompts: Project-specific prompt trust system
- Session Management: Multi-session context handling

## Usage Guidelines

### File Operations
1. Read Operations: Use file reading agents for code analysis
2. Write Operations: File writing with user confirmation
3. Edit Operations: Edit agents provide validation and safety
4. Batch Operations: Batch agents handle multiple files efficiently

### Command Management
1. TOML Commands: Use command agents for TOML definition management
2. Prompt Engineering: Prompt agents handle trusted prompt system
3. Context Management: Context agents manage project-specific context
4. Format Conversion: Conversion agents handle format adaptations

### Development Workflow
1. Build: Use workflow agents for build automation
2. Test: Test agents orchestrate testing procedures
3. Deploy: Deployment agents handle release processes
4. Monitor: Monitoring agents track system health

## QWEN Integration Notes

### Command Adaptation
- Commands are automatically converted to TOML format
- Markdown syntax is adapted for QWEN compatibility
- QWEN-specific features are leveraged appropriately

### Permission Management
- All operations respect user file system permissions
- Shell execution requires explicit user confirmation
- Trusted prompts provide project-specific context

### Memory Management
- Context is preserved through trusted prompts system
- Project-specific context is automatically detected
- Efficient memory usage for large projects

This agents file is synchronized from Claude Code and adapted for QWEN usage patterns.

Generated: ${timestamp}
EOF

  log_success "Memory files created for QWEN: QWEN.md, AGENTS.md"
}

run_sync_components() {
  local failures=0

  for component in "${SELECTED_COMPONENTS[@]}"; do
    case "$component" in
      commands)
        if ! sync_commands; then
          ((failures += 1))
        fi
        ;;
      rules)
        if ! sync_rules; then
          ((failures += 1))
        fi
        ;;
      settings)
        if ! sync_settings; then
          ((failures += 1))
        fi
        ;;
      memory)
        if ! sync_memory; then
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
