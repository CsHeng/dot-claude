#!/bin/bash

# Review LLM Prompts - Analysis Workflow
# Scans LLM-facing files, groups violations by category, and prints a summary.

set -euo pipefail
trap 'echo "ERROR: Failure on line $LINENO" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_CONFIG_DIR="${HOME}/.claude"
TARGET_FILE=""
DRY_RUN=false
TARGET_FILES=()

declare -a issue_categories=()
declare -a issue_counts=()
declare -a issue_details=()
declare -a issue_files=()

declare -a reminder_categories=()
declare -a reminder_counts=()
declare -a reminder_details=()

declare -a seen_targets=()

# === Helpers ===

is_human_document() {
    local path="$1"
    local base
    base="$(basename "$path")"
    local base_lower
    base_lower="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"

    case "$base_lower" in
        readme|readme.md)
            return 0
            ;;
    esac

    if [[ "$path" == */docs/* ]]; then
        return 0
    fi

    return 1
}

find_issue_category_index() {
    local category="$1"
    local idx
    for idx in "${!issue_categories[@]}"; do
        if [[ "${issue_categories[$idx]}" == "$category" ]]; then
            printf '%s' "$idx"
            return 0
        fi
    done
    printf '%s' "-1"
}

find_reminder_category_index() {
    local category="$1"
    local idx
    for idx in "${!reminder_categories[@]}"; do
        if [[ "${reminder_categories[$idx]}" == "$category" ]]; then
            printf '%s' "$idx"
            return 0
        fi
    done
    printf '%s' "-1"
}

add_issue_file_to_category() {
    local idx="$1"
    local file="$2"
    local existing="${issue_files[$idx]-}"
    local line

    if [[ -z "$existing" ]]; then
        issue_files[$idx]="$file"
        return
    fi

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" == "$file" ]]; then
            return
        fi
    done <<< "$existing"

    issue_files[$idx]="${existing}"$'\n'"$file"
}

has_seen_target() {
    local candidate="$1"
    local item

    if [[ -z "${seen_targets[*]-}" ]]; then
        return 1
    fi

    for item in "${seen_targets[@]}"; do
        if [[ "$item" == "$candidate" ]]; then
            return 0
        fi
    done
    return 1
}

record_issue() {
    local category="$1"
    local file="$2"
    local line="$3"
    local message="$4"

    local idx
    idx="$(find_issue_category_index "$category")"
    if [[ "$idx" == "-1" ]]; then
        issue_categories+=("$category")
        issue_counts+=(0)
        issue_details+=("")
        issue_files+=("")
        idx=$((${#issue_categories[@]} - 1))
    fi

    issue_details[$idx]+="$file:$line - $message"$'\n'
    issue_counts[$idx]=$((issue_counts[$idx] + 1))
    add_issue_file_to_category "$idx" "$file"
}

record_reminder() {
    local category="$1"
    local file="$2"
    local line="$3"
    local message="$4"

    local idx
    idx="$(find_reminder_category_index "$category")"
    if [[ "$idx" == "-1" ]]; then
        reminder_categories+=("$category")
        reminder_counts+=(0)
        reminder_details+=("")
        idx=$((${#reminder_categories[@]} - 1))
    fi

    reminder_details[$idx]+="$file:$line - $message"$'\n'
    reminder_counts[$idx]=$((reminder_counts[$idx] + 1))
}

describe_issue_category() {
    case "$1" in
        bold_markers) echo "Bold markers (**) detected";;
        emoji_usage) echo "Emoji usage detected";;
        frontmatter_missing) echo "Missing command front matter";;
        *) echo "$1";;
    esac
}

describe_reminder_category() {
    case "$1" in
        rule_headers) echo "Rule header reminders";;
        *) echo "$1";;
    esac
}

describe_issue_rule() {
    case "$1" in
        bold_markers) echo "Rule 99 · Bold markers forbidden";;
        emoji_usage) echo "Rule 99 · Emoji usage restricted";;
        frontmatter_missing) echo "Rule 99 · Slash command front matter";;
        *) echo "$1";;
    esac
}

describe_issue_action() {
    case "$1" in
        bold_markers) echo "Strip Markdown emphasis from LLM instructions; keep glob literals as plain text";;
        emoji_usage) echo "Remove pictographs from rule/command files; limit emoji to status markers only";;
        frontmatter_missing) echo "Add YAML front matter with name/description per slash command spec";;
        *) echo "Review and remediate per rules/99-llm-prompt-writing-rules.md";;
    esac
}

format_issue_files() {
    local idx="$1"
    local data="${issue_files[$idx]-}"
    local formatted=""
    local line

    if [[ -z "$data" ]]; then
        printf '%s' "none"
        return
    fi

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ -z "$formatted" ]]; then
            formatted="$line"
        else
            formatted+=", $line"
        fi
    done <<< "$data"

    printf '%s' "$formatted"
}

print_section() {
    echo "=== $*"
}

print_subsection() {
    echo "--- $*"
}

print_success() {
    echo "SUCCESS: $*"
}

print_warning() {
    echo "WARNING: $*"
}

print_error() {
    echo "ERROR: $*"
}

add_target_file() {
    local path="$1"
    [[ -f "$path" ]] || return
    if is_human_document "$path"; then
        return
    fi
    if has_seen_target "$path"; then
        return
    fi
    seen_targets+=("$path")
    TARGET_FILES+=("$path")
}

discover_target_files() {
    if [[ -z "$TARGET_FILE" ]]; then
        add_target_file "$CLAUDE_CONFIG_DIR/CLAUDE.md"
        add_target_file "$CLAUDE_CONFIG_DIR/AGENTS.md"
        add_target_file "$CLAUDE_CONFIG_DIR/settings.json"

        if [[ -d "$CLAUDE_CONFIG_DIR/rules" ]]; then
            while IFS= read -r -d '' file; do
                add_target_file "$file"
            done < <(find "$CLAUDE_CONFIG_DIR/rules" -name "*.md" -print0 2>/dev/null || true)
        fi

        if [[ -d "$CLAUDE_CONFIG_DIR/commands" ]]; then
            while IFS= read -r -d '' file; do
                add_target_file "$file"
            done < <(find "$CLAUDE_CONFIG_DIR/commands" -name "*.md" -print0 2>/dev/null || true)
        fi

        if [[ -d "$CLAUDE_CONFIG_DIR/skills" ]]; then
            while IFS= read -r -d '' file; do
                add_target_file "$file"
            done < <(find "$CLAUDE_CONFIG_DIR/skills" -name "SKILL.md" -print0 2>/dev/null || true)
        fi
    else
        local target_path="$TARGET_FILE"
        if [[ ! "$target_path" = /* ]]; then
            target_path="$CLAUDE_CONFIG_DIR/$target_path"
        fi

        if [[ -f "$target_path" ]]; then
            add_target_file "$target_path"
        elif [[ -d "$target_path" ]]; then
            while IFS= read -r -d '' file; do
                add_target_file "$file"
            done < <(find "$target_path" -name "*.md" -print0 2>/dev/null || true)
        else
            print_error "Target not found: $target_path"
            exit 1
        fi
    fi

    printf '%s\n' "${TARGET_FILES[@]:-}"
}

# === Checks ===

check_bold_markers() {
    local file="$1"
    [[ "$file" == *.md ]] || return 0

    local bold_regex='(?<![`\\])\*\*(?![`/\\\s])(?:(?!\*\*)[^\r\n])*?(?<![`/\\\s])\*\*(?![`\\])'
    local matches
    matches="$(rg --pcre2 -n "$bold_regex" "$file" 2>/dev/null || true)"
    [[ -n "$matches" ]] || return 0

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local line_num="${line%%:*}"
        local snippet="${line#*:}"
        record_issue "bold_markers" "$file" "$line_num" "Contains bold markers: ${snippet}"
    done <<< "$matches"
}

check_emojis() {
    local file="$1"
    [[ "$file" == *.md ]] || return 0

    local matches
    matches="$(rg --pcre2 -n '\p{Extended_Pictographic}' "$file" 2>/dev/null || true)"
    [[ -n "$matches" ]] || return 0

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local line_num="${line%%:*}"
        local snippet="${line#*:}"
        record_issue "emoji_usage" "$file" "$line_num" "Contains emoji: ${snippet}"
    done <<< "$matches"
}

check_command_frontmatter() {
    local file="$1"
    [[ "$file" == *.md ]] || return 0

    local first_line
    first_line="$(head -n 1 "$file" 2>/dev/null || true)"

    if [[ "$first_line" != "---" ]]; then
        record_issue "frontmatter_missing" "$file" 1 "Missing opening --- front matter delimiter"
        return
    fi

    local delimiter_count
    delimiter_count=$(grep -c '^---$' "$file" 2>/dev/null || true)
    if (( delimiter_count < 2 )); then
        record_issue "frontmatter_missing" "$file" 1 "Missing closing --- front matter delimiter"
    fi
}

check_rule_headers() {
    local file="$1"
    [[ "$file" == *.md ]] || return 0

    local head_cache
    head_cache="$(head -n 10 "$file")"

    if ! grep -q "# Cursor Rules" <<< "$head_cache"; then
        record_reminder "rule_headers" "$file" 1 "Missing # Cursor Rules header"
    fi
    if ! grep -q "# Copilot Instructions" <<< "$head_cache"; then
        record_reminder "rule_headers" "$file" 1 "Missing # Copilot Instructions header"
    fi
    if ! grep -q "# Kiro Steering" <<< "$head_cache"; then
        record_reminder "rule_headers" "$file" 1 "Missing # Kiro Steering header"
    fi
}

# === Analysis ===

analyze_files() {
    local files=("$@")
    print_section "review-llm-prompts"
    print_subsection "Scanning ${#files[@]} LLM-facing files"

    for file in "${files[@]}"; do
        [[ -f "$file" ]] || continue

        check_bold_markers "$file"
        check_emojis "$file"

        if [[ "$file" == */commands/* ]]; then
            check_command_frontmatter "$file"
        elif [[ "$file" == */rules/* ]]; then
            check_rule_headers "$file"
        fi
    done
}

print_issue_summary() {
    print_section "Issue Summary"

    if [[ ${#issue_categories[@]} -eq 0 ]]; then
        print_success "No blocking issues detected"
    else
        local idx
        for idx in "${!issue_categories[@]}"; do
            local category="${issue_categories[$idx]}"
            local count="${issue_counts[$idx]}"
            echo "- $(describe_issue_category "$category"): $count occurrence(s)"
        done
    fi

    if [[ ${#reminder_categories[@]} -gt 0 ]]; then
        print_subsection "Reminders"
        local idx
        for idx in "${!reminder_categories[@]}"; do
            local category="${reminder_categories[$idx]}"
            local count="${reminder_counts[$idx]}"
            echo "- $(describe_reminder_category "$category"): $count reminder(s)"
        done
    fi

    if [[ ${#issue_categories[@]} -gt 0 ]]; then
        print_section "Detailed Findings"
        local idx
        for idx in "${!issue_categories[@]}"; do
            local category="${issue_categories[$idx]}"
            print_subsection "$(describe_issue_category "$category")"
            printf '%s\n' "${issue_details[$idx]}"
        done
    fi

    if [[ ${#reminder_categories[@]} -gt 0 ]]; then
        print_section "Reminders Detail"
        local idx
        for idx in "${!reminder_categories[@]}"; do
            local category="${reminder_categories[$idx]}"
            print_subsection "$(describe_reminder_category "$category")"
            printf '%s\n' "${reminder_details[$idx]}"
        done
    fi
}

print_remediation_plan() {
    print_section "Remediation Plan"

    if [[ ${#issue_categories[@]} -eq 0 ]]; then
        echo "- OK: No remediation needed; continue monitoring"
        return
    fi

    local idx
    for idx in "${!issue_categories[@]}"; do
        local category="${issue_categories[$idx]}"
        local rule_desc
        local files_desc
        local action_desc

        rule_desc="$(describe_issue_rule "$category")"
        files_desc="$(format_issue_files "$idx")"
        action_desc="$(describe_issue_action "$category")"

        echo "- WARN: ${rule_desc}: files → ${files_desc} | action → ${action_desc}"
    done
}

# === Argument Parsing ===

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target=*)
                TARGET_FILE="${1#*=}"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --debug)
                export DEBUG=1
                shift
                ;;
            -h|--help)
                cat << 'EOF'
Review LLM Prompts - Analyze LLM-facing files for compliance

USAGE:
    review.sh [OPTIONS]

OPTIONS:
    --target=<path>     Specific file or directory to analyze
    --dry-run           Reserved for backward compatibility (analysis is read-only)
    --debug             Enable debug output
    -h, --help          Show this help message
EOF
                exit 0
                ;;
            *)
                print_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

# === Main ===

main() {
    parse_arguments "$@"

    local files=()
    while IFS= read -r file; do
        files+=("$file")
    done < <(discover_target_files)

    if [[ ${#files[@]} -eq 0 ]]; then
        print_warning "No LLM-facing files discovered"
        exit 0
    fi

    analyze_files "${files[@]}"
    print_issue_summary
    print_remediation_plan
    print_success "review complete"
}

main "$@"
