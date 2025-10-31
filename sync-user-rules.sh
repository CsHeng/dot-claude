#!/usr/bin/env bash
# Sync shared Claude rules into user-level tooling directories (Qwen CLI, Factory/Droid CLI, Codex)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
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

GENERAL_RULES_DIR="$HOME/.claude/rules"
QWEN_RULE_DIR="$HOME/.qwen/rules"
DROID_RULE_DIR="$HOME/.factory/rules"
CODEX_AGENTS_FILE="$HOME/.codex/AGENTS.md"

TARGETS=(qwen droid codex)
declare -A TARGET_LABELS=(
    [qwen]="Qwen CLI (~/.qwen/rules)"
    [droid]="Factory/Droid CLI (~/.factory/rules)"
    [codex]="Codex CLI (~/.codex/AGENTS.md)"
)

SELECTED_TARGETS=()

show_usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --all                 Sync all targets without prompting
  --target <name>       Sync a specific target (repeatable)
                        Available: qwen, droid, codex
  --dry-run             Show destinations without copying
  --verify-only         Report existing file counts without syncing
  --help                Display this help message

Note: Custom command synchronization lives in ./sync-user-commands.sh
EOF
}

check_prerequisites() {
    if [[ ! -d "$GENERAL_RULES_DIR" ]]; then
        log_error "General rules directory missing: $GENERAL_RULES_DIR"
        exit 1
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
        echo "Select targets to sync (e.g. '1', '1 3', or 'a'):
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


collect_rule_files() {
    local -n _out=$1
    _out=()
    while IFS= read -r file; do
        _out+=("$file")
    done < <(find "$GENERAL_RULES_DIR" -maxdepth 1 -name "*.md" -type f -print | LC_ALL=C sort)
}
rule_heading() {
    local file="$1"
    local heading
    heading=$(sed -n 's/^#\s*//p' "$file" | head -n 1)
    if [[ -z "$heading" ]]; then
        local base
        base="$(basename "$file" .md)"
        if [[ $base =~ ^[0-9]{2}-(.+)$ ]]; then
            heading="${BASH_REMATCH[1]}"
        else
            heading="$base"
        fi
    fi
    echo "$heading"
}

sync_qwen_rules() {
    log_info "Syncing Qwen CLI rules"
    local copied
    copied=$(copy_markdown_rules "$QWEN_RULE_DIR" "$GENERAL_RULES_DIR")
    log_success "Qwen CLI: $copied file(s) copied"
    generate_qwen_memory
}

verify_qwen_rules() {
    local count
    count=$(verify_markdown_count "$QWEN_RULE_DIR")
    printf "  %s: %d file(s)\n" "${TARGET_LABELS[qwen]}" "$count"
    [[ -f "$HOME/.qwen/QWEN.md" ]] && printf "    • QWEN.md present\n"
}

sync_droid_rules() {
    log_info "Syncing Factory/Droid CLI rules"
    local copied
    copied=$(copy_markdown_rules "$DROID_RULE_DIR" "$GENERAL_RULES_DIR")
    log_success "Droid CLI: $copied file(s) copied"
    log_info "Custom commands are managed separately via ./sync-user-commands.sh"
}

verify_droid_rules() {
    local count
    count=$(verify_markdown_count "$DROID_RULE_DIR")
    printf "  %s: %d rule file(s)\n" "${TARGET_LABELS[droid]}" "$count"
    printf "    • Commands: run ./sync-user-commands.sh --verify-only for custom command status\n"
}

sync_codex_rules() {
    log_info "Generating Codex AGENTS.md"
    ensure_directory "$(dirname "$CODEX_AGENTS_FILE")"

    local rule_files=()
    collect_rule_files rule_files

    {
        echo "# Repository Guidelines"
        echo ""
        echo "> Auto-generated from ~/.claude/rules by sync-user-rules.sh"
        echo ""
        echo "## Toolchain"
        echo "- Primary agents: Codex CLI, Qwen CLI, Factory/Droid CLI"
        echo "- Shared context: ~/.claude/rules/*.md"
        echo "- Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo ""
        echo "## Rule Index"
        if (( ${#rule_files[@]} == 0 )); then
            echo "- (no rule files found)"
        else
            for file in "${rule_files[@]}"; do
                local base_name
                base_name="$(basename "$file")"
                local heading
                heading="$(rule_heading "$file")"
                echo "- **$heading** (_${base_name}_)"
            done
        fi
        echo ""
        echo "## Detailed Guidance"
        for file in "${rule_files[@]}"; do
            local heading="$(rule_heading "$file")"
            echo "### $heading"
            echo "_Source: $(basename "$file")_"
            echo ""
            cat "$file"
            echo ""
            echo "---"
            echo ""
        done
        echo "## Codex Workflow Tips"
        cat <<'EOF'
- Launch Codex with the appropriate sandbox and approval policy for repository work:
  ```bash
  codex --sandbox workspace-write --ask-for-approval on-request
  ```
- Reference specific rule files in prompts, for example:
  ```bash
  codex "Follow testing strategy from 04-testing-strategy.md to write pytest cases"
  ```
- Combine Codex with other tools:
  ```bash
  qwen -p "Use 01-general-development.md to review this diff"
  factory "Apply security checklist from 03-security-guidelines.md"
  ```
- Keep AGENTS.md refreshed after editing ~/.claude/rules to ensure Codex loads the latest context.
EOF
    } > "$CODEX_AGENTS_FILE"

    log_success "Codex AGENTS.md updated: $CODEX_AGENTS_FILE"
}

verify_codex_rules() {
    if [[ -f "$CODEX_AGENTS_FILE" ]]; then
        local sections
        sections=$(grep -c '^### ' "$CODEX_AGENTS_FILE" || true)
        local bytes
        bytes=$(wc -c < "$CODEX_AGENTS_FILE")
        printf "  %s: %d sections, %d bytes\n" "${TARGET_LABELS[codex]}" "$sections" "$bytes"
    else
        printf "  %s: (missing)\n" "${TARGET_LABELS[codex]}"
    fi
}

dry_run_entry() {
    case "$1" in
        qwen)
            echo "${TARGET_LABELS[qwen]} → $QWEN_RULE_DIR"
            ;;
        droid)
            echo "${TARGET_LABELS[droid]} → $DROID_RULE_DIR"
            ;;
        codex)
            echo "${TARGET_LABELS[codex]} → $CODEX_AGENTS_FILE"
            ;;
    esac
}

run_target() {
    case "$1" in
        qwen)
            sync_qwen_rules
            ;;
        droid)
            sync_droid_rules
            ;;
        codex)
            sync_codex_rules
            ;;
    esac
}

verify_target() {
    case "$1" in
        qwen)
            verify_qwen_rules
            ;;
        droid)
            verify_droid_rules
            ;;
        codex)
            verify_codex_rules
            ;;
    esac
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

    check_prerequisites

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
        run_target "$target"
    done

    log_info "Verification"
    for target in "${SELECTED_TARGETS[@]}"; do
        verify_target "$target"
    done
}

main "$@"
