#!/usr/bin/env bash

# Synchronize taxonomy components (rules, agents, skills, output_styles)
# from ~/.claude into target CLI config directories based on the manifest.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
LIB_DIR="${SCRIPT_DIR%/scripts}/lib"

source "$LIB_DIR/common.sh"

TARGET_SPEC=""
COMPONENT=""
DRY_RUN=false
VERBOSE=false

usage() {
  cat <<EOF
Usage: sync-taxonomy-component.sh --target=<list|all> --component=<rules|agents|skills|output_styles> [options]

Options:
  --target=<list|all>      Comma-separated list of targets or 'all'
  --component=<name>       Component to sync: rules, agents, skills, output_styles
  --dry-run                Show actions without applying changes
  --verbose                Enable verbose logging
  --help                   Show this help message
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
      --component=*)
        COMPONENT="${1#--component=}"
        shift
        ;;
      --component)
        COMPONENT="$2"
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

  if [[ -z "$COMPONENT" ]]; then
    log_error "--component is required"
    usage
    exit 1
  fi

  case "$COMPONENT" in
    rules|agents|skills|output_styles) ;;
    *)
      log_error "Unsupported component for taxonomy sync: $COMPONENT"
      exit 1
      ;;
  esac
}

run_sync() {
  local targets=()
  mapfile -t targets < <(parse_target_list "$TARGET_SPEC")

  if [[ ${#targets[@]} -eq 0 ]]; then
    log_error "No targets resolved from: $TARGET_SPEC"
    exit 1
  fi

  local src
  if ! src="$(get_source_path "$COMPONENT")"; then
    log_error "Failed to resolve source path for component '$COMPONENT'"
    exit 1
  fi

  if [[ ! -d "$src" ]]; then
    log_warning "Source directory for '$COMPONENT' does not exist: $src"
    return 0
  fi

  log_info "Syncing taxonomy component '$COMPONENT' from $src"

  for target in "${targets[@]}"; do
    if ! target_supports_component "$target" "$COMPONENT"; then
      log_info "Target '$target' does not declare component '$COMPONENT'; skipping"
      continue
    fi

    local dest
    if ! dest="$(get_target_path "$target" "$COMPONENT")"; then
      log_warning "Could not resolve destination for '$COMPONENT' on '$target'; skipping"
      continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
      log_info "[dry-run] Would rsync $src/ -> $dest/"
      continue
    fi

    mkdir -p "$dest"
    if rsync -av --delete "$src/" "$dest/"; then
      log_info "Synced '$COMPONENT' to $target: $dest"
    else
      log_error "Failed to sync '$COMPONENT' to $target: $dest"
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

