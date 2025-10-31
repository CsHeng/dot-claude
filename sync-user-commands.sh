#!/usr/bin/env bash
# Sync Claude custom commands into Droid CLI command directory with compatibility sanitization

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
trap '{ echo "[sync-user-commands] error on line $LINENO" >&2; log_error "Failure on line $LINENO"; exit 1; }' ERR

CLAUDE_COMMAND_DIR="$HOME/.claude/commands"
DROID_COMMAND_DIR="$HOME/.factory/commands"
SYNC_PREFIX="claude__"

if (( ${BASH_VERSINFO[0]:-3} < 4 )); then
    log_error "This script requires Bash 4 or newer"
    exit 1
fi

show_usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --dry-run             Show planned command copies without writing files
  --verify-only         Report current synced command files
  --help                Display this help message
EOF
}

print_missing_source_message() {
    log_warning "Claude custom command directory not found: $CLAUDE_COMMAND_DIR"
    log_warning "Create commands under ~/.claude/commands to enable synchronization."
}

list_command_sources() {
    local -n _out=$1
    command_collect_sources "$CLAUDE_COMMAND_DIR" _out
    if (( ${#_out[@]} == 0 )); then
        log_warning "No Claude custom commands detected in $CLAUDE_COMMAND_DIR"
    fi
}

dry_run_sync() {
    local -n src_ref=$1
    local -a warnings=()
    local -A seen_destinations=()

    log_info "Dry run - evaluating mappings"
    for relative in "${src_ref[@]}"; do
        local flattened
        flattened=$(command_flatten_filename "$relative")
        local dest_basename="${SYNC_PREFIX}${flattened}"

        if [[ -n "${seen_destinations[$dest_basename]:-}" ]]; then
            warnings+=("destination collision: $relative and ${seen_destinations[$dest_basename]} -> $dest_basename")
            continue
        fi
        seen_destinations[$dest_basename]="$relative"

        printf "  %s -> %s\n" "$relative" "$dest_basename"

        if [[ "$relative" == *.md ]]; then
            local tmp
            tmp=$(mktemp)
            command_sanitize_markdown "$CLAUDE_COMMAND_DIR/$relative" "$tmp" warnings || true
            rm -f "$tmp"
        fi
    done

    if (( ${#warnings[@]} > 0 )); then
        log_warning "Warnings detected during dry run:"
        for warning in "${warnings[@]}"; do
            printf "    • %s\n" "$warning"
        done
    else
        log_success "Dry run completed with no warnings"
    fi
}

sync_commands() {
    local -n src_ref=$1

    ensure_directory "$DROID_COMMAND_DIR"
    command_clean_prefixed_files "$DROID_COMMAND_DIR" "$SYNC_PREFIX"

    local -a warnings=()
    local -A seen_destinations=()
    local total=0

    for relative in "${src_ref[@]}"; do
        local flattened
        flattened=$(command_flatten_filename "$relative")
        local dest_basename="${SYNC_PREFIX}${flattened}"

        if [[ -n "${seen_destinations[$dest_basename]:-}" ]]; then
            warnings+=("destination collision: $relative and ${seen_destinations[$dest_basename]} -> $dest_basename")
            continue
        fi
        seen_destinations[$dest_basename]="$relative"

        if [[ "$relative" == *.md ]]; then
            command_sanitize_markdown "$CLAUDE_COMMAND_DIR/$relative" "$DROID_COMMAND_DIR/$dest_basename" warnings
        else
            cp "$CLAUDE_COMMAND_DIR/$relative" "$DROID_COMMAND_DIR/$dest_basename"
        fi
        ((total++))
    done

    log_success "Droid CLI commands synchronized: $total file(s)"

    if (( ${#warnings[@]} > 0 )); then
        log_warning "Warnings detected during synchronization:"
        for warning in "${warnings[@]}"; do
            printf "    • %s\n" "$warning"
        done
    fi

    return 0
}

verify_commands() {
    if [[ ! -d "$DROID_COMMAND_DIR" ]]; then
        printf "  Droid commands: (missing)\n"
        return
    fi

    local count
    count=$(find "$DROID_COMMAND_DIR" -maxdepth 1 -type f -name "${SYNC_PREFIX}*" -print 2>/dev/null | wc -l | tr -d '[:space:]')
    count=${count:-0}

    printf "  Droid commands: %d synced file(s) with prefix %s\n" "$count" "$SYNC_PREFIX"

    if (( count > 0 )); then
        local latest
        latest=$(find "$DROID_COMMAND_DIR" -maxdepth 1 -type f -name "${SYNC_PREFIX}*" -print0 2>/dev/null | xargs -0 stat -f '%m %N' 2>/dev/null | sort -nr | head -n 1)
        if [[ -n "$latest" ]]; then
            local timestamp file
            timestamp=${latest%% *}
            file=${latest#* }
            if [[ -n "$timestamp" && -n "$file" ]]; then
                printf "    • Most recent: %s (%s)\n" "$(date -r "$timestamp" '+%Y-%m-%d %H:%M:%S %Z')" "$(basename "$file")"
            fi
        fi
    fi

    return 0
}

main() {
    local dry_run=false
    local verify_only=false

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

    if [[ "$verify_only" == true ]]; then
        verify_commands
        exit 0
    fi

    if [[ ! -d "$CLAUDE_COMMAND_DIR" ]]; then
        print_missing_source_message
        exit 1
    fi

    local sources=()
    list_command_sources sources
    if (( ${#sources[@]} == 0 )); then
        exit 0
    fi

    IFS=$'\n' sources=($(printf '%s\n' "${sources[@]}" | LC_ALL=C sort))
    unset IFS

    if [[ "$dry_run" == true ]]; then
        dry_run_sync sources
        exit 0
    fi

    sync_commands sources
    log_info "Verification"
    verify_commands

    return 0
}

if ! main "$@"; then
    status=$?
    echo "[sync-user-commands] exit status: $status" >&2
    exit "$status"
fi

exit 0
