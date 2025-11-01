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

log_info()    { printf '[INFO] %s\n' "$*"; }
log_success() { printf '[OK] %s\n' "$*"; }
log_warning() { printf '[WARN] %s\n' "$*"; }
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
    opencode) printf '%s\n' "$HOME/.config/opencode" ;;
  esac
}

get_target_rules_dir() {
  local tool="$1"
  case "$tool" in
    droid)   printf '%s\n' "$HOME/.factory/rules" ;;
    qwen)    printf '%s\n' "$HOME/.qwen/rules" ;;
    codex)   printf '%s\n' "$HOME/.codex/rules" ;;
    opencode) printf '%s\n' "$HOME/.config/opencode/rules" ;;
  esac
}

get_target_commands_dir() {
  local tool="$1"
  case "$tool" in
    droid)   printf '%s\n' "$HOME/.factory/commands" ;;
    qwen)    printf '%s\n' "$HOME/.qwen/commands" ;;
    codex)   printf '%s\n' "$HOME/.codex/commands" ;;
    opencode) printf '%s\n' "$HOME/.config/opencode/command" ;;
  esac
}
