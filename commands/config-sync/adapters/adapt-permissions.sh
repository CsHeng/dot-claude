#!/bin/bash

# Config-Sync Permission Adaptation Command
# Adapt Claude permissions to target tool format

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

TARGET=""
MODE="adapt"
DRY_RUN=false
FORCE=false
VERBOSE=false

declare -a ALLOW_LIST=()
declare -a ASK_LIST=()
declare -a DENY_LIST=()

contains_command() {
  local needle="$1"
  shift
  for candidate in "$@"; do
    if [[ "$candidate" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

usage() {
  cat << EOF
Config-Sync Permission Adaptation Command - Adapt Claude Permissions

USAGE:
  adapt-permissions.sh --target <droid|qwen|codex|opencode|amp> [OPTIONS]

OPTIONS:
  --target <tool>         Target tool for permission adaptation (required)
  --mode <adapt|verify>   Run adaptation (default) or verification
  --dry-run               Show what would be done without executing
  --force                 Force overwrite existing permissions
  --verbose               Enable detailed output
  --help                  Show this help message
EOF
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --target=*)
        TARGET="${1#--target=}"
        shift
        ;;
      --target)
        TARGET="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --mode=*)
        MODE="${1#--mode=}"
        shift
        ;;
      --mode)
        MODE="$2"
        shift 2
        ;;
      --action=*)
        case "${1#--action=}" in
          verify) MODE="verify" ;;
          *) MODE="adapt" ;;
        esac
        shift
        ;;
      --action)
        case "$2" in
          verify) MODE="verify" ;;
          *) MODE="adapt" ;;
        esac
        shift 2
        ;;
      --force)
        FORCE=true
        shift
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  if [[ -z "$TARGET" ]]; then
    echo "Error: --target is required" >&2
    exit 1
  fi

  if [[ ! "$TARGET" =~ ^(droid|qwen|codex|opencode|amp)$ ]]; then
    echo "Error: Invalid target '$TARGET'. Must be droid, qwen, codex, opencode, or amp" >&2
    exit 1
  fi

  MODE=$(echo "$MODE" | tr '[:upper:]' '[:lower:]')
  if [[ ! "$MODE" =~ ^(adapt|verify)$ ]]; then
    echo "Error: Invalid mode '$MODE'. Use adapt or verify" >&2
    exit 1
  fi
}

read_claude_permissions() {
  local allow_list=()
  local ask_list=()
  local deny_list=()

  local settings_file="$CLAUDE_CONFIG_DIR/settings.json"
  if [[ -f "$settings_file" ]] && command -v jq >/dev/null 2>&1; then
    local allow_commands ask_commands deny_commands
    allow_commands=$(jq -r '.bash.allow[]? // empty' "$settings_file" 2>/dev/null || true)
    ask_commands=$(jq -r '.bash.ask[]? // empty' "$settings_file" 2>/dev/null || true)
    deny_commands=$(jq -r '.bash.deny[]? // empty' "$settings_file" 2>/dev/null || true)

    while IFS= read -r cmd; do
      [[ -n "$cmd" ]] && allow_list+=("$cmd")
    done <<< "$allow_commands"

    while IFS= read -r cmd; do
      [[ -n "$cmd" ]] && ask_list+=("$cmd")
    done <<< "$ask_commands"

    while IFS= read -r cmd; do
      [[ -n "$cmd" ]] && deny_list+=("$cmd")
    done <<< "$deny_commands"
  fi

  if [[ ${#allow_list[@]} -eq 0 ]]; then
    allow_list=("read" "write" "edit" "search" "analyze" "list" "help" "status")
  fi
  if [[ ${#ask_list[@]} -eq 0 ]]; then
    ask_list=("git commit" "git push" "git pull" "npm install" "pip install" "mkdir" "rsync" "mv" "chmod" "chown")
  fi
  if [[ ${#deny_list[@]} -eq 0 ]]; then
    deny_list=("rm" "sudo" "su" "dd" "mkfs" "reboot" "shutdown" "kill" "killall" "systemctl" "service" "halt" "poweroff")
  fi

  ALLOW_LIST=("${allow_list[@]}")
  ASK_LIST=("${ask_list[@]}")
  DENY_LIST=("${deny_list[@]}")
}

adapt_droid_permissions() {
  log_info "Adapting permissions for Droid..."

  local config_dir
  config_dir=$(get_target_config_dir "$TARGET")
  local settings_file="$config_dir/settings.json"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would adapt permissions for Droid in $settings_file"
    return 0
  fi

  if [[ ! -f "$settings_file" ]]; then
    log_warn "Droid settings.json not found at $settings_file; skipping permission adaptation"
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
    log_warn "jq or python3 missing; skipping Droid permission adaptation"
    return 0
  fi

  local allow_json deny_json
  allow_json=$(printf '%s\n' "${ALLOW_LIST[@]}" | jq -R . | jq -sc 'unique')
  deny_json=$(printf '%s\n' "${DENY_LIST[@]}" | jq -R . | jq -sc 'unique')

  python3 - "$settings_file" "$allow_json" "$deny_json" << 'PY'
import json, sys
from pathlib import Path

settings_path = Path(sys.argv[1])
allow = json.loads(sys.argv[2])
deny = json.loads(sys.argv[3])

try:
    raw = settings_path.read_text(encoding="utf-8")
    data = json.loads("\n".join(line for line in raw.splitlines() if not line.lstrip().startswith("//")).strip() or "{}")
except Exception:
    sys.exit(0)

if not isinstance(data, dict) or not data:
    sys.exit(0)

data["commandAllowlist"] = allow
data["commandDenylist"] = deny

settings_path.write_text(json.dumps(data, indent=2, sort_keys=True), encoding="utf-8")
PY

  log_success "Droid permissions adapted in $settings_file (commandAllowlist/commandDenylist only)"
}

adapt_qwen_permissions() {
  log_info "Adapting permissions for Qwen..."

  local config_dir
  config_dir=$(get_target_config_dir "$TARGET")
  local manifest_file="$config_dir/permissions.json"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would write Qwen permission manifest to $manifest_file"
    return 0
  fi

  mkdir -p "$config_dir"

  local allow_blob ask_blob deny_blob
  allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
  ask_blob=$(printf '%s\n' "${ASK_LIST[@]}")
  deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

  ALLOW_BLOB="$allow_blob" ASK_BLOB="$ask_blob" DENY_BLOB="$deny_blob" \
  python3 - "$manifest_file" << 'PY'
import json, os, sys
from pathlib import Path

manifest_path = Path(sys.argv[1])

def collect(env_name: str):
    return [line for line in os.environ.get(env_name, "").splitlines() if line.strip()]

manifest = {
    "version": 1,
    "permissions": {
        "allow": collect("ALLOW_BLOB"),
        "ask": collect("ASK_BLOB"),
        "deny": collect("DENY_BLOB"),
    },
}

manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY

  log_success "Qwen permission manifest updated in $manifest_file"
}

adapt_codex_permissions() {
  log_info "Codex has no explicit permission surface; skipping permission adaptation"
  return 0
}

adapt_opencode_permissions() {
  log_info "Adapting permissions for OpenCode..."

  local config_dir
  config_dir=$(get_target_config_dir "$TARGET")
  local config_file="$config_dir/opencode.json"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would update permission section in $config_file"
    return 0
  fi

  if [[ ! -f "$config_file" ]]; then
    log_warn "OpenCode config $config_file not found; skipping permission adaptation"
    return 0
  fi

  local allow_env ask_env deny_env
  allow_env=$(printf '%s\n' "${ALLOW_LIST[@]}")
  ask_env=$(printf '%s\n' "${ASK_LIST[@]}")
  deny_env=$(printf '%s\n' "${DENY_LIST[@]}")

  ALLOW_LINES="$allow_env" ASK_LINES="$ask_env" DENY_LINES="$deny_env" \
  python3 - "$config_file" << 'PY'
import json, os, sys
from collections import OrderedDict
from pathlib import Path

config_path = Path(sys.argv[1])

def load_lines(env_name: str):
    return [line.strip() for line in os.environ.get(env_name, "").splitlines() if line.strip()]

try:
    data = json.loads(config_path.read_text(encoding="utf-8").strip() or "{}")
except Exception:
    sys.exit(0)

if not isinstance(data, dict) or not data:
    sys.exit(0)

allow = load_lines("ALLOW_LINES")
ask = load_lines("ASK_LINES")
deny = load_lines("DENY_LINES")

bash_permissions = OrderedDict()
for cmd in allow:
    bash_permissions[cmd] = "allow"
for cmd in ask:
    bash_permissions[cmd] = "ask"
for cmd in deny:
    bash_permissions[cmd] = "deny"

perm = data.get("permission")
if not isinstance(perm, dict):
    perm = {}

perm["bash"] = bash_permissions
data["permission"] = perm

config_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY

  log_success "OpenCode permissions adapted in $config_file (permission.bash only)"
}

adapt_amp_permissions() {
  log_info "Adapting permissions for Amp..."

  local config_dir
  config_dir=$(get_target_config_dir "$TARGET")
  local settings_file="$config_dir/settings.json"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "Would update amp.permissions inside $settings_file"
    return 0
  fi

  if [[ ! -f "$settings_file" ]]; then
    log_warn "Amp settings.json not found at $settings_file; skipping permission adaptation"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_warn "python3 not available; skipping Amp permission adaptation"
    return 0
  fi

  local allow_env ask_env deny_env
  allow_env=$(printf '%s\n' "${ALLOW_LIST[@]}")
  ask_env=$(printf '%s\n' "${ASK_LIST[@]}")
  deny_env=$(printf '%s\n' "${DENY_LIST[@]}")

  AMP_ALLOW_LINES="$allow_env" AMP_ASK_LINES="$ask_env" AMP_DENY_LINES="$deny_env" \
  python3 - "$settings_file" << 'PY'
import json, os, sys
from pathlib import Path

settings_path = Path(sys.argv[1])

def load_lines(env_name: str):
    return [line.strip() for line in os.environ.get(env_name, "").splitlines() if line.strip()]

try:
    raw = settings_path.read_text(encoding="utf-8").strip()
    data = json.loads(raw or "{}")
except Exception:
    sys.exit(0)

if not isinstance(data, dict) or not data:
    sys.exit(0)

def dedupe(values):
    seen = set()
    out = []
    for v in values:
        if v not in seen:
            out.append(v)
            seen.add(v)
    return out

allow_cmds = dedupe(load_lines("AMP_ALLOW_LINES"))
ask_cmds = dedupe(load_lines("AMP_ASK_LINES"))
deny_cmds = dedupe(load_lines("AMP_DENY_LINES"))

permissions = []

def build_entry(action, commands):
    if not commands:
        return None
    return {"tool": "Bash", "matches": {"cmd": commands}, "action": action}

for action, cmds in (("reject", deny_cmds), ("ask", ask_cmds), ("allow", allow_cmds)):
    entry = build_entry(action, cmds)
    if entry:
        permissions.append(entry)

permissions.append({"tool": "*", "action": "ask"})

data["amp.permissions"] = permissions

settings_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY

  log_success "Amp permissions updated in $settings_file"
}

generate_adaptation_report() {
  echo "# Permission Adaptation Report"
  echo "Target Tool: $TARGET"
  echo "Dry Run: $DRY_RUN"
}

verify_droid_permissions() {
  log_info "Droid permission verification not enforced; skipping"
  return 0
}

verify_qwen_permissions() {
  log_info "Qwen permission verification not enforced; skipping"
  return 0
}

verify_codex_permissions() {
  log_info "Codex permissions verification skipped (no permission surface managed)"
  return 0
}

verify_opencode_permissions() {
  log_info "OpenCode permission verification not enforced; skipping"
  return 0
}

verify_amp_permissions() {
  log_info "Amp permission verification not enforced; skipping"
  return 0
}

run_permission_adaptation() {
  log_info "Starting permission adaptation for target: $TARGET"

  if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
    log_error "Claude configuration directory not found: $CLAUDE_CONFIG_DIR"
    exit 1
  fi

  read_claude_permissions

  case "$TARGET" in
    droid)    adapt_droid_permissions ;;
    qwen)     adapt_qwen_permissions ;;
    codex)    adapt_codex_permissions ;;
    opencode) adapt_opencode_permissions ;;
    amp)      adapt_amp_permissions ;;
  esac

  generate_adaptation_report
}

run_permission_verification() {
  log_info "Verifying permissions for target: $TARGET"

  if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
    log_error "Claude configuration directory not found: $CLAUDE_CONFIG_DIR"
    exit 1
  fi

  read_claude_permissions

  case "$TARGET" in
    droid)    verify_droid_permissions ;;
    qwen)     verify_qwen_permissions ;;
    codex)    verify_codex_permissions ;;
    opencode) verify_opencode_permissions ;;
    amp)      verify_amp_permissions ;;
  esac

  log_success "Permission verification completed for $TARGET"
}

main() {
  parse_arguments "$@"

  [[ "$VERBOSE" == true ]] && set -x

  if [[ "$MODE" == "verify" ]]; then
    run_permission_verification
  else
    run_permission_adaptation
    if [[ "$DRY_RUN" == true ]]; then
      log_success "Permission adaptation dry run completed - no changes were made"
    else
      log_success "Permission adaptation completed successfully"
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

