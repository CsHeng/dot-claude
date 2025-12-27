# Claude Configuration Management System

A comprehensive configuration management and agent orchestration system for Claude Code environments. This repository provides a unified framework for synchronizing rules, agents, skills, and commands across multiple AI CLI targets.

## Overview

This system enables centralized management of Claude Code configurations with support for multiple target environments including Droid CLI, Qwen CLI, OpenAI Codex CLI, OpenCode, and Amp CLI. It provides automated synchronization, backup management, and governance capabilities.

### Architecture: User-Level vs Project-Level

The system operates across two complementary levels:

- **User-Level** (`~/.claude/`): Global configuration and personal automation tools that apply to all projects
- **Project-Level** (`.claude/` within projects): Project-specific management tools (config-sync) scoped to individual projects

When Claude Code runs in the `~/.claude/` directory, it merges both levels for development purposes. In normal projects, only user-level components are available.

### Discovery Model

Agents, skills, and commands are discovered automatically via their frontmatter - no manual registration required:
- **Commands** (`commands/*.md`): User-visible slash commands
- **Agents** (`agents/*/AGENT.md`): Execution units with system prompts
- **Skills** (`skills/*/SKILL.md`): Reusable capability modules
- **Rules** (`rules/*.md`): Development standards (auto-loaded by CLAUDE.md)

## Key Components

### 🔧 Configuration Synchronization (`config-sync`)
- **Multi-target support**: Synchronize configurations across different AI CLI environments
- **Automated backup**: Built-in backup and retention policies
- **Phase-based execution**: Structured workflow with collect → analyze → plan → prepare → adapt → execute → verify → cleanup → report
- **Target adapters**: Specialized adapters for each CLI environment
- **Project-level component**: Located at `~/.claude/.claude/` for project-specific management

### 🤖 Agent System
Specialized agents for different workflows:

**User-Level Agents** (available globally):
- `agent:llm-governance`: LLM prompt optimization and governance
- `agent:workflow-helper`: Draft commit messages and shell script review
- `agent:code-architecture-reviewer`: Architecture review and compliance
- `agent:code-refactor-master`: Code refactoring and restructuring
- `agent:plan-reviewer`: Development plan review and validation
- `agent:ts-code-error-resolver`: TypeScript error resolution
- `agent:web-research-specialist`: Research and information gathering
- `agent:refactor-planner`: Complex refactoring planning

**Project-Level Agents** (project-specific management):
- `agent:config-sync`: Configuration synchronization and management

### 🛠️ Skills Framework
Domain-specific skills providing focused expertise:
- **Language skills**: Python, Go, Shell scripting standards
- **Architecture skills**: Patterns, development standards, security
- **Workflow skills**: Discipline, automation selection, environment validation
- **Governance skills**: LLM governance, output style management
- **Quality skills**: Testing strategy, error patterns, quality standards

### 📋 Rule System
Comprehensive rule set covering:
- Development standards and best practices
- Security standards and guardrails
- Communication protocols and output styles
- LLM prompt writing guidelines
- Language-specific guidelines (Python, Shell, Go)
- Cross-language architecture principles

## Directory Structure

### User-Level Structure (`~/.claude/`)
Global configuration available across all projects:
```
~/.claude/
├── CLAUDE.md                 # Rule-loading conditions
├── AGENTS.md                 # Agent discovery documentation
├── rules/                    # Development standards (auto-loaded)
├── skills/                   # User-level skill definitions
├── agents/                   # User-level agent definitions
├── commands/                 # User-level command definitions
├── output-styles/            # Named output style manifests
├── docs/                     # Documentation
├── settings.json             # Global configuration
└── README.md                 # This file
```

### Project-Level Structure (`.claude/` within projects)
Project-specific Claude Code management tools:
```
.claude/
├── CLAUDE.md                 # Project-level rule overrides (inherits user-level)
├── skills/                   # Project-specific skills
├── agents/                   # Project-specific agents
├── commands/                 # Project-level commands
├── config-sync/              # Config-sync subsystem
│   ├── sync-cli.sh          # Unified orchestrator
│   ├── settings.json        # Sync configuration
│   ├── adapters/            # Target-specific adapters
│   ├── lib/                 # Shared libraries and phases
│   └── scripts/             # Utility scripts
```

## Quick Start

### Prerequisites
- Claude Code CLI
- Shell environment (bash/zsh)
- Optional: Python with `toml` module (for Qwen CLI support)

### Basic Usage

1. **Synchronize all configurations** (project-level command):
   ```bash
   /config-sync/sync-cli --action=sync
   ```

2. **Analyze specific target** (project-level command):
   ```bash
   /config-sync/sync-cli --action=analyze --target=opencode
   ```

3. **Synchronize specific components** (project-level command):
   ```bash
   /config-sync/sync-cli --action=sync --target=amp --components=commands,settings
   ```

4. **Generate documentation**:
   ```bash
   ```

5. **Review shell script**:
   ```bash
   /review-shell-syntax path/to/script.sh
   ```

6. **Draft commit message**:
   ```bash
   /draft-commit-message
   ```

## Configuration

### Global Settings
Edit `settings.json` to configure:
- Environment variables
- Permission settings
- Status line configuration
- Timeout settings

### Target Configuration
Each target CLI requires specific configuration:
- **Droid CLI**: Full YAML frontmatter support
- **Qwen CLI**: Python TOML module required
- **OpenAI Codex CLI**: Minimal configuration
- **OpenCode**: JSON command format
- **Amp CLI**: Global memory support

### Backup Management
Configure backup retention in `.claude/config-sync/settings.json` (project-level):
```json
{
  "backup": {
    "retention": {
      "maxRuns": 5,
      "enabled": true,
      "dryRun": false
    }
  }
}
```

## Supported Targets

| Target | Platform | Command Format | Special Requirements |
|--------|----------|----------------|---------------------|
| Droid CLI | Factory AI | YAML frontmatter | Full YAML support |
| Qwen CLI | QwenLM | TOML commands | Python `toml` module |
| OpenAI Codex CLI | OpenAI | Markdown | Minimal config |
| OpenCode | OpenCode | JSON | JSON command format |
| Amp CLI | Amp | YAML | AGENTS.md memory support |

## Development Guidelines

### Adding New Agents
**User-Level Agents** (global availability):
1. Create agent directory under `~/.claude/agents/`
2. Define `AGENT.md` with proper frontmatter (`name`, `description`, `metadata`)
3. Specify required and optional skills in the agent documentation
4. Agent is automatically discovered via frontmatter

**Project-Level Agents** (project-specific):
1. Create agent directory under `.claude/agents/`
2. Define `AGENT.md` with proper frontmatter
3. Specify required and optional skills
4. Agent is automatically discovered via frontmatter

### Creating New Skills
**User-Level Skills** (global availability):
1. Create skill directory under `~/.claude/skills/`
2. Define `SKILL.md` with skill specification
3. Include required tools and dependencies
4. Test with `skill:environment-validation`

**Project-Level Skills** (project-specific):
1. Create skill directory under `.claude/skills/`
2. Define `SKILL.md` with skill specification
3. Include required tools and dependencies

### Extending Config Sync
1. Add target adapter in `.claude/config-sync/adapters/`
2. Update target resolver in `.claude/config-sync/lib/common.sh`
3. Test with `/config-sync/sync-cli --action=analyze`

## Philosophy

This project follows the LLM Prompt Philosophy outlined in `docs/llm-philosophy.md`:
- **Direct and unambiguous**: High-density imperative language
- **Deterministic structures**: Predictable formatting and organization
- **Separation of concerns**: Machine-readable rules separate from human explanations
- **Multi-AI compatibility**: Conservative structures work across different AI systems

### Design Principles

The system is designed according to `docs/taxonomy-rfc.md`:
- **Frontmatter-based discovery**: No manual registration required
- **User-level inheritance**: Project-level configurations inherit user-level defaults
- **Clean separation**: User-level (global) vs project-level (scoped) components
- **Rule auto-loading**: Context-based rule application via CLAUDE.md
