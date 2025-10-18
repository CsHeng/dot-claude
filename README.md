# Claude Global Configuration Management

A comprehensive configuration management system for Claude AI and other AI development tools. This repository provides unified rules, permissions, and preferences that can be synchronized across multiple AI assistants (Claude, Cursor, Copilot, Kiro) for consistent behavior and productivity.

## 📁 Directory Structure

```
~/.claude/
├── CLAUDE.md                     # Main user memory file
├── settings.json                 # Command permissions configuration
├── sync-rules.sh                 # Rules synchronization script
├── COMMANDS.md                   # Command permissions documentation
├── README.md                     # This file
├── rules/                        # Common rules library
│   ├── 00-user-preferences.md
│   ├── 01-general-development.md
│   ├── 02-architecture-patterns.md
│   ├── 03-security-guidelines.md
│   ├── 04-testing-strategy.md
│   ├── 05-error-handling.md
│   ├── 10-python-guidelines.md
│   ├── 11-go-guidelines.md
│   ├── 12-shell-guidelines.md
│   ├── 13-docker-guidelines.md
│   ├── 14-networking-guidelines.md
│   ├── 20-development-tools.md
│   ├── 21-code-quality.md
│   ├── 22-logging-standards.md
│   └── 23-workflow-patterns.md
```

## 🎯 Component Overview

### 1. Rules System (rules/)

Common rules library shared by all projects:

- **00-user-preferences.md**: User preferences and development settings (loaded first)
- **01-23*.md**: Various development guidelines and standards
- **Loading order**: Sorted by numeric prefix to ensure priority

### 2. Sync Script (sync-rules.sh)

Unified script to sync rules to various AI tools:

- **Global usage**: `~/.claude/sync-rules.sh`
- **Project usage**: Copy to project's `.claude/` directory
- **Smart detection**: Automatically identifies project environment, prevents polluting config directory

### 3. Command Permissions (settings.json)

Controls commands that Claude can execute:

- **allow**: Automatically allowed safe commands
- **deny**: Completely forbidden dangerous commands
- **ask**: Commands requiring user confirmation
- **Documentation**: Refer to `COMMANDS.md` for detailed information
- **Configuration**: Generate from `COMMANDS.md` using LLM with `Bash(command:*)` syntax
- **Validation**: Use `claude /doctor` to verify configuration

### 4. User Memory (CLAUDE.md + rules/00-user-preferences.md)

Claude's personalized settings:

- **CLAUDE.md**: Main memory file that references user preferences
- **rules/00-user-preferences.md**: Detailed user preferences and development settings
- **Synchronization**: User preferences are automatically synced to all AI tools (Cursor, Copilot, Kiro) for consistent behavior

#### Memory System Structure

The memory system uses a structured approach:

1. **CLAUDE.md**: Serves as Claude's memory entry point, references the detailed preferences
2. **rules/00-user-preferences.md**: Contains all personal preferences, tool configurations, and development workflow settings
3. **Automatic Sync**: Preferences are synchronized to all AI tools via `sync-rules.sh`

#### Benefits

- **Single Source of Truth**: All preferences defined once in `00-user-preferences.md`
- **Consistent Behavior**: Claude, Cursor, Copilot, and Kiro use the same preferences
- **Easy Maintenance**: Update preferences once, sync to all tools automatically
- **No Duplication**: Eliminates redundant preference definitions across tools

## 🚀 Usage

### New Project Setup

```bash
# 1. Copy sync script to project
cp ~/.claude/sync-rules.sh /path/to/project/.claude/

# 2. Create project-specific rules
echo "# Project-specific rules" > /path/to/project/.claude/rules/project.md

# 3. Run synchronization
cd /path/to/project && .claude/sync-rules.sh
```

### Daily Maintenance

```bash
# Edit general rules
vim ~/.claude/rules/01-general-development.md

# Edit command permissions
vim ~/.claude/settings.json

# Sync to all tools
~/.claude/sync-rules.sh  # Run from project directory
```

### Project-specific Configuration

Projects can override or extend global settings in `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(project-specific-command:*)"
    ]
  }
}
```

## 📋 Rules Hierarchy

When Claude processes code, rule priority is:

1. **Project-specific rules** (`.claude/rules/project.md`) - Highest priority
2. **Global common rules** (`~/.claude/rules/`) - Standard priority
3. **Tool default rules** - Lowest priority

## 🛠️ Maintenance Guide

### Adding New Rules

1. Create new file in `~/.claude/rules/`, follow naming convention
2. Add appropriate tool headers (Cursor/Copilot/Kiro)
3. Run sync script to update all tools

### Command Permission Management

**Initial Setup**:
- Generate `settings.json` from `COMMANDS.md` using LLM
- Ensure `Bash(command:*)` syntax format
- Validate with `claude /doctor`

**Modifications**:
1. Edit `~/.claude/settings.json`
2. Choose appropriate category: `allow`/`deny`/`ask`
3. Update `COMMANDS.md` documentation if needed
4. Validate changes with `claude /doctor`

### Sync Script Maintenance

- **Global script**: `~/.claude/sync-rules.sh` - As template
- **Project script**: Copy from global version to project
- **Smart detection**: Automatically prevents polluting `~/.claude` directory

## 🔧 Troubleshooting

### Rules Not Taking Effect
1. Check file naming and header format
2. Run `~/.claude/sync-rules.sh --verify-only`
3. Confirm project directory structure is correct

### Sync Failure
1. Check source files: `ls ~/.claude/rules/`
2. Check target directory permissions
3. Review sync script error messages

### Command Permission Issues

**Configuration Problems**:
1. **Syntax Check**: Ensure `Bash(command:*)` format, not `Bash(command :*)`
2. **Generation**: Use LLM to create settings from `COMMANDS.md` documentation
3. **Validation**: Run `claude /doctor` to verify configuration
4. **Reference**: Consult `COMMANDS.md` for permission categories
5. **Override**: Use `settings.local.json` in projects for project-specific settings

## 📚 Related Documentation

- **COMMANDS.md**: Detailed command permissions documentation
- **Individual rule files**: Specific development guidelines and standards

This global configuration system ensures consistency and maintainability across all projects and AI development tools.

## 🚀 Quick Start

```bash
# Clone this repository
git clone <repository-url> ~/.claude
cd ~/.claude

# Generate proper settings.json from COMMANDS.md documentation
# Ask Claude: "Generate settings.json based on COMMANDS.md with correct Bash(command:*) syntax"
# Verify with: claude /doctor

# Run sync script to apply rules to your AI tools
./sync-rules.sh
```

### Initial Configuration Setup

For new environment setup or permission modifications:

1. **Generate Configuration**: Use LLM to create `settings.json` from `COMMANDS.md`
2. **Syntax Requirements**: Use `Bash(command:*)` format, NOT `Bash(command :*)`
3. **Validation**: Run `claude /doctor` to verify configuration
4. **Testing**: Verify commands work as expected

**Example Prompt**:
```
"Generate settings.json based on COMMANDS.md with proper permissions configuration
using correct Bash(command:*) syntax organized into allow/deny/ask categories."
```

## 📄 License

This configuration system is provided as-is for personal and professional use to streamline AI-assisted development workflows.