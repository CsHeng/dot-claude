---
name: "config-sync:sync"
description: Synchronize Claude Code configuration to target AI tools
argument-hint: --target=<droid|qwen|codex|opencode|all> --component=<rules|permissions|commands|settings|memory|all> [--dry-run] [--force] [--verify]
---

# Config-Sync Main Command

## Task
Orchestrate synchronization of Claude Code configuration components to one or more target AI tools, handling format conversion, adaptation, and verification.

## Usage
```bash
/config-sync:sync --target=<tool|all> --component=<type|all> [options]
```

### Arguments
- `--target`: Target tool (droid, qwen, codex, opencode) or "all"
- `--component`: Component type (rules, permissions, commands, settings, memory) or "all"
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

### Dry run to preview changes
```bash
/config-sync:sync --target=all --component=commands --dry-run
```

### Force sync to overwrite existing configs
```bash
/config-sync:sync --target=all --component=all --force
```

## Implementation Details

This command orchestrates the synchronization process:

1. **Validation**: Checks source and target availability
2. **Adaptation**: Converts formats for each target tool
3. **Execution**: Performs file operations with backup
4. **Verification**: Ensures sync completeness

### Target Tool Support

#### Droid CLI
- **Format**: Markdown with frontmatter (compatible)
- **Permissions**: Allowlist/denylist mapping
- **Features**: Full compatibility

#### Qwen CLI
- **Format**: TOML conversion required
- **Namespaces**: Command organization
- **Features**: Multi-modal support

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