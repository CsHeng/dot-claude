#!/usr/bin/env bash
# Sync shared Claude rules into project-level tooling directories (Cursor, VS Code Copilot)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
SCRIPT_ROOT="$(cd "$SCRIPT_DIR" && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_ROOT")"
HOME_CLAUDE_ROOT="$(cd "$HOME/.claude" && pwd -P 2>/dev/null)"
SCRIPT_ROOT_NORM="${SCRIPT_ROOT,,}"
HOME_CLAUDE_ROOT_NORM="${HOME_CLAUDE_ROOT,,}"

COMMON_LIB=""
for candidate in "$SCRIPT_DIR/lib/rule-sync-common.sh" "$HOME/.claude/lib/rule-sync-common.sh"; do
    if [[ -f "$candidate" ]]; then
        COMMON_LIB="$candidate"
        break
    fi
done

if [[ -z "$COMMON_LIB" ]]; then
    echo "Missing helper library: expected at $SCRIPT_DIR/lib/rule-sync-common.sh or $HOME/.claude/lib/rule-sync-common.sh" >&2
    exit 1
fi
source "$COMMON_LIB"

GENERAL_RULES_DIR="$HOME/.claude/rules"
PROJECT_RULES_DIR="$PROJECT_ROOT/.claude/rules"

TARGETS=(cursor copilot)
declare -A TARGET_LABELS=(
    [cursor]="Cursor project rules (.cursor/rules)"
    [copilot]="VS Code Copilot instructions (.github/instructions)"
)
declare -A TARGET_DIRS=(
    [cursor]="$PROJECT_ROOT/.cursor/rules"
    [copilot]="$PROJECT_ROOT/.github/instructions"
)

SELECTED_TARGETS=()
SOURCE_DIRS=()

show_usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --all                 Sync all targets without prompting
  --target <name>       Sync a specific target (repeatable)
                        Available: cursor, copilot
  --dry-run             Show destinations without copying
  --verify-only         Report existing file counts without syncing
  --help                Display this help message
EOF
}

check_environment() {
    if [[ -n "$HOME_CLAUDE_ROOT" && "$SCRIPT_ROOT_NORM" == "$HOME_CLAUDE_ROOT_NORM" ]]; then
        log_error "Copy this script into a project .claude/ directory before running."
        exit 1
    fi

    if [[ ! -d "$GENERAL_RULES_DIR" ]]; then
        log_error "General rules directory missing: $GENERAL_RULES_DIR"
        exit 1
    fi

    if [[ ! -d "$PROJECT_RULES_DIR" ]]; then
        log_warning "Project rules directory missing: $PROJECT_RULES_DIR"
    fi
}

build_sources() {
    SOURCE_DIRS=()
    SOURCE_DIRS+=("$GENERAL_RULES_DIR")
    [[ -d "$PROJECT_RULES_DIR" ]] && SOURCE_DIRS+=("$PROJECT_RULES_DIR")
}

is_valid_target() {
    local candidate="$1"
    for t in "${TARGETS[@]}"; do
        if [[ "$t" == "$candidate" ]]; then
            return 0
        fi
    done
    return 1
}

normalize_targets() {
    local -n _out=$1
    shift
    local -A seen=()
    local ordered=()
    for item in "$@"; do
        is_valid_target "$item" || continue
        if [[ -z "${seen[$item]+x}" ]]; then
            seen[$item]=1
            ordered+=("$item")
        fi
    done
    _out=("${ordered[@]}")
}

prompt_target_selection() {
    while true; do
        echo "Select targets to sync (e.g. '1', '1 2', or 'a'):
  - Enter one or more numbers separated by spaces
  - Enter 'a' (or 'all') to select every target
  - Enter '0' to clear selection and try again"
        for i in "${!TARGETS[@]}"; do
            local idx=$((i + 1))
            local key="${TARGETS[$i]}"
            printf "  %d) %s\n" "$idx" "${TARGET_LABELS[$key]}"
        done
        echo "  a) All targets"
        echo ""
        read -r -p "Choice: " selection || exit 1
        if [[ -z "$selection" ]]; then
            echo "Please choose at least one option." >&2
            continue
        fi

        read -r -a tokens <<< "$selection"
        local error=false
        local picks=()
        for token in "${tokens[@]}"; do
            local normalized="${token,,}"
            if [[ "$normalized" == "a" || "$normalized" == "all" ]]; then
                picks=("${TARGETS[@]}")
                error=false
                break
            fi
            if [[ "$normalized" == "0" ]]; then
                picks=()
                error=true
                echo "Selection cleared. Choose targets again." >&2
                break
            fi
            if [[ ! "$token" =~ ^[0-9]+$ ]]; then
                echo "Invalid entry: $token" >&2
                error=true
                break
            fi
            local index=$((token - 1))
            if (( index < 0 || index >= ${#TARGETS[@]} )); then
                echo "Invalid number: $token" >&2
                error=true
                break
            fi
            picks+=("${TARGETS[$index]}")
        done
        if [[ "$error" == true ]]; then
            continue
        fi
        if (( ${#picks[@]} == 0 )); then
            echo "Please select at least one valid target." >&2
            continue
        fi

        normalize_targets SELECTED_TARGETS "${picks[@]}"
        break
    done
}

dry_run_entry() {
    local target="$1"
    echo "${TARGET_LABELS[$target]} → ${TARGET_DIRS[$target]}"
}

sync_target() {
    local target="$1"
    local target_dir="${TARGET_DIRS[$target]}"
    local label="${TARGET_LABELS[$target]}"

    log_info "Syncing rules into $label"
    local copied
    copied=$(copy_markdown_rules "$target_dir" "${SOURCE_DIRS[@]}")
    log_success "$label: $copied file(s) copied"
}

verify_target() {
    local target="$1"
    local target_dir="${TARGET_DIRS[$target]}"
    local label="${TARGET_LABELS[$target]}"
    local count
    count=$(verify_markdown_count "$target_dir")
    printf "  %s: %d file(s)\n" "$label" "$count"
}

main() {
    local dry_run=false
    local verify_only=false
    local use_all=false
    local parsed_targets=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run=true
                shift
                ;;
            --verify-only)
                verify_only=true
                shift
                ;;
            --all)
                use_all=true
                shift
                ;;
            --target)
                if [[ $# -lt 2 ]]; then
                    log_error "--target requires an argument"
                    exit 1
                fi
                parsed_targets+=("$2")
                shift 2
                ;;
            --target=*)
                parsed_targets+=("${1#*=}")
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    check_environment
    build_sources

    if [[ "$use_all" == true ]]; then
        SELECTED_TARGETS=("${TARGETS[@]}")
    elif (( ${#parsed_targets[@]} > 0 )); then
        normalize_targets SELECTED_TARGETS "${parsed_targets[@]}"
        if (( ${#SELECTED_TARGETS[@]} == 0 )); then
            log_error "No valid targets specified"
            exit 1
        fi
    else
        prompt_target_selection
    fi

    if (( ${#SELECTED_TARGETS[@]} == 0 )); then
        log_error "No targets selected"
        exit 1
    fi

    if [[ "$verify_only" == true ]]; then
        log_info "Verification"
        for target in "${SELECTED_TARGETS[@]}"; do
            verify_target "$target"
        done
        exit 0
    fi

    if [[ "$dry_run" == true ]]; then
        local entries=()
        for target in "${SELECTED_TARGETS[@]}"; do
            entries+=("$(dry_run_entry "$target")")
        done
        dry_run_report "${entries[@]}"
        exit 0
    fi

    for target in "${SELECTED_TARGETS[@]}"; do
        sync_target "$target"
    done

    log_info "Verification"
    for target in "${SELECTED_TARGETS[@]}"; do
        verify_target "$target"
    done
}

main "$@"
