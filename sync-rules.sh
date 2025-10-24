#!/usr/bin/env bash
# Claude Rules Sync Script - Sync common rules and project rules to various AI tools
# Usage: ./sync-rules.sh

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source directories
GENERAL_RULES_DIR="$HOME/.claude/rules"
PROJECT_RULES_DIR="${PROJECT_ROOT}/.claude/rules"
# Documentation files to sync
DOCUMENTATION_FILES=("$HOME/.claude/README.md" "$HOME/.claude/docs/permissions.md")

# Target directories
CURSOR_ROOT_DIR="${PROJECT_ROOT}/.cursor"
CURSOR_RULES_DIR="${CURSOR_ROOT_DIR}/rules"
COPILOT_ROOT_DIR="${PROJECT_ROOT}/.github"
COPILOT_INSTRUCTIONS_DIR="${COPILOT_ROOT_DIR}/instructions"
KIRO_ROOT_DIR="${PROJECT_ROOT}/.kiro"
KIRO_STEERING_DIR="${KIRO_ROOT_DIR}/steering"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Create directory
create_directory() {
    local dir="$1"
    local description="$2"

    if [[ ! -d "$dir" ]]; then
        log_info "Creating $description: $dir"
        mkdir -p "$dir"
        log_success "Created $description"
    else
        log_info "$description already exists: $dir"
    fi
}

# Clean all files in target directory
cleanup_target_directory() {
    local target_dir="$1"
    local tool_name="$2"

    if [[ ! -d "$target_dir" ]]; then
        return 0
    fi

    # Use find to locate and remove all .md files
    local file_count
    file_count=$(find "$target_dir" -name "*.md" -type f 2>/dev/null | wc -l)
    file_count=${file_count:-0}
    if [[ $file_count -eq 0 ]]; then
        log_info "No files to clean in $tool_name directory"
        return 0
    fi

    log_info "Cleaning $file_count files from $tool_name directory..."

    # Remove files using find -delete, which is more reliable
    local removed_count
    removed_count=$(find "$target_dir" -name "*.md" -type f -delete -print 2>/dev/null | wc -l)
    removed_count=${removed_count:-0}

    if [[ $removed_count -gt 0 ]]; then
        log_success "Cleaned $removed_count files from $tool_name"
    else
        log_warning "No files were removed from $tool_name directory"
    fi
}

# Check rule files
check_rule_files() {
    log_info "Checking rule files..."

    # Check general rules
    if [[ ! -d "$GENERAL_RULES_DIR" ]]; then
        log_error "General rules directory not found: $GENERAL_RULES_DIR"
        log_info "Please run ./docs/setup.sh first to install general rules"
        return 1
    fi

    local general_rule_count
    general_rule_count=$(find "$GENERAL_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    general_rule_count=${general_rule_count:-0}
    if [[ $general_rule_count -eq 0 ]]; then
        log_warning "No general rule files found in $GENERAL_RULES_DIR"
    else
        log_success "Found $general_rule_count general rule files"
    fi

    # Check project rules
    if [[ ! -d "$PROJECT_RULES_DIR" ]]; then
        log_warning "Project rules directory not found: $PROJECT_RULES_DIR"
        log_info "Project-specific rules will not be synced"
    else
        local project_rule_count
        project_rule_count=$(find "$PROJECT_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
        project_rule_count=${project_rule_count:-0}
        if [[ $project_rule_count -eq 0 ]]; then
            log_warning "No project rule files found in $PROJECT_RULES_DIR"
        else
            log_success "Found $project_rule_count project rule files"
        fi
    fi

    return 0
}

# AI Tools configuration - tool_name -> (rules_dir, root_dir)
declare -A AI_TOOLS_RULES
declare -A AI_TOOLS_ROOT
AI_TOOLS_RULES["cursor"]="${CURSOR_RULES_DIR}"
AI_TOOLS_ROOT["cursor"]="${CURSOR_ROOT_DIR}"
AI_TOOLS_RULES["copilot"]="${COPILOT_INSTRUCTIONS_DIR}"
AI_TOOLS_ROOT["copilot"]="${COPILOT_ROOT_DIR}"
AI_TOOLS_RULES["kiro"]="${KIRO_STEERING_DIR}"
AI_TOOLS_ROOT["kiro"]="${KIRO_ROOT_DIR}"

# Generic sync function for any AI tool
sync_to_tool() {
    local tool_name="$1"
    local rules_dir="${AI_TOOLS_RULES[$tool_name]}"
    local root_dir="${AI_TOOLS_ROOT[$tool_name]}"
    local display_name="$(capitalize "$tool_name")"

    if [[ -z "$rules_dir" ]] || [[ -z "$root_dir" ]]; then
        log_error "Unknown tool: $tool_name"
        return 1
    fi

    log_info "Syncing rules to $display_name..."

    # Create and clean target directories
    create_directory "$root_dir" "$display_name root directory"
    create_directory "$rules_dir" "$display_name rules directory"
    cleanup_target_directory "$rules_dir" "$display_name"

    # Process all rule files (general + project)
    local total_files=0
    for source_dir in "$GENERAL_RULES_DIR" "$PROJECT_RULES_DIR"; do
        if [[ -d "$source_dir" ]]; then
            for rule_file in "$source_dir"/*.md; do
                [[ -f "$rule_file" ]] || continue
                local basename=$(basename "$rule_file" .md)
                local target_file="${rules_dir}/${basename}.md"

                # Use cp with explicit error handling
                if cp "$rule_file" "$target_file"; then
                    total_files=$((total_files + 1))
                else
                    local exit_code=$?
                    log_error "Failed to sync rule file: $rule_file -> $target_file (exit code: $exit_code)"
                    # Don't exit the script, just continue with next file
                    continue
                fi
            done
        fi
    done

    # Process documentation files if they exist (sync to root directory)
    for doc_file in "${DOCUMENTATION_FILES[@]}"; do
        if [[ -f "$doc_file" ]]; then
            local basename=$(basename "$doc_file")
            local target_doc="${root_dir}/${basename}"

            # Use cp with explicit error handling
            if cp "$doc_file" "$target_doc"; then
                total_files=$((total_files + 1))
            else
                local exit_code=$?
                log_error "Failed to sync documentation file: $doc_file -> $target_doc (exit code: $exit_code)"
                # Don't exit the script, just continue with next file
                continue
            fi
        fi
    done

    log_success "$display_name: $total_files files synced"
}

# Helper function to capitalize tool name
capitalize() {
    echo "$(tr '[:lower:]' '[:upper:]' <<< "${1:0:1}")${1:1}"
}


# Verify sync results
verify_sync() {
    echo ""
    echo "🔍 Verification results:"

    local total_files=0

    for tool_name in "${!AI_TOOLS_RULES[@]}"; do
        local rules_dir="${AI_TOOLS_RULES[$tool_name]}"
        local root_dir="${AI_TOOLS_ROOT[$tool_name]}"
        local display_name="$(capitalize "$tool_name")"

        local count=0
        local rules_count=0
        local root_count=0

        # Count files in both rules directory and root directory
        if [[ -d "$rules_dir" ]]; then
            rules_count=$(find "$rules_dir" -name "*.md" -type f 2>/dev/null | wc -l)
            rules_count=${rules_count:-0}
        fi
        if [[ -d "$root_dir" ]]; then
            root_count=$(find "$root_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
            root_count=${root_count:-0}
        fi
        count=$((rules_count + root_count))

        echo "  • $display_name: $count files"
        total_files=$((total_files + count))
    done

    echo ""
    if [[ $total_files -gt 0 ]]; then
        echo "🎉 Sync completed! Total: $total_files files"
        echo "📁 Sources: $GENERAL_RULES_DIR, $PROJECT_RULES_DIR"
        echo "📝 Documentation: $(printf "%s, " "${DOCUMENTATION_FILES[@]}" | sed 's/, $//')"
        echo "🔄 Re-sync: $0"
        return 0
    else
        echo "❌ Sync failed - no files found"
        return 1
    fi
}

# Check runtime environment
check_run_environment() {
    # If script is located in ~/.claude, need to check if current working directory is a project directory
    if [[ "$SCRIPT_DIR" == "$HOME/.claude" ]]; then
        local current_dir="$(pwd)"

        # Check if current directory has project characteristics
        if [[ -f "$current_dir/.claude/rules/project.md" ]] || [[ -d "$current_dir/.cursor/rules" ]] || [[ -d "$current_dir/.github/instructions" ]] || [[ -d "$current_dir/.kiro/steering" ]]; then
            log_warning "Running global script from project directory"
            log_info "Project detected: $current_dir"
            # Reset project root directory to current directory
            PROJECT_ROOT="$current_dir"
            PROJECT_RULES_DIR="${PROJECT_ROOT}/.claude/rules"
            CURSOR_ROOT_DIR="${PROJECT_ROOT}/.cursor"
            CURSOR_RULES_DIR="${CURSOR_ROOT_DIR}/rules"
            COPILOT_ROOT_DIR="${PROJECT_ROOT}/.github"
            COPILOT_INSTRUCTIONS_DIR="${COPILOT_ROOT_DIR}/instructions"
            KIRO_ROOT_DIR="${PROJECT_ROOT}/.kiro"
            KIRO_STEERING_DIR="${KIRO_ROOT_DIR}/steering"

            # Update AI tools configuration
            AI_TOOLS_RULES["cursor"]="${CURSOR_RULES_DIR}"
            AI_TOOLS_ROOT["cursor"]="${CURSOR_ROOT_DIR}"
            AI_TOOLS_RULES["copilot"]="${COPILOT_INSTRUCTIONS_DIR}"
            AI_TOOLS_ROOT["copilot"]="${COPILOT_ROOT_DIR}"
            AI_TOOLS_RULES["kiro"]="${KIRO_STEERING_DIR}"
            AI_TOOLS_ROOT["kiro"]="${KIRO_ROOT_DIR}"
            return 0
        else
            log_error "Not in a project directory"
            log_error "Current directory: $current_dir"
            log_error ""
            log_error "When running ~/.claude/sync-rules.sh, you must be in a project directory"
            log_error ""
            log_error "Usage options:"
            log_error "  1. cd /path/to/your/project && ~/.claude/sync-rules.sh"
            log_error "  2. Copy script to project: cp ~/.claude/sync-rules.sh /path/to/project/.claude/"
            log_error "  3. Run from project: cd /path/to/project/.claude && ./sync-rules.sh"
            exit 1
        fi
    fi

    # Check if it would pollute ~/.claude directory
    if [[ "$PROJECT_ROOT" == "$HOME/.claude" ]]; then
        log_error "Cannot run sync script - would pollute ~/.claude directory"
        log_error "PROJECT_ROOT would be set to: $PROJECT_ROOT"
        log_error ""
        log_error "Please copy the script to your project's .claude/ directory:"
        log_error "  cp ~/.claude/sync-rules.sh /path/to/your/project/.claude/"
        exit 1
    fi

    # Normal project run
    return 0
}

# Show usage
show_usage() {
    cat << EOF
🎯 Claude Rules Synchronization Tool

Syncs rules & documentation to AI tools: Cursor, Copilot, Kiro

📁 Sources:
  • Rules: $GENERAL_RULES_DIR, $PROJECT_RULES_DIR
  • Documentation: $(printf "${SCRIPT_DIR}/%s, " "${DOCUMENTATION_FILES[@]}" | sed 's/, $//')

🎯 Usage:
  $0                    # Sync all
  $0 --dry-run          # Preview
  $0 --verify-only      # Check results

EOF
}

# Main function
main() {
    local dry_run=false
    local verify_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run=true
                shift
                ;;
            --verify-only)
                verify_only=true
                shift
                ;;
            sync)
                shift
                ;;
            usage|--help|-h)
                show_usage
                exit 0
                ;;
            "")
                # Default operation
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Check runtime environment
    check_run_environment

    echo "🚀 Syncing rules for: $(basename "$PROJECT_ROOT")"
    echo ""

    # Check rule files
    if ! check_rule_files; then
        exit 1
    fi
    echo ""

    if [[ "$verify_only" == true ]]; then
        verify_sync
        exit $?
    fi

    if [[ "$dry_run" == true ]]; then
        echo "🔍 Dry run - will sync to:"
        for tool_name in "${!AI_TOOLS_RULES[@]}"; do
            local rules_dir="${AI_TOOLS_RULES[$tool_name]}"
            local root_dir="${AI_TOOLS_ROOT[$tool_name]}"
            local display_name="$(capitalize "$tool_name")"
            echo "  • $display_name rules: $rules_dir"
            echo "  • $display_name docs: $root_dir"
        done
        exit 0
    fi

    # Execute synchronization for all tools
    for tool_name in "${!AI_TOOLS_RULES[@]}"; do
        sync_to_tool "$tool_name"
        echo ""
    done

    verify_sync
}

# Run main function
main "$@"