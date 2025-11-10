#!/usr/bin/env bash

# Config-Sync Memory Synchronization Command
# Synchronize memory and context files to target tools

set -euo pipefail

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Default values
TARGET_SPEC=""
COMPONENT_SPEC=""
DRY_RUN=false
FORCE=false
VERBOSE=false

declare -a SELECTED_TARGETS=()
declare -a SELECTED_COMPONENTS=()
TARGET_LABEL=""
COMPONENT_LABEL=""

usage() {
    cat << EOF
Config-Sync Memory Synchronization Command - Sync Memory Files

USAGE:
    sync-memory.sh --target <droid,qwen,codex,opencode|all> [OPTIONS]

ARGUMENTS:
    --target <tool[,tool]>  Target tool(s) for memory synchronization (required)

OPTIONS:
    --component <type[,type]> Specific memory component(s) (user, agents, all)
    --dry-run               Show what would be done without executing
    --force                 Force overwrite existing memory files
    --verbose               Enable detailed output
    --help                  Show this help message

COMPONENTS (comma-separated):
    user                    User memory files (CLAUDE.md adaptations)
    agents                  Agent capability files (AGENTS.md)
    all                     All memory components (default)

EXAMPLES:
    sync-memory.sh --target=all
    sync-memory.sh --target=droid --component=user
    sync-memory.sh --target=opencode --dry-run

EOF
}

parse_memory_component_list() {
    local raw="$1"
    local trimmed
    trimmed="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
    trimmed="${trimmed// /}"

    local valid_components=("user" "agents")

    if [[ -z "$trimmed" ]]; then
        log_error "No component specified"
        return 1
    fi

    if [[ "$trimmed" == "all" ]]; then
        printf '%s\n' "${valid_components[@]}"
        return 0
    fi

    IFS=',' read -ra parts <<< "$trimmed"
    declare -A seen=()
    local result=()

    for part in "${parts[@]}"; do
        [[ -z "$part" ]] && continue
        case "$part" in
            user|agents)
                if [[ -z "${seen[$part]:-}" ]]; then
                    result+=("$part")
                    seen["$part"]=1
                fi
                ;;
            *)
                log_error "Invalid memory component specified: $part"
                return 1
                ;;
        esac
    done

    if [[ ${#result[@]} -eq 0 ]]; then
        log_error "No valid memory components found in: $raw"
        return 1
    fi

    printf '%s\n' "${result[@]}"
}

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

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target=*)
                TARGET_SPEC="${1#--target=}"
                shift
                ;;
            --target)
                TARGET_SPEC="$2"
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
    if [[ -z "$TARGET_SPEC" ]]; then
        echo "Error: --target is required" >&2
        exit 1
    fi

    # Set component default
    if [[ -z "$COMPONENT_SPEC" ]]; then
        COMPONENT_SPEC="all"
    fi

    if ! mapfile -t SELECTED_TARGETS < <(parse_target_list "$TARGET_SPEC"); then
        log_error "Invalid target selection: $TARGET_SPEC"
        exit 1
    fi

    if ! mapfile -t SELECTED_COMPONENTS < <(parse_memory_component_list "$COMPONENT_SPEC"); then
        log_error "Invalid component selection: $COMPONENT_SPEC"
        exit 1
    fi

    TARGET_LABEL="$(join_by ',' "${SELECTED_TARGETS[@]}")"
    COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"
}

# Get target list
get_targets() {
    printf '%s\n' "${SELECTED_TARGETS[@]}"
}

# Get component list
get_components() {
    printf '%s\n' "${SELECTED_COMPONENTS[@]}"
}

# Get tool configuration directory
get_tool_config_dir() {
    local tool="$1"
    case "$tool" in
        "droid")
            get_target_config_dir droid
            ;;
        "qwen")
            get_target_config_dir qwen
            ;;
        "codex")
            get_target_config_dir codex
            ;;
        "opencode")
            get_target_config_dir opencode
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get tool-specific memory filename
get_tool_memory_filename() {
    local tool="$1"
    case "$tool" in
        "droid")
            echo "DROID.md"
            ;;
        "qwen")
            echo "QWEN.md"
            ;;
        "codex")
            echo "CODEX.md"
            ;;
        "opencode")
            echo "AGENTS.md"  # OpenCode uses AGENTS.md as primary memory
            ;;
        *)
            echo ""
            ;;
    esac
}

# Note: Backup functions removed - now handled by unified prepare phase

# Backup existing memory files
# Sync user memory file
sync_user_memory() {
    local tool="$1"

    log_info "Syncing user memory for $tool..."

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local memory_filename
    memory_filename=$(get_tool_memory_filename "$tool")
    local target_file="$config_dir/$memory_filename"
    local source_file="$CLAUDE_CONFIG_DIR/CLAUDE.md"

    if [[ ! -f "$source_file" ]]; then
        log_warning "Source CLAUDE.md not found: $source_file"
        return 1
    fi

    # Skip if OpenCode (handled by agents sync)
    if [[ "$tool" == "opencode" ]]; then
        log_info "User memory for OpenCode handled by AGENTS.md sync"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync user memory from $source_file to $target_file"
        return 0
    fi

    sync_claude_memory_file "$target_file" "$FORCE"

    log_success "User memory synced for $tool: $memory_filename"
}

# Sync agents file
sync_agents_file() {
    local tool="$1"

    log_info "Syncing agents file for $tool..."

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local target_file="$config_dir/AGENTS.md"
    local source_file="$CLAUDE_CONFIG_DIR/AGENTS.md"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync agents file to $target_file"
        return 0
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"

    # Note: Backup is now handled by the unified prepare phase
    # No need for individual file backups here

    local tool_name=$(echo "$tool" | tr '[:lower:]' '[:upper:]')

    if [[ -f "$source_file" ]]; then
        # Adapt existing AGENTS.md
        local memory_file="$(get_tool_memory_filename "$tool")"
        sed -e "s/@CLAUDE\.md/@${memory_file}/g" \
            -e "s/CLAUDE.md/${memory_file}/g" \
            "$source_file" > "$target_file"

        # Add tool-specific section
        cat >> "$target_file" << EOF

## $tool_name Agent Configuration

### Tool-Specific Capabilities
The following agent capabilities are specifically configured for $tool_name:

#### File Operations
- **Format**: $tool_name-compatible file editing
- **Scope**: Workspace and configuration directories
- **Syntax**: Adapted for $tool_name command structure

#### Command Execution
- **Safety**: Permission-based command filtering
- **Scope**: Development and build tools
- **Integration**: $tool_name-specific tool integration

#### Analysis and Review
- **Code Analysis**: Multi-language code review
- **Pattern Recognition**: Development pattern identification
- **Best Practices**: Industry standard compliance

### $tool_name Integration Notes
This agents file has been synchronized from Claude Code and adapted for $tool_name usage patterns.

EOF
    else
        # Create basic AGENTS.md if source doesn't exist
        cat > "$target_file" << EOF
# $tool_name Agent Capabilities

## Available Agents

### File Operations Agent
- File reading, writing, and editing using $tool_name syntax
- Search and analysis capabilities
- Code review and suggestions
- Multi-format file support

### Configuration Management Agent
- Settings and preferences management
- Permission configuration and validation
- Rule synchronization and adaptation
- Environment setup and maintenance

### Development Workflow Agent
- Build and deployment automation
- Testing orchestration and validation
- Code quality checks and improvements
- Version control operations

### Analysis and Research Agent
- Code analysis and optimization
- Pattern recognition and suggestions
- Documentation generation
- Security and performance analysis

## $tool_name-Specific Features

### Command Adaptation
- Commands are adapted for $tool_name compatibility
- Syntax differences are automatically handled
- Tool-specific features are leveraged appropriately

### Permission Integration
- Permission boundaries are respected and enforced
- Security-first approach to command execution
- User confirmation for risky operations

### Memory Management
- Context preservation across sessions
- Efficient memory usage for large projects
- Quick access to relevant information

## Usage Guidelines

1. **File Operations**: Use file editing commands for code modifications
2. **Analysis**: Leverage analysis agents for code review and optimization
3. **Configuration**: Manage settings and permissions through configuration agents
4. **Workflow**: Automate development tasks with workflow agents

## Integration Notes

This agents file was created for $tool_name based on Claude Code configuration patterns.

Generated: $(date)
EOF
    fi

    log_success "Agents file synced for $tool: AGENTS.md"
}

# Sync memory components for a tool
sync_memory_components() {
    local tool="$1"
    local components=($(get_components))

    log_info "Syncing memory components for $tool: ${components[*]}"

    for component in "${components[@]}"; do
        case "$component" in
            "user")
                sync_user_memory "$tool"
                ;;
            "agents")
                sync_agents_file "$tool"
                ;;
        esac
    done
}

# Verify memory sync for a tool
verify_memory_sync() {
    local tool="$1"

    log_info "Verifying memory sync for $tool..."

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local issues=0

    # Check user memory file
    local memory_filename
    memory_filename=$(get_tool_memory_filename "$tool")
    if [[ "$tool" != "opencode" ]]; then  # OpenCode uses AGENTS.md as primary
        if [[ -f "$config_dir/$memory_filename" ]]; then
            log_success "SUCCESS: User memory file exists: $memory_filename"
        else
            log_warning "WARNING:  User memory file missing: $memory_filename"
            ((issues += 1))
        fi
    fi

    # Check agents file
    if [[ -f "$config_dir/AGENTS.md" ]]; then
        log_success "SUCCESS: Agents file exists: AGENTS.md"
    else
        log_warning "WARNING:  Agents file missing: AGENTS.md"
        ((issues += 1))
    fi

    # Check rules directory
    if [[ -d "$config_dir/rules" ]]; then
        local rule_count=$(find "$config_dir/rules" -name "*.md" -type f | wc -l)
        if [[ $rule_count -gt 0 ]]; then
            log_success "SUCCESS: Rules directory exists with $rule_count files"
        else
            log_warning "WARNING:  Rules directory exists but is empty"
            ((issues += 1))
        fi
    else
        log_warning "WARNING:  Rules directory missing"
        ((issues += 1))
    fi

    return $issues
}

# Generate memory sync report
generate_memory_sync_report() {
    local targets=($(get_targets))
    local components=($(get_components))

    echo "# Memory Synchronization Report"
    echo "Generated: $(date)"
    echo "Target(s): $TARGET_LABEL"
    echo "Component(s): $COMPONENT_LABEL"
    echo "Dry Run: $DRY_RUN"
    echo ""

    echo "## Sync Summary"
    echo "- **Targets Processed**: ${#targets[@]}"
    echo "- **Components Synced**: ${#components[@]}"
    echo "- **Mode**: $(if [[ $DRY_RUN == true ]]; then echo "Dry Run (no changes made)"; else echo "Live Sync"; fi)"
    echo ""

    echo "## Memory Files by Tool"
    for target in "${targets[@]}"; do
        local config_dir
        config_dir=$(get_tool_config_dir "$target")
        local memory_filename
        memory_filename=$(get_tool_memory_filename "$target")

        echo "- **$target**:"
        echo "  - Config Directory: $config_dir"
        if [[ "$target" != "opencode" ]]; then
            echo "  - User Memory: $memory_filename"
        fi
        echo "  - Agents File: AGENTS.md"
        echo "  - Rules Directory: rules/"
    done
    echo ""

    echo "## Memory Components Synced"
    for component in "${components[@]}"; do
        case "$component" in
            "user")
                echo "- **User Memory**: CLAUDE.md adaptations for each tool"
                ;;
            "agents")
                echo "- **Agents**: AGENTS.md with tool-specific capabilities"
                ;;
        esac
    done
    echo ""

    echo "## Verification Results"
    local total_issues=0
    for target in "${targets[@]}"; do
        verify_memory_sync "$target"
        total_issues=$((total_issues + $?))
    done

    if [[ $total_issues -eq 0 ]]; then
        echo "SUCCESS: **All memory files verified successfully**"
    else
        echo "WARNING:  **$total_issues issues found during verification**"
    fi
    echo ""

    echo "## Usage Guidelines"
    echo "1. Memory files provide context and guidelines for each AI tool"
    echo "2. Rules are automatically loaded from the rules/ directory"
    echo "3. Agent capabilities are documented in AGENTS.md"
    echo "4. Tool-specific adaptations ensure compatibility"
    echo ""

    if [[ $DRY_RUN == false ]]; then
        echo "## Rollback Information"
        echo "If issues occur, backup files are located in:"
        for target in "${targets[@]}"; do
            local config_dir
            config_dir=$(get_tool_config_dir "$target")
            echo "- $target: $config_dir/backup/"
        done
        echo ""
    fi

    echo "## Next Steps"
    echo "1. Test memory files in target tools"
    echo "2. Verify rules are loading correctly"
    echo "3. Customize memory content as needed"
    echo "4. Run regular syncs when updating configurations"
}

# Main memory synchronization function
run_memory_sync() {
    local targets=($(get_targets))

    echo "# Starting Memory Synchronization"
    echo "Target(s): $TARGET_LABEL"
    echo "Component(s): $COMPONENT_LABEL"
    echo "Dry Run: $DRY_RUN"
    echo ""

    # Pre-flight checks
    log_info "Performing pre-flight checks..."

    # Check Claude configuration directory
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        log_error "Claude configuration directory not found: $CLAUDE_CONFIG_DIR"
        exit 1
    fi

    # Check source files exist
    if component_selected "user"; then
        if [[ ! -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]]; then
            log_warning "Source CLAUDE.md not found: $CLAUDE_CONFIG_DIR/CLAUDE.md"
        fi
    fi

    if component_selected "agents"; then
        if [[ ! -f "$CLAUDE_CONFIG_DIR/AGENTS.md" ]]; then
            log_warning "Source AGENTS.md not found: $CLAUDE_CONFIG_DIR/AGENTS.md"
        fi
    fi

    log_success "Pre-flight checks completed"

    # Process each target
    for target_tool in "${targets[@]}"; do
        echo
        echo "## Processing Target: $target_tool"
        echo

        # Create backup
        local backup_dir
        # Note: Backup creation removed - now handled by unified prepare phase
        # No need for create_backup_dir and backup_memory_files calls

        # Sync memory components
        sync_memory_components "$target_tool"

        # Verify sync
        verify_memory_sync "$target_tool"

        echo "SUCCESS: **$target_tool**: Memory sync completed"
    done

    # Generate final report
    echo
    generate_memory_sync_report
}

main() {
    parse_arguments "$@"

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting memory synchronization for target(s): $TARGET_LABEL"

    # Run memory sync
    run_memory_sync

    if [[ "$DRY_RUN" == true ]]; then
        log_success "Memory synchronization dry run completed - no changes were made"
    else
        log_success "Memory synchronization completed successfully"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
