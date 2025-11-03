#!/usr/bin/env bash

# Config-Sync Analysis Command
# Analyze target tool capabilities and configuration state

set -euo pipefail

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Default values
TARGET_SPEC=""
DETAILED=false
FORMAT="markdown"
VERBOSE=false

declare -a SELECTED_TARGETS=()
TARGET_LABEL=""

usage() {
    cat << EOF
Config-Sync Analysis Command - Analyze Target Tool Capabilities

USAGE:
    analyze.sh --target <droid,qwen,codex,opencode|all> [OPTIONS]

ARGUMENTS:
    --target <tool[,tool]>  Target tool(s) to analyze (required)

OPTIONS:
    --detailed             Include detailed analysis and recommendations
    --format <type>        Output format (json, markdown, table) - default: markdown
    --verbose              Enable detailed output
    --help                 Show this help message

FORMATS:
    markdown               Comprehensive readable report (default)
    table                  Compact summary with key metrics
    json                   Structured data for automation

EXAMPLES:
    analyze.sh --target=all
    analyze.sh --target=qwen --detailed
    analyze.sh --target=all --format=table

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
            --detailed)
                DETAILED=true
                shift
                ;;
            --format=*)
                FORMAT="${1#--format=}"
                shift
                ;;
            --format)
                FORMAT="$2"
                shift 2
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

    # Validate format
    if [[ ! "$FORMAT" =~ ^(json|markdown|table)$ ]]; then
        echo "Error: Invalid format '$FORMAT'. Must be json, markdown, or table" >&2
        exit 1
    fi

    if ! mapfile -t SELECTED_TARGETS < <(parse_target_list "$TARGET_SPEC"); then
        echo "Error: Invalid target selection '$TARGET_SPEC'" >&2
        exit 1
    fi

    TARGET_LABEL="$(join_by ',' "${SELECTED_TARGETS[@]}")"
}

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

# Get tool version
get_tool_version() {
    local tool="$1"
    if check_tool_installed "$tool"; then
        case "$tool" in
            "droid")
                "$tool" --version 2>/dev/null || echo "Unknown"
                ;;
            "qwen")
                "$tool" --version 2>/dev/null || echo "Unknown"
                ;;
            "codex")
                "$tool" --version 2>/dev/null || echo "Unknown"
                ;;
            "opencode")
                "$tool" --version 2>/dev/null || echo "Unknown"
                ;;
            *)
                echo "Unknown"
                ;;
        esac
    else
        echo "Not installed"
    fi
}

# Analyze tool installation
analyze_installation() {
    local tool="$1"

    local installed=false
    local version="Not installed"
    local path=""

    if check_tool_installed "$tool"; then
        installed=true
        version=$(get_tool_version "$tool")
        path=$(which "$tool")
    fi

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"installation\": {"
        echo "    \"installed\": $installed,"
        echo "    \"version\": \"$version\","
        echo "    \"path\": \"$path\""
        echo "  },"
    elif [[ "$FORMAT" == "table" ]]; then
        printf "%-10s | %-15s | %-20s\n" "$tool" "$(if [[ $installed == true ]]; then echo "✅ Yes"; else echo "❌ No"; fi)" "$version"
    else
        echo "### Installation Status"
        if [[ $installed == true ]]; then
            echo "- ✅ **Installed**: Yes"
            echo "- **Version**: $version"
            echo "- **Path**: $path"
        else
            echo "- ❌ **Installed**: No"
            echo "- **Version**: Not available"
            echo "- **Path**: Not found"
        fi
        echo
    fi
}

# Analyze configuration directories
analyze_config_directories() {
    local tool="$1"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local commands_dir
    commands_dir=$(get_tool_commands_dir "$tool")

    local config_exists=false
    local commands_exists=false
    local config_writable=false

    if [[ -d "$config_dir" ]]; then
        config_exists=true
        [[ -w "$config_dir" ]] && config_writable=true
    fi

    if [[ -d "$commands_dir" ]]; then
        commands_exists=true
    fi

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"directories\": {"
        echo "    \"config_dir\": \"$config_dir\","
        echo "    \"config_exists\": $config_exists,"
        echo "    \"config_writable\": $config_writable,"
        echo "    \"commands_dir\": \"$commands_dir\","
        echo "    \"commands_exists\": $commands_exists"
        echo "  },"
    elif [[ "$FORMAT" == "table" ]]; then
        printf "%-10s | %-15s | %-15s\n" "$tool" "$(if [[ $config_exists == true ]]; then echo "✅"; else echo "❌"; fi)" "$(if [[ $commands_exists == true ]]; then echo "✅"; else echo "❌"; fi)"
    else
        echo "### Configuration Directories"
        echo "- **Config Directory**: $config_dir"
        echo "- **Config Exists**: $(if [[ $config_exists == true ]]; then echo "✅ Yes"; else echo "❌ No"; fi)"
        echo "- **Config Writable**: $(if [[ $config_writable == true ]]; then echo "✅ Yes"; else echo "❌ No"; fi)"
        echo "- **Commands Directory**: $commands_dir"
        echo "- **Commands Exists**: $(if [[ $commands_exists == true ]]; then echo "✅ Yes"; else echo "❌ No"; fi)"
        echo
    fi
}

# Analyze configuration files
analyze_config_files() {
    local tool="$1"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local files=()
    local file_count=0

    case "$tool" in
        "droid")
            files=("settings.json" "config.json")
            ;;
        "qwen")
            files=("settings.json")
            ;;
        "codex")
            files=("config.toml")
            ;;
        "opencode")
            files=("opencode.json")
            ;;
    esac

    local existing_files=()
    local total_size=0

    for file in "${files[@]}"; do
        local file_path="$config_dir/$file"
        if [[ -f "$file_path" ]]; then
            existing_files+=("$file")
            local size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
            total_size=$((total_size + size))
        fi
    done

    file_count=${#existing_files[@]}

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"config_files\": {"
        echo "    \"expected_files\": [$(printf '"%s",' "${files[@]}" | sed 's/,$//')],"
        echo "    \"existing_files\": [$(printf '"%s",' "${existing_files[@]}" | sed 's/,$//')],"
        echo "    \"file_count\": $file_count,"
        echo "    \"total_size_bytes\": $total_size"
        echo "  },"
    elif [[ "$FORMAT" == "table" ]]; then
        printf "%-10s | %-15d | %-15d bytes\n" "$tool" "$file_count" "$total_size"
    else
        echo "### Configuration Files"
        echo "- **Expected Files**: ${files[*]}"
        echo "- **Existing Files**: ${existing_files[*]:-None}"
        echo "- **File Count**: $file_count/${#files[@]}"
        echo "- **Total Size**: $total_size bytes"

        if [[ $file_count -gt 0 ]]; then
            echo "- **Files Found**:"
            for file in "${existing_files[@]}"; do
                local file_path="$config_dir/$file"
                local size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
                echo "  - $file ($size bytes)"
            done
        fi
        echo
    fi
}

# Analyze component status
analyze_components() {
    local tool="$1"

    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    local commands_dir
    commands_dir=$(get_tool_commands_dir "$tool")

    local components=("rules" "commands" "settings" "memory")
    local component_status=()
    local present_total=0

    for component in "${components[@]}"; do
        local status="missing"
        local count=0

        case "$component" in
            "rules")
                local rules_dir="$config_dir/rules"
                if [[ -d "$rules_dir" ]]; then
                    count=$(find "$rules_dir" -name "*.md" -type f | wc -l)
                    if [[ $count -gt 0 ]]; then
                        status="present"
                    fi
                fi
                ;;
            "commands")
                if [[ -d "$commands_dir" ]]; then
                    case "$tool" in
                        "opencode")
                            count=$(find "$commands_dir" -name "*.md" -type f | wc -l)
                            ;;
                        "qwen")
                            count=$(find "$commands_dir" -name "*.toml" -type f | wc -l)
                            ;;
                        *)
                            count=$(find "$commands_dir" -name "*.md" -type f | wc -l)
                            ;;
                    esac
                    if [[ $count -gt 0 ]]; then
                        status="present"
                    fi
                fi
                ;;
            "settings")
                case "$tool" in
                    "droid")
                        if [[ -f "$config_dir/settings.json" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "qwen")
                        if [[ -f "$config_dir/settings.json" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "codex")
                        if [[ -f "$config_dir/config.toml" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "opencode")
                        if [[ -f "$config_dir/opencode.json" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                esac
                ;;
            "memory")
                case "$tool" in
                    "droid")
                        if [[ -f "$config_dir/DROID.md" ]] || [[ -f "$config_dir/AGENTS.md" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "qwen")
                        if [[ -f "$config_dir/QWEN.md" ]] || [[ -f "$config_dir/AGENTS.md" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "codex")
                        if [[ -f "$config_dir/memory.md" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                    "opencode")
                        if [[ -f "$config_dir/AGENTS.md" ]]; then
                            status="present"
                            count=1
                        fi
                        ;;
                esac
                ;;
        esac

        if [[ "$status" == "present" ]]; then
            ((present_total += 1))
        fi
        component_status+=("$component:$status:$count")
    done

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"components\": {"
        for comp_status in "${component_status[@]}"; do
            IFS=':' read -r component status count <<< "$comp_status"
            echo "    \"$component\": {"
            echo "      \"status\": \"$status\","
            echo "      \"count\": $count"
            echo "    },"
        done
        echo "    \"present_count\": $present_total,"
        echo "    \"total_count\": ${#components[@]}"
        echo "  },"
    elif [[ "$FORMAT" == "table" ]]; then
        printf "%-10s | %-15d / %-15d\n" "$tool" "$present_total" "${#components[@]}"
    else
        echo "### Component Status"
        for comp_status in "${component_status[@]}"; do
            IFS=':' read -r component status count <<< "$comp_status"
            local icon="❌"
            if [[ "$status" == "present" ]]; then
                icon="✅"
            fi
            echo "- **$component**: $icon $status ($count files)"
        done
        echo
    fi
}

# Analyze tool capabilities
analyze_capabilities() {
    local tool="$1"

    local file_format="Markdown"
    local permission_model="Unknown"
    local command_format="Markdown"

    case "$tool" in
        "droid")
            file_format="JSON"
            permission_model="Allowlist/Denylist"
            command_format="Markdown"
            ;;
        "qwen")
            file_format="JSON"
            permission_model="Trusted Prompts"
            command_format="TOML"
            ;;
        "codex")
            file_format="TOML"
            permission_model="Sandbox Levels"
            command_format="Markdown"
            ;;
        "opencode")
            file_format="JSON"
            permission_model="Operation-based"
            command_format="Markdown"
            ;;
    esac

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"capabilities\": {"
        echo "    \"file_format\": \"$file_format\","
        echo "    \"permission_model\": \"$permission_model\","
        echo "    \"command_format\": \"$command_format\""
        echo "  },"
    elif [[ "$FORMAT" == "table" ]]; then
        printf "%-10s | %-15s | %-20s | %-15s\n" "$tool" "$file_format" "$permission_model" "$command_format"
    else
        echo "### Tool Capabilities"
        echo "- **File Format**: $file_format"
        echo "- **Permission Model**: $permission_model"
        echo "- **Command Format**: $command_format"
        echo
    fi
}

# Generate recommendations
generate_recommendations() {
    local tool="$1"

    local recommendations=()

    # Check installation
    if ! check_tool_installed "$tool"; then
        recommendations+=("Install $tool CLI")
    fi

    # Check configuration directory
    local config_dir
    config_dir=$(get_tool_config_dir "$tool")
    if [[ ! -d "$config_dir" ]]; then
        recommendations+=("Create configuration directory: $config_dir")
    fi

    # Check basic sync status
    local sync_needed=false
    local config_dir
    config_dir=$(get_tool_config_dir "$tool")

    if [[ ! -d "$config_dir/rules" ]] || [[ -z "$(find "$config_dir/rules" -name "*.md" -type f 2>/dev/null)" ]]; then
        recommendations+=("Sync rules: /config-sync:sync --target=$tool --component=rules")
        sync_needed=true
    fi

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"recommendations\": [$(printf '"%s",' "${recommendations[@]}" | sed 's/,$//')],"
        echo "  \"sync_needed\": $sync_needed"
    elif [[ "$FORMAT" == "table" ]]; then
        if [[ $sync_needed == true ]]; then
            printf "%-10s | %-15s\n" "$tool" "Yes"
        else
            printf "%-10s | %-15s\n" "$tool" "No"
        fi
    else
        if [[ ${#recommendations[@]} -gt 0 ]]; then
            echo "### Recommendations"
            for recommendation in "${recommendations[@]}"; do
                echo "- $recommendation"
            done
            echo
        else
            echo "### Recommendations"
            echo "- ✅ Configuration looks good!"
            echo
        fi
    fi
}

# Analyze single tool
analyze_tool() {
    local tool="$1"

    if [[ "$FORMAT" == "json" ]]; then
        echo "  \"$tool\": {"
    elif [[ "$FORMAT" == "markdown" ]]; then
        echo "## $tool Analysis"
        echo
    fi

    analyze_installation "$tool"
    analyze_config_directories "$tool"
    analyze_config_files "$tool"
    analyze_components "$tool"

    if [[ "$DETAILED" == true ]]; then
        analyze_capabilities "$tool"
        generate_recommendations "$tool"
    fi

    if [[ "$FORMAT" == "json" ]]; then
        # Remove trailing comma
        sed -i '' '$s/,$//' <<< "$(tail -n 1 <<< "$(echo "  \"capabilities\": {")")" 2>/dev/null || true
        echo "  }"
    elif [[ "$FORMAT" == "markdown" ]]; then
        echo "---"
        echo
    fi
}

# Generate table header
generate_table_header() {
    case "$1" in
        "installation")
            printf "%-10s | %-15s | %-20s\n" "Tool" "Installed" "Version"
            printf "%-10s-+-%-15s-+-%-20s\n" "----------" "---------------" "--------------------"
            ;;
        "directories")
            printf "%-10s | %-15s | %-15s\n" "Tool" "Config" "Commands"
            printf "%-10s-+-%-15s-+-%-15s\n" "----------" "---------------" "---------------"
            ;;
        "config_files")
            printf "%-10s | %-15s | %-15s\n" "Tool" "File Count" "Size"
            printf "%-10s-+-%-15s-+-%-15s\n" "----------" "---------------" "---------------"
            ;;
        "components")
            printf "%-10s | %-15s | %-15s\n" "Tool" "Present" "Total"
            printf "%-10s-+-%-15s-+-%-15s\n" "----------" "---------------" "---------------"
            ;;
        "capabilities")
            printf "%-10s | %-15s | %-20s | %-15s\n" "Tool" "File Format" "Permission Model" "Command Format"
            printf "%-10s-+-%-15s-+-%-20s-+-%-15s\n" "----------" "---------------" "--------------------" "---------------"
            ;;
        "recommendations")
            printf "%-10s | %-15s\n" "Tool" "Sync Needed"
            printf "%-10s-+-%-15s\n" "----------" "---------------"
            ;;
    esac
}

# Main analysis function
run_analysis() {
    local targets=("${SELECTED_TARGETS[@]}")

    if [[ "$FORMAT" == "json" ]]; then
        echo "{"
        echo "  \"analysis_timestamp\": \"$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")\","
        echo "  \"target\": \"$TARGET_LABEL\","
        echo "  \"detailed\": $DETAILED,"
        echo "  \"tools\": {"

        for i in "${!targets[@]}"; do
            analyze_tool "${targets[i]}"
            if [[ $i -lt $((${#targets[@]} - 1)) ]]; then
                echo ","
            fi
        done

        echo "  }"
        echo "}"
    elif [[ "$FORMAT" == "table" ]]; then
        echo "# Configuration Sync Analysis - Table Format"
        echo "Generated: $(date)"
        echo "Target: $TARGET_LABEL"
        echo

        if [[ "$DETAILED" == true ]]; then
            echo "## Installation Status"
            generate_table_header "installation"
            for tool in "${targets[@]}"; do
                analyze_installation "$tool"
            done
            echo

            echo "## Directory Status"
            generate_table_header "directories"
            for tool in "${targets[@]}"; do
                analyze_config_directories "$tool"
            done
            echo

            echo "## Configuration Files"
            generate_table_header "config_files"
            for tool in "${targets[@]}"; do
                analyze_config_files "$tool"
            done
            echo

            echo "## Component Status"
            generate_table_header "components"
            for tool in "${targets[@]}"; do
                analyze_components "$tool"
            done
            echo

            echo "## Tool Capabilities"
            generate_table_header "capabilities"
            for tool in "${targets[@]}"; do
                analyze_capabilities "$tool"
            done
            echo

            echo "## Recommendations"
            generate_table_header "recommendations"
            for tool in "${targets[@]}"; do
                generate_recommendations "$tool"
            done
        else
            printf "%-10s | %-15s | %-15s | %-15s | %-15s\n" "Tool" "Installed" "Config Dir" "Commands" "Components"
            printf "%-10s-+-%-15s-+-%-15s-+-%-15s-+-%-15s\n" "----------" "---------------" "---------------" "---------------" "---------------"

            for tool in "${targets[@]}"; do
                local installed="❌"
                if check_tool_installed "$tool"; then
                    installed="✅"
                fi

                local config_dir
                config_dir=$(get_tool_config_dir "$tool")
                local config_status="❌"
                if [[ -d "$config_dir" ]]; then
                    config_status="✅"
                fi

                local commands_dir
                commands_dir=$(get_tool_commands_dir "$tool")
                local commands_status="❌"
                if [[ -d "$commands_dir" ]]; then
                    commands_status="✅"
                fi

                local component_count=0
                if [[ -d "$config_dir/rules" ]]; then
                    component_count=$((component_count + 1))
                fi
                if [[ -d "$commands_dir" ]]; then
                    component_count=$((component_count + 1))
                fi

                printf "%-10s | %-15s | %-15s | %-15s | %-15d/4\n" "$tool" "$installed" "$config_status" "$commands_status" "$component_count"
            done
        fi
    else
        echo "# Configuration Sync Analysis Report"
        echo "Generated: $(date)"
        echo "Target: $TARGET_LABEL"
        echo "Detailed: $DETAILED"
        echo

        for tool in "${targets[@]}"; do
            analyze_tool "$tool"
        done

        echo "## Summary"
        echo "This analysis provides an overview of your CLI tool configurations and synchronization status."
        echo "Use `/config-sync:sync` to synchronize configurations and `/config-sync:verify` to validate setup."
    fi
}


main() {
    parse_arguments "$@"

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

    log_info "Starting configuration analysis for target(s): $TARGET_LABEL"

    # Run analysis
    run_analysis

    log_success "Analysis completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
