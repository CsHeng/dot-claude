#!/usr/bin/env bash

# Memory sync: copy ~/.claude/AGENTS.md (via realpath) to each
# target's configured memory path (AGENTS.md) based on the manifest.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
LIB_DIR="${SCRIPT_DIR%/scripts}/lib"

source "$LIB_DIR/common.sh"

TARGET_SPEC=""
DRY_RUN=false
VERBOSE=false

usage() {
  cat <<EOF
Usage: sync-memory.sh --target=<list|all> [options]

Options:
  --target=<list|all>   Comma-separated list of targets or 'all'
  --dry-run             Show actions without applying changes
  --verbose             Enable verbose logging
  --help                Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target=*)
        TARGET_SPEC="${1#--target=}"
        shift
        ;;
      --target)
        TARGET_SPEC="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [[ -z "$TARGET_SPEC" ]]; then
    log_error "--target is required"
    usage
    exit 1
  fi
}

run_sync() {
  local agents_path="$HOME/.claude/AGENTS.md"

  if [[ ! -f "$agents_path" ]]; then
    log_warning "Source AGENTS.md not found at $agents_path; skipping memory sync"
    return 0
  fi

  local src
  src="$(realpath "$agents_path")"

  local targets=()
  mapfile -t targets < <(parse_target_list "$TARGET_SPEC")

  if [[ ${#targets[@]} -eq 0 ]]; then
    log_error "No targets resolved from: $TARGET_SPEC"
    exit 1
  fi

  log_info "Syncing memory from $src"

  for target in "${targets[@]}"; do
    if ! target_supports_component "$target" "memory"; then
      log_info "Target '$target' does not declare 'memory' component; skipping"
      continue
    fi

    local dest
    if ! dest="$(get_target_path "$target" "memory")"; then
      log_warning "Could not resolve memory path for '$target'; skipping"
      continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
      log_info "[dry-run] Would copy $src -> $dest"
      continue
    fi

    mkdir -p "$(dirname "$dest")"
    if rsync -a "$src" "$dest"; then
      log_info "Memory synced for $target: $dest"
    else
      log_error "Failed to sync memory for $target: $dest"
    fi
  done
}

main() {
  parse_args "$@"

  if [[ "$VERBOSE" == true ]]; then
    set -x
  fi

  run_sync
}

main "$@"
