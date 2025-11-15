#!/usr/bin/env bash

# Config-Sync Amp Adapter
# Handles Amp CLI-specific configuration synchronization

set -euo pipefail

ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$ADAPTER_DIR"
source "$ADAPTER_DIR/../lib/common.sh"
source "$ADAPTER_DIR/../scripts/executor.sh"

ACTION=""
COMPONENT_SPEC=""
DRY_RUN=false
FORCE=false
VERBOSE=false

declare -a SELECTED_COMPONENTS=()
COMPONENT_LABEL=""

AMP_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
AMP_CONFIG_DIR="$AMP_CONFIG_HOME/amp"
AMP_COMMANDS_DIR="$AMP_CONFIG_DIR/commands"
AMP_RULES_DIR="$AMP_CONFIG_DIR/rules"
AMP_SETTINGS_FILE="$AMP_CONFIG_DIR/settings.json"
AMP_AGENTS_FILE="$AMP_CONFIG_DIR/AGENTS.md"
AMP_GLOBAL_AGENTS_FILE="$AMP_CONFIG_HOME/AGENTS.md"

usage() {
    cat << EOF
Config-Sync Amp Adapter - Amp CLI Synchronization

USAGE:
    amp.sh --action <sync|analyze|verify> --component <rules,permissions,commands,settings,memory|all> [OPTIONS]

OPTIONS:
    --action <operation>     Operation to perform (sync, analyze, verify)
    --component <type>       Component type or "all"
    --dry-run                Show what would be done without executing
    --force                  Force overwrite existing files
    --verbose                Enable detailed output
    --help                   Show this help message

COMPONENTS:
    rules       Sync rule markdown into ~/.config/amp/rules
    permissions Map Claude allow/ask/deny to amp.permissions
    commands    Copy commands to ~/.config/amp/commands (excluding config-sync/)
    settings    Generate/update ~/.config/amp/settings.json
    memory      Delegate to sync-memory adapter for AGENTS.md
    all         Sync all supported components
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action=*)
                ACTION="${1#--action=}"
                shift
                ;;
            --action)
                ACTION="$2"
                shift 2
                ;;
            --component=*)
                COMPONENT_SPEC="${1#--component=}"
                shift
                ;;
            --component)
                COMPONENT_SPEC="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
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

    [[ -n "$ACTION" ]] || { echo "Error: --action is required" >&2; exit 1; }
    [[ -n "$COMPONENT_SPEC" ]] || { echo "Error: --component is required" >&2; exit 1; }

    if ! mapfile -t SELECTED_COMPONENTS < <(parse_component_list "$COMPONENT_SPEC"); then
        log_error "Invalid component selection: $COMPONENT_SPEC"
        exit 1
    fi

    COMPONENT_LABEL="$(IFS=,; printf '%s' "${SELECTED_COMPONENTS[*]}")"
}

check_amp_installation() {
    if command -v amp >/dev/null 2>&1; then
        log_info "Amp CLI found: $(which amp)"
    else
        log_warning "Amp CLI not found in PATH; install it before running sync operations"
    fi
}

setup_amp_directories() {
    local dirs=("$AMP_CONFIG_DIR" "$AMP_COMMANDS_DIR" "$AMP_RULES_DIR")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                log_info "Would create directory: $dir"
            else
                mkdir -p "$dir"
                log_info "Created directory: $dir"
            fi
        fi
    done
}

sync_rules() {
    log_info "Syncing rules to Amp..."
    local source_dir="$CLAUDE_CONFIG_DIR/rules"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source rules directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would rsync $source_dir → $AMP_RULES_DIR"
        return 0
    fi

    mkdir -p "$AMP_RULES_DIR"
    rsync -a --delete "$source_dir"/ "$AMP_RULES_DIR"/
    log_success "Rules synchronized to $AMP_RULES_DIR"
}

sync_permissions() {
    log_info "Syncing permissions via adapt-permissions (Amp)..."
    local args=("--target=amp")
    [[ "$DRY_RUN" == true ]] && args+=("--dry-run")
    [[ "$FORCE" == true ]] && args+=("--force")
    [[ "$VERBOSE" == true ]] && args+=("--verbose")

    bash "$ADAPTER_DIR/adapt-permissions.sh" "${args[@]}"
}

sync_commands() {
    log_info "Syncing commands to Amp..."
    local source_dir="$CLAUDE_CONFIG_DIR/commands"

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source commands directory not found: $source_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would rsync $source_dir → $AMP_COMMANDS_DIR (excluding config-sync/)"
        return 0
    fi

    mkdir -p "$AMP_COMMANDS_DIR"
    rsync -a --delete --exclude="config-sync/" "$source_dir"/ "$AMP_COMMANDS_DIR"/
    log_success "Commands synchronized to $AMP_COMMANDS_DIR"
}

sync_settings() {
    log_info "Amp settings (non-permission fields) are user-managed; skipping settings sync"
    return 0
}

sync_memory() {
    log_info "Delegating memory sync for Amp..."
    local args=("--target=amp")
    [[ "$DRY_RUN" == true ]] && args+=("--dry-run")
    [[ "$FORCE" == true ]] && args+=("--force")
    [[ "$VERBOSE" == true ]] && args+=("--verbose")

    bash "$ADAPTER_DIR/sync-memory.sh" "${args[@]}"
}

analyze_amp() {
    log_info "Analyzing Amp configuration..."

    [[ -d "$AMP_CONFIG_DIR" ]] && log_success "Config directory: $AMP_CONFIG_DIR" || log_warning "Config directory missing: $AMP_CONFIG_DIR"

    if command -v amp >/dev/null 2>&1; then
        echo "SUCCESS: Amp CLI detected ($(command -v amp))"
        amp --version 2>/dev/null || true
    else
        echo "WARNING:  Amp CLI not found in PATH"
    fi

    if [[ -f "$AMP_SETTINGS_FILE" ]]; then
        local settings_size
        settings_size=$(wc -c < "$AMP_SETTINGS_FILE" 2>/dev/null || echo 0)
        echo "SUCCESS: settings.json present (${settings_size} bytes)"
        python3 - "$AMP_SETTINGS_FILE" <<'PY'
import json, pathlib, sys
settings = pathlib.Path(sys.argv[1])
try:
    data = json.loads(settings.read_text(encoding="utf-8"))
    perms = data.get("amp.permissions")
    if isinstance(perms, list):
        print(f"INFO: amp.permissions entries: {len(perms)}")
except Exception:
    print("WARNING:  Unable to parse settings.json for amp.permissions")
PY
    else
        echo "ERROR: settings.json missing at $AMP_SETTINGS_FILE"
    fi

    if [[ -f "$AMP_AGENTS_FILE" ]]; then
        echo "SUCCESS: AGENTS.md present in $AMP_AGENTS_FILE"
    else
        echo "WARNING:  AGENTS.md missing in $AMP_AGENTS_FILE"
    fi

    if [[ -f "$AMP_GLOBAL_AGENTS_FILE" ]]; then
        echo "INFO: Shared AGENTS.md found at $AMP_GLOBAL_AGENTS_FILE"
    else
        echo "INFO: No shared $AMP_GLOBAL_AGENTS_FILE (Amp will fall back to CLAUDE.md if needed)"
    fi

    if [[ -d "$AMP_RULES_DIR" ]]; then
        local rule_count
        rule_count=$(find "$AMP_RULES_DIR" -type f -name "*.md" 2>/dev/null | wc -l)
        echo "SUCCESS: Rules directory contains $rule_count markdown files"
    else
        echo "WARNING:  Rules directory missing at $AMP_RULES_DIR"
    fi

    if [[ -d "$AMP_COMMANDS_DIR" ]]; then
        local cmd_count
        cmd_count=$(find "$AMP_COMMANDS_DIR" -type f \( -perm -111 -o -name "*.md" \) 2>/dev/null | wc -l)
        echo "SUCCESS: Commands directory contains $cmd_count entries"
    else
        echo "WARNING:  Commands directory missing at $AMP_COMMANDS_DIR"
    fi
}

verify_amp() {
    log_info "Verifying Amp configuration..."
    local errors=0

    if ! command -v amp >/dev/null 2>&1; then
        log_warning "Amp CLI not detected in PATH"
    fi

    if [[ ! -d "$AMP_CONFIG_DIR" ]]; then
        log_error "Amp config directory missing: $AMP_CONFIG_DIR"
        ((errors += 1))
    fi

    if [[ ! -f "$AMP_SETTINGS_FILE" ]]; then
        log_error "settings.json missing: $AMP_SETTINGS_FILE"
        ((errors += 1))
    else
        if ! python3 - "$AMP_SETTINGS_FILE" <<'PY'
import json, sys, pathlib
settings = pathlib.Path(sys.argv[1])
data = json.loads(settings.read_text(encoding="utf-8"))
perms = data.get("amp.permissions")
if not isinstance(perms, list) or not perms:
    print("[ERROR] amp.permissions missing or empty", file=sys.stderr)
    raise SystemExit(1)
if not any(isinstance(entry, dict) and entry.get("tool") == "*" for entry in perms):
    print("[WARN] No fallback rule with tool='*'", file=sys.stderr)
PY
        then
            log_error "Invalid amp.permissions configuration"
            ((errors += 1))
        else
            log_success "amp.permissions present"
        fi
    fi

    if [[ ! -d "$AMP_RULES_DIR" ]] || [[ -z "$(find "$AMP_RULES_DIR" -type f -name '*.md' 2>/dev/null)" ]]; then
        log_warning "Rules directory missing or empty at $AMP_RULES_DIR"
    else
        log_success "Rules directory verified"
    fi

    if [[ ! -d "$AMP_COMMANDS_DIR" ]] || [[ -z "$(find "$AMP_COMMANDS_DIR" -mindepth 1 2>/dev/null)" ]]; then
        log_warning "Commands directory missing or empty at $AMP_COMMANDS_DIR"
    else
        log_success "Commands directory verified"
    fi

    if [[ ! -f "$AMP_AGENTS_FILE" ]]; then
        log_warning "AGENTS.md missing at $AMP_AGENTS_FILE"
    else
        log_success "AGENTS.md present"
    fi

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    log_success "Amp verification completed"
    return 0
}

run_sync_components() {
    local failures=0
    for component in "${SELECTED_COMPONENTS[@]}"; do
        case "$component" in
            rules)
                sync_rules || ((failures += 1))
                ;;
            permissions)
                sync_permissions || ((failures += 1))
                ;;
            commands)
                sync_commands || ((failures += 1))
                ;;
            settings)
                sync_settings || ((failures += 1))
                ;;
            memory)
                sync_memory || ((failures += 1))
                ;;
            *)
                log_error "Unsupported component '$component' for Amp adapter"
                return 1
                ;;
        esac
    done
    (( failures == 0 ))
}

perform_action() {
    case "$ACTION" in
        sync)
            setup_amp_directories
            run_sync_components
            ;;
        analyze)
            analyze_amp
            ;;
        verify)
            verify_amp
            ;;
        *)
            log_error "Unknown action: $ACTION"
            exit 1
            ;;
    esac
}

main() {
    parse_arguments "$@"

    validate_target "amp"
    for component in "${SELECTED_COMPONENTS[@]}"; do
        validate_component "$component"
    done

    if [[ "$ACTION" == "sync" ]]; then
        check_amp_installation
    fi

    [[ "$VERBOSE" == true ]] && set -x

    log_info "Starting Amp $ACTION for component(s): $COMPONENT_LABEL"

    if ! perform_action; then
        log_error "Amp $ACTION failed"
        exit 1
    fi

    log_success "Amp $ACTION completed successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
