#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

ensure_directory() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        return
    fi
    log_info "Creating directory: $dir"
    mkdir -p "$dir"
}

clean_markdown_targets() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    find "$dir" -name "*.md" -type f -delete >/dev/null 2>&1 || true
}

copy_markdown_rules() {
    local target_dir="$1"
    shift
    local source_dirs=("$@")

    ensure_directory "$target_dir"
    clean_markdown_targets "$target_dir"

    local total=0
    for source_dir in "${source_dirs[@]}"; do
        [[ -d "$source_dir" ]] || continue
        while IFS= read -r -d '' file; do
            rsync -a --quiet "$file" "$target_dir/$(basename "$file")"
            total=$((total + 1))
        done < <(find "$source_dir" -maxdepth 1 -name "*.md" -type f -print0)
    done

    echo "$total"
}

verify_markdown_count() {
    local dir="$1"
    local count=0
    if [[ -d "$dir" ]]; then
        count=$(find "$dir" -name "*.md" -type f 2>/dev/null | wc -l)
        count=${count:-0}
    fi
    echo "$count"
}

generate_tool_memory() {
    local tool_name="$1"
    local memory_file="$2"
    local claudemd_file="$HOME/.claude/CLAUDE.md"

    ensure_directory "$(dirname "$memory_file")"

    # Check if CLAUDE.md exists
    if [[ ! -f "$claudemd_file" ]]; then
        log_error "CLAUDE.md not found at $claudemd_file"
        return 1
    fi

    # Read CLAUDE.md content and adapt it for the specific tool
    local tool_memory_content
    tool_memory_content=$(adapt_claude_memory_for_tool "$tool_name" "$memory_file" "$claudemd_file")

    # Write the adapted content to the target memory file
    echo "$tool_memory_content" > "$memory_file"

    log_success "$tool_name memory file generated: $memory_file"
}

adapt_claude_memory_for_tool() {
    local tool_name="$1"
    local claudemd_file="$2"

    # Determine tool-specific replacements
    local tool_cli_name=""
    local tool_memory_file=""
    local tool_agents_file=""
    local tool_settings_ref=""

    case "$tool_name" in
        qwen)
            tool_cli_name="Qwen CLI"
            tool_memory_file="QWEN.md"
            tool_agents_file="AGENTS.md"
            tool_settings_ref="@~/.qwen/settings.json"
            ;;
        codex)
            tool_cli_name="Codex CLI"
            tool_memory_file="CODEX.md"
            tool_agents_file="AGENTS.md"
            tool_settings_ref="@~/.codex/settings.json"
            ;;
        droid)
            tool_cli_name="Factory/Droid CLI"
            tool_memory_file="DROID.md"
            tool_agents_file="AGENTS.md"
            tool_settings_ref="@~/.factory/settings.json"
            ;;
        *)
            log_error "Unknown tool: $tool_name"
            return 1
            ;;
    esac

    # Read and adapt the content
    python3 - "$tool_name" "$tool_cli_name" "$tool_memory_file" "$tool_agents_file" "$tool_settings_ref" "$claudemd_file" <<'PYCODE'
import sys
import re

tool_name = sys.argv[1] if len(sys.argv) > 1 else ""
tool_cli_name = sys.argv[2] if len(sys.argv) > 2 else ""
tool_memory_file = sys.argv[3] if len(sys.argv) > 3 else ""
tool_agents_file = sys.argv[4] if len(sys.argv) > 4 else ""
tool_settings_ref = sys.argv[5] if len(sys.argv) > 5 else ""
claudemd_file = sys.argv[6] if len(sys.argv) > 6 else ""

# Read CLAUDE.md content
with open(claudemd_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace tool-specific references
replacements = {
    r'# User Memory': f'# {tool_cli_name} User Memory',
    r'Claude Code': tool_cli_name,
    r'@CLAUDE\.md': f'@{tool_memory_file}',
    r'Load `@CLAUDE\.md`': f'Load `@{tool_memory_file}`',
    r'Keep `@CLAUDE\.md` in context': f'Keep `@{tool_memory_file}` in context',
    r'Memory index.*`@CLAUDE\.md`.*Mapping of rule files for fast lookup': f'Memory index | `@{tool_memory_file}` | Mapping of rule files for fast lookup',
    r'Shared permission policy.*`@\.claude/settings\.json`': f'Shared permission policy | {tool_settings_ref}',
    r'Follow the instructions below whenever you operate within this configuration': f'Follow the instructions below whenever you operate with {tool_cli_name}',
    r'Reference specific rule files in prompts.*reference `@rules/04-testing-strategy\.md` to write pytest cases': f'Reference specific rule files in prompts, for example:\n  ```bash\n  {tool_cli_name.lower().replace(" ", "").replace("/", "")} "Follow testing strategy from @rules/04-testing-strategy.md to write pytest cases"\n  ```',
    r'AGENTS\.md.*notify the user so they can refresh `AGENTS\.md`': f'{tool_agents_file}. If you notice rule updates that are not reflected here, notify the user so they can refresh `{tool_agents_file}`.',
}

# Apply replacements
for pattern, replacement in replacements.items():
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

# Add tool-specific execution guidelines section if not present
if '## Execution Guidelines' in content:
    # Replace tool-specific execution guidelines
    execution_guidelines = {
        r'PlantUML diagrams.*PlantUML ≥ 1\.2025\.9\.': f'PlantUML diagrams: validate with `plantuml --check-syntax <path>` (PlantUML ≥ 1.2025.9).',
        r'Shell scripts.*@rules/12-shell-guidelines\.md\.': f'Shell scripts: run the appropriate syntax check (`bash -n`, `sh -n`, or `zsh -n`) before proposing changes; ensure traps and strict mode adhere to `@rules/12-shell-guidelines.md`.',
    }

    for pattern, replacement in execution_guidelines.items():
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)

print(content)
PYCODE
}

generate_tool_agents_md() {
    local tool_name="$1"
    local target_file="$2"
    local agents_md_file="$HOME/.claude/AGENTS.md"
    local general_rules_dir="$HOME/.claude/rules"

    ensure_directory "$(dirname "$target_file")"

    # Check if AGENTS.md exists
    if [[ ! -f "$agents_md_file" ]]; then
        log_error "AGENTS.md not found at $agents_md_file"
        return 1
    fi

    # Determine tool-specific replacements
    local tool_cli_name=""
    local tool_memory_file=""
    local tool_rules_dir=""
    local tool_settings_ref=""

    case "$tool_name" in
        qwen)
            tool_cli_name="Qwen CLI"
            tool_memory_file="QWEN.md"
            tool_rules_dir="$HOME/.qwen/rules"
            tool_settings_ref="@~/.qwen/settings.json"
            ;;
        codex)
            tool_cli_name="Codex CLI"
            tool_memory_file="CODEX.md"
            tool_rules_dir="$HOME/.codex/rules"
            tool_settings_ref="@~/.codex/settings.json"
            ;;
        droid)
            tool_cli_name="Factory/Droid CLI"
            tool_memory_file="DROID.md"
            tool_rules_dir="$HOME/.factory/rules"
            tool_settings_ref="@~/.factory/settings.json"
            ;;
        *)
            log_error "Unknown tool for AGENTS.md generation: $tool_name"
            return 1
            ;;
    esac

    # Read rule files for the tool
    local rule_files=()
    if [[ -d "$tool_rules_dir" ]]; then
        while IFS= read -r file; do
            rule_files+=("$file")
        done < <(find "$tool_rules_dir" -maxdepth 1 -name "*.md" -type f -print | LC_ALL=C sort)
    fi

    # Generate tool-specific AGENTS.md
    local generated_content
    generated_content=$(python3 - "$tool_name" "$tool_cli_name" "$tool_memory_file" "$tool_settings_ref" "$agents_md_file" "$tool_rules_dir" "${rule_files[@]}" <<'PYCODE'
import sys
import re
import os

tool_name = sys.argv[1] if len(sys.argv) > 1 else ""
tool_cli_name = sys.argv[2] if len(sys.argv) > 2 else ""
tool_memory_file = sys.argv[3] if len(sys.argv) > 3 else ""
tool_settings_ref = sys.argv[4] if len(sys.argv) > 4 else ""
agents_md_file = sys.argv[5] if len(sys.argv) > 5 else ""
tool_rules_dir = sys.argv[6] if len(sys.argv) > 6 else ""
rule_files = sys.argv[7:] if len(sys.argv) > 7 else []

def rule_heading(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('# '):
                    return line[2:].strip()
        # If no heading found, derive from filename
        base = os.path.basename(file_path)
        name = os.path.splitext(base)[0]
        if re.match(r'^\d{2}-(.+)$', name):
            return re.sub(r'-', ' ', re.match(r'^\d{2}-(.+)$', name).group(1)).title()
        return name.replace('-', ' ').title()
    except:
        return os.path.basename(file_path)

# Read the base AGENTS.md content
with open(agents_md_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace tool-specific references
replacements = {
    r'# Agent Operating Guide': f'# {tool_cli_name} Agent Operating Guide',
    r'Claude Code': tool_cli_name,
    r'@CLAUDE\.md': f'@{tool_memory_file}',
    r'Load `@CLAUDE\.md`': f'Load `@{tool_memory_file}`',
    r'Keep `@CLAUDE\.md` in context': f'Keep `@{tool_memory_file}` in context',
    r'Memory index.*`@CLAUDE\.md`.*Mapping of rule files for fast lookup': f'Memory index | `@{tool_memory_file}` | Mapping of rule files for fast lookup',
    r'Shared permission policy.*`@\.claude/settings\.json`': f'Shared permission policy | {tool_settings_ref}',
    r'Follow the instructions below whenever you operate within this configuration': f'Follow the instructions below whenever you operate with {tool_cli_name}',
    r'Primary agents.*Claude Code.*Qwen CLI.*Factory/Droid CLI': f'Primary agents: {tool_cli_name}',
    r'Shared context.*~/.claude/rules/\*\.md': f'Shared context: {tool_rules_dir}/*.md',
}

# Apply replacements
for pattern, replacement in replacements.items():
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

# Update the quick reference table
content = re.sub(
    r'\|.*Memory index.*\|.*@CLAUDE\.md.*\|.*Mapping of rule files for fast lookup.*\|',
    f'| Memory index | `@{tool_memory_file}` | Mapping of rule files for fast lookup |',
    content
)

# Update the final line about refreshing
content = re.sub(
    r'If you notice rule updates that are not reflected here, notify the user so they can refresh `AGENTS\.md`',
    f'If you notice rule updates that are not reflected here, notify the user so they can refresh `AGENTS.md`',
    content
)

print(content)
PYCODE
)

    # Write the generated content to the target file
    echo "$generated_content" > "$target_file"

    log_success "$tool_cli_name AGENTS.md generated: $target_file"
}

dry_run_report() {
    log_info "Dry run - no files copied"
    for entry in "$@"; do
        echo "  $entry"
    done
}

# ---- Custom command helpers -------------------------------------------------

_command_allowed_frontmatter_keys=("description" "argument-hint")

_command_is_allowed_key() {
    local key="$1"
    for allowed in "${_command_allowed_frontmatter_keys[@]}"; do
        if [[ "$allowed" == "$key" ]]; then
            return 0
        fi
    done
    return 1
}

command_flatten_filename() {
    local relative_path="$1"
    local extension=""
    if [[ "$relative_path" == *.* ]]; then
        extension=".${relative_path##*.}"
    fi

    local stem="$relative_path"
    if [[ -n "$extension" ]]; then
        stem="${relative_path%"$extension"}"
    fi

    stem="${stem//\//__}"
    stem="${stem// /-}"
    stem="$(echo "$stem" | tr '[:upper:]' '[:lower:]')"
    stem="$(echo "$stem" | sed 's/[^a-z0-9._-]/-/g')"

    echo "${stem}${extension}"
}

command_collect_sources() {
    local source_dir="$1"
    local -n out_ref=$2
    out_ref=()
    [[ -d "$source_dir" ]] || return

    while IFS= read -r -d '' absolute_path; do
        local relative
        if [[ "$absolute_path" == "$source_dir" ]]; then
            relative="$(basename "$absolute_path")"
        else
            relative="${absolute_path#"$source_dir"/}"
        fi

        if [[ "$relative" == *.md ]]; then
            out_ref+=("$relative")
            continue
        fi

        local first_line
        IFS= read -r first_line < "$absolute_path" || true
        if [[ "$first_line" == "#!"* ]]; then
            out_ref+=("$relative")
        fi
    done < <(find "$source_dir" -type f -print0)
}

command_sanitize_markdown() {
    local src="$1"
    local dest="$2"
    local -n _warnings=$3

    local python_output
    python_output=$(python3 - "$src" "$dest" <<'PYCODE'
import sys
import re

src, dest = sys.argv[1], sys.argv[2]
allowed_keys = {"description", "argument-hint"}
warnings = []

with open(src, 'r', encoding='utf-8') as fh:
    lines = fh.readlines()

result_lines = []
idx = 0

if lines and lines[0].strip() == '---':
    idx = 1
    captured = []
    while idx < len(lines) and lines[idx].strip() != '---':
        captured.append(lines[idx].rstrip('\n'))
        idx += 1
    if idx < len(lines):
        idx += 1  # Skip closing ---
        kept = []
        for line in captured:
            stripped = line.strip()
            if not stripped:
                continue
            if ':' not in stripped:
                warnings.append(f"frontmatter line ignored (no key): {line}")
                continue
            key, value = stripped.split(':', 1)
            key = key.strip()
            value = value.strip()
            if key in allowed_keys:
                kept.append(f"{key}: {value}\n")
            else:
                warnings.append(f"frontmatter key '{key}' removed (unsupported by Droid)")
        if kept:
            result_lines.append('---\n')
            result_lines.extend(kept)
            result_lines.append('---\n')
    else:
        # No closing delimiter; treat entire file as content
        idx = 0

content = lines[idx:]
body = ''.join(content)

if re.search(r"\$[1-9][0-9]*", body):
    warnings.append("positional placeholder ($1, $2, ...) detected; Droid only supports $ARGUMENTS")

result_lines.extend(content)

with open(dest, 'w', encoding='utf-8') as fh:
    fh.writelines(result_lines)

for message in warnings:
    print(f"WARN:{message}")
PYCODE
)
    local status=$?
    if (( status != 0 )); then
        log_error "Failed to sanitize markdown command: $src"
        return 1
    fi

    if [[ -n "$python_output" ]]; then
        local warning_lines=()
        mapfile -t warning_lines <<< "$python_output"
        for line in "${warning_lines[@]}"; do
            [[ -z "$line" ]] && continue
            if [[ "$line" == WARN:* ]]; then
                _warnings+=("${line#WARN:}")
            fi
        done
    fi

    return 0
}

command_copy_file() {
    local source_dir="$1"
    local relative_path="$2"
    local dest_dir="$3"
    local prefix="$4"
    local -n _warnings=$5

    local src="$source_dir/$relative_path"
    local flattened
    flattened=$(command_flatten_filename "$relative_path")

    local dest_basename="${prefix}${flattened}"
    local dest="$dest_dir/$dest_basename"

    ensure_directory "$dest_dir"

    if [[ "$dest" == *.md ]]; then
        command_sanitize_markdown "$src" "$dest" _warnings
    else
        rsync -a --quiet "$src" "$dest"
    fi

    echo "$dest"
}

command_clean_prefixed_files() {
    local target_dir="$1"
    local prefix="$2"
    [[ -d "$target_dir" ]] || return
    find "$target_dir" -maxdepth 1 -type f -name "${prefix}*" -exec rm -f {} + 2>/dev/null
}
