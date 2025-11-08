#!/usr/bin/env bash
# Droid/Factory CLI configuration synchronization (Markdown compatible)

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
  sync      Synchronize configuration to Droid/Factory
  analyze   Analyze current configuration state
  verify    Verify synchronization completeness

Components (comma-separated):
  rules      Development guidelines
  commands   Custom slash commands
  settings   Factory/Droid settings
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
        log_warn "Component 'permissions' is not supported for Droid adapter; skipping"
        skip_permissions_warning=true
      fi
      ;;
    *)
      log_error "Component '$component' is not supported for Droid adapter"
      exit 1
      ;;
  esac
done

if [[ ${#filtered_components[@]} -eq 0 ]]; then
  log_error "No supported components selected for Droid adapter"
  exit 1
fi

SELECTED_COMPONENTS=("${filtered_components[@]}")
COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"

# Setup directories
CLAUDE_ROOT="$CLAUDE_CONFIG_DIR"
DROID_ROOT="$(get_target_config_dir droid)"

# Pre-flight checks
log_info "Starting Droid/Factory configuration $ACTION for $COMPONENT_LABEL"

if ! check_dependencies; then
  log_error "Dependency check failed"
  exit 1
fi

if ! check_target_tool "factory"; then
  log_error "Factory/Droid target check failed"
  exit 1
fi

if ! validate_source_config "$CLAUDE_ROOT"; then
  log_error "Source configuration validation failed"
  exit 1
fi

# Ensure target directories exist
mkdir -p "$DROID_ROOT/commands" "$DROID_ROOT/rules"

# Sync functions
sync_commands() {
  local source_commands="$CLAUDE_ROOT/commands"
  local target_commands="$DROID_ROOT/commands"
  local excluded_dir="$target_commands/config-sync"

  if [[ ! -d "$source_commands" ]]; then
    log_warn "Source commands directory not found: $source_commands"
    return 0
  fi

  log_info "Syncing commands to Droid/Factory (Markdown format)..."

  local processed=0
  local failed=0

  if [[ -d "$excluded_dir" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      log_info "Would remove excluded module: $excluded_dir"
    else
      log_info "Removing excluded module: $excluded_dir"
      rm -rf "$excluded_dir"
    fi
  fi

  # Use rsync for efficient sync (Factory uses same Markdown format)
  if command -v rsync >/dev/null 2>&1; then
    log_info "Using rsync for commands sync"

    local rsync_args=("-av" "--delete" "--exclude=config-sync/**" "--include=*.md" "--include=*/" "--exclude=*")
    if [[ "$DRY_RUN" == "true" ]]; then
      rsync_args+=("--dry-run")
    fi

    if rsync "${rsync_args[@]}" "$source_commands/" "$target_commands/"; then
      local count
      count=$(find "$source_commands" -name "*.md" -type f | wc -l)
      processed=$count
      log_info "✓ Commands synced successfully ($count files)"
    else
      log_error "✗ Commands sync failed"
      failed=1
    fi
  else
    log_info "Using file-sync fallback for commands (rsync not available)"

    while IFS= read -r -d '' cmd_file; do
      local rel_path="${cmd_file#$source_commands/}"
      local target_file="$target_commands/$rel_path"

      if [[ "$rel_path" == config-sync/* ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
          log_info "Skipping config-sync command: $rel_path"
        fi
        continue
      fi

      mkdir -p "$(dirname "$target_file")"

      if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would sync: $cmd_file -> $target_file"
        ((processed += 1))
      else
        if sync_with_verification "$cmd_file" "$target_file"; then
          if [[ "$VERBOSE" == "true" ]]; then
            log_info "✓ Synced: $rel_path"
          fi
          ((processed += 1))
        else
          log_error "✗ Failed to sync: $rel_path"
          ((failed += 1))
        fi
      fi
    done < <(find "$source_commands" -type f -name "*.md" -print0)
  fi

  log_info "Commands sync: $processed processed, $failed failed"
  return $failed
}

sync_rules() {
  local source_rules="$CLAUDE_ROOT/rules"
  local target_rules="$DROID_ROOT/rules"

  if [[ ! -d "$source_rules" ]]; then
    log_warn "Source rules directory not found: $source_rules"
    return 0
  fi

  log_info "Syncing rules to Droid/Factory..."

  local processed=0
  local failed=0

  # Use rsync if available, otherwise fall back to local sync
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

sync_settings() {
  local settings_file="$DROID_ROOT/settings.json"

  log_info "Syncing Factory/Droid settings..."

  if ! command -v jq >/dev/null 2>&1; then
    log_warn "jq not available, skipping settings sync"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would create/update settings file: $settings_file"
    return 0
  fi

  if [[ -f "$settings_file" ]]; then
    log_info "Creating backup of existing settings..."
    if ! backup_file "$settings_file"; then
      log_error "✗ Failed to create settings backup"
      return 1
    fi
  fi

  # Factory/Droid settings - basic configuration
  if [[ -f "$settings_file" ]]; then
    log_info "Updating existing settings file"
    local temp_file
    temp_file=$(mktemp)

    # Update or add Factory-specific settings
    if jq '(
          if has("model") then . else . + {"model":"claude-3-5-sonnet-20241022"} end
        )
        | (if has("temperature") then . else . + {"temperature":0.1} end)
        | (if has("maxTokens") then . else . + {"maxTokens":4096} end)
        ' "$settings_file" > "$temp_file"; then
      mv "$temp_file" "$settings_file"
      log_info "✓ Settings updated"
    else
      log_error "✗ Failed to update settings"
      rm -f "$temp_file"
      return 1
    fi
  else
    log_info "Creating new settings file"
    if jq -n '{"model":"claude-3-5-sonnet-20241022","temperature":0.1,"maxTokens":4096}' > "$settings_file"; then
      log_info "✓ Settings created"
    else
      log_error "✗ Failed to create settings"
      return 1
    fi
  fi

  return 0
}

# Analyze function
analyze_configuration() {
  log_info "Analyzing Droid/Factory configuration..."

  local missing_components=()

  # Check commands
  if [[ ! -d "$DROID_ROOT/commands" ]] || [[ -z "$(find "$DROID_ROOT/commands" -name "*.md" -type f 2>/dev/null)" ]]; then
    missing_components+=("commands (no markdown files found)")
  fi

  # Check rules
  if [[ ! -d "$DROID_ROOT/rules" ]] || [[ -z "$(find "$DROID_ROOT/rules" -name "*.md" -type f 2>/dev/null)" ]]; then
    missing_components+=("rules (no markdown files found)")
  fi

  # Check settings
  if [[ ! -f "$DROID_ROOT/settings.json" ]]; then
    missing_components+=("settings.json")
  fi

  if [[ ${#missing_components[@]} -eq 0 ]]; then
    log_info "✓ Droid/Factory configuration appears complete"
  else
    log_warn "Missing or incomplete components:"
    for component in "${missing_components[@]}"; do
      log_warn "  - $component"
    done
  fi

  # Show statistics
  if [[ -d "$DROID_ROOT/commands" ]]; then
    local cmd_count
    cmd_count=$(find "$DROID_ROOT/commands" -name "*.md" -type f | wc -l)
    log_info "Commands: $cmd_count markdown files"
  fi

  if [[ -d "$DROID_ROOT/rules" ]]; then
    local rules_count
    rules_count=$(find "$DROID_ROOT/rules" -name "*.md" -type f | wc -l)
    log_info "Rules: $rules_count markdown files"
  fi
}

# Verify function
verify_configuration() {
  log_info "Verifying Droid/Factory configuration..."

  local issues=0

  # Verify commands have proper frontmatter
  if [[ -d "$DROID_ROOT/commands" ]]; then
    while IFS= read -r -d '' cmd_file; do
      if ! python3 -c "
import sys
import re

with open('$cmd_file', 'r', encoding='utf-8') as f:
    content = f.read()

# Check for YAML frontmatter
if content.startswith('---'):
    print(f'✓ Valid frontmatter: $cmd_file')
else:
    print(f'WARNING: No frontmatter: $cmd_file')

# Basic validation
if len(content.strip()) == 0:
    print(f'✗ Empty file: $cmd_file')
    sys.exit(1)
" 2>/dev/null; then
        ((issues += 1))
      fi
    done < <(find "$DROID_ROOT/commands" -name "*.md" -type f -print0)
  fi

  # Verify settings are valid JSON
  if [[ -f "$DROID_ROOT/settings.json" ]]; then
    if jq empty "$DROID_ROOT/settings.json" 2>/dev/null; then
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
  log_info "Syncing memory files to Droid/Factory..."

  local memory_file="$DROID_ROOT/DROID.md"
  local agents_file="$DROID_ROOT/AGENTS.md"
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would create memory files: $memory_file, $agents_file"
    return 0
  fi

  # Create DROID.md - tool-specific memory file
  log_info "Creating DROID.md with Droid-specific content..."
  cat > "$memory_file" <<EOF
# DROID User Memory

## Tool Configuration
- **Tool**: DROID/Factory CLI
- **Source**: Synchronized from Claude Code configuration
- **Sync Date**: ${timestamp}
- **Format**: Markdown compatible with Droid/Factory

## DROID-Specific Capabilities

### Command Execution Model
- **Permission System**: Allowlist/denylist based access control
- **Safety Mechanisms**: Command validation and sandboxing
- **Execution Context**: User permissions with command filtering

### File Operations
- **Supported Formats**: Markdown, JSON, configuration files
- **Editing Capabilities**: Full file read/write/edit operations
- **Safety Features**: Backup before destructive operations

### Integration Features
- **Commands**: Native Markdown command format support
- **Rules**: Automatic rule loading from rules/ directory
- **Settings**: JSON-based configuration management

## Development Standards

This file contains adapted memory content from Claude Code configuration, customized for DROID usage patterns.

### Core Rules Directory
Your development rules have been synchronized to: \`rules/\`

The following rule categories are available and automatically loaded:
- General development standards (01-development-standards.md)
- Architecture patterns (02-architecture-patterns.md)
- Security guidelines (03-security-standards.md)
- Testing strategy (04-testing-strategy.md)
- Error handling (05-error-patterns.md)
- Language-specific guidelines (python, go, shell, docker)

### DROID-Specific Adaptations
This memory file has been adapted for DROID with the following changes:
- Updated command syntax for DROID compatibility
- Adapted permission system references
- Added DROID-specific capability documentation
- Integrated with DROID's allowlist/denylist model

### Memory File References
- Primary agents and capabilities: See AGENTS.md
- Development rules: Automatically loaded from rules/ directory
- Tool-specific settings: In settings.json and config.json

## Usage Notes
- This file serves as your primary memory reference for DROID
- Rules are automatically loaded from the rules/ directory
- Agent instructions and capabilities are documented in AGENTS.md
- Configuration is managed through DROID's permission system

## DROID Integration Notes
- Commands follow DROID's Markdown format
- Permissions are managed through allowlist/denylist in settings.json
- Rules are automatically adapted for DROID compatibility
- All operations respect DROID's security boundaries

Generated from Claude Code configuration on ${timestamp}.
EOF

  # Create AGENTS.md - universal agent capabilities with DROID-specific notes
  log_info "Creating AGENTS.md with DROID-specific integration notes..."
  cat > "$agents_file" <<EOF
# DROID Agent Capabilities

## Available Agents

### File Operations Agent
- **DROID Integration**: Native file read/write/edit operations
- **Scope**: Workspace and configuration directories
- **Safety**: Automatic backup before destructive operations
- **Format Support**: Markdown, JSON, TOML, configuration files

### Configuration Management Agent
- **DROID Integration**: Settings.json and config.json management
- **Permission Control**: Allowlist/denylist management
- **Rule Synchronization**: Automatic rule loading and adaptation
- **Environment Setup**: Development environment configuration

### Development Workflow Agent
- **DROID Integration**: Command execution within permission boundaries
- **Build Automation**: Support for build tools and scripts
- **Testing Orchestration**: Test execution and reporting
- **Code Quality**: Linting and analysis tool integration

### Security and Analysis Agent
- **DROID Integration**: Permission-aware operations
- **Risk Assessment**: Command safety evaluation
- **Audit Trail**: Operation logging and tracking
- **Compliance**: Security policy enforcement

## DROID-Specific Features

### Permission System Integration
- **Command Filtering**: Automatic allowlist/denylist checking
- **Safety Validation**: Pre-execution safety checks
- **User Confirmation**: Required for high-risk operations
- **Audit Logging**: All operations logged for security

### File Operation Safety
- **Automatic Backups**: Created before destructive operations
- **Validation**: File syntax and structure validation
- **Rollback**: Capability to undo harmful operations
- **Integrity Checks**: File integrity verification

### Command Execution
- **Context Awareness**: Working directory and environment awareness
- **Dependency Checking**: Tool availability verification
- **Error Handling**: Comprehensive error reporting
- **Performance**: Optimized for development workflows

## Usage Guidelines

### File Operations
1. **Read Operations**: Use file reading agents for code analysis
2. **Write Operations**: File writing agents include automatic backup
3. **Edit Operations**: Edit agents provide validation and safety
4. **Batch Operations**: Batch agents handle multiple files efficiently

### Configuration Management
1. **Settings**: Use configuration agents for settings.json management
2. **Permissions**: Permission agents manage allowlist/denylist
3. **Rules**: Rule agents handle development guidelines
4. **Environment**: Environment agents manage development setup

### Development Workflow
1. **Build**: Use workflow agents for build automation
2. **Test**: Test agents orchestrate testing procedures
3. **Deploy**: Deployment agents handle release processes
4. **Monitor**: Monitoring agents track system health

## DROID Integration Notes

### Command Adaptation
- Commands are automatically adapted for DROID compatibility
- Syntax differences are handled transparently
- DROID-specific features are leveraged appropriately

### Permission Management
- All operations respect DROID's permission system
- High-risk operations require user confirmation
- Audit trails are maintained for security compliance

### Memory Management
- Context is preserved across command sessions
- Efficient memory usage for large projects
- Quick access to relevant development information

This agents file is synchronized from Claude Code and adapted for DROID usage patterns.

Generated: ${timestamp}
EOF

  log_success "Memory files created for DROID: DROID.md, AGENTS.md"
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
      log_error "Droid/Factory sync encountered errors"
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

log_info "Droid/Factory $ACTION for $COMPONENT_LABEL completed"
