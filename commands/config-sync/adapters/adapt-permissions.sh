#!/bin/bash

# Config-Sync Permission Adaptation Command
# Adapt Claude permissions to target tool format

set -euo pipefail

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../scripts/executor.sh"

# Default values
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

ARGUMENTS:
    --target <tool>         Target tool for permission adaptation (required)

OPTIONS:
    --mode <adapt|verify>   Run adaptation (default) or verification
    --dry-run               Show what would be done without executing
    --force                 Force overwrite existing permissions
    --verbose               Enable detailed output
    --help                  Show this help message

TARGET TOOLS:
    droid                   Factory/Droid CLI (JSON allowlist/denylist)
    qwen                    Qwen CLI (permission guidelines)
    codex                   Codex CLI (permission guidelines)
    opencode                OpenCode CLI (operation-based permissions)
    amp                     Amp CLI (amp.permissions array in settings.json)

EXAMPLES:
    adapt-permissions.sh --target=droid
    adapt-permissions.sh --target=opencode --dry-run

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

    # Validate required arguments
    if [[ -z "$TARGET" ]]; then
        echo "Error: --target is required" >&2
        exit 1
    fi

    # Validate target
    if [[ ! "$TARGET" =~ ^(droid|qwen|codex|opencode|amp)$ ]]; then
        echo "Error: Invalid target '$TARGET'. Must be droid, qwen, codex, opencode, or amp" >&2
        exit 1
    fi
    # Convert to lowercase for case-insensitive comparison
    MODE=$(echo "$MODE" | tr '[:upper:]' '[:lower:]')
    if [[ ! "$MODE" =~ ^(adapt|verify)$ ]]; then
        echo "Error: Invalid mode '$MODE'. Use adapt or verify" >&2
        exit 1
    fi
}

# Read Claude permissions
read_claude_permissions() {
    local allow_list=()
    local ask_list=()
    local deny_list=()

    # Read from Claude settings
    local settings_file="$CLAUDE_CONFIG_DIR/settings.json"
    if [[ -f "$settings_file" ]]; then
        if command -v jq &> /dev/null; then
            # Extract permissions using jq
            local allow_commands=$(jq -r '.bash.allow[]? // empty' "$settings_file" 2>/dev/null || true)
            local ask_commands=$(jq -r '.bash.ask[]? // empty' "$settings_file" 2>/dev/null || true)
            local deny_commands=$(jq -r '.bash.deny[]? // empty' "$settings_file" 2>/dev/null || true)

            while IFS= read -r cmd; do
                [[ -n "$cmd" ]] && allow_list+=("$cmd")
            done <<< "$allow_commands"

            while IFS= read -r cmd; do
                [[ -n "$cmd" ]] && ask_list+=("$cmd")
            done <<< "$ask_commands"

            while IFS= read -r cmd; do
                [[ -n "$cmd" ]] && deny_list+=("$cmd")
            done <<< "$deny_commands"
        else
            log_warning "jq not available - using default permission sets"
        fi
    fi

    # Use default permissions if none found
    if [[ ${#allow_list[@]} -eq 0 ]]; then
        allow_list=(
            "read" "write" "edit" "search" "analyze" "list" "help" "status"
            "git" "npm" "pip" "cargo" "go" "python" "node" "docker"
            "ls" "cat" "grep" "find" "head" "tail" "wc" "sort" "uniq"
            "git status" "git log" "git diff" "git show" "git branch"
            "npm list" "npm view" "pip list" "pip show" "go version"
        )
    fi

    if [[ ${#ask_list[@]} -eq 0 ]]; then
        ask_list=(
            "git commit" "git push" "git pull" "git merge"
            "npm install" "pip install" "cargo build" "go build"
            "docker build" "docker run" "docker compose"
            "mkdir" "rsync" "mv" "chmod" "chown"
        )
    fi

    if [[ ${#deny_list[@]} -eq 0 ]]; then
        deny_list=(
            "rm" "sudo" "su" "dd" "mkfs" "reboot" "shutdown"
            "kill" "pkill" "killall" "passwd" "useradd" "userdel"
            "systemctl" "service" "init" "halt" "poweroff"
        )
    fi

    ALLOW_LIST=("${allow_list[@]}")
    ASK_LIST=("${ask_list[@]}")
    DENY_LIST=("${deny_list[@]}")
}

# Adapt permissions for Droid
adapt_droid_permissions() {
    log_info "Adapting permissions for Droid..."

    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local settings_file="$config_dir/settings.json"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would adapt permissions for Droid in $settings_file"
        return 0
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"

    # Note: Backup handled by unified prepare phase
    # No need for individual settings backup

    local allow_list=("${ALLOW_LIST[@]}")
    local ask_list=("${ASK_LIST[@]}")
    local deny_list=("${DENY_LIST[@]}")

    # Merge dangerous ask commands into deny list for security
    local dangerous_ask_commands=("git commit" "git push" "git pull" "mkdir" "rsync" "mv" "chmod" "chown")
    local sanitized_ask_list=()
    for cmd in "${ask_list[@]}"; do
        if contains_command "$cmd" "${dangerous_ask_commands[@]}"; then
            deny_list+=("$cmd")
        else
            sanitized_ask_list+=("$cmd")
        fi
    done
    ask_list=("${sanitized_ask_list[@]}")

    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is required to generate Droid permissions JSON"
        return 1
    fi

    local allow_json
    local deny_json
    allow_json=$(printf '%s\n' "${allow_list[@]}" | jq -R . | jq -sc 'unique')
    deny_json=$(printf '%s\n' "${deny_list[@]}" | jq -R . | jq -sc 'unique')

    if command -v python3 >/dev/null 2>&1; then
        if ! python3 - "$settings_file" "$allow_json" "$deny_json" <<'PY'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
allow = json.loads(sys.argv[2])
deny = json.loads(sys.argv[3])

def load_existing(path: Path) -> dict:
    if not path.exists():
        return {}

    raw = path.read_text(encoding="utf-8")
    cleaned_lines = []
    for line in raw.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("//"):
            continue
        cleaned_lines.append(line)

    cleaned = "\n".join(cleaned_lines).strip()
    if not cleaned:
        return {}

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        return {}

data = load_existing(settings_path)
data["commandAllowlist"] = allow
data["commandDenylist"] = deny
data.setdefault("model", "claude-sonnet-4-5-20250929")
data.setdefault("autonomy", "balanced")

settings_path.write_text(json.dumps(data, indent=2, sort_keys=True), encoding="utf-8")
PY
        then
            log_warn "Failed to update settings.json via python; writing fallback template"
            cat > "$settings_file" <<EOF
{
  "autonomy": "balanced",
  "commandAllowlist": $allow_json,
  "commandDenylist": $deny_json,
  "model": "claude-sonnet-4-5-20250929"
}
EOF
        fi
    else
        cat > "$settings_file" <<EOF
{
  "autonomy": "balanced",
  "commandAllowlist": $allow_json,
  "commandDenylist": $deny_json,
  "model": "claude-sonnet-4-5-20250929"
}
EOF
    fi

    log_success "Droid permissions adapted in $settings_file"
}

# Adapt permissions for Qwen
adapt_qwen_permissions() {
    log_info "Adapting permissions for Qwen..."

    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local manifest_file="$config_dir/permissions.json"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would write Qwen permission manifest to $manifest_file"
        return 0
    fi

    mkdir -p "$config_dir"

    local allow_blob ask_blob deny_blob
    allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_blob=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

    ALLOW_BLOB="$allow_blob" \
    ASK_BLOB="$ask_blob" \
    DENY_BLOB="$deny_blob" \
    MANIFEST_TS="$timestamp" \
    python3 - "$manifest_file" <<'PYMANIFEST'
import json
import os
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])

def collect(env_name: str) -> list[str]:
    return [line for line in os.environ.get(env_name, "").splitlines() if line.strip()]

manifest = {
    "version": 1,
    "generated_at": os.environ.get("MANIFEST_TS"),
    "permissions": {
        "allow": collect("ALLOW_BLOB"),
        "ask": collect("ASK_BLOB"),
        "deny": collect("DENY_BLOB"),
    },
}

manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PYMANIFEST

    log_success "Qwen permission manifest updated in $manifest_file"
}

# Adapt permissions for Codex
adapt_codex_permissions() {
    log_info "Adapting permissions for Codex..."

    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local config_file="$config_dir/config.toml"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would adapt permissions for Codex in $config_file"
        return 0
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"

    # Determine sandbox mode based on permission restrictiveness
    local sandbox_mode="workspace-write"
    local allow_execution=true
    local allow_network=true

    local dangerous_count=${#DENY_LIST[@]}

    if [[ $dangerous_count -ge 15 ]]; then
        sandbox_mode="read-only"
        allow_execution=false
    elif [[ $dangerous_count -ge 8 ]]; then
        sandbox_mode="workspace-write"
        allow_execution=true
        allow_network=false
    fi

    # Create or update config.toml
    if [[ -f "$config_file" ]]; then
        SANDBOX_MODE="$sandbox_mode" \
        ALLOW_EXEC="$allow_execution" \
        ALLOW_NET="$allow_network" \
        python3 - "$config_file" <<'PY'
import os
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
text = config_path.read_text(encoding="utf-8") if config_path.exists() else ""

mode = os.environ.get("SANDBOX_MODE", "workspace-write")
allow_exec = os.environ.get("ALLOW_EXEC", "true").lower()
allow_net = os.environ.get("ALLOW_NET", "true").lower()

block_pattern = re.compile(r"(?ms)^\[sandbox\]\n(.*?)(?=^\[|\Z)")
match = block_pattern.search(text)
block_body = match.group(1) if match else ""

def parse_values(body: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in body.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        values[key.strip()] = value.strip()
    return values

existing = parse_values(block_body)
enabled = existing.get("enabled", "true")
timeout = existing.get("timeout", "30")
memory_limit = existing.get("memory_limit", '"512MB"')

new_lines = [
    "[sandbox]",
    f'mode = "{mode}"',
    f"allow_network = {allow_net}",
    f"allow_execution = {allow_exec}",
    f"enabled = {enabled}",
    f"timeout = {timeout}",
    f"memory_limit = {memory_limit}",
]
new_block = "\n".join(new_lines) + "\n"

if match:
    start, end = match.span()
    text = text[:start] + new_block + text[end:]
else:
    if text and not text.endswith("\n"):
        text += "\n"
    if text:
        text += "\n"
    text += new_block

config_path.write_text(text, encoding="utf-8")
PY
    else
        # Create new file
        cat > "$config_file" << EOF
# Codex CLI Configuration
[core]
api_key = ""  # Set your OpenAI API key here
model = "code-davinci-002"
temperature = 0.1
max_tokens = 1000

[sandbox]
mode = "$sandbox_mode"
allow_network = $allow_network
allow_execution = $allow_execution
timeout = 30
memory_limit = "512MB"

[sync]
source = "claude-code-sync"
last_sync = "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
EOF
    fi

    log_success "Codex permissions adapted in $config_file (sandbox mode: $sandbox_mode)"
}

# Adapt permissions for OpenCode
adapt_opencode_permissions() {
    log_info "Adapting permissions for OpenCode..."

    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local config_file="$config_dir/opencode.json"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would adapt permissions for OpenCode in $config_file"
        return 0
    fi

    mkdir -p "$config_dir"

    local allow_env ask_env deny_env
    allow_env=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_env=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_env=$(printf '%s\n' "${DENY_LIST[@]}")

    # Note: Backup handled by unified prepare phase
    # No need for individual config file backup

    ALLOW_LINES="$allow_env" \
    ASK_LINES="$ask_env" \
    DENY_LINES="$deny_env" \
    python3 - "$config_file" <<'PYCONF'
import json
import os
import sys
from collections import OrderedDict
from pathlib import Path

config_path = Path(sys.argv[1])

def load_lines(env_name: str) -> list[str]:
    return [line.strip() for line in os.environ.get(env_name, "").splitlines() if line.strip()]

allow = load_lines("ALLOW_LINES")
ask = load_lines("ASK_LINES")
deny = load_lines("DENY_LINES")

bash_permissions: dict[str, str] = OrderedDict()
for cmd in allow:
    bash_permissions[cmd] = "allow"
for cmd in ask:
    bash_permissions[cmd] = "ask"
for cmd in deny:
    bash_permissions[cmd] = "deny"

config = OrderedDict(
    [
        ("$schema", "https://opencode.ai/config.json"),
        ("theme", "claude"),
        ("model", "anthropic/claude-3-5-sonnet-20241022"),
        ("instructions", ["rules/*.md", "AGENTS.md", "OPENCODE.md"]),
        (
            "permission",
            {
                "edit": "allow",
                "bash": bash_permissions,
                "webfetch": "ask",
            },
        ),
    ]
)

config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
PYCONF

    log_success "OpenCode permissions adapted in $config_file"
    log_info "Permission entries written: bash=${#ALLOW_LIST[@]} allow, ${#ASK_LIST[@]} ask, ${#DENY_LIST[@]} deny"
}

adapt_amp_permissions() {
    log_info "Adapting permissions for Amp..."

    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local settings_file="$config_dir/settings.json"
    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would update amp.permissions inside $settings_file"
        return 0
    fi

    mkdir -p "$config_dir"

    local allow_env ask_env deny_env
    allow_env=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_env=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_env=$(printf '%s\n' "${DENY_LIST[@]}")

    AMP_ALLOW_LINES="$allow_env" \
    AMP_ASK_LINES="$ask_env" \
    AMP_DENY_LINES="$deny_env" \
    AMP_PERM_TIMESTAMP="$timestamp" \
    python3 - "$settings_file" <<'PY'
import json
import os
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])

def load_lines(env_name: str) -> list[str]:
    return [line.strip() for line in os.environ.get(env_name, "").splitlines() if line.strip()]

def load_settings(path: Path) -> dict:
    if not path.exists():
        return {}
    raw = path.read_text(encoding="utf-8").strip()
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {}

def dedupe(values: list[str]) -> list[str]:
    seen = set()
    ordered = []
    for item in values:
        if item not in seen:
            ordered.append(item)
            seen.add(item)
    return ordered

allow_cmds = dedupe(load_lines("AMP_ALLOW_LINES"))
ask_cmds = dedupe(load_lines("AMP_ASK_LINES"))
deny_cmds = dedupe(load_lines("AMP_DENY_LINES"))
timestamp = os.environ.get("AMP_PERM_TIMESTAMP")

data = load_settings(settings_path)

permissions = []

def build_entry(action: str, commands: list[str]):
    if not commands:
        return None
    return {
        "tool": "Bash",
        "matches": {"cmd": commands},
        "action": action,
    }

for action, cmds in (("reject", deny_cmds), ("ask", ask_cmds), ("allow", allow_cmds)):
    entry = build_entry(action, cmds)
    if entry:
        permissions.append(entry)

# Always append a safe fallback rule so Amp prompts instead of assuming access
permissions.append({"tool": "*", "action": "ask"})

data["amp.permissions"] = permissions
if timestamp:
    data["amp.settings.lastPermissionsSync"] = timestamp
data.setdefault("$schema", "https://ampcode.com/settings.schema.json")

settings_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY

    log_success "Amp permissions updated in $settings_file"
}

# Generate adaptation report
generate_adaptation_report() {
    echo "# Permission Adaptation Report"
    echo "Generated: $(date)"
    echo "Target Tool: $TARGET"
    echo "Dry Run: $DRY_RUN"
    echo ""

    echo "## Adaptation Summary"
    case "$TARGET" in
        "droid")
            echo "- **Format**: JSON allowlist/denylist"
            echo "- **File**: ~/.factory/settings.json"
            echo "- **Method**: Map Claude allow/ask/deny to commandAllowlist/commandDenylist"
            ;;
        "qwen")
            echo "- **Format**: JSON permission manifest"
            echo "- **File**: ~/.qwen/permissions.json"
            echo "- **Method**: Structured allow/ask/deny mapping consumed by the CLI"
            ;;
        "codex")
            echo "- **Format**: TOML sandbox configuration"
            echo "- **File**: ~/.codex/config.toml"
            echo "- **Method**: Set sandbox mode based on permission restrictiveness"
            ;;
        "opencode")
            echo "- **Format**: JSON operation-based permissions"
            echo "- **File**: ${XDG_CONFIG_HOME:-~/.config}/opencode/opencode.json"
            echo "- **Method**: Map command permissions to operation permissions"
            ;;
        "amp")
            echo "- **Format**: amp.permissions array in settings.json"
            echo "- **File**: ${XDG_CONFIG_HOME:-~/.config}/amp/settings.json"
            echo "- **Method**: Ordered reject/ask/allow rules plus fallback (per Amp manual)"
            ;;
    esac
    echo ""

    echo "## Security Considerations"
    echo "- Permissions were mapped with security-first approach"
    echo "- Dangerous commands were moved to deny/restricted categories"
    echo "- Original permission boundaries were preserved or strengthened"
    echo ""

    echo "## Verification"
    echo "1. Review generated permission configuration"
    echo "2. Test functionality in target tool"
    echo "3. Run \`/config-sync/sync-cli --action=verify --target=$TARGET\` to validate setup"
    echo ""

    if [[ "$DRY_RUN" == false ]]; then
        echo "## Rollback Information"
        local config_dir
        config_dir=$(get_target_config_dir "$TARGET")
        echo "- Backup files are located in: $config_dir/backup/"
        echo "- Restore from backup if issues occur"
        echo ""
    fi

    echo "## Next Steps"
    echo "1. Test the adapted permissions in $TARGET"
    echo "2. Customize settings as needed for your workflow"
    echo "3. Monitor permission effectiveness and adjust if required"
}

verify_droid_permissions() {
    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local settings_file="$config_dir/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        log_error "Droid settings.json not found at $settings_file"
        return 1
    fi

    local allow_blob deny_blob
    allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
    deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

    EXPECTED_ALLOW="$allow_blob" \
    EXPECTED_DENY="$deny_blob" \
    python3 - "$settings_file" <<'PYVERIFY'
import json, os, sys
from pathlib import Path

settings_path = Path(sys.argv[1])
expected_allow = [line for line in os.environ.get("EXPECTED_ALLOW", "").splitlines() if line.strip()]
expected_deny = [line for line in os.environ.get("EXPECTED_DENY", "").splitlines() if line.strip()]

if not settings_path.exists():
    print(f"[ERROR] Missing settings: {settings_path}", file=sys.stderr)
    sys.exit(1)

def load_clean_json(path: Path) -> dict:
    raw = path.read_text(encoding="utf-8")
    cleaned = "\n".join(
        line for line in raw.splitlines()
        if not line.lstrip().startswith("//")
    ).strip()
    if not cleaned:
        return {}
    return json.loads(cleaned)

data = load_clean_json(settings_path)
allow = set(data.get("commandAllowlist") or [])
deny = set(data.get("commandDenylist") or [])

missing_allow = [cmd for cmd in expected_allow if cmd not in allow]
missing_deny = [cmd for cmd in expected_deny if cmd not in deny]

if missing_allow or missing_deny:
    if missing_allow:
        print("[ERROR] commandAllowlist missing:", ", ".join(missing_allow), file=sys.stderr)
    if missing_deny:
        print("[ERROR] commandDenylist missing:", ", ".join(missing_deny), file=sys.stderr)
    sys.exit(1)
PYVERIFY

    log_success "Droid permissions verified in $settings_file"
}

verify_qwen_permissions() {
    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local manifest_file="$config_dir/permissions.json"

    if [[ ! -f "$manifest_file" ]]; then
        log_error "Qwen permissions.json not found at $manifest_file"
        return 1
    fi

    local allow_blob ask_blob deny_blob
    allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_blob=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

    EXPECTED_ALLOW="$allow_blob" \
    EXPECTED_ASK="$ask_blob" \
    EXPECTED_DENY="$deny_blob" \
    python3 - "$manifest_file" <<'PYVERIFY'
import json, os, sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text(encoding="utf-8") or "{}")
permissions = manifest.get("permissions") or {}

allow = set(permissions.get("allow") or [])
ask = set(permissions.get("ask") or [])
deny = set(permissions.get("deny") or [])

def collect(env_name: str) -> list[str]:
    return [line for line in os.environ.get(env_name, "").splitlines() if line.strip()]

problems = []
for entry in collect("EXPECTED_ALLOW"):
    if entry not in allow:
        problems.append(f"allow:{entry}")
for entry in collect("EXPECTED_ASK"):
    if entry not in ask:
        problems.append(f"ask:{entry}")
for entry in collect("EXPECTED_DENY"):
    if entry not in deny:
        problems.append(f"deny:{entry}")

if problems:
    print("[ERROR] Qwen permissions.json missing entries:", ", ".join(problems), file=sys.stderr)
    sys.exit(1)
PYVERIFY

    log_success "Qwen permission manifest verified in $manifest_file"
}

verify_codex_permissions() {
    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local config_file="$config_dir/config.toml"

    if [[ ! -f "$config_file" ]]; then
        log_error "Codex config.toml not found at $config_file"
        return 1
    fi

    local sandbox_mode="workspace-write"
    local allow_execution=true
    local allow_network=true
    local dangerous_count=${#DENY_LIST[@]}

    if [[ $dangerous_count -ge 15 ]]; then
        sandbox_mode="read-only"
        allow_execution=false
    elif [[ $dangerous_count -ge 8 ]]; then
        sandbox_mode="workspace-write"
        allow_network=false
    fi

    EXPECTED_MODE="$sandbox_mode" \
    EXPECTED_EXEC="$allow_execution" \
    EXPECTED_NET="$allow_network" \
    python3 - "$config_file" <<'PYVERIFY'
import os
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
expected_mode = os.environ.get("EXPECTED_MODE")
expected_exec = os.environ.get("EXPECTED_EXEC")
expected_net = os.environ.get("EXPECTED_NET")

sandbox = {}
current_section = None
for line in config_path.read_text(encoding="utf-8").splitlines():
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        continue
    if stripped.startswith("[") and stripped.endswith("]"):
        current_section = stripped
        continue
    if current_section != "[sandbox]":
        continue
    if "=" not in stripped:
        continue
    key, value = stripped.split("=", 1)
    sandbox[key.strip()] = value.strip().strip('"')

errors = []
if sandbox.get("mode") != expected_mode:
    errors.append(f"mode expected {expected_mode}, found {sandbox.get('mode')}")
if str(sandbox.get("allow_execution", "")).lower() != expected_exec:
    errors.append(f"allow_execution expected {expected_exec}, found {sandbox.get('allow_execution')}")
if str(sandbox.get("allow_network", "")).lower() != expected_net:
    errors.append(f"allow_network expected {expected_net}, found {sandbox.get('allow_network')}")

if errors:
    for err in errors:
        print(f"[ERROR] Codex sandbox mismatch: {err}", file=sys.stderr)
    sys.exit(1)
PYVERIFY

    log_success "Codex sandbox configuration verified in $config_file"
}

verify_opencode_permissions() {
    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local config_file="$config_dir/opencode.json"

    if [[ ! -f "$config_file" ]]; then
        log_error "OpenCode opencode.json not found at $config_file"
        return 1
    fi

    local allow_blob ask_blob deny_blob
    allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_blob=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

    EXPECTED_ALLOW="$allow_blob" \
    EXPECTED_ASK="$ask_blob" \
    EXPECTED_DENY="$deny_blob" \
    python3 - "$config_file" <<'PYVERIFY'
import json, os, sys
from pathlib import Path

config_path = Path(sys.argv[1])
config = json.loads(config_path.read_text(encoding="utf-8") or "{}")
bash_permissions = config.get("permission", {}).get("bash", {})

def collect(env_name: str, label: str) -> list[str]:
    return [(cmd, label) for cmd in os.environ.get(env_name, "").splitlines() if cmd.strip()]

expected = (
    collect("EXPECTED_ALLOW", "allow")
    + collect("EXPECTED_ASK", "ask")
    + collect("EXPECTED_DENY", "deny")
)

missing = []
for cmd, label in expected:
    current = bash_permissions.get(cmd)
    if current != label:
        missing.append(f"{cmd}=>{label} (found {current})")

if missing:
    print("[ERROR] OpenCode permission mismatches:", ", ".join(missing), file=sys.stderr)
    sys.exit(1)
PYVERIFY

    log_success "OpenCode permissions verified in $config_file"
}

verify_amp_permissions() {
    local config_dir
    config_dir=$(get_target_config_dir "$TARGET")
    local settings_file="$config_dir/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        log_error "Amp settings.json not found at $settings_file"
        return 1
    fi

    local allow_blob ask_blob deny_blob
    allow_blob=$(printf '%s\n' "${ALLOW_LIST[@]}")
    ask_blob=$(printf '%s\n' "${ASK_LIST[@]}")
    deny_blob=$(printf '%s\n' "${DENY_LIST[@]}")

    AMP_ALLOW_LINES="$allow_blob" \
    AMP_ASK_LINES="$ask_blob" \
    AMP_DENY_LINES="$deny_blob" \
    python3 - "$settings_file" <<'PY'
import json, os, sys
from pathlib import Path

settings_path = Path(sys.argv[1])

def has_values(env_name: str) -> bool:
    return any(line.strip() for line in os.environ.get(env_name, "").splitlines())

try:
    data = json.loads(settings_path.read_text(encoding="utf-8"))
except json.JSONDecodeError:
    print("[ERROR] settings.json is not valid JSON", file=sys.stderr)
    sys.exit(1)

permissions = data.get("amp.permissions")
if not isinstance(permissions, list) or not permissions:
    print("[ERROR] amp.permissions array missing or empty", file=sys.stderr)
    sys.exit(1)

actions_present = {entry.get("action") for entry in permissions if isinstance(entry, dict)}
fallback_present = any(
    isinstance(entry, dict) and entry.get("tool") == "*"
    for entry in permissions
)

expected = {
    "allow": has_values("AMP_ALLOW_LINES"),
    "ask": has_values("AMP_ASK_LINES"),
    "reject": has_values("AMP_DENY_LINES"),
}

missing = [action for action, needed in expected.items() if needed and action not in actions_present]
if missing:
    print(f"[ERROR] Missing amp.permissions entries for actions: {', '.join(missing)}", file=sys.stderr)
    sys.exit(1)

if not fallback_present:
    print("[WARN] No fallback rule with tool='*' detected", file=sys.stderr)

print("[SUCCESS] amp.permissions entries verified")
PY

    log_success "Amp permissions verified in $settings_file"
}

# Main adaptation function
run_permission_adaptation() {
    log_info "Starting permission adaptation for target: $TARGET"

    # Pre-flight checks
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        log_error "Claude configuration directory not found: $CLAUDE_CONFIG_DIR"
        exit 1
    fi

    read_claude_permissions

    # Adapt permissions based on target
    case "$TARGET" in
        "droid")
            adapt_droid_permissions
            ;;
        "qwen")
            adapt_qwen_permissions
            ;;
        "codex")
            adapt_codex_permissions
            ;;
        "opencode")
            adapt_opencode_permissions
            ;;
        "amp")
            adapt_amp_permissions
            ;;
    esac

    # Generate report
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
        "droid")
            verify_droid_permissions
            ;;
        "qwen")
            verify_qwen_permissions
            ;;
        "codex")
            verify_codex_permissions
            ;;
        "opencode")
            verify_opencode_permissions
            ;;
        "amp")
            verify_amp_permissions
            ;;
    esac

    log_success "Permission verification completed for $TARGET"
}

main() {
    parse_arguments "$@"

    # Setup logging
    if [[ "$VERBOSE" == true ]]; then
        set -x
    fi

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

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
