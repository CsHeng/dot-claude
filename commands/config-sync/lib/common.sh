#!/usr/bin/env bash
# Shell helpers for config-sync workflows.

set -euo pipefail

validate_target() {
  local target="$1"
  case "$target" in
    droid|qwen|codex|opencode|all) return 0 ;;
    *)
      echo "[common] unsupported target: $target" >&2
      return 1
      ;;
  esac
}

validate_component() {
  local component="$1"
  case "$component" in
    rules|permissions|commands|settings|memory) return 0 ;;
    *)
      echo "[common] unsupported component: $component" >&2
      return 1
      ;;
  esac
}

# Get component list from SELECTED_COMPONENTS
get_components() {
    printf '%s\n' "${SELECTED_COMPONENTS[@]}"
}

# Get tool-specific memory filename
get_tool_memory_filename() {
    local tool="$1"
    case "$tool" in
        "droid")
            echo "DROID.md"
            ;;
        "qwen")
            echo "QWEN.md"
            ;;
        "codex")
            echo "CODEX.md"
            ;;
        "opencode")
            echo "AGENTS.md"  # OpenCode uses AGENTS.md as primary memory
            ;;
        *)
            echo ""
            ;;
    esac
}

log_info()    { printf '[INFO] %s\n' "$*"; }
log_success() { printf '[OK] %s\n' "$*"; }
log_warning() { printf '[WARN] %s\n' "$*"; }
log_warn()     { log_warning "$@"; }  # Backward compatibility alias
log_error()   { printf '[ERROR] %s\n' "$*"; }

setup_plugin_environment() {
  export CONFIG_SYNC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  export CONFIG_SYNC_SCRIPTS="$CONFIG_SYNC_ROOT/scripts"
  export PATH="$CONFIG_SYNC_SCRIPTS:$PATH"
}

check_tool_installed() {
  local tool="$1"
  command -v "$tool" >/dev/null 2>&1
}

get_target_config_dir() {
  local tool="$1"
  case "$tool" in
    droid)   printf '%s\n' "$HOME/.factory" ;;
    qwen)    printf '%s\n' "$HOME/.qwen" ;;
    codex)   printf '%s\n' "$HOME/.codex" ;;
    opencode)
      local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
      printf '%s\n' "$config_dir"
      ;;
  esac
}

get_target_rules_dir() {
  local tool="$1"
  case "$tool" in
    droid)   printf '%s\n' "$HOME/.factory/rules" ;;
    qwen)    printf '%s\n' "$HOME/.qwen/rules" ;;
    codex)   printf '%s\n' "$HOME/.codex/rules" ;;
    opencode) printf '%s\n' "$(get_target_config_dir opencode)/rules" ;;
  esac
}

get_target_commands_dir() {
  local tool="$1"
  case "$tool" in
    droid)   printf '%s\n' "$HOME/.factory/commands" ;;
    qwen)    printf '%s\n' "$HOME/.qwen/commands" ;;
    codex)   printf '%s\n' "$HOME/.codex/commands" ;;
    opencode)
      local base="$(get_target_config_dir opencode)"
      if [[ -d "$base/command" || ! -d "$base/commands" ]]; then
        printf '%s\n' "$base/command"
      else
        printf '%s\n' "$base/commands"
      fi
      ;;
  esac
}


parse_target_list() {
  local raw="$1"
  local trimmed
  trimmed="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  trimmed="${trimmed// /}"

  local valid_targets=("droid" "qwen" "codex" "opencode")

  if [[ -z "$trimmed" ]]; then
    log_error "No target specified"
    return 1
  fi

  if [[ "$trimmed" == "all" ]]; then
    printf '%s\n' "${valid_targets[@]}"
    return 0
  fi

  IFS=',' read -ra parts <<< "$trimmed"
  declare -A seen=()
  local result=()

  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    if [[ "$part" == "all" ]]; then
      printf '%s\n' "${valid_targets[@]}"
      return 0
    fi
    case "$part" in
      droid|qwen|codex|opencode) ;;
      *)
        log_error "Invalid target specified: $part"
        return 1
        ;;
    esac
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

  local valid_components=("commands" "rules" "settings" "permissions" "memory")

  if [[ -z "$trimmed" ]]; then
    log_error "No component specified"
    return 1
  fi

  if [[ "$trimmed" == "all" ]]; then
    printf '%s\n' "${valid_components[@]}"
    return 0
  fi

  IFS=',' read -ra parts <<< "$trimmed"
  declare -A seen=()
  local result=()

  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    if [[ "$part" == "all" ]]; then
      printf '%s\n' "${valid_components[@]}"
      return 0
    fi
    case "$part" in
      commands|rules|settings|permissions|memory) ;;
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
