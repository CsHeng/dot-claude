#!/usr/bin/env bash

# Config-Sync Codex Adapter
# Handles OpenAI Codex CLI-specific configuration synchronization

set -euo pipefail

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Default values
ACTION=""
COMPONENT_SPEC=""
DRY_RUN=false
FORCE=false
VERBOSE=false

declare -a SELECTED_COMPONENTS=()
COMPONENT_LABEL=""

# Codex-specific paths
CODEX_CONFIG_DIR="${HOME}/.codex"
CODEX_COMMANDS_DIR="${CODEX_CONFIG_DIR}/commands"
CODEX_SETTINGS_FILE="${CODEX_CONFIG_DIR}/config.toml"

usage() {
    cat << EOF
Config-Sync Codex Adapter - OpenAI Codex CLI Configuration Synchronization

USAGE:
    codex.sh --action <sync|analyze|verify> --component <rules,permissions,commands,settings,memory|all> [OPTIONS]

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
    commands                Sync custom slash commands
    settings                Sync Codex configuration settings
    memory                  Sync memory and context files
    all                     Sync all supported components

EXAMPLES:
    codex.sh --action=sync --component=all
    codex.sh --action=analyze --component=rules
    codex.sh --action=verify --component=settings

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
        log_error "No components selected for Codex adapter"
        exit 1
    fi

    COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"
}

check_codex_installation() {
    if ! command -v codex &> /dev/null; then
        log_error "OpenAI Codex CLI is not installed or not in PATH"
        log_info "Install Codex CLI first: https://github.com/openai/codex-cli"
        exit 1
    fi

    if [[ "$VERBOSE" == true ]]; then
        log_info "Codex CLI found: $(which codex)"
    fi
}

setup_codex_directories() {
    local dirs=("$CODEX_CONFIG_DIR" "$CODEX_COMMANDS_DIR")

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

sync_rules() {
    log_info "Syncing rules to Codex..."

    local source_dir="$CLAUDE_CONFIG_DIR/rules"
    local target_dir="$CODEX_CONFIG_DIR/rules"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source rules directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync rules from $source_dir to $target_dir"
        return 0
    fi

    # Create target directory
    mkdir -p "$target_dir"

    # Sync and simplify rules for Codex
    find "$source_dir" -name "*.md" -type f | while read -r rule_file; do
        local basename=$(basename "$rule_file")
        local target_file="$target_dir/$basename"

        log_info "Processing rule: $basename"

        # Convert to simple markdown (remove complex frontmatter)
        sed '/^---$/,/^---$/d' "$rule_file" | \
        sed 's/^# \([0-9]\{2\}-.*\)/# \1/' | \
        sed '/^<!--/,/-->/d' > "$target_file"

        log_success "Converted rule: $basename"
    done

    log_success "Rules synchronization completed"
}

sync_permissions() {
    log_info "Syncing permissions to Codex..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would create Codex permissions configuration"
        return 0
    fi

    local target_file="$CODEX_CONFIG_DIR/permissions.toml"

    # Create simplified permissions for Codex
    cat > "$target_file" << 'EOF'
# Codex CLI Permissions Configuration
# Simplified permission system for OpenAI Codex

[permissions]
# Default permission level for operations
default = "workspace-write"

# Sandbox access levels
[sandbox]
read_only = false
workspace_write = true
full_access = false

# Allowed operations
[operations]
file_read = true
file_write = true
file_delete = false
command_execute = false
network_access = false

# Tool restrictions
[tools]
allow_git = true
allow_file_operations = true
allow_system_commands = false
allow_network_access = false
EOF

    log_success "Permissions configuration created: $target_file"
}

sync_commands() {
    log_info "Syncing commands to Codex..."

    local source_dir="$CLAUDE_CONFIG_DIR/commands"
    local target_dir="$CODEX_COMMANDS_DIR"
    local excluded_dir="$target_dir/config-sync"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source commands directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync commands from $source_dir to $target_dir"
        return 0
    fi

    # Create target directory
    mkdir -p "$target_dir"

    if [[ -d "$excluded_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_info "Would remove excluded module: $excluded_dir"
        else
            log_info "Removing excluded module: $excluded_dir"
            rm -rf "$excluded_dir"
        fi
    fi

    # Sync and simplify commands for Codex
    find "$source_dir" -name "*.md" -type f | while read -r cmd_file; do
        local rel_path="${cmd_file#$source_dir/}"
        if [[ "$rel_path" == config-sync/* ]]; then
            if [[ "$VERBOSE" == true ]]; then
                log_info "Skipping config-sync command: $rel_path"
            fi
            continue
        fi
        local basename=$(basename "$cmd_file" .md)
        local target_file="$target_dir/$basename.md"

        log_info "Processing command: $basename"

        # Convert to simple markdown without frontmatter
        sed '/^---$/,/^---$/d' "$cmd_file" | \
        sed 's/^# /## /' | \
        sed '/^<!--/,/-->/d' > "$target_file"

        log_success "Converted command: $basename"
    done

    log_success "Commands synchronization completed"
}

sync_settings() {
    log_info "Syncing settings to Codex..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would create or update Codex settings configuration"
        return 0
    fi

    local target_file="$CODEX_SETTINGS_FILE"
    mkdir -p "$CODEX_CONFIG_DIR"

    if [[ -f "$target_file" && "$FORCE" != true ]]; then
        log_info "Codex settings already exist; preserving sandbox configuration (use --force to regenerate)"
        return 0
    fi

    # Note: Backup handled by unified prepare phase
    # No need for individual file backup

    # Create minimal Codex configuration
    cat > "$target_file" << EOF
# Codex CLI Configuration
# Minimal configuration for OpenAI Codex

[core]
# API configuration (requires user to set API key)
api_key = ""  # Set your OpenAI API key here
model = "code-davinci-002"
temperature = 0.1
max_tokens = 1000

[editor]
# Editor preferences
tab_size = 4
use_tabs = false
line_wrap = true

[generation]
# Code generation preferences
language = "auto"
style = "consistent"
include_comments = true

[sandbox]
# Sandbox security settings
mode = "workspace-write"
allow_network = true
allow_execution = true
enabled = true
timeout = 30
memory_limit = "512MB"

[sync]
source = "claude-code-sync"
last_sync = "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
EOF

    log_warning "WARNING:  IMPORTANT: Edit $target_file to set your OpenAI API key"
    log_success "Settings configuration created: $target_file"
}

sync_memory() {
    log_info "Syncing memory files to Codex..."

    local memory_file="$CODEX_CONFIG_DIR/CODEX.md"
    local agents_file="$CODEX_CONFIG_DIR/AGENTS.md"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would copy CLAUDE.md to $memory_file and regenerate $agents_file"
        return 0
    fi

    sync_claude_memory_file "$memory_file" "$FORCE"

    # Create AGENTS.md - universal agent capabilities with Codex-specific notes
    log_info "Creating AGENTS.md with Codex-specific integration notes..."
    cat > "$agents_file" <<EOF
# CODEX Agent Capabilities

## Available Agents

### Code Generation Agent
- CODEX Integration: OpenAI Codex API for code generation
- Scope: Multiple programming languages and frameworks
- Safety: Sandbox environment for secure generation
- Format Support: Source code, documentation, configuration files

### File Operations Agent
- CODEX Integration: File read/write within sandbox boundaries
- Scope: Workspace directory with configurable permissions
- Safety: Read-only default, workspace-write on request
- Format Support: Source code, markdown, JSON, TOML, configuration

### Configuration Management Agent
- CODEX Integration: TOML configuration file management
- Permission Control: Sandbox level configuration
- Rule Synchronization: Automatic rule loading and adaptation
- Environment Setup: Development environment configuration

### API Management Agent
- CODEX Integration: OpenAI API key and configuration management
- Rate Limiting: API rate limit awareness and handling
- Model Selection: Optimal model configuration for tasks
- Error Handling: API error recovery and retry logic

## CODEX-Specific Features

### Sandbox Security Integration
- Isolation: Code generation in isolated sandbox environment
- File System: Limited to workspace with configurable permissions
- Network Access: Controlled network access for external resources
- Execution Prevention: No direct code execution capabilities

### API Optimization
- Model Selection: Automatic model selection based on task type
- Token Management: Optimal token usage for cost efficiency
- Rate Limiting: Automatic rate limit handling and queuing
- Error Recovery: Robust error handling and retry mechanisms

### Code Generation Quality
- Consistency: Low temperature for consistent, reliable output
- Best Practices: Generated code follows industry best practices
- Context Awareness: Maintains context across generation sessions
- Language Support: Multi-language code generation capabilities

## Usage Guidelines

### Code Generation
1. Specific Prompts: Use specific, detailed prompts for best results
2. Context Provision: Provide relevant context for accurate generation
3. Language Specification: Clearly specify target programming language
4. Style Guidelines: Provide style preferences for consistent output

### File Operations
1. Workspace Management: Use file agents for workspace organization
2. Configuration: Configuration agents handle TOML file management
3. Backup: Automatic backup before destructive operations
4. Validation: File syntax and structure validation

### API Management
1. Key Security: Ensure API key is properly secured
2. Rate Monitoring: Monitor API usage and rate limits
3. Cost Optimization: Optimize token usage for cost efficiency
4. Error Handling: Implement robust error handling procedures

### Development Workflow
1. Code Generation: Use generation agents for code creation
2. Review Process: Review generated code for quality and accuracy
3. Integration: Integrate generated code into existing codebase
4. Testing: Test generated code for functionality and performance

## CODEX Integration Notes

### API Integration
- All code generation requests go through OpenAI Codex API
- API rate limits are automatically respected and managed
- Error handling includes retry logic for transient failures

### Sandbox Management
- Code generation occurs in secure sandbox environment
- File operations are limited to configured workspace boundaries
- Network access is controlled and monitored

### Quality Assurance
- Generated code is validated for syntax and structure
- Best practices are enforced through rule-based checking
- Context is maintained across multiple generation requests

This agents file is synchronized from Claude Code and adapted for CODEX usage patterns.

Generated: ${timestamp}
EOF

    log_success "Memory files created for CODEX: CODEX.md, AGENTS.md"
}

analyze_codex() {
    log_info "Analyzing Codex configuration..."

    echo "=== Codex CLI Analysis ==="
    echo

    # Check installation
    if command -v codex &> /dev/null; then
        echo "SUCCESS: Codex CLI: $(which codex)"
        codex --version 2>/dev/null || echo "Version information not available"
    else
        echo "ERROR: Codex CLI: Not installed"
    fi

    echo
    echo "=== Configuration Files ==="

    # Check config directory
    if [[ -d "$CODEX_CONFIG_DIR" ]]; then
        echo "SUCCESS: Config directory: $CODEX_CONFIG_DIR"

        # List configuration files
        for file in "$CODEX_SETTINGS_FILE" "$CODEX_CONFIG_DIR/permissions.toml" "$CODEX_CONFIG_DIR/CODEX.md" "$CODEX_CONFIG_DIR/AGENTS.md"; do
            if [[ -f "$file" ]]; then
                echo "SUCCESS: $(basename "$file"): Exists ($(stat -f%z "$file" 2>/dev/null || echo "unknown") bytes)"
            else
                echo "ERROR: $(basename "$file"): Missing"
            fi
        done

        # Check rules
        if [[ -d "$CODEX_CONFIG_DIR/rules" ]]; then
            local rule_count=$(find "$CODEX_CONFIG_DIR/rules" -name "*.md" -type f | wc -l)
            echo "SUCCESS: Rules: $rule_count files"
        else
            echo "ERROR: Rules directory: Missing"
        fi

        # Check commands
        if [[ -d "$CODEX_COMMANDS_DIR" ]]; then
            local cmd_count=$(find "$CODEX_COMMANDS_DIR" -name "*.md" -type f | wc -l)
            echo "SUCCESS: Commands: $cmd_count files"
        else
            echo "ERROR: Commands directory: Missing"
        fi
    else
        echo "ERROR: Config directory: Not found"
    fi

    echo
    echo "=== Recommendations ==="

    if [[ ! -f "$CODEX_SETTINGS_FILE" ]]; then
        echo "→ Run: codex.sh --action=sync --component=settings"
    fi

    if [[ ! -d "$CODEX_CONFIG_DIR/rules" ]] || [[ -z "$(find "$CODEX_CONFIG_DIR/rules" -name "*.md" -type f)" ]]; then
        echo "→ Run: codex.sh --action=sync --component=rules"
    fi

    if command -v codex &> /dev/null && [[ -f "$CODEX_SETTINGS_FILE" ]]; then
        if ! grep -q "api_key.*[^\"[:space:]]" "$CODEX_SETTINGS_FILE"; then
            echo "WARNING:  Set your OpenAI API key in $CODEX_SETTINGS_FILE"
        fi
    fi
}

verify_codex() {
    log_info "Verifying Codex configuration..."

    local errors=0
    local warnings=0

    echo "=== Codex Configuration Verification ==="
    echo

    # Verify installation
    if ! command -v codex &> /dev/null; then
        echo "ERROR: Codex CLI is not installed"
        ((errors += 1))
        return $errors
    else
        echo "SUCCESS: Codex CLI is installed"
    fi

    # Verify config directory
    if [[ ! -d "$CODEX_CONFIG_DIR" ]]; then
        echo "ERROR: Config directory missing: $CODEX_CONFIG_DIR"
        ((errors += 1))
    else
        echo "SUCCESS: Config directory exists"
    fi

    # Verify settings file
    if [[ ! -f "$CODEX_SETTINGS_FILE" ]]; then
        echo "ERROR: Settings file missing: $CODEX_SETTINGS_FILE"
        ((errors += 1))
    else
        echo "SUCCESS: Settings file exists"

        # Check API key
        if ! grep -q "api_key.*[^\"[:space:]]" "$CODEX_SETTINGS_FILE"; then
            echo "WARNING:  API key not configured"
            ((warnings += 1))
        else
            echo "SUCCESS: API key is configured"
        fi
    fi

    # Verify rules directory and files
    if [[ ! -d "$CODEX_CONFIG_DIR/rules" ]]; then
        echo "ERROR: Rules directory missing"
        ((errors += 1))
    else
        local rule_count=$(find "$CODEX_CONFIG_DIR/rules" -name "*.md" -type f | wc -l)
        if [[ $rule_count -eq 0 ]]; then
            echo "WARNING:  No rules files found"
            ((warnings += 1))
        else
            echo "SUCCESS: Rules directory: $rule_count files"
        fi
    fi

    # Verify commands directory
    if [[ ! -d "$CODEX_COMMANDS_DIR" ]]; then
        echo "WARNING:  Commands directory missing"
        ((warnings += 1))
    else
        local cmd_count=$(find "$CODEX_COMMANDS_DIR" -name "*.md" -type f | wc -l)
        echo "SUCCESS: Commands directory: $cmd_count files"
    fi

    echo
    if [[ $errors -gt 0 ]]; then
        echo "ERROR: Verification failed with $errors error(s)"
        echo "Run: codex.sh --action=sync --component=all"
    elif [[ $warnings -gt 0 ]]; then
        echo "WARNING:  Verification completed with $warnings warning(s)"
    else
        echo "SUCCESS: Verification completed successfully"
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
            setup_codex_directories
            if ! run_sync_components; then
                log_error "Codex sync encountered errors"
                exit 1
            fi
            ;;
        analyze)
            analyze_codex
            ;;
        verify)
            verify_codex
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
    validate_target "codex"
    for component in "${SELECTED_COMPONENTS[@]}"; do
        validate_component "$component"
    done

    # Check installation for sync operations
    if [[ "$ACTION" == "sync" ]]; then
        check_codex_installation
    fi

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting Codex $ACTION for component(s): $COMPONENT_LABEL"

    # Perform the requested action
    perform_action

    log_success "Codex $ACTION completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
