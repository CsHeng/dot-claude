#!/usr/bin/env bash
# Shell helpers for config-sync workflows.
# Path resolution is manifest-driven via jq and Bash, Python is reserved for
# validation and format conversions (e.g. Markdown→TOML).

set -euo pipefail

# Setup environment for config-sync
setup_plugin_environment() {
  local script_dir="${BASH_SOURCE%/*}"
  if [[ -z "$script_dir" ]]; then
    script_dir="$(pwd)"
  fi

  export CONFIG_SYNC_ROOT="$(cd "$script_dir/.." && pwd)"
  export CONFIG_SYNC_SCRIPTS="$CONFIG_SYNC_ROOT/scripts"
  export CONFIG_SYNC_MANIFEST="$CONFIG_SYNC_ROOT/directory-manifest.json"
  local python_root="$CONFIG_SYNC_ROOT/lib/python"
  if [[ -d "$python_root" ]]; then
    if [[ -n "${PYTHONPATH:-}" ]]; then
      export PYTHONPATH="$python_root:$PYTHONPATH"
    else
      export PYTHONPATH="$python_root"
    fi
  fi
  export PATH="$CONFIG_SYNC_SCRIPTS:$PATH"
}

# Initialize environment when this file is sourced
setup_plugin_environment

# Get component list from SELECTED_COMPONENTS (used by prepare phase)
get_components() {
  printf '%s\n' "${SELECTED_COMPONENTS[@]}"
}

# Resolve target config dir from manifest
get_target_config_dir() {
  local target="$1"
  if [[ ! -f "$CONFIG_SYNC_MANIFEST" ]]; then
    log_error "Manifest not found at $CONFIG_SYNC_MANIFEST"
    return 1
  fi

  local raw
  raw="$(jq -r --arg t "$target" '.targets[$t].configDir // empty' "$CONFIG_SYNC_MANIFEST")"
  if [[ -z "$raw" || "$raw" == "null" ]]; then
    log_error "No configDir configured for target: $target"
    return 1
  fi
  # If configDir is absolute, use it as-is; otherwise treat as $HOME-relative
  if [[ "$raw" == /* ]]; then
    printf '%s\n' "$raw"
  else
    printf '%s\n' "${HOME}/${raw}"
  fi
}

# Resolve target component path from manifest
get_target_path() {
  local target="$1"
  local component="$2"

  local config_dir
  config_dir="$(get_target_config_dir "$target")" || return 1

  local sub
  sub="$(jq -r --arg t "$target" --arg c "$component" '.targets[$t].components[$c] // empty' "$CONFIG_SYNC_MANIFEST")"

  if [[ -z "$sub" || "$sub" == "null" ]]; then
    log_error "Component '$component' not configured for target '$target'"
    return 1
  fi

  printf '%s\n' "${config_dir%/}/$sub"
}

# Resolve source component path from Claude root (~/.claude)
get_source_path() {
  local component="$1"
  case "$component" in
    commands)
      printf '%s\n' "${HOME}/.claude/commands"
      ;;
    rules)
      printf '%s\n' "${HOME}/.claude/rules"
      ;;
    skills)
      printf '%s\n' "${HOME}/.claude/skills"
      ;;
    agents)
      printf '%s\n' "${HOME}/.claude/agents"
      ;;
    output_styles)
      printf '%s\n' "${HOME}/.claude/output-styles"
      ;;
    *)
      log_error "Source path not configured for component '$component'"
      return 1
      ;;
  esac
}

# Legacy functions for backward compatibility
get_target_rules_dir() {
  get_target_path "$1" "rules"
}

get_target_commands_dir() {
  get_target_path "$1" "commands"
}

# Get memory filename for target from manifest
get_tool_memory_filename() {
  local target="$1"
  local memory_file
  memory_file="$(jq -r --arg t "$target" '.targets[$t].components.memory // empty' "$CONFIG_SYNC_MANIFEST")"
  if [[ -z "$memory_file" || "$memory_file" == "null" ]]; then
    log_error "Memory file not configured for target '$target'"
    return 1
  fi
  printf '%s\n' "$memory_file"
}

# Parse target list using manifest instead of hardcoded values (Shell + jq)
parse_target_list() {
  local raw="$1"
  local trimmed
  trimmed="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  trimmed="${trimmed// /}"

  if [[ -z "$trimmed" ]]; then
    log_error "No target specified"
    return 1
  fi

  if [[ "$trimmed" == "all" ]]; then
    jq -r '.targets | keys[]' "$CONFIG_SYNC_MANIFEST"
    return 0
  fi

  IFS=',' read -ra parts <<< "$trimmed"
  declare -A seen=()
  local result=()

  # Get valid targets from manifest
  local valid_targets
  mapfile -t valid_targets < <(jq -r '.targets | keys[]' "$CONFIG_SYNC_MANIFEST")

  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    if [[ "$part" == "all" ]]; then
      printf '%s\n' "${valid_targets[@]}"
      return 0
    fi

    # Validate against manifest targets
    local found=false
    for valid_target in "${valid_targets[@]}"; do
      if [[ "$part" == "$valid_target" ]]; then
        found=true
        break
      fi
    done

    if [[ "$found" == "false" ]]; then
      log_error "Invalid target specified: $part"
      return 1
    fi

    if [[ -z "${seen[$part]:-}" ]]; then
      result+=("$part")
      seen["$part"]=1
    fi
  done

  if [[ ${#result[@]} -eq 0 ]]; then
    log_error "No valid targets found in: $raw"
    return 1
  fi

  printf '%s\n' "${result[@]}"
}

parse_component_list() {
  local raw="$1"
  local trimmed
  trimmed="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  trimmed="${trimmed// /}"

  if [[ -z "$trimmed" ]]; then
    log_error "No component specified"
    return 1
  fi

  if [[ "$trimmed" == "all" ]]; then
    printf '%s\n' "commands" "rules" "skills" "agents" "output_styles" "settings" "permissions" "memory"
    return 0
  fi

  IFS=',' read -ra parts <<< "$trimmed"
  declare -A seen=()
  local result=()

  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    if [[ "$part" == "all" ]]; then
      printf '%s\n' "commands" "rules" "skills" "agents" "output_styles" "settings" "permissions" "memory"
      return 0
    fi

    case "$part" in
      commands|rules|skills|agents|output_styles|settings|permissions|memory) ;;
      *)
        log_error "Invalid component specified: $part"
        return 1
        ;;
    esac

    if [[ -z "${seen[$part]:-}" ]]; then
      result+=("$part")
      seen["$part"]=1
    fi
  done

  if [[ ${#result[@]} -eq 0 ]]; then
    log_error "No valid components found in: $raw"
    return 1
  fi

  printf '%s\n' "${result[@]}"
}

# Basic component validation for direct adapter usage
validate_component() {
  local component="$1"
  case "$component" in
    commands|rules|skills|agents|output_styles|settings|permissions|memory) return 0 ;;
    *)
      echo "[common] unsupported component: $component" >&2
      return 1
      ;;
  esac
}

# Check if a target supports a given component in the manifest
target_supports_component() {
  local target="$1"
  local component="$2"
  local val

  val="$(jq -r --arg t "$target" --arg c "$component" '.targets[$t].components[$c] // empty' "$CONFIG_SYNC_MANIFEST")"
  [[ -n "$val" && "$val" != "null" ]]
}

# Utility functions
log_info()    { printf '[INFO] %s\n' "$*"; }
log_success() { printf '[OK] %s\n' "$*"; }
log_warning() { printf '[WARN] %s\n' "$*"; }
log_warn()     { log_warning "$@"; }  # Backward compatibility alias
log_error()   { printf '[ERROR] %s\n' "$*"; }

check_tool_installed() {
  local tool="$1"
  command -v "$tool" >/dev/null 2>&1
}

# File synchronization helpers
sync_with_verification() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    log_error "Source file not found: $source"
    return 1
  fi

  # Create target directory if needed
  mkdir -p "$(dirname "$target")"

  # Copy file
  if cp "$source" "$target"; then
    log_info "Synced: $source -> $target"
    return 0
  else
    log_error "Failed to sync: $source -> $target"
    return 1
  fi
}

sync_claude_memory_file() {
  local target_file="$1"
  local force="${2:-false}"

  local source_file="$CONFIG_SYNC_ROOT/../CLAUDE.md"

  if [[ ! -f "$source_file" ]]; then
    log_warning "CLAUDE.md not found, skipping memory sync"
    return 0
  fi

  if [[ -f "$target_file" && "$force" != "true" ]]; then
    log_info "Memory file exists, skipping sync (use --force to override): $target_file"
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"

  if cp "$source_file" "$target_file"; then
    log_info "Memory file synced: $target_file"
    return 0
  else
    log_error "Failed to sync memory file: $target_file"
    return 1
  fi
}
