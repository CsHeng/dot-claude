---
name: "config-sync:qwen"
description: Qwen CLI specific operations with TOML conversion
argument-hint: --action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>
---

# Config-Sync Qwen Command

## Task
Handle Qwen CLI-specific configuration synchronization with automatic TOML conversion during sync operations.

> Multi-select support: pass comma-separated values such as `--component=rules,commands` to process multiple components in a single run.

## Implementation

```bash
# Parse arguments
ACTION="sync"
COMPONENT="all"

for arg in "$@"; do
  case $arg in
    --action=*) ACTION="${arg#--action=}" ;;
    --component=*) COMPONENT="${arg#--component=}" ;;
  esac
done

# Quiet sync operation
source ~/.claude/commands/config-sync/scripts/executor.sh

if ! declare -F check_tool_installed >/dev/null 2>&1; then
  check_tool_installed() { command -v "$1" >/dev/null 2>&1; }
fi

ensure_python_available() {
  if ! check_tool_installed python3; then
    echo "[qwen-adapter] python3 is required for content conversion" >&2
    exit 1
  fi
}

ensure_jq_available() {
  if ! check_tool_installed jq; then
    echo "[qwen-adapter] jq is required for settings updates" >&2
    exit 1
  fi
}

# Setup directories
CLAUDE_ROOT="$HOME/.claude"
QWEN_ROOT="$HOME/.qwen"
mkdir -p "$QWEN_ROOT/commands" "$QWEN_ROOT/rules"

case "$COMPONENT" in
  all|commands)
    # Sync ALL commands (not just config-sync)
    SOURCE_COMMANDS="$CLAUDE_ROOT/commands"
    TARGET_COMMANDS="$QWEN_ROOT/commands"
    if [[ -d "$SOURCE_COMMANDS" ]]; then
      while IFS= read -r -d '' cmd_file; do
        rel_path="${cmd_file#$SOURCE_COMMANDS/}"
        rel_path="${rel_path%.md}.toml"
        toml_file="$TARGET_COMMANDS/$rel_path"

        convert_markdown_to_toml "$cmd_file" "$toml_file" "qwen"
      done < <(find "$SOURCE_COMMANDS" -type f -name "*.md" -print0)

      # Remove legacy Markdown command files from target
      while IFS= read -r -d '' legacy_md; do
        echo "[qwen-adapter] Removing legacy markdown command: $legacy_md" >&2
        rm "$legacy_md"
      done < <(find "$TARGET_COMMANDS" -type f -name "*.md" -print0)
    else
      echo "[qwen-adapter] Skipping commands sync, no source commands at $SOURCE_COMMANDS" >&2
    fi
    ;;
esac

case "$COMPONENT" in
  all|rules)
    SOURCE_RULES="$CLAUDE_ROOT/rules"
    TARGET_RULES="$QWEN_ROOT/rules"
    if [[ -d "$SOURCE_RULES" ]]; then
      ensure_python_available
      python3 - "$SOURCE_RULES" "$TARGET_RULES" <<'PY'
import sys
from pathlib import Path

src_base = Path(sys.argv[1])
dst_base = Path(sys.argv[2])
dst_base.mkdir(parents=True, exist_ok=True)

for src in src_base.rglob('*.md'):
    rel = src.relative_to(src_base)
    dst = dst_base / rel
    dst.parent.mkdir(parents=True, exist_ok=True)

    content = src.read_text(encoding='utf-8')
    if content.startswith('---\n'):
        closing = content.find('\n---', 4)
        if closing != -1:
            content = content[closing + 4:]

    content = content.lstrip()

    if dst.exists():
        current = dst.read_text(encoding='utf-8')
        if current == content:
            continue

    dst.write_text(content, encoding='utf-8')
PY
    else
      echo "[qwen-adapter] Skipping rules sync, no source rules at $SOURCE_RULES" >&2
    fi
    ;;
esac

case "$COMPONENT" in
  all|settings)
    SETTINGS_FILE="$QWEN_ROOT/settings.json"
    mkdir -p "$QWEN_ROOT"
    ensure_jq_available

    if [[ -f "$SETTINGS_FILE" ]]; then
      tmp_file="$(mktemp)"
      jq '(
            if has("model") and (.model|type=="object") then . else . + {"model":{"name":"qwen-max"}} end
          )
          | (if has("temperature") then . else . + {"temperature":0.1} end)
          | (if has("$version") then . else . + {"$version":2} end)
          ' "$SETTINGS_FILE" > "$tmp_file"
      mv "$tmp_file" "$SETTINGS_FILE"
    else
      jq -n '{"model":{"name":"qwen-max"},"temperature":0.1,"$version":2}' > "$SETTINGS_FILE"
    fi
    ;;
esac

echo "Qwen sync complete: $COMPONENT"
```
