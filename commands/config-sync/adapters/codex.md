---
name: "config-sync:codex"
description: OpenAI Codex CLI specific operations with minimal configuration
argument-hint: --action=<sync|analyze|verify> --component=<rules,permissions,commands,settings,memory|all>
---

# Config-Sync Codex Command

## Task
Handle OpenAI Codex CLI-specific configuration synchronization with minimal setup requirements.

## Usage
```bash
/config-sync:codex --action=<operation> --component=<type[,type]|all>
```

### Arguments
- `--action`: Operation (sync, analyze, verify)
- `--component`: One or more component types (comma-separated: rules,permissions,commands,settings,memory) or "all"

## Quick Examples

### Sync all components to Codex
```bash
/config-sync:codex --action=sync --component=all
```

### Analyze Codex configuration
```bash
/config-sync:codex --action=analyze
```

### Sync only rules with sandbox documentation
```bash
/config-sync:codex --action=sync --component=rules
```

### Sync permissions and settings together
```bash
/config-sync:codex --action=sync --component=permissions,settings
```

## OpenAI Codex CLI Features

### Command Format
- **Simple**: Basic Markdown (no frontmatter)
- **Minimal**: Stripped-down functionality
- **Focus**: Code generation capabilities

### Permission System
- **Sandbox**: Three access levels
  - `read-only`: No modifications
  - `workspace-write`: Workspace access
  - `danger-full-access`: Full access

### Configuration
- **Format**: TOML configuration
- **Minimal**: Basic settings only
- **Authentication**: API key required

## Synchronization Process

1. **Simplify**: Remove complex Claude features
2. **Convert**: Adapt to basic Markdown
3. **Configure**: Set sandbox permissions
4. **Document**: Add limitation notes

## Limitations

- **No formal permission system**
- **Minimal configuration options**
- **Simple command structure**
- **No MCP server support**

## Integration

Provides essential functionality for OpenAI Codex CLI with focus on core features.
