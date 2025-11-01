---
name: "config-sync:droid"
description: Droid CLI specific operations and configuration
argument-hint: --action=<sync|analyze|verify> --component=<rules|permissions|commands|settings|memory|all>
---

# Config-Sync Droid Command

## Task
Handle Droid CLI-specific configuration synchronization with full compatibility support.

## Usage
```bash
/config-sync:droid --action=<operation> --component=<type|all>
```

### Arguments
- `--action`: Operation (sync, analyze, verify)
- `--component`: Component type (rules, permissions, commands, settings, memory) or "all"

## Quick Examples

### Sync all components to Droid
```bash
/config-sync:droid --action=sync --component=all
```

### Analyze Droid configuration
```bash
/config-sync:droid --action=analyze
```

### Verify Droid synchronization
```bash
/config-sync:droid --action=verify
```

### Sync only permissions
```bash
/config-sync:droid --action=sync --component=permissions
```

## Droid CLI Features

### Command Format
- **Compatible**: Markdown with YAML frontmatter (same as Claude)
- **No conversion needed**: Direct copy possible
- **Features**: Full feature parity

### Permission System
- **Format**: JSON allowlist/denylist
- **Mapping**: Claude permissions → Droid lists
- **Security**: Conservative approach (ask → deny)

### Configuration Structure
- **Settings**: `settings.json`, `config.json`
- **Commands**: `commands/` directory
- **Rules**: `rules/` directory
- **Memory**: `DROID.md`, `AGENTS.md`

## Synchronization Process

1. **Backup**: Create backup of existing configuration
2. **Adapt**: Update tool references and syntax
3. **Copy**: Transfer files with proper permissions
4. **Verify**: Ensure completeness and correctness

## Common Issues

### Permission Mapping
- No wildcard support in Droid
- Convert ask permissions to deny
- Manual review recommended

### Command Compatibility
- Most Claude commands work directly
- Check for Droid-specific features
- Test after sync

## Integration

Delegates to adapter-droid.md for detailed implementation while providing simple interface for Droid-specific operations.