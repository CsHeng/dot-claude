# LLM-Powered Configuration Sync Commands

This directory contains intelligent commands that use Claude Code as the single source of truth to analyze and adapt configurations for target tools (Qwen CLI, Factory/Droid CLI, Codex CLI, OpenCode). All config-sync commands now live under `commands/config-sync/` and are exposed via slash commands such as `/config-sync:sync`.

## Available Commands

### 🚀 Core Commands

#### `/config-sync:sync`
**Purpose**: Directly synchronize specific configuration components
**Usage**: `/config-sync:sync --target=<tool> --component=<rules|permissions|commands|settings|memory|all> [--dry-run] [--force] [--verify]`

#### `/config-sync:sync-user-config`
**Purpose**: Complete configuration sync from Claude to target tools
**Usage**: `/config-sync:sync-user-config --target=<tool> --component=<type>`

**Examples**:
```bash
# Sync everything to all tools
/config-sync:sync-user-config --target=all

# Sync only rules and permissions to Droid CLI
/config-sync:sync-user-config --target=droid --component=rules,permissions

# Sync only commands to Codex CLI
/config-sync:sync-user-config --target=codex --component=commands
```

#### `/config-sync:adapt-permissions`
**Purpose**: Adapt Claude permissions to target tool format
**Usage**: `/config-sync:adapt-permissions --target=<tool>`

**Examples**:
```bash
# Adapt permissions for Factory/Droid CLI
/config-sync:adapt-permissions --target=droid

# Generate permission guidelines for Qwen CLI
/config-sync:adapt-permissions --target=qwen
```

#### `/config-sync:adapt-commands`
**Purpose**: Adapt Claude commands for universal tool compatibility
**Usage**: `/config-sync:adapt-commands --target=<tool>`

**Examples**:
```bash
# Make commands compatible with Droid CLI
/config-sync:adapt-commands --target=droid

# Adapt commands for Codex CLI
/config-sync:adapt-commands --target=codex
```

#### `/config-sync:verify`
**Purpose**: Verify configuration sync completeness and correctness
**Usage**: `/config-sync:verify --target=<tool>`

**Examples**:
```bash
# Verify all tools
/config-sync:verify --target=all

# Verify specific tool
/config-sync:verify --target=qwen
```

#### `/config-sync:analyze`
**Purpose**: Analyze target tool capabilities, configuration state, and sync requirements
**Usage**: `/config-sync:analyze --target=<tool|all> [--detailed] [--format=<markdown|table|json>]`

**Examples**:
```bash
# Analyze Codex CLI capabilities
/config-sync:analyze --target=codex --detailed

# Research Droid CLI configuration system
/config-sync:analyze --target=droid
```

## Target Tools

### Target Tool Snapshot

| Tool | Config Directory | Key Files | Command Format |
| --- | --- | --- | --- |
| Factory/Droid CLI | `~/.factory` | `settings.json`, `config.json`, `DROID.md`, `AGENTS.md`, `rules/` | Markdown |
| Qwen CLI | `~/.qwen` | `settings.json`, `QWEN.md`, `AGENTS.md`, `rules/` | TOML |
| OpenAI Codex CLI | `~/.codex` | `config.toml`, `CODEX.md`, `AGENTS.md`, `rules/` | Markdown |
| OpenCode | `~/.config/opencode` | `opencode.json`, optional `user-settings.json`, `AGENTS.md`, `rules/` | JSON |

## Usage Patterns

### Complete Setup for New Tool
```bash
# 1. Analyze target capabilities
/config-sync:analyze --target=droid

# 2. Perform complete sync
/config-sync:sync-user-config --target=droid

# 3. Verify sync success
/config-sync:verify --target=droid
```

### Update Specific Components
```bash
# Update only permissions
/config-sync:adapt-permissions --target=droid

# Update only commands
/config-sync:adapt-commands --target=droid

# Verify specific component
/config-sync:verify --target=droid
```

### Maintenance and Updates
```bash
# Regular sync check
/config-sync:sync-user-config --target=all

# Periodic verification
/config-sync:verify --target=all
```

## Configuration Components

### Rules
- Development guidelines and standards
- Stored as Markdown files
- Synchronized to all target tools
- Referenced by memory files

### Memory Files
- Tool-specific adaptations of `CLAUDE.md`
- Context and rule indexing
- Tool-specific references and settings

### Agent Guides
- Tool-specific adaptations of `AGENTS.md`
- Operating instructions for each tool
- References to tool-specific memory files

### Permissions
- Claude's `allow/ask/deny` system
- Adapted to target tool formats where supported
- Documented for tools without permission systems

### Commands
- Custom task templates
- Adapted for universal compatibility
- Claude-specific features removed

### Settings
- Environment variables and preferences
- Tool-specific configuration syntax
- Relevant settings transferred where applicable

## Safety and Best Practices

### Before Running Commands
1. **Back up existing configurations**: Important target configurations should be backed up
2. **Verify target tool installation**: Ensure target tools are properly installed
3. **Check file permissions**: Verify write access to target directories
4. **Review scope**: Understand what will be synchronized

### During Sync Operations
1. **Monitor output**: Watch for warnings or error messages
2. **Verify adaptations**: Review changes made during adaptation
3. **Check security**: Ensure no dangerous permissions are inappropriately allowed
4. **Document changes**: Keep track of what was modified

### After Sync Operations
1. **Run verification**: Always use `/config-sync:verify` after synchronization
2. **Test functionality**: Verify that target tools work correctly with new configurations
3. **Review documentation**: Read any generated documentation or guidelines
4. **Address issues**: Fix any problems identified during verification

## Troubleshooting

### Common Issues
- **Permission denied**: Check write access to target directories
- **File not found**: Verify target tool is installed and configured
- **Parse errors**: Ensure configuration files are valid JSON/YAML
- **Command failures**: Check for unsupported features or syntax

### Getting Help
- Run `/config-sync:analyze --target=<tool>` to understand tool capabilities
- Use `/config-sync:verify` to identify specific issues
- Review command output for detailed remediation guidance