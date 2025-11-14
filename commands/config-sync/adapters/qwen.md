---
name: "config-sync:qwen"
description: "Qwen CLI specific operations with TOML conversion"
argument-hint: "--action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(python3:*)
  - Bash(jq:*)
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(cat:*)
disable-model-invocation: true
is_background: false
---

## Usage
```bash
/config-sync:qwen --action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>
```

## Arguments
- **action**: Operation mode - sync, analyze, or verify
- **component**: Components to process - comma-separated list or all

## Workflow
1. **Parameter Parsing**: Extract action and component specifications
2. **Tool Validation**: Verify python3 and jq availability
3. **Qwen Analysis**: Examine existing Qwen CLI configuration
4. **Content Conversion**: Convert Claude formats to Qwen-compatible formats
5. **TOML Processing**: Convert command files to TOML format
6. **Permission Setup**: Generate JSON permission manifests
7. **Verification**: Validate synchronization completeness

### Qwen CLI Features
- **Command Format**: TOML conversion from Markdown
- **Permissions**: JSON permission manifests
- **Conversion Required**: Automatic format transformation
- **Dependencies**: python3 and jq required for processing

### Component Processing
- **Rules**: Direct sync to Qwen rules directory
- **Commands**: Convert from Markdown to TOML format
- **Settings**: Generate Qwen-specific configuration files
- **Memory**: Configure AGENTS.md and QWEN.md references
- **Permissions**: Convert to JSON permission manifests

### Dependencies
- **python3**: Required for content conversion
- **jq**: Required for settings updates and JSON processing

## Output
- **Converted Commands**: TOML format command files
- **Synced Components**: Rules and settings in Qwen directories
- **Permission Manifests**: JSON permission configurations
- **Conversion Report**: Format transformation summary
- **Verification Results**: Component-by-component status
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

      # Remove stray Markdown command files from target
      while IFS= read -r -d '' stale_md; do
        echo "[qwen-adapter] Removing stray markdown command: $stale_md" >&2
        rm "$stale_md"
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
