#!/usr/bin/env bash

# Config-Sync Verification Command
# Verify configuration sync completeness and correctness with optional auto-fixing

set -euo pipefail

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Default values
TARGET_SPEC=""
COMPONENT_SPEC=""
DETAILED=false
FIX=false
VERBOSE=false

declare -a SELECTED_TARGETS=()
declare -a SELECTED_COMPONENTS=()
TARGET_LABEL=""
COMPONENT_LABEL=""

usage() {
    cat << EOF
Config-Sync Verification Command - Verify Configuration Sync Completeness

USAGE:
    verify.sh --target <droid,qwen,codex,opencode|all> [OPTIONS]

ARGUMENTS:
    --target <tool[,tool]>  Target tool(s) to verify (required)

OPTIONS:
    --component <type[,type]> Specific component(s) to verify (rules, permissions, commands, settings, memory, all)
    --detailed             Include detailed verification and recommendations
    --fix                  Attempt to automatically fix common issues
    --verbose              Enable detailed output
    --help                 Show this help message

COMPONENTS:
    rules                  Development rules and guidelines
    permissions            Permission configurations
    commands               Custom slash commands
    settings               Configuration settings
    memory                 Memory and context files
    all                    All components (default)

EXAMPLES:
    verify.sh --target=all
    verify.sh --target=droid --component=permissions
    verify.sh --target=all --detailed --fix

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
            --detailed)
                DETAILED=true
                shift
                ;;
            --fix)
                FIX=true
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

# Selection helpers
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

# Determine target list
get_targets() {
    printf '%s\n' "${SELECTED_TARGETS[@]}"
}

# Determine component list
get_components() {
    printf '%s\n' "${SELECTED_COMPONENTS[@]}"
}

# Get tool config directory
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

# Get tool commands directory
get_tool_commands_dir() {
    local tool="$1"
    case "$tool" in
        "droid")
            get_target_commands_dir droid
            ;;
        "qwen")
            get_target_commands_dir qwen
            ;;
        "codex")
            get_target_commands_dir codex
            ;;
        "opencode")
            get_target_commands_dir opencode
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if tool is installed
check_tool_installed() {
    local tool="$1"
    command -v "$tool" &> /dev/null
}

# Verify tool installation
verify_tool_installation() {
    local tool="$1"
    local issues=0

    echo "### Installation Check"

    if check_tool_installed "$tool"; then
        echo "✅ $tool is installed and accessible"
        if [[ "$VERBOSE" == true ]]; then
            echo "   Path: $(which "$tool")"
        fi
    else
        echo "❌ $tool is not installed or not in PATH"
        ((issues += 1))
    fi

    echo
    return $issues
}

# Verify configuration structure
verify_configuration_structure() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Configuration Structure"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    if [[ ! -d "$config_dir" ]]; then
        echo "❌ Configuration directory not found: $config_dir"
        ((issues += 1))
        if [[ "$FIX" == true ]]; then
            mkdir -p "$config_dir"
            echo "🔧 Created configuration directory: $config_dir"
            ((fixes += 1))
        fi
    else
        echo "✅ Configuration directory exists: $config_dir"

        # Check if directory is writable
        if [[ ! -w "$config_dir" ]]; then
            echo "❌ Configuration directory not writable"
            ((issues += 1))
            if [[ "$FIX" == true ]]; then
                chmod u+w "$config_dir"
                echo "🔧 Made configuration directory writable"
                ((fixes += 1))
            fi
        fi
    fi

    # Check commands directory
    local commands_dir
    commands_dir=$(get_tool_commands_dir "$tool")

    if [[ ! -d "$commands_dir" ]]; then
        echo "❌ Commands directory not found: $commands_dir"
        ((issues += 1))
        if [[ "$FIX" == true ]]; then
            mkdir -p "$commands_dir"
            echo "🔧 Created commands directory: $commands_dir"
            ((fixes += 1))
        fi
    else
        echo "✅ Commands directory exists: $commands_dir"
    fi

    echo
    return $issues
}

# Verify rules files
verify_rules_files() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Rules Verification"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local rules_dir="$config_dir/rules"

    if [[ ! -d "$rules_dir" ]]; then
        echo "❌ Rules directory does not exist: $rules_dir"
        ((issues += 1))
        if [[ "$FIX" == true ]]; then
            mkdir -p "$rules_dir"
            echo "🔧 Created rules directory: $rules_dir"
            ((fixes += 1))
        fi
        return $issues
    fi

    # Check for rule files
    local rule_files=("$rules_dir"/*.md)
    if [[ ! -f "${rule_files[0]}" ]]; then
        echo "❌ No rule files found"
        ((issues += 1))
        if [[ "$FIX" == true ]] && [[ -d "$CLAUDE_CONFIG_DIR/rules" ]]; then
            # Sync basic rule files
            local synced=0
            for rule_file in "$CLAUDE_CONFIG_DIR/rules"/*.md; do
                [[ -f "$rule_file" ]] || continue
                rsync -a --quiet "$rule_file" "$rules_dir/"
                ((synced += 1))
            done
            if [[ $synced -gt 0 ]]; then
                echo "🔧 Synced $synced rule files from Claude"
                ((fixes += 1))
            fi
        fi
    else
        local rule_count=$(ls "$rules_dir"/*.md 2>/dev/null | wc -l)
        echo "✅ Found $rule_count rule files"

        # Detailed check for tool-specific adaptations
        if [[ "$DETAILED" == "true" ]]; then
            for rule_file in "$rules_dir"/*.md; do
                [[ -f "$rule_file" ]] || continue

                # Check for Claude references that should be adapted
                if grep -q "CLAUDE.md" "$rule_file"; then
                    echo "⚠️  Rule $(basename "$rule_file") contains Claude references"
                    ((issues += 1))
                    if [[ "$FIX" == true ]]; then
                        sed -i '' 's/CLAUDE.md/AGENTS.md/g' "$rule_file"
                        echo "🔧 Updated tool references in $(basename "$rule_file")"
                        ((fixes += 1))
                    fi
                fi
            done
        fi
    fi

    echo
    return $issues
}

# Verify permissions configuration
verify_permissions_files() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Permissions Verification"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    case "$tool" in
        "droid")
            verify_droid_permissions "$config_dir" issues fixes
            ;;
        "qwen")
            verify_qwen_permissions "$config_dir" issues fixes
            ;;
        "codex")
            verify_codex_permissions "$config_dir" issues fixes
            ;;
        "opencode")
            verify_opencode_permissions "$config_dir" issues fixes
            ;;
    esac

    echo
    return $issues
}

# Verify Droid permissions
verify_droid_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local settings_file="$config_dir/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        echo "❌ Droid settings.json not found"
        ((issues_ref += 1))
        if [[ "$FIX" == "true" ]]; then
            # Create basic settings file
            cat > "$settings_file" << 'JSON'
{
  "commandAllowlist": [
    "read", "write", "edit", "search", "analyze", "list", "help", "status",
    "git", "npm", "pip", "cargo", "go", "python", "node", "docker"
  ],
  "commandDenylist": [
    "rm", "sudo", "chmod", "chown", "dd", "mkfs", "reboot", "shutdown",
    "kill", "pkill", "killall"
  ],
  "model": "claude-sonnet-4-5-20250929",
  "autonomy": "balanced"
}
JSON
            echo "🔧 Created basic Droid settings.json"
            ((fixes_ref += 1))
        fi
    else
        echo "✅ Droid settings.json exists"

        # Validate JSON syntax
        if command -v jq &> /dev/null; then
            if ! jq empty "$settings_file" 2>/dev/null; then
                echo "❌ Invalid JSON syntax in settings.json"
                ((issues_ref += 1))
            else
                echo "✅ JSON syntax is valid"
            fi
        fi
    fi
}

# Verify Qwen permissions
verify_qwen_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local permissions_file="$config_dir/PERMISSIONS.md"

    if [[ ! -f "$permissions_file" ]]; then
        echo "❌ Qwen permissions documentation not found"
        ((issues_ref += 1))
        if [[ "$FIX" == "true" ]]; then
            cat > "$permissions_file" << 'MARKDOWN'
# Qwen CLI Permissions

Qwen CLI does not have a formal permission system like Claude Code.
It operates with the same permissions as the user account.

## Security Features
- Shell execution requires user confirmation
- File access respects user file system permissions
- Optional sandbox mode can be applied

## Synchronized Configuration
This file was synchronized from Claude Code configuration system.
MARKDOWN
            echo "🔧 Created Qwen permissions documentation"
            ((fixes_ref += 1))
        fi
    else
        echo "✅ Qwen permissions documentation exists"
    fi
}

# Verify Codex permissions
verify_codex_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_file="$config_dir/config.toml"

    if [[ ! -f "$config_file" ]]; then
        echo "❌ Codex config.toml not found"
        ((issues_ref += 1))
        if [[ "$FIX" == "true" ]]; then
            cat > "$config_file" << 'TOML'
# Codex CLI Configuration
[core]
api_key = ""  # Set your OpenAI API key here
model = "code-davinci-002"
temperature = 0.1
max_tokens = 1000

[sandbox]
mode = "workspace-write"
timeout = 30
memory_limit = "512MB"

[sync]
source = "claude-code-sync"
last_sync = ""
TOML
            echo "🔧 Created basic Codex config.toml"
            ((fixes_ref += 1))
        fi
    else
        echo "✅ Codex config.toml exists"

        # Check for sandbox configuration
        if ! grep -q "\[sandbox\]" "$config_file"; then
            echo "⚠️  Missing sandbox configuration"
            ((issues_ref += 1))
            if [[ "$FIX" == "true" ]]; then
                echo -e "\n[sandbox]\nmode = \"workspace-write\"" >> "$config_file"
                echo "🔧 Added sandbox configuration"
                ((fixes_ref += 1))
            fi
        fi
    fi
}

# Verify OpenCode permissions
verify_opencode_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_file="$config_dir/opencode.json"

    if [[ ! -f "$config_file" ]]; then
        echo "❌ OpenCode opencode.json not found"
        ((issues_ref += 1))
        if [[ "$FIX" == "true" ]]; then
            cat > "$config_file" << 'JSON'
{
  "version": "1.0.0",
  "name": "OpenCode Configuration",
  "permissions": {
    "edit": {
      "enabled": true,
      "description": "File editing operations",
      "scope": ["workspace"]
    },
    "bash": {
      "enabled": true,
      "description": "Command execution operations",
      "scope": ["readonly"],
      "restrictions": ["no-destructive-commands"]
    },
    "webfetch": {
      "enabled": true,
      "description": "Web content fetching",
      "scope": ["allowed-domains"],
      "restrictions": ["no-authenticated-sites"]
    },
    "read": {
      "enabled": true,
      "description": "File reading operations",
      "scope": ["workspace", "config"]
    }
  },
  "sync": {
    "lastSync": "",
    "source": "claude-code",
    "version": "1.0.0"
  }
}
JSON
            echo "🔧 Created basic OpenCode opencode.json"
            ((fixes_ref += 1))
        fi
    else
        echo "✅ OpenCode opencode.json exists"

        # Validate JSON syntax
        if command -v jq &> /dev/null; then
            if ! jq empty "$config_file" 2>/dev/null; then
                echo "❌ Invalid JSON syntax in opencode.json"
                ((issues_ref += 1))
            else
                echo "✅ JSON syntax is valid"
            fi
        fi
    fi
}

# Verify commands files
verify_commands_files() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Commands Verification"

    local commands_dir
    commands_dir=$(get_tool_commands_dir "$tool")

    if [[ ! -d "$commands_dir" ]]; then
        echo "❌ Commands directory does not exist: $commands_dir"
        ((issues += 1))
        return $issues
    fi

    # Check for command files based on tool format
    local cmd_files=()
    case "$tool" in
        "opencode")
            mapfile -t cmd_files < <(find "$commands_dir" -type f -name "*.md" 2>/dev/null)
            ;;
        "qwen")
            mapfile -t cmd_files < <(find "$commands_dir" -type f -name "*.toml" 2>/dev/null)
            ;;
        *)
            mapfile -t cmd_files < <(find "$commands_dir" -type f -name "*.md" 2>/dev/null)
            ;;
    esac

    if [[ ${#cmd_files[@]} -eq 0 ]]; then
        echo "❌ No command files found"
        ((issues += 1))
        if [[ "$FIX" == true ]] && [[ -d "$CLAUDE_CONFIG_DIR/commands" ]]; then
            echo "🔧 Would sync command files (requires adapter implementation)"
        fi
    else
        local cmd_count=${#cmd_files[@]}
        echo "✅ Found $cmd_count command files"

        # Validate command formats
        if [[ "$DETAILED" == "true" ]]; then
            case "$tool" in
                "opencode")
                    for cmd_file in "${cmd_files[@]}"; do
                        [[ -f "$cmd_file" ]] || continue
                        if command -v jq &> /dev/null && ! jq empty "$cmd_file" 2>/dev/null; then
                            echo "⚠️  Command $(basename "$cmd_file") has invalid JSON"
                            ((issues += 1))
                        fi
                    done
                    ;;
                "qwen")
                    for cmd_file in "${cmd_files[@]}"; do
                        [[ -f "$cmd_file" ]] || continue
                        if ! grep -q "^prompt = " "$cmd_file"; then
                            echo "⚠️  Command $(basename "$cmd_file") missing prompt field"
                            ((issues += 1))
                        fi
                    done
                    ;;
            esac
        fi
    fi

    echo
    return $issues
}

# Verify settings files
verify_settings_files() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Settings Verification"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    case "$tool" in
        "droid")
            if [[ -f "$config_dir/settings.json" ]]; then
                echo "✅ Droid settings.json exists"
            else
                echo "⚠️  Droid settings.json not found"
                ((issues += 1))
            fi
            ;;
        "qwen")
            if [[ -f "$config_dir/settings.json" ]]; then
                echo "✅ Qwen settings.json exists"
            else
                echo "⚠️  Qwen settings.json not found"
                ((issues += 1))
            fi
            ;;
        "codex")
            if [[ -f "$config_dir/config.toml" ]]; then
                echo "✅ Codex config.toml exists"
            else
                echo "⚠️  Codex config.toml not found"
                ((issues += 1))
            fi
            ;;
        "opencode")
            if [[ -f "$config_dir/opencode.json" ]]; then
                echo "✅ OpenCode opencode.json exists"
            else
                echo "⚠️  OpenCode opencode.json not found"
                ((issues += 1))
            fi
            ;;
    esac

    echo
    return $issues
}

# Verify memory files
verify_memory_files() {
    local tool="$1"
    local issues=0
    local fixes=0

    echo "### Memory Verification"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    case "$tool" in
        "droid")
            if [[ -f "$config_dir/DROID.md" ]]; then
                echo "✅ DROID.md exists"
            else
                echo "⚠️  DROID.md not found"
                ((issues += 1))
                if [[ "$FIX" == true ]]; then
                    create_basic_memory_file "$tool" "$config_dir/DROID.md"
                    echo "🔧 Created DROID.md"
                    ((fixes += 1))
                fi
            fi
            ;;
        "qwen")
            if [[ -f "$config_dir/QWEN.md" ]]; then
                echo "✅ QWEN.md exists"
            else
                echo "⚠️  QWEN.md not found"
                ((issues += 1))
                if [[ "$FIX" == true ]]; then
                    create_basic_memory_file "$tool" "$config_dir/QWEN.md"
                    echo "🔧 Created QWEN.md"
                    ((fixes += 1))
                fi
            fi
            ;;
        "codex")
            if [[ -f "$config_dir/memory.md" ]]; then
                echo "✅ Codex memory.md exists"
            else
                echo "⚠️  Codex memory.md not found"
                ((issues += 1))
                if [[ "$FIX" == true ]]; then
                    create_basic_memory_file "$tool" "$config_dir/memory.md"
                    echo "🔧 Created memory.md"
                    ((fixes += 1))
                fi
            fi
            ;;
        "opencode")
            if [[ -f "$config_dir/AGENTS.md" ]]; then
                echo "✅ OpenCode AGENTS.md exists"
            else
                echo "⚠️  AGENTS.md not found"
                ((issues += 1))
                if [[ "$FIX" == true ]]; then
                    create_basic_agents_file "$tool" "$config_dir/AGENTS.md"
                    echo "🔧 Created AGENTS.md"
                    ((fixes += 1))
                fi
            fi
            ;;
    esac

    echo
    return $issues
}

# Create basic memory file
create_basic_memory_file() {
    local tool="$1"
    local memory_file="$2"

    local tool_name=$(echo "$tool" | tr '[:lower:]' '[:upper:]')

    cat > "$memory_file" << EOF
# $tool_name User Memory

## Tool Configuration
- **Tool**: $tool_name CLI
- **Source**: Synchronized from Claude Code

## Status
This is a basic memory file created during verification.
For complete configuration, run a full sync operation.

## Next Steps
1. Run \`/config-sync:sync --target=$tool --component=memory\`
2. Customize this file with your specific preferences
3. Add tool-specific notes and configurations

Generated: $(date)
EOF
}

# Create basic AGENTS.md file
create_basic_agents_file() {
    local tool="$1"
    local agents_file="$2"

    local tool_name=$(echo "$tool" | tr '[:lower:]' '[:upper:]')

    cat > "$agents_file" << EOF
# $tool_name Agent Capabilities

## Available Agents

### File Operations Agent
- File reading, writing, and editing
- Search and analysis capabilities

### Command Execution Agent
- Execute allowed commands
- Process automation

### Analysis Agent
- Code analysis and review
- Pattern recognition

This is a basic agents file created during verification.
Run a full sync for complete agent documentation.

Generated: $(date)
EOF
}

# Verify component files
verify_component_files() {
    local tool="$1"
    local component="$2"
    local issues=0

    case "$component" in
        "rules")
            verify_rules_files "$tool"
            issues=$?
            ;;
        "permissions")
            verify_permissions_files "$tool"
            issues=$?
            ;;
        "commands")
            verify_commands_files "$tool"
            issues=$?
            ;;
        "settings")
            verify_settings_files "$tool"
            issues=$?
            ;;
        "memory")
            verify_memory_files "$tool"
            issues=$?
            ;;
    esac

    return $issues
}

# Main verification function
run_verification() {
    local total_issues=0
    local total_fixes=0

    echo "# Configuration Sync Verification Report"
    echo "Generated: $(date)"
    echo "Target(s): $TARGET_LABEL"
    echo "Components: $COMPONENT_LABEL"
    echo ""

    local targets=($(get_targets))
    local components=($(get_components))

    for tool in "${targets[@]}"; do
        echo "## $tool Verification"
        echo ""

        local tool_issues=0

        # Installation verification
        verify_tool_installation "$tool"
        tool_issues=$((tool_issues + $?))

        # Structure verification
        verify_configuration_structure "$tool"
        tool_issues=$((tool_issues + $?))

        # Component verification
        for component in "${components[@]}"; do
            verify_component_files "$tool" "$component"
            tool_issues=$((tool_issues + $?))
        done

        # Summary for this tool
        if [[ $tool_issues -eq 0 ]]; then
            echo "✅ **$tool**: No issues found"
        else
            echo "❌ **$tool**: $tool_issues issue(s) found"
            if [[ "$FIX" == "true" ]]; then
                echo "🔧 **Fixes Applied**: Check individual component logs above"
            fi
        fi

        echo ""
        total_issues=$((total_issues + tool_issues))
    done

    # Overall summary
    echo "## Verification Summary"
    echo ""

    if [[ $total_issues -eq 0 ]]; then
        echo "🎉 **All checks passed!** Configuration synchronization is complete and correct."
    else
        echo "⚠️ **Issues Found**: $total_issues total issue(s)"
        if [[ "$FIX" == "true" ]]; then
            echo "🔧 **Auto-fix Applied**: Some issues may have been automatically resolved"
            echo "💡 **Recommendation**: Run verification again to check remaining issues"
        else
            echo "💡 **Recommendation**: Run with --fix flag to automatically resolve common issues"
        fi
    fi

    echo ""
    echo "## Next Steps"
    if [[ $total_issues -gt 0 ]]; then
        echo "1. Address remaining issues manually or run with --fix"
        echo "2. Run full sync for incomplete components: \`/config-sync:sync --target=all\`"
        echo "3. Test functionality in each target tool"
    else
        echo "1. Test synced configurations in target tools"
        echo "2. Customize configurations as needed"
        echo "3. Run regular verification after changes"
    fi

    return $total_issues
}

main() {
    parse_arguments "$@"

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting configuration verification for target(s): $TARGET_LABEL"

    # Run verification
    run_verification

    if [[ $? -eq 0 ]]; then
        log_success "Verification completed successfully - no issues found"
    else
        log_info "Verification completed with issues found"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
