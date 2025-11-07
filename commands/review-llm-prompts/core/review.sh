#!/bin/bash

# Review LLM Prompts - Core Implementation
# Analyze LLM-facing files for compliance with LLM prompt writing standards

set -euo pipefail

# === Configuration ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_CONFIG_DIR="${HOME}/.claude"
TARGET_FILE=""
MODE="analyze"
DRY_RUN=false

# === Utility Functions ===

debug_print() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "DEBUG: $*" >&2
    fi
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

# === Core Analysis Functions ===

analyze_claude_md() {
    local file="$1"
    print_subsection "Analyzing CLAUDE.md"

    # Check for clear trigger keywords in rule descriptions
    if grep -q "99-llm-prompt-writing-rules.md" "$file"; then
        local rule_line=$(grep -n "99-llm-prompt-writing-rules.md" "$file")
        local line_num=$(echo "$rule_line" | cut -d: -f1)
        local description=$(echo "$rule_line" | cut -d: -f2-)

        if echo "$description" | grep -q -E "(when user asks about|commands|rules|guidelines|standards)"; then
            print_success "Rule description has clear trigger keywords"
        else
            print_warning "Rule description lacks clear trigger keywords (line $line_num)"
            echo "PROPOSAL: Change \"$description\" to include explicit trigger conditions like \"when user asks about: commands, rules, guidelines\""
        fi
    else
        print_warning "99-llm-prompt-writing-rules.md not found in CLAUDE.md"
    fi
}

analyze_agents_md() {
    local file="$1"
    print_subsection "Analyzing AGENTS.md"

    # Check for LLM prompt rules priority
    if grep -q "99-llm-prompt-writing-rules.md" "$file"; then
        print_success "AGENTS.md references LLM prompt writing rules"
    else
        print_warning "AGENTS.md does not reference LLM prompt writing rules"
        echo "PROPOSAL: Add reference to 99-llm-prompt-writing-rules.md with clear priority instructions"
    fi
}

analyze_rules_file() {
    local file="$1"
    local basename=$(basename "$file")
    print_subsection "Analyzing $basename"

    # Check for proper frontmatter
    if head -10 "$file" | grep -q "^---"; then
        print_success "Has YAML frontmatter"

        # Check for Cursor Rules section
        if head -10 "$file" | grep -q "# Cursor Rules"; then
            print_success "Has Cursor Rules section"
        else
            print_warning "Missing # Cursor Rules section in frontmatter"
        fi

        # Check for Copilot Instructions section
        if head -10 "$file" | grep -q "# Copilot Instructions"; then
            print_success "Has Copilot Instructions section"
        else
            print_warning "Missing # Copilot Instructions section in frontmatter"
        fi
    else
        print_warning "Missing YAML frontmatter"
        echo "PROPOSAL: Add proper frontmatter with Cursor Rules and Copilot Instructions sections"
    fi
}

analyze_command_file() {
    local file="$1"
    local basename=$(basename "$file")
    print_subsection "Analyzing command $basename"

    # Check for proper frontmatter
    if head -10 "$file" | grep -q "^---"; then
        print_success "Has YAML frontmatter"

        # Check for applyTo field for command files
        if head -10 "$file" | grep -q "applyTo:"; then
            print_success "Has applyTo field"
        else
            print_warning "Missing applyTo field in frontmatter"
        fi
    else
        print_warning "Missing YAML frontmatter"
    fi
}

# === File Discovery ===

discover_target_files() {
    local targets=()

    if [[ -z "$TARGET_FILE" ]]; then
        # Default: analyze all LLM-facing files
        targets+=("$CLAUDE_CONFIG_DIR/CLAUDE.md")
        targets+=("$CLAUDE_CONFIG_DIR/AGENTS.md")

        # Add all rules files
        while IFS= read -r -d '' file; do
            targets+=("$file")
        done < <(find "$CLAUDE_CONFIG_DIR/rules" -name "*.md" -print0 2>/dev/null || true)

        # Add all command files
        while IFS= read -r -d '' file; do
            targets+=("$file")
        done < <(find "$CLAUDE_CONFIG_DIR/commands" -name "*.md" -print0 2>/dev/null || true)
    else
        # Specific target
        local target_path="$TARGET_FILE"
        if [[ ! "$target_path" = /* ]]; then
            target_path="$CLAUDE_CONFIG_DIR/$target_path"
        fi

        if [[ -f "$target_path" ]]; then
            targets+=("$target_path")
        elif [[ -d "$target_path" ]]; then
            while IFS= read -r -d '' file; do
                targets+=("$file")
            done < <(find "$target_path" -name "*.md" -print0)
        else
            print_error "Target not found: $target_path"
            echo "Tried: $target_path"
            exit 1
        fi
    fi

    printf '%s\n' "${targets[@]}"
}

# === Proposal Generation Functions ===

generate_proposals() {
    local files=("$@")
    local total_proposals=0

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_warning "File not found: $file"
            continue
        fi

        local basename=$(basename "$file")
        print_subsection "Generating proposals for $basename"

        case "$basename" in
            "CLAUDE.md")
                generate_claude_md_proposals "$file"
                ;;
            "AGENTS.md")
                generate_agents_md_proposals "$file"
                ;;
            *.md)
                if [[ "$file" =~ /rules/ ]]; then
                    generate_rules_file_proposals "$file"
                elif [[ "$file" =~ /commands/ ]]; then
                    generate_command_file_proposals "$file"
                else
                    print_warning "Unknown file type, generating basic proposals"
                    generate_basic_proposals "$file"
                fi
                ;;
            *)
                print_warning "Skipping non-markdown file: $file"
                continue
                ;;
        esac
        echo
    done

    print_section "Proposal Generation Summary"
    echo "Files analyzed: ${#files[@]}"
    echo "Total proposals generated: $total_proposals"
    echo
    echo "=== Next Steps"
    echo "Review the proposals above and apply changes manually or:"
    echo "1. Create backup of target files"
    echo "2. Apply modifications one by one"
    echo "3. Run /review-llm-prompts --mode=validate to verify"
}

generate_claude_md_proposals() {
    local file="$1"
    local temp_file=$(mktemp)

    while IFS= read -r line; do
        if echo "$line" | grep -q "99-llm-prompt-writing-rules.md.*-.*LLM-facing work"; then
            print_success "Found CLAUDE.md line to improve"
            echo "PROPOSAL: Improve rule description with clear trigger keywords"
            echo "CURRENT: $line"
            echo "PROPOSED: - \`99-llm-prompt-writing-rules.md\` - AI/LLM agent development (when user asks about: commands, rules, guidelines, standards, patterns, principles, prompt writing, AI systems, agents, skills, automation, tools, or similar topics)"
            echo
        fi
    done < "$file"

    rm -f "$temp_file"
}

generate_agents_md_proposals() {
    local file="$1"

    if ! grep -q "99-llm-prompt-writing-rules.md" "$file"; then
        print_success "Found missing LLM prompt rules reference"
        echo "PROPOSAL: Add LLM prompt writing rules reference with clear priority"
        echo "LOCATION: Add after Rule Sources section, before Memory & Settings Expectations"
        echo "CONTENT TO ADD:"
        echo "## LLM Prompt Writing Priority"
        echo "- \`@rules/99-llm-prompt-writing-rules.md\` is ALWAYS loaded for ANY discussion involving:"
        echo "  - AI agents, LLMs, or coding assistants"
        echo "  - Commands, skills, or prompts"
        echo "  - AI-facing rules or documentation"
        echo "  - Agent configuration or behavior"
        echo "- This rule supersedes all other rules for AI-related discussions"
        echo
    fi
}

generate_rules_file_proposals() {
    local file="$1"
    local basename=$(basename "$file")

    if ! head -10 "$file" | grep -q "^---"; then
        print_success "Found missing frontmatter"
        echo "RECOMMENDATION: Consider adding frontmatter to $basename for better tool compatibility"
        echo "OPTIONAL CONTENT (customize as needed):"
        cat << 'EOF'
---
# Cursor Rules
alwaysApply: false  # Set to true only if this rule should always apply

# Copilot Instructions
applyTo: "**/*"     # Adjust based on rule scope, or use context-based matching

# Kiro Steering
inclusion: contextual  # Or "always" for universal rules
---
EOF
        echo "NOTE: Frontmatter is optional - rules can also be loaded via CLAUDE.md context"
        echo
    fi

    # Check if rule has clear scope/purpose indication
    if ! head -20 "$file" | grep -q -E "(Apply|Scope|When to use|Purpose)"; then
        print_success "Found unclear rule scope"
        echo "RECOMMENDATION: Add clear scope/purpose description early in the file"
        echo "EXAMPLE: Add a section like:"
        echo "## When This Rule Applies"
        echo "- Use this rule when working with [specific contexts]"
        echo "- Applies to [file types or situations]"
        echo
    fi
}

generate_command_file_proposals() {
    local file="$1"
    local basename=$(basename "$file")

    if ! head -10 "$file" | grep -q "^---"; then
        print_success "Found missing frontmatter"
        echo "PROPOSAL: Add proper frontmatter to $basename"
        echo "CONTENT TO ADD at file start:"
        cat << 'EOF'
---
# Cursor Rules
alwaysApply: false

# Copilot Instructions
applyTo: "commands/**/*.md"

# Kiro Steering
inclusion: contextual
---
EOF
        echo
    fi

    if head -10 "$file" | grep -q "^---" && ! head -15 "$file" | grep -q "applyTo:"; then
        print_success "Found missing applyTo field"
        echo "PROPOSAL: Add applyTo field in frontmatter"
        echo "EXAMPLE: applyTo: \"commands/**/*.md\""
        echo
    fi
}

generate_basic_proposals() {
    local file="$1"
    print_warning "Generating basic proposals for unknown file type"
    echo "RECOMMENDATION: Ensure file has proper markdown structure and clear headings"
    echo
}

# === Validation Functions ===

validate_changes() {
    local files=("$@")
    local total_validations=0
    local passed_validations=0

    print_subsection "Validating files against LLM prompt writing standards"

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_warning "File not found: $file"
            continue
        fi

        local basename=$(basename "$file")
        echo "Validating: $basename"

        # Check for forbidden bold markers (critical for LLM-facing files)
        if grep -q "\*\*.*\*\*" "$file"; then
            print_error "Contains bold markers (forbidden in LLM-facing files)"
        else
            print_success "No forbidden bold markers"
            ((passed_validations++))
        fi
        ((total_validations++))

        # Check for imperative language in rules (important for AI comprehension)
        if [[ "$file" =~ /rules/ ]]; then
            local imperative_count
            imperative_count=$(grep -c "^[[:space:]]*- [A-Z][a-z]" "$file" 2>/dev/null || echo "0")
            imperative_count=$(echo "$imperative_count" | tr -d '\n\r' | head -1)

            if [[ "$imperative_count" -gt 5 ]]; then
                print_success "Uses imperative language consistently ($imperative_count imperative statements)"
                ((passed_validations++))
            elif [[ "$imperative_count" -gt 0 ]]; then
                print_warning "Some imperative language use ($imperative_count statements), could be more consistent"
                ((passed_validations++))
            else
                print_warning "Limited imperative language use - consider using more direct, actionable statements"
                ((passed_validations++))
            fi
            ((total_validations++))
        fi

        # Check for clear structure (headings, organization)
        local heading_count
        heading_count=$(grep -c "^##" "$file" || echo "0")
        if [[ "$heading_count" -gt 2 ]]; then
            print_success "Well-structured with clear headings ($heading_count sections)"
            ((passed_validations++))
        elif [[ "$heading_count" -gt 0 ]]; then
            print_warning "Some structure but could benefit from more clear headings"
            ((passed_validations++))
        else
            print_warning "Lacks clear structure - consider adding descriptive headings"
            ((passed_validations++))
        fi
        ((total_validations++))

        # Check for examples (very helpful for AI understanding)
        if grep -q -E '(```|Example|For instance:)' "$file"; then
            print_success "Includes examples or code blocks"
            ((passed_validations++))
        else
            print_warning "Could benefit from concrete examples"
            ((passed_validations++))
        fi
        ((total_validations++))
    done

    echo
    print_section "Validation Results Summary"
    echo "Total validations: $total_validations"
    echo "Passed validations: $passed_validations"

    if [[ $total_validations -gt 0 ]]; then
        echo "Success rate: $(( passed_validations * 100 / total_validations ))%"
    fi

    if [[ $total_validations -eq 0 ]]; then
        print_warning "No validations performed"
    elif [[ $passed_validations -eq $total_validations ]]; then
        print_success "All validations passed!"
    else
        print_warning "Some validations need attention. Review suggestions above."
    fi
}

analyze_files() {
    local files=("$@")

    print_section "Scanning ~/.claude/ for LLM-facing files"
    echo "Found ${#files[@]} files to analyze"
    echo

    local total_issues=0
    local total_proposals=0

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_warning "File not found: $file"
            continue
        fi

        local basename=$(basename "$file")

        case "$basename" in
            "CLAUDE.md")
                analyze_claude_md "$file"
                ;;
            "AGENTS.md")
                analyze_agents_md "$file"
                ;;
            *.md)
                if [[ "$file" =~ /rules/ ]]; then
                    analyze_rules_file "$file"
                elif [[ "$file" =~ /commands/ ]]; then
                    analyze_command_file "$file"
                else
                    print_subsection "Analyzing $basename"
                    print_warning "Unknown file type, performing basic checks"
                fi
                ;;
            *)
                print_warning "Skipping non-markdown file: $file"
                continue
                ;;
        esac
        echo
    done

    print_section "Analysis Summary"
    echo "Files analyzed: ${#files[@]}"
    echo "Issues found: $total_issues"
    echo "Proposals generated: $total_proposals"
}

# === Argument Parsing ===

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target=*)
                TARGET_FILE="${1#*=}"
                shift
                ;;
            --mode=*)
                MODE="${1#*=}"
                if [[ ! "$MODE" =~ ^(analyze|propose|validate)$ ]]; then
                    print_error "Invalid mode: $MODE. Use analyze, propose, or validate"
                    exit 1
                fi
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
                cat << EOF
Review LLM Prompts - Analyze LLM-facing files for compliance

USAGE:
    $(basename "$0") [OPTIONS]

OPTIONS:
    --target=<path>     Specific file or directory to analyze
    --mode=<mode>       Operation mode: analyze|propose|validate (default: analyze)
    --dry-run           Show analysis without making changes
    --debug             Enable debug output
    -h, --help          Show this help message

EXAMPLES:
    $(basename "$0")                           # Analyze all LLM-facing files
    $(basename "$0") --target=CLAUDE.md       # Analyze specific file
    $(basename "$0") --mode=propose           # Generate improvement proposals
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

# === Main Entry Point ===

main() {
    parse_arguments "$@"

    debug_print "CLAUDE_CONFIG_DIR: $CLAUDE_CONFIG_DIR"
    debug_print "TARGET_FILE: $TARGET_FILE"
    debug_print "MODE: $MODE"
    debug_print "DRY_RUN: $DRY_RUN"

    # Discover target files
    local files=()
    while IFS= read -r file; do
        files+=("$file")
    done < <(discover_target_files)

    # Run analysis
    case "$MODE" in
        analyze)
            analyze_files "${files[@]}"
            ;;
        propose)
            echo "=== Generating Improvement Proposals"
            echo
            generate_proposals "${files[@]}"
            ;;
        validate)
            echo "=== Validating Changes Against Standards"
            echo
            validate_changes "${files[@]}"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"