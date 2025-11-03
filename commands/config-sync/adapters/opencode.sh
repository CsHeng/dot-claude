#!/usr/bin/env bash

# Config-Sync OpenCode Adapter
# Handles OpenCode-specific configuration synchronization with markdown commands and configuration updates

set -euo pipefail

# Import common utilities
ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$ADAPTER_DIR"
EXECUTOR_SCRIPT="$ADAPTER_DIR/../scripts/executor.sh"
source "$ADAPTER_DIR/../lib/common.sh"
source "$EXECUTOR_SCRIPT"

# Default values
ACTION=""
COMPONENT_SPEC=""
DRY_RUN=false
FORCE=false
VERBOSE=false

declare -a SELECTED_COMPONENTS=()
COMPONENT_LABEL=""

# OpenCode-specific paths
OPENCODE_BASE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
OPENCODE_CONFIG_DIR="${OPENCODE_BASE_DIR}/opencode"
LEGACY_OPENCODE_DIR="${HOME}/.opencode"
OPENCODE_COMMANDS_DIR="${OPENCODE_CONFIG_DIR}/command"
OPENCODE_RULES_DIR="${OPENCODE_CONFIG_DIR}/rules"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.json"

usage() {
    cat << EOF
Config-Sync OpenCode Adapter - OpenCode Configuration Synchronization

USAGE:
    opencode.sh --action <sync|analyze|verify> --component <rules,permissions,commands,settings,memory|all> [OPTIONS]

ARGUMENTS:
    --action <operation>     Operation to perform (sync, analyze, verify)
    --component <type>       Component type or "all"

OPTIONS:
    --dry-run               Show what would be done without executing
    --force                 Force overwrite existing files
    --verbose               Enable detailed output
    --help                  Show this help message

COMPONENTS (comma-separated):
    rules                   Sync development rules and guidelines
    permissions             Sync permission configurations
    commands                Sync custom slash commands (markdown format)
    settings                Sync OpenCode configuration settings
    memory                  Sync memory and context files (AGENTS.md)
    all                     Sync all supported components

EXAMPLES:
    opencode.sh --action=sync --component=all
    opencode.sh --action=analyze --component=commands
    opencode.sh --action=verify --component=permissions

EOF
}

parse_arguments() {
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
            --force)
                FORCE=true
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
                echo "Unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$ACTION" ]]; then
        echo "Error: --action is required" >&2
        exit 1
    fi

    if [[ -z "$COMPONENT_SPEC" ]]; then
        echo "Error: --component is required" >&2
        exit 1
    fi

    # Validate action
    if [[ ! "$ACTION" =~ ^(sync|analyze|verify)$ ]]; then
        echo "Error: Invalid action '$ACTION'. Must be sync, analyze, or verify" >&2
        exit 1
    fi

    # Validate component
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

    if [[ ${#SELECTED_COMPONENTS[@]} -eq 0 ]]; then
        log_error "No components selected for OpenCode adapter"
        exit 1
    fi

    COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"
}

check_opencode_installation() {
    if ! command -v opencode &> /dev/null; then
        log_error "OpenCode CLI is not installed or not in PATH"
        log_info "Install OpenCode CLI first: https://github.com/opencode/opencode-cli"
        exit 1
    fi

    if [[ "$VERBOSE" == true ]]; then
        log_info "OpenCode CLI found: $(which opencode)"
    fi
}

migrate_legacy_opencode_dir() {
    if [[ ! -d "$LEGACY_OPENCODE_DIR" ]]; then
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        if [[ ! -d "$OPENCODE_CONFIG_DIR" ]]; then
            log_info "Would migrate legacy OpenCode configuration from $LEGACY_OPENCODE_DIR to $OPENCODE_CONFIG_DIR"
        else
            log_info "Would merge legacy OpenCode configuration from $LEGACY_OPENCODE_DIR into $OPENCODE_CONFIG_DIR"
        fi
        return
    fi

    mkdir -p "$(dirname "$OPENCODE_CONFIG_DIR")"

    if [[ -d "$OPENCODE_CONFIG_DIR" ]]; then
        log_info "Merging legacy OpenCode configuration from $LEGACY_OPENCODE_DIR into $OPENCODE_CONFIG_DIR"
        mkdir -p "$OPENCODE_CONFIG_DIR"
        rsync -a --quiet "$LEGACY_OPENCODE_DIR"/ "$OPENCODE_CONFIG_DIR"/
        rm -rf "$LEGACY_OPENCODE_DIR"
    else
        log_info "Migrating legacy OpenCode configuration from $LEGACY_OPENCODE_DIR to $OPENCODE_CONFIG_DIR"
        mv "$LEGACY_OPENCODE_DIR" "$OPENCODE_CONFIG_DIR"
    fi
}

setup_opencode_directories() {
    migrate_legacy_opencode_dir

    local dirs=("$OPENCODE_CONFIG_DIR" "$OPENCODE_COMMANDS_DIR" "$OPENCODE_RULES_DIR")

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if [[ "$DRY_RUN" == false ]]; then
                log_info "Creating directory: $dir"
                mkdir -p "$dir"
            else
                log_info "Would create directory: $dir"
            fi
        fi
    done
}

convert_markdown_to_json() {
    : # legacy no-op (retained for compatibility)
}

sync_rules() {
    log_info "Syncing rules to OpenCode..."

    local source_dir="$CLAUDE_CONFIG_DIR/rules"
    local target_dir="$OPENCODE_RULES_DIR"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source rules directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync rules from $source_dir to $target_dir"
        return 0
    fi

    mkdir -p "$target_dir"

    # Clean legacy root-level rule artifacts (keep memory files)
    find "$OPENCODE_CONFIG_DIR" -maxdepth 1 -type f -name "*.md" ! -name "OPENCODE.md" ! -name "AGENTS.md" -delete

    # Sync rules into dedicated rules directory
    find "$source_dir" -name "*.md" -type f | while read -r rule_file; do
        local basename=$(basename "$rule_file")
        local target_file="$target_dir/$basename"

        log_info "Processing rule: $basename"

        # Sync rule file with OpenCode-specific modifications
        sed '/^---$/,/^---$/d' "$rule_file" | \
        sed 's/^# \([0-9]\{2\}-.*\)/# \1/' | \
        sed '/^<!--/,/-->/d' | \
        cat > "$target_file"

        log_success "Synced rule: $basename"
    done

    log_success "Rules synchronization completed"
}

sync_permissions() {
    log_info "Syncing permissions to OpenCode via adapt-permissions..."

    local args=("--target=opencode")
    if [[ "$DRY_RUN" == true ]]; then
        args+=("--dry-run")
    fi
    if [[ "$FORCE" == true ]]; then
        args+=("--force")
    fi
    if [[ "$VERBOSE" == true ]]; then
        args+=("--verbose")
    fi

    bash "$ADAPTER_DIR/adapt-permissions.sh" "${args[@]}"
}

sync_commands() {
    log_info "Syncing commands to OpenCode..."

    local source_dir="$CLAUDE_CONFIG_DIR/commands"
    local target_dir="$OPENCODE_COMMANDS_DIR"
    local excluded_dir="$target_dir/config-sync"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source commands directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync commands from $source_dir to $target_dir"
        return 0
    fi

    if [[ -d "$OPENCODE_CONFIG_DIR/commands" && "$DRY_RUN" != true ]]; then
        log_info "Removing legacy OpenCode commands directory: $OPENCODE_CONFIG_DIR/commands"
        rm -rf "$OPENCODE_CONFIG_DIR/commands"
    fi

    mkdir -p "$target_dir"

    if [[ -d "$excluded_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_info "Would remove excluded module: $excluded_dir"
        else
            log_info "Removing excluded module: $excluded_dir"
            rm -rf "$excluded_dir"
        fi
    fi

    rsync -a --delete --exclude 'config-sync/**' --include '*/' --include '*.md' --exclude '*' "$source_dir/" "$target_dir/"

    log_success "Commands synchronization completed"
}

sync_settings() {
    log_info "OpenCode settings are managed via opencode.json; no additional sync required"
    return 0
}

sync_memory() {
    log_info "Syncing memory files to OpenCode..."

    local memory_file="$OPENCODE_CONFIG_DIR/OPENCODE.md"
    local agents_file="$OPENCODE_CONFIG_DIR/AGENTS.md"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would create memory files: $memory_file, $agents_file"
        return 0
    fi

    # Create OPENCODE.md - tool-specific memory file
    log_info "Creating OPENCODE.md with OpenCode-specific content..."
    cat > "$memory_file" <<'EOF'
# OPENCODE User Memory

## Tool Configuration
- **Tool**: OpenCode CLI
- **Source**: Synchronized from Claude Code configuration
- **Sync Date**: ${timestamp}
- **Format**: Markdown commands, Markdown rules, operation-based permissions

## OPENCODE-Specific Capabilities

### Operation-Based Permission System
- **Edit Operations**: File modification with full editing capabilities
- **Bash Operations**: Command execution with configurable restrictions
- **WebFetch Operations**: Web content retrieval with domain filtering
- **Read Operations**: File access across workspace and configuration

### Command Format
- **Markdown Commands**: YAML frontmatter with metadata and markdown templates
- **External References**: Lazy loading for large documentation
- **Instruction Arrays**: Complex operation support with reusable prompts
- **Parameter Guidance**: Describe expected arguments within command templates

### Integration Features
- **Commands**: Markdown command files with frontmatter metadata
- **Rules**: Markdown rule files with automatic loading
- **Settings**: JSON-based configuration with operation permissions
- **Memory**: AGENTS.md as primary reference + OPENCODE.md

## Development Standards

This file contains adapted memory content from Claude Code configuration, customized for OPENCODE usage patterns.

### Core Rules Directory
Your development rules have been synchronized to: `rules/`

The following rule categories are available and automatically loaded:
- General development standards (01-general-development.md)
- Architecture patterns (02-architecture-patterns.md)
- Security guidelines (03-security-guidelines.md)
- Testing strategy (04-testing-strategy.md)
- Error handling (05-error-handling.md)
- Language-specific guidelines (python, go, shell, docker)

### OPENCODE-Specific Adaptations
This memory file has been adapted for OPENCODE with the following changes:
- Updated content for operation-based permission model
- Adapted to OpenCode markdown command format
- Added OpenCode-specific capability documentation
- Integrated with external reference system

### Memory File References
- Primary agents and capabilities: See AGENTS.md
- Development rules: Automatically loaded from rules/ directory
- Tool-specific settings: In opencode.json
- Command definitions: In command/ directory (markdown format)

## Usage Notes
- This file serves as your primary memory reference for OPENCODE
- Rules are automatically loaded from the rules/ directory
- Agent instructions and capabilities are documented in AGENTS.md
- Commands are defined in markdown format with frontmatter metadata
- Operations are controlled through permission-based system

## OPENCODE Integration Notes
- Commands follow OpenCode's markdown format with YAML frontmatter metadata
- Permissions are managed through operation-based categories
- Rules are automatically adapted for OPENCODE compatibility
- External references provide efficient documentation loading
- All operations respect permission boundaries and safety measures

## Permission Categories
- **edit**: File modification operations (create, update, delete)
- **bash**: Command execution operations (with restrictions)
- **webfetch**: Web content retrieval (domain filtered)
- **read**: File reading operations (workspace and config)

Generated from Claude Code configuration on ${timestamp}.
EOF

    # Create AGENTS.md - universal agent capabilities with OpenCode-specific notes
    log_info "Creating AGENTS.md with OpenCode-specific integration notes..."
    cat > "$agents_file" <<'EOF'
# OpenCode Agent Configuration

## Agent Capabilities

### Core Operations
- **edit**: Modify files in the workspace with full editing capabilities
- **bash**: Execute commands with configurable restrictions and safety measures
- **webfetch**: Retrieve web content with domain filtering and security controls
- **read**: Access files across workspace and configuration directories

### Permission System
OpenCode uses an operation-based permission system with the following categories:

#### Edit Operations
- **Scope**: Workspace files and project directories
- **Capabilities**: Create, modify, delete files
- **Restrictions**: System files outside workspace

#### Bash Operations
- **Scope**: Read-only system commands by default
- **Capabilities**: Execute development tools, git commands, build processes
- **Restrictions**: Destructive system commands require explicit permission

#### WebFetch Operations
- **Scope**: Pre-approved domains and development resources
- **Capabilities**: Retrieve documentation, API references, code examples
- **Restrictions**: Authenticated sites and sensitive resources blocked

#### Read Operations
- **Scope**: All workspace files and configuration directories
- **Capabilities**: Access project files, settings, documentation
- **Restrictions**: System-critical files outside project context

## External References

### Configuration Files
- **opencode.json**: Main configuration with permissions and settings
- **command/**: Markdown command definitions with metadata
- **rules/*.md**: Development guidelines and coding standards

### Development Standards
- File naming conventions follow the original Claude Code structure
- Markdown commands include external references to source documentation
- Permission configuration uses operation-based categories

## Agent Instructions

### Primary Directives
1. **Maintain Context**: Use AGENTS.md as the primary reference for agent capabilities
2. **Follow Permissions**: Respect operation-based permission boundaries
3. **Use External References**: Leverage linked files for detailed information
4. **Provide Safety**: Apply safety checks for destructive operations

### Development Workflow
1. **Load Configuration**: Start with opencode.json for current permissions
2. **Access Commands**: Use markdown command definitions from command/ directory
3. **Apply Rules**: Follow development guidelines from rules/ files
4. **Update Memory**: Maintain AGENTS.md as the central reference point

## Integration Notes

### Claude Code Compatibility
This configuration is synchronized from Claude Code with the following adaptations:
- Commands synchronized as Markdown with YAML frontmatter metadata
- Permissions adapted to operation-based categories
- Rules maintained as Markdown files under rules/
- AGENTS.md serves as the primary memory reference

### Performance Optimization
- External references use lazy loading for large documentation
- Markdown commands include metadata for categorization and search
- Permission settings are optimized for operation-based checks

Generated from Claude Code configuration on ${timestamp}.
EOF

    log_success "Memory files created for OpenCode: OPENCODE.md, AGENTS.md"
}

analyze_opencode() {
    log_info "Analyzing OpenCode configuration..."

    echo "=== OpenCode Analysis ==="
    echo

    # Check installation
    if command -v opencode &> /dev/null; then
        echo "✅ OpenCode CLI: $(which opencode)"
        opencode --version 2>/dev/null || echo "Version information not available"
    else
        echo "❌ OpenCode CLI: Not installed"
    fi

    echo
    echo "=== Configuration Files ==="

    # Check config directory
    if [[ -d "$OPENCODE_CONFIG_DIR" ]]; then
        echo "✅ Config directory: $OPENCODE_CONFIG_DIR"

        # Check main config file
        if [[ -f "$OPENCODE_CONFIG_FILE" ]]; then
            echo "✅ Main config: $OPENCODE_CONFIG_FILE"

            if command -v jq &>  /dev/null; then
                local model=$(jq -r '.model // "default"' "$OPENCODE_CONFIG_FILE" 2>/dev/null)
                local theme=$(jq -r '.theme // "default"' "$OPENCODE_CONFIG_FILE" 2>/dev/null)
                echo "  Model: $model"
                echo "  Theme: $theme"
            fi
        else
            echo "❌ Main config: Missing"
        fi

        # Check AGENTS.md
        if [[ -f "$OPENCODE_CONFIG_DIR/AGENTS.md" ]]; then
            echo "✅ AGENTS.md: Exists ($(stat -f%z "$OPENCODE_CONFIG_DIR/AGENTS.md" 2>/dev/null || echo "unknown") bytes)"
        else
            echo "❌ AGENTS.md: Missing"
        fi

        # Check rules
        if [[ -d "$OPENCODE_RULES_DIR" ]]; then
            local rule_count=$(find "$OPENCODE_RULES_DIR" -type f -name "*.md" 2>/dev/null | wc -l)
            if [[ $rule_count -gt 0 ]]; then
                echo "✅ Rules: $rule_count files"
            else
                echo "❌ Rules: No files found"
            fi
        else
            echo "❌ Rules: Directory missing ($OPENCODE_RULES_DIR)"
        fi

        # Check commands
        if [[ -d "$OPENCODE_COMMANDS_DIR" ]]; then
            local cmd_count=$(find "$OPENCODE_COMMANDS_DIR" -name "*.md" -type f | wc -l)
            echo "✅ Commands: $cmd_count markdown files"
        else
            echo "❌ Commands directory: Missing"
        fi
    else
        echo "❌ Config directory: Not found"
    fi

    echo
    echo "=== Recommendations ==="

    if [[ ! -f "$OPENCODE_CONFIG_FILE" ]]; then
        echo "→ Run: opencode.sh --action=sync --component=settings"
    fi

    if [[ ! -f "$OPENCODE_CONFIG_DIR/AGENTS.md" ]]; then
        echo "→ Run: opencode.sh --action=sync --component=memory"
    fi

    if [[ ! -d "$OPENCODE_COMMANDS_DIR" ]] || [[ -z "$(find "$OPENCODE_COMMANDS_DIR" -name "*.md" -type f)" ]]; then
        echo "→ Run: opencode.sh --action=sync --component=commands"
    fi

    if [[ -d "$OPENCODE_RULES_DIR" ]] && [[ -z "$(find "$OPENCODE_RULES_DIR" -type f -name "*.md")" ]]; then
        echo "→ Run: opencode.sh --action=sync --component=rules"
    fi
}

verify_opencode() {
    log_info "Verifying OpenCode configuration..."

    local errors=0
    local warnings=0

    echo "=== OpenCode Configuration Verification ==="
    echo

    # Verify installation
    if ! command -v opencode &> /dev/null; then
        echo "❌ OpenCode CLI is not installed"
        ((errors += 1))
        return $errors
    else
        echo "✅ OpenCode CLI is installed"
    fi

    # Verify config directory
    if [[ ! -d "$OPENCODE_CONFIG_DIR" ]]; then
        echo "❌ Config directory missing: $OPENCODE_CONFIG_DIR"
        ((errors += 1))
    else
        echo "✅ Config directory exists"
    fi

    # Verify main configuration file
    if [[ ! -f "$OPENCODE_CONFIG_FILE" ]]; then
        echo "❌ Main configuration file missing: $OPENCODE_CONFIG_FILE"
        ((errors += 1))
    else
        echo "✅ Main configuration file exists"

        # Validate JSON syntax
        if command -v jq &> /dev/null; then
            if jq empty "$OPENCODE_CONFIG_FILE" 2>/dev/null; then
                echo "✅ Configuration file has valid JSON syntax"
            else
                echo "❌ Configuration file has invalid JSON syntax"
                ((errors += 1))
            fi
        else
            echo "⚠️  jq not available - cannot validate JSON syntax"
            ((warnings += 1))
        fi
    fi

    # Verify AGENTS.md (primary memory reference)
    if [[ ! -f "$OPENCODE_CONFIG_DIR/AGENTS.md" ]]; then
        echo "❌ AGENTS.md missing (primary memory reference)"
        ((errors += 1))
    else
        echo "✅ AGENTS.md exists"
    fi

    # Verify rules directory and files
    if [[ ! -d "$OPENCODE_RULES_DIR" ]]; then
        echo "⚠️  Rules directory missing: $OPENCODE_RULES_DIR"
        ((warnings += 1))
    else
        local rule_count
        rule_count=$(find "$OPENCODE_RULES_DIR" -type f -name "*.md" 2>/dev/null | wc -l)
        if [[ $rule_count -eq 0 ]]; then
            echo "⚠️  No rules files found in $OPENCODE_RULES_DIR"
            ((warnings += 1))
        else
            echo "✅ Rules directory: $rule_count files"
        fi
    fi

    # Verify commands directory
    if [[ ! -d "$OPENCODE_COMMANDS_DIR" ]]; then
        echo "⚠️  Commands directory missing"
        ((warnings += 1))
    else
        local cmd_count=$(find "$OPENCODE_COMMANDS_DIR" -name "*.md" -type f | wc -l)
        if [[ $cmd_count -eq 0 ]]; then
            echo "⚠️  No markdown command files found"
            ((warnings += 1))
        else
            echo "✅ Commands directory: $cmd_count markdown files"
        fi
    fi

    echo
    if [[ $errors -gt 0 ]]; then
        echo "❌ Verification failed with $errors error(s)"
        echo "Run: opencode.sh --action=sync --component=all"
    elif [[ $warnings -gt 0 ]]; then
        echo "⚠️  Verification completed with $warnings warning(s)"
    else
        echo "✅ Verification completed successfully"
    fi

    return $errors
}

run_sync_components() {
    local failures=0

    for component in "${SELECTED_COMPONENTS[@]}"; do
        case "$component" in
            rules)
                if ! sync_rules; then
                    ((failures += 1))
                fi
                ;;
            permissions)
                if ! sync_permissions; then
                    ((failures += 1))
                fi
                ;;
            commands)
                if ! sync_commands; then
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

perform_action() {
    case "$ACTION" in
        sync)
            setup_opencode_directories
            if ! run_sync_components; then
                log_error "OpenCode sync encountered errors"
                exit 1
            fi
            ;;
        analyze)
            analyze_opencode
            ;;
        verify)
            verify_opencode
            ;;
        *)
            log_error "Unknown action: $ACTION"
            exit 1
            ;;
    esac
}

main() {
    parse_arguments "$@"

    # Validate environment
    validate_target "opencode"
    for component in "${SELECTED_COMPONENTS[@]}"; do
        validate_component "$component"
    done

    # Check installation for sync operations
    if [[ "$ACTION" == "sync" ]]; then
        check_opencode_installation
    fi

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting OpenCode $ACTION for component(s): $COMPONENT_LABEL"

    # Perform the requested action
    perform_action

    log_success "OpenCode $ACTION completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
