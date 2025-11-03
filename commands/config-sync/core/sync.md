---
name: "config-sync:sync"
description: Synchronize Claude Code configuration to target AI tools
argument-hint: --target=<droid,qwen,codex,opencode|all> --component=<rules,permissions,commands,settings,memory|all> [--dry-run] [--force] [--verify]
---

# Config-Sync Main Command

## Task
Orchestrate synchronization of Claude Code configuration components to one or more target AI tools, handling format conversion, adaptation, and verification.

## Usage
```bash
/config-sync:sync --target=<tool[,tool]|all> --component=<type[,type]|all> [options]
```

### Arguments
- `--target`: One or more target tools (comma-separated: droid,qwen,opencode) or `all`
- `--component`: One or more component types (comma-separated: rules,commands) or `all`
- `--dry-run`: Preview changes without executing
- `--force`: Force overwrite existing configurations
- `--verify`: Run verification after sync (default: true)

## Quick Examples

### Sync all configurations to all tools
```bash
/config-sync:sync --target=all --component=all
```

### Sync only rules to Droid CLI
```bash
/config-sync:sync --target=droid --component=rules
```

### Sync rules to Droid and Qwen together
```bash
/config-sync:sync --target=droid,qwen --component=rules
```

### Dry run to preview changes
```bash
/config-sync:sync --target=all --component=commands --dry-run
```

### Force sync to overwrite existing configs
```bash
/config-sync:sync --target=all --component=all --force
```

## ⚠️ CRITICAL: Workflow for Qwen CLI

**For Qwen CLI specifically, ALWAYS use the adapter command directly:**

```bash
# Use this command for Qwen - it preserves settings!
/config-sync:adapters:qwen --action=sync --component=all

# NEVER use these commands for Qwen - they overwrite settings!
# /config-sync:sync --target=qwen --component=settings  # ❌ BAD
# rsync -a settings.json ~/.qwen/settings.json            # ❌ VERY BAD
```

**Reason**: The Qwen adapter includes logic to preserve existing API keys and configuration, while the core sync will blindly overwrite files.

## Implementation Details

This command orchestrates the synchronization process:

1. **Validation**: Checks source and target availability
2. **Adaptation**: Converts formats for each target tool using **tool-specific adapters**
3. **Execution**: Performs file operations with backup
4. **Verification**: Ensures sync completeness

### ⚠️ IMPORTANT: Settings File Handling

**NEVER directly overwrite existing settings files** - always use tool-specific adapters:

- **Qwen CLI**: Use `/config-sync:adapters:qwen` which preserves existing settings
- **Other tools**: Use their respective adapters that handle settings properly

**Exception**: Only overwrite settings if `--force` flag is explicitly used and user has been warned

### Target Tool Support

#### Droid CLI
- **Format**: Markdown with frontmatter (compatible)
- **Permissions**: Allowlist/denylist mapping
- **Features**: Full compatibility

#### Qwen CLI
- **Format**: TOML conversion required
- **Namespaces**: Command organization
- **Features**: Multi-modal support
- **Settings**: Preserves existing configuration (only creates if missing)
- **⚠️ CRITICAL**: Always use the `/config-sync:adapters:qwen` command - NEVER overwrite settings.json manually

#### OpenAI Codex CLI
- **Format**: Simple Markdown
- **Permissions**: Sandbox configuration
- **Features**: Minimal setup

#### OpenCode
- **Format**: JSON with metadata
- **Permissions**: Operation-based
- **Features**: External references

## Error Handling

The command includes comprehensive error handling:
- Pre-sync validation
- Backup creation before changes
- Rollback capability
- Detailed error reporting

## Integration

Uses plugin scripts and utilities:
- `scripts/executor.sh` - File operations
- `scripts/backup.sh` - Backup management
- Tool-specific adapter logic
