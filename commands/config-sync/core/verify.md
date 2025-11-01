---
name: "config-sync:verify"
description: Verify configuration sync completeness and correctness
argument-hint: --target=<droid|qwen|codex|opencode|all> [--component=<rules|permissions|commands|settings|memory|all>] [--detailed] [--fix]
---

# Config-Sync Verify Command

## Task
Comprehensively verify that configuration synchronization was successful and complete for the target tool(s), with optional automatic fixing of common issues.

## Usage
```bash
/config-sync:verify --target=<tool|all> [options]
```

### Arguments
- `--target`: Target tool (droid, qwen, codex, opencode) or "all"
- `--component`: Specific component to verify (optional, defaults to all)
- `--detailed`: Include detailed verification and recommendations
- `--fix`: Attempt to automatically fix common issues found

## Implementation

### 1. Parse Arguments and Setup
```bash
# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Parse arguments
TARGET=""
COMPONENT=""
DETAILED=false
FIX=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --target=*)
            TARGET="${1#*=}"
            ;;
        --component=*)
            COMPONENT="${1#*=}"
            ;;
        --detailed)
            DETAILED=true
            ;;
        --fix)
            FIX=true
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Validate target
if [[ "$TARGET" == "all" ]]; then
    TARGETS=("droid" "qwen" "codex" "opencode")
else
    validate_target "$TARGET" || exit 1
    TARGETS=("$TARGET")
fi

# Set component list
if [[ -n "$COMPONENT" ]]; then
    validate_component "$COMPONENT" || exit 1
    COMPONENTS=("$COMPONENT")
else
    COMPONENTS=("rules" "permissions" "commands" "settings" "memory")
fi

# Initialize verification environment
setup_plugin_environment
```

### 2. Verification Functions

### verify_tool_installation()
Verify tool is installed and accessible
```bash
verify_tool_installation() {
    local tool="$1"
    local issues=()

    if check_tool_installed "$tool"; then
        log_info "✅ $tool is installed and accessible"
    else
        issues+=("Tool not installed or not in PATH")
        if [[ "$FIX" == "true" ]]; then
            issues+=("Cannot fix automatically - tool installation required")
        fi
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_error "❌ Installation issues for $tool:"
        for issue in "${issues[@]}"; do
            log_error "   - $issue"
        done
        return 1
    fi

    return 0
}
```

### verify_configuration_structure()
Verify configuration directory structure
```bash
verify_configuration_structure() {
    local tool="$1"
    local issues=()
    local fixes=()

    local config_dir
    config_dir=$(get_target_config_dir "$tool")

    if [[ ! -d "$config_dir" ]]; then
        issues+=("Configuration directory not found: $config_dir")
        if [[ "$FIX" == "true" ]]; then
            mkdir -p "$config_dir"
            fixes+=("Created configuration directory")
        fi
    else
        log_info "✅ Configuration directory exists: $config_dir"

        # Check if directory is writable
        if [[ ! -w "$config_dir" ]]; then
            issues+=("Configuration directory not writable")
            if [[ "$FIX" == "true" ]]; then
                chmod u+w "$config_dir"
                fixes+=("Made configuration directory writable")
            fi
        fi
    fi

    # Check subdirectories
    local subdirs=("rules" "commands")
    for subdir in "${subdirs[@]}"; do
        local subdir_path
        case "$subdir" in
            "rules")
                subdir_path=$(get_target_rules_dir "$tool")
                ;;
            "commands")
                subdir_path=$(get_target_commands_dir "$tool")
                ;;
        esac

        if [[ ! -d "$subdir_path" ]]; then
            issues+=("Subdirectory not found: $subdir_path")
            if [[ "$FIX" == "true" ]]; then
                mkdir -p "$subdir_path"
                fixes+=("Created $subdir directory")
            fi
        else
            log_info "✅ $subdir directory exists: $subdir_path"
        fi
    done

    # Apply fixes if requested
    if [[ ${#fixes[@]} -gt 0 ]]; then
        log_info "🔧 Applied fixes for $tool:"
        for fix in "${fixes[@]}"; do
            log_info "   - $fix"
        done
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_error "❌ Structure issues for $tool:"
        for issue in "${issues[@]}"; do
            log_error "   - $issue"
        done
        return 1
    fi

    return 0
}
```

### verify_component_files()
Verify specific component files
```bash
verify_component_files() {
    local tool="$1"
    local component="$2"
    local issues=()
    local fixes=()

    case "$component" in
        "rules")
            verify_rules_files "$tool" issues fixes
            ;;
        "permissions")
            verify_permissions_files "$tool" issues fixes
            ;;
        "commands")
            verify_commands_files "$tool" issues fixes
            ;;
        "settings")
            verify_settings_files "$tool" issues fixes
            ;;
        "memory")
            verify_memory_files "$tool" issues fixes
            ;;
    esac

    # Apply fixes if requested
    if [[ ${#fixes[@]} -gt 0 ]]; then
        log_info "🔧 Applied fixes for $tool:$component:"
        for fix in "${fixes[@]}"; do
            log_info "   - $fix"
        done
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_error "❌ $component issues for $tool:"
        for issue in "${issues[@]}"; do
            log_error "   - $issue"
        done
        return 1
    fi

    return 0
}
```

### verify_rules_files()
Verify rules synchronization
```bash
verify_rules_files() {
    local tool="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local rules_dir
    rules_dir=$(get_target_rules_dir "$tool")

    if [[ ! -d "$rules_dir" ]]; then
        issues_ref+=("Rules directory does not exist")
        return 1
    fi

    # Check for rule files
    local rule_files=("$rules_dir"/*.md)
    if [[ ! -f "${rule_files[0]}" ]]; then
        issues_ref+=("No rule files found")
        if [[ "$FIX" == "true" ]] && [[ -d "$CLAUDE_RULES_DIR" ]]; then
            # Copy basic rule files
            local copied=0
            for rule_file in "$CLAUDE_RULES_DIR"/*.md; do
                [[ -f "$rule_file" ]] || continue
                cp "$rule_file" "$rules_dir/"
                ((copied++))
            done
            if [[ $copied -gt 0 ]]; then
                fixes_ref+=("Copied $copied rule files from Claude")
            fi
        fi
    else
        local rule_count=$(ls "$rules_dir"/*.md 2>/dev/null | wc -l)
        log_info "✅ Found $rule_count rule files"

        # Check rule file content
        if [[ "$DETAILED" == "true" ]]; then
            for rule_file in "$rules_dir"/*.md; do
                [[ -f "$rule_file" ]] || continue

                # Check for adaptation header
                if ! grep -q "Adapted Rule" "$rule_file"; then
                    issues_ref+=("Rule $(basename "$rule_file") may not be properly adapted")
                fi

                # Check for tool-specific references
                if grep -q "CLAUDE.md" "$rule_file"; then
                    issues_ref+=("Rule $(basename "$rule_file") contains Claude references")
                    if [[ "$FIX" == "true" ]]; then
                        sed -i '' 's/CLAUDE.md/AGENTS.md/g' "$rule_file"
                        fixes_ref+=("Updated tool references in $(basename "$rule_file")")
                    fi
                fi
            done
        fi
    fi
}
```

### verify_permissions_files()
Verify permissions configuration
```bash
verify_permissions_files() {
    local tool="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_dir
    config_dir=$(get_target_config_dir "$tool")

    case "$tool" in
        "droid")
            verify_droid_permissions "$config_dir" issues_ref fixes_ref
            ;;
        "qwen")
            verify_qwen_permissions "$config_dir" issues_ref fixes_ref
            ;;
        "codex")
            verify_codex_permissions "$config_dir" issues_ref fixes_ref
            ;;
        "opencode")
            verify_opencode_permissions "$config_dir" issues_ref fixes_ref
            ;;
    esac
}
```

### verify_droid_permissions()
Verify Droid permissions configuration
```bash
verify_droid_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local settings_file="$config_dir/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        issues_ref+=("Droid settings.json not found")
        if [[ "$FIX" == "true" ]]; then
            # Create basic settings file
            cat > "$settings_file" << 'JSON'
{
  "commandAllowlist": [
    "read", "write", "edit", "search", "analyze", "list", "help", "status"
  ],
  "commandDenylist": [
    "rm", "sudo", "chmod", "chown", "dd", "mkfs", "reboot", "shutdown"
  ],
  "model": "claude-sonnet-4-5-20250929",
  "autonomy": "balanced"
}
JSON
            fixes_ref+=("Created basic Droid settings.json")
        fi
    else
        # Validate JSON syntax
        if ! python3 -m json.tool "$settings_file" > /dev/null 2>&1; then
            issues_ref+=("Invalid JSON syntax in settings.json")
        else
            # Check for required fields
            if ! jq -e '.commandAllowlist' "$settings_file" > /dev/null 2>&1; then
                issues_ref+=("Missing commandAllowlist in settings.json")
            fi
            if ! jq -e '.commandDenylist' "$settings_file" > /dev/null 2>&1; then
                issues_ref+=("Missing commandDenylist in settings.json")
            fi
        fi
    fi
}
```

### verify_qwen_permissions()
Verify Qwen permissions documentation
```bash
verify_qwen_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local permissions_file="$config_dir/PERMISSIONS.md"

    if [[ ! -f "$permissions_file" ]]; then
        issues_ref+=("Qwen permissions documentation not found")
        if [[ "$FIX" == "true" ]]; then
            cat > "$permissions_file" << 'MARKDOWN'
# Qwen CLI Permissions

Qwen CLI does not have a formal permission system like Claude Code.
It operates with the same permissions as the user account.

## Security Features
- Shell execution requires user confirmation
- File access respects user file system permissions
- Optional sandbox mode can be applied
MARKDOWN
            fixes_ref+=("Created Qwen permissions documentation")
        fi
    fi
}
```

### verify_codex_permissions()
Verify Codex sandbox configuration
```bash
verify_codex_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_file="$config_dir/config.toml"

    if [[ ! -f "$config_file" ]]; then
        issues_ref+=("Codex config.toml not found")
        if [[ "$FIX" == "true" ]]; then
            cat > "$config_file" << 'TOML'
[api]
base_url = "https://api.openai.com/v1"

[sandbox]
mode = "workspace-write"
allow_network = true
allow_execution = true

[sync]
source = "claude-code-sync"
TOML
            fixes_ref+=("Created basic Codex config.toml")
        fi
    else
        # Check for sandbox configuration
        if ! grep -q "\[sandbox\]" "$config_file"; then
            issues_ref+=("Missing sandbox configuration")
            if [[ "$FIX" == "true" ]]; then
                echo -e "\n[sandbox]\nmode = \"workspace-write\"" >> "$config_file"
                fixes_ref+=("Added sandbox configuration")
            fi
        fi
    fi
}
```

### verify_opencode_permissions()
Verify OpenCode operation permissions
```bash
verify_opencode_permissions() {
    local config_dir="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_file="$config_dir/opencode.json"

    if [[ ! -f "$config_file" ]]; then
        issues_ref+=("OpenCode opencode.json not found")
        if [[ "$FIX" == "true" ]]; then
            cat > "$config_file" << 'JSON'
{
  "permissions": {
    "edit": { "enabled": true, "scope": ["workspace"] },
    "bash": { "enabled": true, "confirmation": "destructive-operations" },
    "webfetch": { "enabled": true, "confirmation": "external-domains" }
  },
  "sync": { "source": "claude-code" }
}
JSON
            fixes_ref+=("Created basic OpenCode opencode.json")
        fi
    else
        # Validate JSON and check for permissions
        if ! python3 -m json.tool "$config_file" > /dev/null 2>&1; then
            issues_ref+=("Invalid JSON syntax in opencode.json")
        else
            if ! jq -e '.permissions' "$config_file" > /dev/null 2>&1; then
                issues_ref+=("Missing permissions configuration")
            fi
        fi
    fi
}
```

### verify_commands_files()
Verify command synchronization
```bash
verify_commands_files() {
    local tool="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local commands_dir
    commands_dir=$(get_target_commands_dir "$tool")

    if [[ ! -d "$commands_dir" ]]; then
        issues_ref+=("Commands directory does not exist")
        return 1
    fi

    # Check for command files
    local cmd_files=("$commands_dir"/*)
    if [[ ! -f "${cmd_files[0]}" ]]; then
        issues_ref+=("No command files found")
        if [[ "$FIX" == "true" ]] && [[ -d "$CLAUDE_COMMANDS_DIR" ]]; then
            # Copy and adapt commands based on tool requirements
            local copied=0
            for cmd_file in "$CLAUDE_COMMANDS_DIR"/*.md; do
                [[ -f "$cmd_file" ]] || continue

                local cmd_name=$(basename "$cmd_file" .md)
                local target_file="$commands_dir/$cmd_name"

                case "$tool" in
                    "droid")
                        cp "$cmd_file" "$target_file.md"
                        ;;
                    "qwen")
                        # Simple conversion to TOML
                        convert_simple_markdown_to_toml "$cmd_file" "$target_file.toml"
                        ;;
                    "codex"|"opencode")
                        cp "$cmd_file" "$target_file.md"
                        ;;
                esac
                ((copied++))
            done
            if [[ $copied -gt 0 ]]; then
                fixes_ref+=("Copied and adapted $copied command files")
            fi
        fi
    else
        local cmd_count=$(find "$commands_dir" -type f | wc -l)
        log_info "✅ Found $cmd_count command files"

        # Validate command formats based on tool
        if [[ "$DETAILED" == "true" ]]; then
            validate_command_formats "$tool" "$commands_dir" issues_ref fixes_ref
        fi
    fi
}
```

### validate_command_formats()
Validate command file formats
```bash
validate_command_formats() {
    local tool="$1"
    local commands_dir="$2"
    local -n issues_ref=$3
    local -n fixes_ref=$4

    case "$tool" in
        "droid")
            # Check for proper frontmatter
            for cmd_file in "$commands_dir"/*.md; do
                [[ -f "$cmd_file" ]] || continue
                if ! grep -q "^---" "$cmd_file"; then
                    issues_ref+=("Command $(basename "$cmd_file") missing frontmatter")
                fi
            done
            ;;
        "qwen")
            # Check for proper TOML format
            for cmd_file in "$commands_dir"/*.toml; do
                [[ -f "$cmd_file" ]] || continue
                if ! grep -q "^prompt = " "$cmd_file"; then
                    issues_ref+=("Command $(basename "$cmd_file") missing prompt field")
                fi
            done
            ;;
        "opencode")
            # Check for JSON format
            for cmd_file in "$commands_dir"/*.json; do
                [[ -f "$cmd_file" ]] || continue
                if ! python3 -m json.tool "$cmd_file" > /dev/null 2>&1; then
                    issues_ref+=("Command $(basename "$cmd_file") has invalid JSON")
                fi
            done
            ;;
    esac
}
```

### verify_settings_files()
Verify settings configuration
```bash
verify_settings_files() {
    local tool="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_dir
    config_dir=$(get_target_config_dir "$tool")

    case "$tool" in
        "droid")
            if [[ ! -f "$config_dir/config.json" ]]; then
                issues_ref+=("Droid config.json not found")
                if [[ "$FIX" == "true" ]]; then
                    echo '{}' > "$config_dir/config.json"
                    fixes_ref+=("Created basic Droid config.json")
                fi
            fi
            ;;
        "qwen")
            if [[ ! -f "$config_dir/settings.json" ]]; then
                issues_ref+=("Qwen settings.json not found")
                if [[ "$FIX" == "true" ]]; then
                    echo '{}' > "$config_dir/settings.json"
                    fixes_ref+=("Created basic Qwen settings.json")
                fi
            fi
            ;;
        "codex")
            # Already handled in permissions verification
            ;;
        "opencode")
            if [[ ! -f "$config_dir/user-settings.json" ]]; then
                issues_ref+=("OpenCode user-settings.json not found")
                if [[ "$FIX" == "true" ]]; then
                    echo '{}' > "$config_dir/user-settings.json"
                    fixes_ref+=("Created basic OpenCode user-settings.json")
                fi
            fi
            ;;
    esac
}
```

### verify_memory_files()
Verify memory file generation
```bash
verify_memory_files() {
    local tool="$1"
    local -n issues_ref=$2
    local -n fixes_ref=$3

    local config_dir
    config_dir=$(get_target_config_dir "$tool")

    case "$tool" in
        "droid")
            if [[ ! -f "$config_dir/DROID.md" ]]; then
                issues_ref+=("DROID.md memory file not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_memory_file "$tool" "$config_dir/DROID.md"
                    fixes_ref+=("Created DROID.md")
                fi
            fi
            if [[ ! -f "$config_dir/AGENTS.md" ]]; then
                issues_ref+=("AGENTS.md not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_agents_file "$tool" "$config_dir/AGENTS.md"
                    fixes_ref+=("Created AGENTS.md")
                fi
            fi
            ;;
        "qwen")
            if [[ ! -f "$config_dir/QWEN.md" ]]; then
                issues_ref+=("QWEN.md memory file not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_memory_file "$tool" "$config_dir/QWEN.md"
                    fixes_ref+=("Created QWEN.md")
                fi
            fi
            if [[ ! -f "$config_dir/AGENTS.md" ]]; then
                issues_ref+=("AGENTS.md not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_agents_file "$tool" "$config_dir/AGENTS.md"
                    fixes_ref+=("Created AGENTS.md")
                fi
            fi
            ;;
        "codex")
            if [[ ! -f "$config_dir/CODEX.md" ]]; then
                issues_ref+=("CODEX.md memory file not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_memory_file "$tool" "$config_dir/CODEX.md"
                    fixes_ref+=("Created CODEX.md")
                fi
            fi
            ;;
        "opencode")
            if [[ ! -f "$config_dir/AGENTS.md" ]]; then
                issues_ref+=("AGENTS.md not found")
                if [[ "$FIX" == "true" ]]; then
                    create_basic_agents_file "$tool" "$config_dir/AGENTS.md"
                    fixes_ref+=("Created AGENTS.md")
                fi
            fi
            ;;
    esac
}
```

### create_basic_memory_file()
Create basic memory file for tool
```bash
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
```

### create_basic_agents_file()
Create basic AGENTS.md file
```bash
create_basic_agents_file() {
    local tool="$1"
    local agents_file="$2"

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
```

### 3. Main Verification Loop
```bash
echo "# Configuration Sync Verification Report"
echo "Generated: $(date)"
echo "Target(s): ${TARGETS[*]}"
echo "Components: ${COMPONENTS[*]}"
echo ""

local total_issues=0
local total_fixes=0

for tool in "${TARGETS[@]}"; do
    echo "## $tool Verification"
    echo ""

    local tool_issues=0
    local tool_fixes=0

    # Installation verification
    if ! verify_tool_installation "$tool"; then
        ((tool_issues++))
    fi

    # Structure verification
    if ! verify_configuration_structure "$tool"; then
        ((tool_issues++))
    fi

    # Component verification
    for component in "${COMPONENTS[@]}"; do
        if ! verify_component_files "$tool" "$component"; then
            ((tool_issues++))
        fi
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
    ((total_issues += tool_issues))
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
```

## Error Handling

### Verification Errors
- Missing directories or files
- Invalid file formats (JSON/TOML)
- Permission issues
- Configuration inconsistencies

### Auto-Fix Capabilities
- Create missing directories
- Generate basic configuration files
- Fix file permissions
- Update tool references
- Create missing memory/agents files

## Integration

This command integrates with:
- `lib/common.sh` - Shared utilities and validation
- `config-sync.md` - Main sync command
- Tool-specific adapter functions

## Examples

### Verify all tools
```bash
/config-sync:verify --target=all
```

### Detailed verification with auto-fix
```bash
/config-sync:verify --target=all --detailed --fix
```

### Verify specific component
```bash
/config-sync:verify --target=droid --component=permissions
```