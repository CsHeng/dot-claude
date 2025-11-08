#!/usr/bin/env bash

# Config-Sync User Configuration Command
# Complete configuration sync from Claude to target tools with orchestration

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

ensure_interactive_available() {
    if [[ ! -t 0 && ! -t 1 ]]; then
        log_error "Interactive selection is unavailable; please pass required arguments explicitly."
        usage >&2
        exit 1
    fi
}

prompt_for_targets() {
    ensure_interactive_available

    local options=("droid" "qwen" "codex" "opencode")
    local descriptions=(
        "Factory/Droid CLI"
        "Qwen CLI"
        "OpenAI Codex CLI"
        "OpenCode CLI (~/.config/opencode)"
    )

    printf "\nSelect target tools to synchronize:\n" > /dev/tty
    for idx in "${!options[@]}"; do
        local num=$((idx + 1))
        printf "  %d. %-8s %s\n" "$num" "${options[$idx]}" "${descriptions[$idx]}" > /dev/tty
    done
    printf "  a. %-8s %s\n" "all" "Synchronize to every available target" > /dev/tty
    printf "  (Enter comma-separated numbers or names. Press Enter or 'a' for all.)\n" > /dev/tty

    while true; do
        printf "> " > /dev/tty
        local selection=""
        if ! read -r selection < /dev/tty; then
            log_error "Failed to read target selection"
            exit 1
        fi

        selection="${selection,,}"
        selection="${selection// /}"
        if [[ -z "$selection" ]]; then
            TARGET_SPEC="all"
            log_info "Selected targets: all"
            return
        fi

        IFS=',' read -ra tokens <<< "$selection"
        declare -A seen=()
        local chosen=()
        local invalid=false

        for token in "${tokens[@]}"; do
            [[ -z "$token" ]] && continue
            local value=""
            case "$token" in
                1|d|droid) value="droid" ;;
                2|q|qwen) value="qwen" ;;
                3|c|codex) value="codex" ;;
                4|o|opencode) value="opencode" ;;
                a|all) value="all" ;;
                *) invalid=true ;;
            esac

            if [[ "$invalid" == true ]]; then
                break
            fi

            if [[ "$value" == "all" ]]; then
                TARGET_SPEC="all"
                log_info "Selected targets: all"
                return
            fi

            if [[ -z "${seen[$value]:-}" ]]; then
                chosen+=("$value")
                seen["$value"]=1
            fi
        done

        if [[ "$invalid" == true || ${#chosen[@]} -eq 0 ]]; then
            printf "Invalid selection. Please choose from the listed options.\n" > /dev/tty
            continue
        fi

        TARGET_SPEC="$(IFS=,; printf '%s' "${chosen[*]}")"
        log_info "Selected targets: $TARGET_SPEC"
        return
    done
}

prompt_for_components() {
    ensure_interactive_available

    local options=("commands" "rules" "settings" "permissions" "memory" "all")
    local descriptions=(
        "Slash commands / automation"
        "Development rules and guidelines"
        "Tool-specific settings"
        "Permission configurations"
        "Memory files (CLAUDE.md / AGENTS.md)"
        "All components"
    )

    printf "\nSelect components to synchronize:\n" > /dev/tty
    for idx in "${!options[@]}"; do
        local num=$((idx + 1))
        printf "  %d. %-11s %s\n" "$num" "${options[$idx]}" "${descriptions[$idx]}" > /dev/tty
    done
    printf "  (Enter comma-separated numbers or names. Press Enter for 'all'.)\n" > /dev/tty

    while true; do
        printf "> " > /dev/tty
        local selection=""
        if ! read -r selection < /dev/tty; then
            log_error "Failed to read component selection"
            exit 1
        fi

        selection="${selection,,}"
        selection="${selection// /}"
        if [[ -z "$selection" ]]; then
            COMPONENT_SPEC="all"
            log_info "Selected components: all"
            return
        fi

        IFS=',' read -ra tokens <<< "$selection"
        declare -A seen=()
        local chosen=()
        local invalid=false

        for token in "${tokens[@]}"; do
            [[ -z "$token" ]] && continue
            local value=""
            case "$token" in
                1|commands|cmd|cmds) value="commands" ;;
                2|rules|rule) value="rules" ;;
                3|settings|setting|cfg|config) value="settings" ;;
                4|permissions|perm|perms) value="permissions" ;;
                5|memory|mem) value="memory" ;;
                6|all) value="all" ;;
                *) invalid=true ;;
            esac

            if [[ "$invalid" == true ]]; then
                break
            fi

            if [[ "$value" == "all" ]]; then
                COMPONENT_SPEC="all"
                log_info "Selected components: all"
                return
            fi

            if [[ -z "${seen[$value]:-}" ]]; then
                chosen+=("$value")
                seen["$value"]=1
            fi
        done

        if [[ "$invalid" == true || ${#chosen[@]} -eq 0 ]]; then
            printf "Invalid selection. Please choose from the listed options.\n" > /dev/tty
            continue
        fi

        COMPONENT_SPEC="$(IFS=,; printf '%s' "${chosen[*]}")"
        log_info "Selected components: $COMPONENT_SPEC"
        return
    done
}

interactive_selection_wizard() {
    while true; do
        prompt_for_targets
        prompt_for_components

        printf "\nStep 3/3: Confirm Selection\n" > /dev/tty
        printf "  Targets:    %s\n" "$TARGET_SPEC" > /dev/tty
        printf "  Components: %s\n" "$COMPONENT_SPEC" > /dev/tty
        printf "Proceed with these selections? [Y/n] " > /dev/tty

        local answer=""
        if ! read -r answer < /dev/tty; then
            log_error "Failed to read confirmation input"
            exit 1
        fi

        answer="${answer,,}"
        answer="${answer// /}"

        if [[ -z "$answer" || "$answer" == "y" || "$answer" == "yes" ]]; then
            log_info "Confirmed selections: targets=$TARGET_SPEC components=$COMPONENT_SPEC"
            return
        fi

        printf "\nLet's try again.\n" > /dev/tty
        TARGET_SPEC=""
        COMPONENT_SPEC=""
    done
}

usage() {
    cat << EOF
Config-Sync User Configuration Command - Complete Configuration Sync

USAGE:
    sync-user-config.sh --target <droid,qwen,codex,opencode|all> [OPTIONS]

ARGUMENTS:
    --target <tool[,tool]>  Target tool(s) for synchronization (required)

OPTIONS:
    --component <type[,type]> Specific component(s) to sync (rules, permissions, commands, settings, all)
    --dry-run               Show what would be done without executing
    --force                 Force overwrite existing files
    --verbose               Enable detailed output
    --help                  Show this help message

COMPONENTS:
    rules                   Development rules and guidelines
    permissions             Permission configurations
    commands                Custom slash commands
    settings                Configuration settings
    all                     All components (default)

EXAMPLES:
    sync-user-config.sh --target=all
    sync-user-config.sh --target=droid --component=permissions
    sync-user-config.sh --target=qwen --dry-run

EOF
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

    local missing_target=false
    local missing_component=false

    [[ -z "$TARGET_SPEC" ]] && missing_target=true
    [[ -z "$COMPONENT_SPEC" ]] && missing_component=true

    if [[ "$missing_target" == true && "$missing_component" == true ]]; then
        interactive_selection_wizard
    else
        if [[ "$missing_target" == true ]]; then
            prompt_for_targets
        fi
        if [[ "$missing_component" == true ]]; then
            prompt_for_components
        fi
    fi

    if ! mapfile -t SELECTED_TARGETS < <(parse_target_list "$TARGET_SPEC"); then
        echo "Error: Invalid target selection '$TARGET_SPEC'" >&2
        exit 1
    fi

    if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
        echo "Error: Invalid component selection '$COMPONENT_SPEC'" >&2
        exit 1
    fi

    TARGET_LABEL="$(join_by ',' "${SELECTED_TARGETS[@]}")"
    COMPONENT_LABEL="$(join_by ',' "${SELECTED_COMPONENTS[@]}")"
}

# Utility helpers for selections
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

# Create backup directory
create_backup_dir() {
    local tool="$1"
    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local backup_dir="$config_dir/backup/$(date +%Y%m%d_%H%M%S)"

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$backup_dir"
        echo "$backup_dir"
    else
        echo "Would create backup directory: $backup_dir"
    fi
}

# Backup existing files
backup_existing_files() {
    local tool="$1"
    local backup_dir="$2"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    log_info "Creating backup of existing configuration..."

    if [[ -d "$config_dir" ]]; then
        # Backup key configuration files
        local files_to_backup=(
            "settings.json"
            "config.json"
            "opencode.json"
            "PERMISSIONS.md"
            "AGENTS.md"
            "DROID.md"
            "QWEN.md"
            "CODEX.md"
            "memory.md"
        )

        for file in "${files_to_backup[@]}"; do
            local source_file="$config_dir/$file"
            if [[ -f "$source_file" ]]; then
                if [[ "$DRY_RUN" == false ]]; then
                    rsync -a --quiet "$source_file" "$backup_dir/$file"
                    log_info "Backed up: $file"
                else
                    log_info "Would backup: $file"
                fi
            fi
        done

        # Backup entire rules directory if it exists
        if [[ -d "$config_dir/rules" ]]; then
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$backup_dir/rules"
                rsync -a --quiet "$config_dir/rules"/ "$backup_dir/rules"/
                log_info "Backed up: rules directory"
            else
                log_info "Would backup: rules directory"
            fi
        fi

        # Backup entire commands directory if it exists
        local commands_dir="$config_dir/commands"
        if [[ -d "$commands_dir" ]]; then
            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$backup_dir/commands"
                rsync -a --quiet "$commands_dir"/ "$backup_dir/commands"/
                log_info "Backed up: commands directory"
            else
                log_info "Would backup: commands directory"
            fi
        fi
    fi

    log_success "Backup completed"
}

# Execute adapter command
execute_adapter_command() {
    local command="$1"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would execute: $command"
        return 0
    fi

    log_info "Executing: $command"

    # Execute the command using the adapter script directly
    case "$command" in
        *"adapt-permissions"*)
            local tool=$(echo "$command" | grep -o '\-\-target=[^[:space:]]*' | cut -d'=' -f2)
            if [[ -z "$tool" ]]; then
                log_warning "Unable to determine target tool for permission adaptation"
                return 1
            fi
            local args=("--target=$tool")
            if [[ "$DRY_RUN" == true ]]; then
                args+=("--dry-run")
            fi
            if [[ "$FORCE" == true ]]; then
                args+=("--force")
            fi
            if [[ "$VERBOSE" == true ]]; then
                args+=("--verbose")
            fi
            "$SCRIPT_DIR/../adapters/adapt-permissions.sh" "${args[@]}"
            ;;
        *"adapt-commands"*)
            local tool=$(echo "$command" | grep -o '\-\-target=[^[:space:]]*' | cut -d'=' -f2)
            "$SCRIPT_DIR/../adapters/${tool}.sh" --action=sync --component=commands
            ;;
        *"adapt-rules-content"*)
            # This would be handled by the sync process itself
            log_info "Rules content adaptation handled by main sync process"
            ;;
        *)
            log_warning "Unknown adapter command: $command"
            ;;
    esac
}

# Sync rules for a tool
sync_rules_for_tool() {
    local tool="$1"
    local backup_dir="$2"

    log_info "Syncing rules for $tool..."

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local target_rules_dir="$config_dir/rules"

    if [[ "$DRY_RUN" == false ]]; then
        # Create target directory
        mkdir -p "$target_rules_dir"

        # Sync rules using rsync
        if [[ -d "$CLAUDE_CONFIG_DIR/rules" ]]; then
            rsync -av --delete "$CLAUDE_CONFIG_DIR/rules/" "$target_rules_dir/"
            log_success "Rules synced to $tool"
        else
            log_warning "Source rules directory not found: $CLAUDE_CONFIG_DIR/rules"
        fi
    else
        log_info "Would sync rules from $CLAUDE_CONFIG_DIR/rules to $target_rules_dir"
    fi
}

# Sync memory files for a tool
sync_memory_for_tool() {
    local tool="$1"
    local backup_dir="$2"

    log_info "Syncing memory files for $tool..."

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    case "$tool" in
        "droid")
            sync_tool_memory "$tool" "$config_dir" "DROID.md" "$backup_dir"
            sync_agents_file "$tool" "$config_dir" "AGENTS.md" "$backup_dir"
            ;;
        "qwen")
            sync_tool_memory "$tool" "$config_dir" "QWEN.md" "$backup_dir"
            sync_agents_file "$tool" "$config_dir" "AGENTS.md" "$backup_dir"
            ;;
        "codex")
            sync_tool_memory "$tool" "$config_dir" "memory.md" "$backup_dir"
            ;;
        "opencode")
            sync_agents_file "$tool" "$config_dir" "AGENTS.md" "$backup_dir"
            ;;
    esac
}

# Sync tool-specific memory file
sync_tool_memory() {
    local tool="$1"
    local config_dir="$2"
    local memory_file="$3"
    local backup_dir="$4"

    local target_file="$config_dir/$memory_file"
    local source_file="$CLAUDE_CONFIG_DIR/CLAUDE.md"

    if [[ ! -f "$source_file" ]]; then
        log_warning "Source memory file not found: $source_file"
        return 1
    fi

    if [[ "$DRY_RUN" == false ]]; then
        # Create tool-specific memory file
        local tool_name=$(echo "$tool" | tr '[:lower:]' '[:upper:]')

        cat > "$target_file" << EOF
# $tool_name User Memory

## Tool Configuration
- **Tool**: $tool_name CLI
- **Source**: Synchronized from Claude Code configuration
- **Sync Date**: $(date)

## Development Standards

This file contains adapted memory content from Claude Code configuration.

### Core Development Guidelines
The following rules and guidelines have been synchronized from your Claude Code configuration:

$(if [[ -d "$CLAUDE_CONFIG_DIR/rules" ]]; then
    find "$CLAUDE_CONFIG_DIR/rules" -name "*.md" -type f | while read -r rule_file; do
        local basename=$(basename "$rule_file" .md)
        echo "- **$basename**: Available in rules/$basename.md"
    done
else
    echo "- No rules files found"
fi)

### Agent Instructions
For detailed agent instructions and operating procedures, see AGENTS.md in this directory.

### Configuration Notes
- This is a $tool_name-specific adaptation of your Claude Code configuration
- Rules have been synchronized to the rules/ directory
- Commands have been adapted for $tool_name compatibility
- Permission settings have been mapped to $tool_name's permission model

Generated from Claude Code configuration on $(date).
EOF

        log_success "Created $memory_file for $tool"
    else
        log_info "Would create $memory_file for $tool"
    fi
}

# Sync AGENTS.md file
sync_agents_file() {
    local tool="$1"
    local config_dir="$2"
    local agents_file="$3"
    local backup_dir="$4"

    local target_file="$config_dir/$agents_file"
    local source_file="$CLAUDE_CONFIG_DIR/AGENTS.md"

    if [[ "$DRY_RUN" == false ]]; then
        if [[ -f "$source_file" ]]; then
            # Sync and adapt AGENTS.md
            sed "s/CLAUDE.md/$(basename "$agents_file" .md).md/g" "$source_file" > "$target_file"
            log_success "Synced $agents_file for $tool"
        else
            # Create basic AGENTS.md if source doesn't exist
            local tool_name=$(echo "$tool" | tr '[:lower:]' '[:upper:]')
            cat > "$target_file" << EOF
# $tool_name Agent Capabilities

## Available Agents

### File Operations Agent
- File reading, writing, and editing
- Search and analysis capabilities
- Code review and suggestions

### Configuration Management Agent
- Settings and preferences management
- Permission configuration
- Rule synchronization

### Development Workflow Agent
- Build and deployment automation
- Testing orchestration
- Code quality checks

This is a basic agents file created during synchronization.
For complete agent documentation, ensure AGENTS.md exists in your Claude configuration.

Generated: $(date)
EOF
            log_success "Created basic $agents_file for $tool"
        fi
    else
        log_info "Would sync $agents_file for $tool"
    fi
}

# Sync components for a tool
sync_components_for_tool() {
    local tool="$1"
    local backup_dir="$2"
    local components=($(get_components))

    log_info "Syncing components for $tool: ${components[*]}"

    for component in "${components[@]}"; do
        case "$component" in
            "rules")
                sync_rules_for_tool "$tool" "$backup_dir"
                ;;
            "permissions")
                execute_adapter_command "/config-sync:adapt-permissions --target=$tool"
                ;;
            "commands")
                execute_adapter_command "/config-sync:adapt-commands --target=$tool"
                ;;
            "settings")
                execute_adapter_command "/config-sync:sync --target=$tool --component=settings"
                ;;
            "memory")
                sync_memory_for_tool "$tool" "$backup_dir"
                ;;
        esac
    done

    # Always sync memory files when rules are requested (unless already handled)
    if component_selected "rules" && ! component_selected "memory"; then
        sync_memory_for_tool "$tool" "$backup_dir"
    fi
}

# Verify sync for a tool
verify_sync_for_tool() {
    local tool="$1"

    log_info "Verifying sync for $tool..."

    # Run verification for the tool
    if [[ "$DRY_RUN" == false ]] && command -v "$SCRIPT_DIR/verify.sh" &> /dev/null; then
        "$SCRIPT_DIR/verify.sh" --target="$tool" --detailed
    else
        log_info "Would run verification for $tool"
    fi
}

# Generate sync report
generate_sync_report() {
    local targets=($(get_targets))
    local components=($(get_components))

    echo "# Configuration Sync Report"
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

    echo "## Targets Processed"
    for target in "${targets[@]}"; do
        local config_dir
        config_dir=$(get_tool_config_dir "$target")
        echo "- **$target**: $config_dir"
    done
    echo ""

    echo "## Recommendations"
    echo "1. Test configurations in each target tool"
    echo "2. Run \`/config-sync:verify --target=all\` to validate setup"
    echo "3. Customize configurations as needed for your workflow"
    echo ""

    if [[ $DRY_RUN == false ]]; then
        echo "## Rollback Information"
        echo "If issues occur, you can restore from backup directories located in:"
        for target in "${targets[@]}"; do
            local config_dir
            config_dir=$(get_tool_config_dir "$target")
            echo "- $target: $config_dir/backup/"
        done
        echo ""
    fi

    echo "## Next Steps"
    echo "1. Verify configurations are working in target tools"
    echo "2. Run tests to ensure functionality"
    echo "3. Customize any tool-specific settings as needed"
}

# Main orchestration function
run_sync_orchestration() {
    local targets=($(get_targets))

    echo "# Starting Configuration Sync Orchestration"
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

    # Check source components exist
    if component_selected "rules"; then
        if [[ ! -d "$CLAUDE_CONFIG_DIR/rules" ]]; then
            log_warning "Source rules directory not found: $CLAUDE_CONFIG_DIR/rules"
        fi
    fi

    if component_selected "commands"; then
        if [[ ! -d "$CLAUDE_CONFIG_DIR/commands" ]]; then
            log_warning "Source commands directory not found: $CLAUDE_CONFIG_DIR/commands"
        fi
    fi

    log_success "Pre-flight checks completed"

    # Process each target
    for target_tool in "${targets[@]}"; do
        echo
        echo "## Processing Target: $target_tool"
        echo

        # Check if tool is installed
        if ! command -v "$target_tool" &> /dev/null; then
            log_warning "$target_tool is not installed - will create configuration files only"
        fi

        # Create backup
        local backup_dir
        backup_dir=$(create_backup_dir "$target_tool")

        # Backup existing files
        backup_existing_files "$target_tool" "$backup_dir"

        # Sync components
        sync_components_for_tool "$target_tool" "$backup_dir"

        # Verify sync
        verify_sync_for_tool "$target_tool"

        echo "SUCCESS: $target_tool: Sync completed"
    done

    # Generate final report
    echo
    generate_sync_report
}

main() {
    parse_arguments "$@"

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting configuration sync orchestration for target(s): $TARGET_LABEL"

    # Run orchestration
    run_sync_orchestration

    if [[ "$DRY_RUN" == true ]]; then
        log_success "Dry run completed - no changes were made"
    else
        log_success "Configuration sync orchestration completed successfully"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
