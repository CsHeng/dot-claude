---
name: "config-sync:qwen"
description: Qwen CLI specific operations with TOML conversion
argument-hint: --action=<sync|analyze|verify> --component=<rules|permissions|commands|settings|memory|all>
---

# Config-Sync Qwen Command

## Task
Handle Qwen CLI-specific configuration synchronization where `settings.json` carries the primary configuration. Command files still require Markdown→TOML conversion.

## Usage
```bash
/config-sync:qwen --action=<operation> --component=<type|all>
```

### Arguments
- `--action`: Operation (sync, analyze, verify)
- `--component`: Component type (rules, permissions, commands, settings, memory) or "all"

## Quick Examples

### Sync all components to Qwen
```bash
/config-sync:qwen --action=sync --component=all
```

### Analyze Qwen configuration
```bash
/config-sync:qwen --action=analyze
```

### Sync only commands with TOML conversion
```bash
/config-sync:qwen --action=sync --component=commands
```

## Qwen CLI Features

### Command Format
- **Required**: TOML format (not Markdown)
- **Conversion**: Claude Markdown → Qwen TOML
- **Namespaces**: Colon-separated organization

### Configuration Files
- `~/.qwen/settings.json`
- Optional provider-specific TOML snippets

### Permission System
- **Documentation**: No formal system
- **User permissions**: Default behavior
- **Confirmation**: Shell execution prompts

### Special Syntax
- **File references**: `@{file_path}`
- **Shell commands**: `!{command}`
- **Arguments**: `{{args}}`

## Synchronization Process

1. **Convert**: Markdown commands to TOML format
2. **Organize**: Create namespace structure
3. **Adapt**: Update syntax references
4. **Verify**: TOML syntax validation

## Integration

Handles TOML conversion and namespace organization for Qwen CLI compatibility.