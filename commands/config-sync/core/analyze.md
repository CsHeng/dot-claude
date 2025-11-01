---
name: "config-sync:analyze"
description: Analyze target tool capabilities and configuration state
argument-hint: --target=<droid|qwen|codex|opencode|all> [--detailed] [--format=<json|markdown|table>]
---

# Config-Sync Analyze Command

## Task
Comprehensively analyze target tool capabilities, current configuration state, and synchronization requirements.

## Usage
```bash
/config-sync:analyze --target=<tool|all> [options]
```

### Arguments
- `--target`: Target tool (droid, qwen, codex, opencode) or "all"
- `--detailed`: Include detailed analysis and recommendations
- `--format`: Output format (json, markdown, table) - default: markdown

## Quick Examples

### Analyze all target tools
```bash
/config-sync:analyze --target=all
```

### Detailed analysis of specific tool
```bash
/config-sync:analyze --target=qwen --detailed
```

### Table format summary
```bash
/config-sync:analyze --target=all --format=table
```

## Analysis Features

### Installation Status
- Check if tool is installed and accessible
- Version information
- Configuration directory existence (use the helper mapping below)

### Configuration Directory Map
- **Factory/Droid CLI** → `~/.factory`
- **Qwen CLI** → `~/.qwen`
- **Codex CLI** → `~/.codex`
- **OpenCode** → `~/.config/opencode`

Use `get_target_config_dir` and other helpers from `config-sync/lib/common.sh` when resolving paths so the correct directories are inspected.

### Key Configuration Files
- **Factory/Droid CLI**: `settings.json`, `config.json`
- **Qwen CLI**: `settings.json`
- **Codex CLI**: `config.toml`
- **OpenCode**: `opencode.json` (plus `user-settings.json` if present)

### Configuration Capabilities
- File format support (JSON, TOML, Markdown)
- Permission system capabilities
- Command format compatibility

### Current State Assessment
- Existing configuration files
- Component status (rules, commands, settings, memory)
- Configuration completeness

### Synchronization Requirements
- Format conversion needs
- Permission mapping requirements
- Potential compatibility issues

### Issue Identification
- Common problems and solutions
- Recommended fixes
- Configuration gaps

## Tool-Specific Analysis

| Tool | Core Configuration Files | Command File Format | Permission Model |
| --- | --- | --- | --- |
| Factory/Droid CLI | `settings.json`, `config.json` | Markdown | Allowlist / Denylist (JSON) |
| Qwen CLI | `settings.json` | TOML (command definitions) | Trusted project prompts |
| OpenAI Codex CLI | `config.toml` | Markdown | Sandbox levels (read-only / workspace / full) |
| OpenCode | `opencode.json` (+ `user-settings.json`) | JSON with metadata | Operation-based (edit/bash/webfetch) |

*Command File Format indicates the required format for synced command files. Runtime configuration still uses the files listed in the Core Configuration column.*

## Output Formats

### Markdown (default)
Comprehensive readable report with sections and details

### Table
Compact summary showing key metrics for each tool

### JSON
Structured data for automation and processing

## Integration

Works with adapter commands to provide detailed analysis of each target tool's capabilities and current state.