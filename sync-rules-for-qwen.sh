#!/usr/bin/env bash
# Qwen CLI Rules Sync Script - Sync rules to Qwen CLI tool
# Usage: ./sync-rules-for-qwen.sh

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_RULES_DIR="$SCRIPT_DIR/rules"
TARGET_RULES_DIR="$HOME/.qwen/rules"

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

log_progress() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# Check source rules directory
check_source_rules() {
    log_info "Checking source rules directory: $SOURCE_RULES_DIR"

    if [[ ! -d "$SOURCE_RULES_DIR" ]]; then
        log_error "Source rules directory not found: $SOURCE_RULES_DIR"
        return 1
    fi

    local rule_count
    rule_count=$(find "$SOURCE_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    rule_count=${rule_count:-0}

    if [[ $rule_count -eq 0 ]]; then
        log_error "No rule files found in $SOURCE_RULES_DIR"
        return 1
    else
        log_success "Found $rule_count rule files to sync"
        return 0
    fi
}

# Create target directory
create_target_directory() {
    if [[ ! -d "$TARGET_RULES_DIR" ]]; then
        log_info "Creating target directory: $TARGET_RULES_DIR"
        mkdir -p "$TARGET_RULES_DIR"
        log_success "Created target directory"
    else
        log_info "Target directory already exists: $TARGET_RULES_DIR"
    fi
}

# Clean target directory
cleanup_target_directory() {
    log_info "Cleaning target directory..."

    local file_count
    file_count=$(find "$TARGET_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    file_count=${file_count:-0}

    if [[ $file_count -eq 0 ]]; then
        log_info "No files to clean in target directory"
        return 0
    fi

    log_info "Removing $file_count existing files..."
    local removed_count
    removed_count=$(find "$TARGET_RULES_DIR" -name "*.md" -type f -delete -print 2>/dev/null | wc -l)
    removed_count=${removed_count:-0}

    if [[ $removed_count -gt 0 ]]; then
        log_success "Cleaned $removed_count files"
    else
        log_warning "No files were removed"
    fi
}

# Sync rules to target
sync_rules() {
    log_info "Syncing rules to Qwen CLI..."

    local total_files=0
    local failed_files=0
    local source_file_count=0

    # Count source files first
    source_file_count=$(find "$SOURCE_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    source_file_count=${source_file_count:-0}

    log_progress "Processing $source_file_count rule files..."

    for rule_file in "$SOURCE_RULES_DIR"/*.md; do
        [[ -f "$rule_file" ]] || continue

        local basename=$(basename "$rule_file")
        local target_file="${TARGET_RULES_DIR}/${basename}"

        log_progress "Syncing: $basename ($((total_files + 1))/$source_file_count)"

        if cp "$rule_file" "$target_file"; then
            total_files=$((total_files + 1))
        else
            local exit_code=$?
            failed_files=$((failed_files + 1))
            log_error "Failed to sync: $basename (exit code: $exit_code)"
        fi
    done

    if [[ $failed_files -eq 0 ]]; then
        log_success "Qwen CLI sync completed: $total_files files synced successfully"
    else
        log_warning "Sync completed with $failed_files failures out of $source_file_count files"
    fi

    return 0
}

# Create Qwen memory file
create_memory_file() {
    local memory_file="$HOME/.qwen/QWEN.md"

    log_info "Creating Qwen memory file..."

    cat > "$memory_file" << 'EOF'
# Qwen CLI User Memory

## Available Rules

Development guidelines available in `rules/` directory:

- `00-user-preferences.md` - Personal preferences and tool configurations
- `01-general-development.md` - General coding standards and practices
- `02-architecture-patterns.md` - Architecture and design patterns
- `03-security-guidelines.md` - Security practices and guidelines
- `04-testing-strategy.md` - Testing approaches and strategies
- `05-error-handling.md` - Error handling patterns
- `10-python-guidelines.md` - Python-specific guidelines
- `11-go-guidelines.md` - Go-specific guidelines
- `12-shell-guidelines.md` - Shell scripting guidelines
- `13-docker-guidelines.md` - Docker and containerization guidelines
- `14-networking-guidelines.md` - Network programming patterns
- `20-development-tools.md` - Development tool configuration
- `21-code-quality.md` - Code quality standards
- `22-logging-standards.md` - Logging and monitoring standards
- `23-workflow-patterns.md` - Development workflow patterns

## Quick Start

### Basic Usage
Load user preferences for general sessions:
```bash
qwen -p "$(cat rules/00-user-preferences.md)"
```

### Language-Specific Sessions
Python development:
```bash
qwen -p "$(cat rules/10-python-guidelines.md)"
```

Go development:
```bash
qwen -p "$(cat rules/11-go-guidelines.md)"
```

### Interactive Mode
Start interactive session with specific guidelines:
```bash
qwen -i -p "$(cat rules/01-general-development.md)"
```

### Multiple Rules
Combine user preferences with language guidelines:
```bash
qwen -p "$(cat rules/00-user-preferences.md rules/10-python-guidelines.md)"
```

### Project-Specific Rules
If working on a project with local rules:
```bash
qwen -p "$(cat .claude/rules/project.md rules/01-general-development.md)"
```

## Best Practices

- Start with `00-user-preferences.md` for general behavior
- Add language-specific rules for development tasks
- Use interactive mode (`-i`) for longer sessions
- Combine multiple rules when needed for comprehensive guidance
- Check rule files exist before using them

## Error Handling

If rule files are missing, the commands will fail gracefully. Check available rules with:
```bash
ls rules/
```
EOF

    log_success "Created Qwen memory file: $memory_file"
}

# Verify sync results
verify_sync() {
    echo ""
    echo "🔍 Verification results:"

    local source_count
    local target_count

    source_count=$(find "$SOURCE_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    source_count=${source_count:-0}

    target_count=$(find "$TARGET_RULES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
    target_count=${target_count:-0}

    echo "  • Source files: $source_count"
    echo "  • Target files: $target_count"
    echo "  • Memory file: ~/.qwen/QWEN.md"

    if [[ $source_count -eq $target_count ]] && [[ $source_count -gt 0 ]]; then
        echo ""
        echo "🎉 Sync verified successfully!"
        echo "📁 Target directory: $TARGET_RULES_DIR"
        echo "🧠 Memory file: ~/.qwen/QWEN.md"
        echo "💡 Usage example: qwen -p \"\$(cat ~/.qwen/rules/00-user-preferences.md)\""
        return 0
    else
        echo ""
        echo "❌ Sync verification failed"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
🎯 Qwen CLI Rules Synchronization Tool

Syncs Claude rules to Qwen CLI tool for consistent behavior.

📁 Source: $SOURCE_RULES_DIR
🎯 Target: $TARGET_RULES_DIR

🎯 Usage:
  $0                     # Sync rules
  $0 --dry-run           # Preview what would be synced
  $0 --verify-only       # Verify existing sync

💡 After sync, use rules with Qwen:
  qwen -p "\$(cat ~/.qwen/rules/00-user-preferences.md)"

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
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    echo "🚀 Qwen CLI Rules Sync"
    echo ""

    # Check source rules
    if ! check_source_rules; then
        exit 1
    fi
    echo ""

    if [[ "$verify_only" == true ]]; then
        verify_sync
        exit $?
    fi

    if [[ "$dry_run" == true ]]; then
        echo "🔍 Dry run - will sync these files:"
        for rule_file in "$SOURCE_RULES_DIR"/*.md; do
            [[ -f "$rule_file" ]] || continue
            echo "  • $(basename "$rule_file")"
        done
        echo ""
        echo "🎯 Target directory: $TARGET_RULES_DIR"
        exit 0
    fi

    # Execute sync
    create_target_directory
    cleanup_target_directory
    sync_rules
    create_memory_file

    verify_sync
}

# Run main function
main "$@"