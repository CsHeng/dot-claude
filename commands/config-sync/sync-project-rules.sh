#!/usr/bin/env bash

set -euo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_ROOT="$(cd "$HOME/.claude" && pwd -P)"
CURRENT_DIR="$(pwd -P)"

log_info() {
    printf '[INFO] %s\n' "$1"
}

log_success() {
    printf '[OK] %s\n' "$1"
}

log_warning() {
    printf '[WARN] %s\n' "$1"
}

log_error() {
    printf '[ERROR] %s\n' "$1" >&2
}

dry_run_report() {
    log_info "Dry run - no files copied"
    local entry
    for entry in "$@"; do
        printf '  %s\n' "$entry"
    done
}

ensure_directory() {
    local dir="$1"
    [[ -d "$dir" ]] && return
    log_info "Creating directory: $dir"
    mkdir -p "$dir"
}

clean_markdown_targets() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    find "$dir" -name "*.md" -type f -delete >/dev/null 2>&1 || true
}

sync_markdown_rules() {
    local target_dir="$1"
    shift
    local source_dirs=("$@")

    ensure_directory "$target_dir"

    local total=0
    local source
    for source in "${source_dirs[@]}"; do
        [[ -d "$source" ]] || continue
        while IFS= read -r -d '' file; do
            rsync -a "$file" "$target_dir/"
            total=$((total + 1))
        done < <(find "$source" -maxdepth 1 -type f -name "*.md" -print0)
    done

    echo "$total"
}

verify_markdown_count() {
    local dir="$1"
    local count=0
    if [[ -d "$dir" ]]; then
        count=$(find "$dir" -type f -name "*.md" 2>/dev/null | wc -l | tr -d '[:space:]')
    fi
    echo "${count:-0}"
}

TARGETS=(cursor copilot)
declare -A TARGET_LABELS=(
    [cursor]="Cursor project rules (.cursor/rules)"
    [copilot]="VS Code Copilot instructions (.github/instructions)"
)
declare -A TARGET_DIRS=()

SELECTED_TARGETS=()
SOURCE_DIRS=()

PROJECT_ROOT=""
PROJECT_RULES_DIR=""
GENERAL_RULES_DIR="$CLAUDE_ROOT/rules"
PROJECT_ROOT_OVERRIDE=""
ENV_PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-}"

show_usage() {
    cat <<EOF
Usage: /config-sync:sync-project-rules [options]

Options:
  --all                   Sync all targets without prompting
  --target <name>         Sync a specific target (repeatable: cursor, copilot)
  --dry-run               Show destinations without copying
  --verify-only           Report existing file counts without syncing
  --project-root <path>   Override auto-detected project root
  --help                  Display this help message
EOF
}

resolve_project_root() {
    if [[ -n "$PROJECT_ROOT_OVERRIDE" ]]; then
        if [[ ! -d "$PROJECT_ROOT_OVERRIDE" ]]; then
            log_error "Project root not found: $PROJECT_ROOT_OVERRIDE"
            exit 1
        fi
        PROJECT_ROOT="$(cd "$PROJECT_ROOT_OVERRIDE" && pwd -P)"
        return
    fi

    if [[ -n "$ENV_PROJECT_ROOT" ]]; then
        if [[ ! -d "$ENV_PROJECT_ROOT" ]]; then
            log_error "CLAUDE_PROJECT_DIR does not exist: $ENV_PROJECT_ROOT"
            exit 1
        fi
        PROJECT_ROOT="$(cd "$ENV_PROJECT_ROOT" && pwd -P)"
        return
    fi

    if [[ "$CURRENT_DIR" == "$CLAUDE_ROOT"* ]]; then
        log_error "Run this command from a project directory or set CLAUDE_PROJECT_DIR/--project-root"
        exit 1
    fi

    PROJECT_ROOT="$CURRENT_DIR"

    PROJECT_RULES_DIR="$PROJECT_ROOT/.claude/rules"
    TARGET_DIRS=(
        [cursor]="$PROJECT_ROOT/.cursor/rules"
        [copilot]="$PROJECT_ROOT/.github/instructions"
    )
}

build_sources() {
    SOURCE_DIRS=()
    SOURCE_DIRS+=("$GENERAL_RULES_DIR")
    [[ -d "$PROJECT_RULES_DIR" ]] && SOURCE_DIRS+=("$PROJECT_RULES_DIR")
}

check_environment() {
    if [[ ! -d "$GENERAL_RULES_DIR" ]]; then
        log_error "General rules directory missing: $GENERAL_RULES_DIR"
        exit 1
    fi

    if [[ ! -d "$PROJECT_RULES_DIR" ]]; then
        log_warning "Project rules directory missing: $PROJECT_RULES_DIR"
    fi
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
    copied=$(sync_markdown_rules "$target_dir" "${SOURCE_DIRS[@]}")
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
            --project-root)
                if [[ $# -lt 2 ]]; then
                    log_error "--project-root requires an argument"
                    exit 1
                fi
                PROJECT_ROOT_OVERRIDE="$2"
                shift 2
                ;;
            --project-root=*)
                PROJECT_ROOT_OVERRIDE="${1#*=}"
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

    resolve_project_root
    build_sources
    check_environment

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
