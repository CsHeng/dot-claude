---
name: "config-sync:opencode"
description: OpenCode specific operations with JSON format and external references
argument-hint: --action=<sync|analyze|verify> --component=<rules,permissions,commands,settings,memory|all>
disable-model-invocation: true
---

# Config-Sync OpenCode Command

## Task
Handle OpenCode-specific configuration synchronization with JSON format and external references.

## Usage
```bash
/config-sync:opencode --action=<operation> --component=<type[,type]|all>
```

### Arguments
- `--action`: Operation (sync, analyze, verify)
- `--component`: One or more component types (comma-separated: rules,permissions,commands,settings,memory) or "all"

## Quick Examples

### Sync all components to OpenCode
```bash
/config-sync:opencode --action=sync --component=all
```

### Analyze OpenCode configuration
```bash
/config-sync:opencode --action=analyze
```

### Sync only permissions with operation-based config
```bash
/config-sync:opencode --action=sync --component=permissions
```

### Sync rules and commands together
```bash
/config-sync:opencode --action=sync --component=rules,commands
```

## OpenCode Features

### Command Format
- JSON: Structured command definitions
- Metadata: Rich command information
- External references: File linking support

### Permission System
- Operation-based: edit, bash, webfetch
- Less granular: Operation categories only
- Configurable: JSON permission settings

### File Structure
- Commands: JSON files in `command/`
- Rules: Root-level Markdown files
- Configuration: `opencode.json`
- Memory: `AGENTS.md` (primary reference)

## Special Features

### External References
- Lazy loading: Performance optimization
- File linking: Reference organization
- Instruction arrays: Complex operations

### AGENTS.md Focus
- Primary reference: No tool-specific memory files
- Agent documentation: Comprehensive capability guide
- External references: Enhanced linking

## Synchronization Process

1. Convert: Markdown → JSON commands
2. Organize: External reference structure
3. Configure: Operation permissions
4. Generate: AGENTS.md as primary reference

## Integration

Handles JSON format conversion and external reference management for OpenCode.
