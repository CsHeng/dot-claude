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
            cp "$file" "$target_dir/$(basename "$file")"
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

generate_qwen_memory() {
    local memory_file="$HOME/.qwen/QWEN.md"
    ensure_directory "$(dirname "$memory_file")"
    cat > "$memory_file" <<'EOF'
# Qwen CLI User Memory

## Available Rules

Development guidelines available in `rules/` directory:

- `00-user-preferences.md`
- `01-general-development.md`
- `02-architecture-patterns.md`
- `03-security-guidelines.md`
- `04-testing-strategy.md`
- `05-error-handling.md`
- `10-python-guidelines.md`
- `11-go-guidelines.md`
- `12-shell-guidelines.md`
- `13-docker-guidelines.md`
- `14-networking-guidelines.md`
- `20-development-tools.md`
- `21-code-quality.md`
- `22-logging-standards.md`
- `23-workflow-patterns.md`

## Quick Start

```bash
qwen -p "$(cat ~/.qwen/rules/00-user-preferences.md)"

qwen -p "$(cat ~/.qwen/rules/00-user-preferences.md ~/.qwen/rules/10-python-guidelines.md)"

qwen -i -p "$(cat ~/.qwen/rules/01-general-development.md)"
```

EOF
    log_success "Qwen memory file refreshed"
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
        cp "$src" "$dest"
    fi

    echo "$dest"
}

command_clean_prefixed_files() {
    local target_dir="$1"
    local prefix="$2"
    [[ -d "$target_dir" ]] || return
    find "$target_dir" -maxdepth 1 -type f -name "${prefix}*" -exec rm -f {} + 2>/dev/null
}
