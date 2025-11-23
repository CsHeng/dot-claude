# Claude Configuration Management System

A comprehensive configuration management and agent orchestration system for Claude Code environments. This repository provides a unified framework for synchronizing rules, agents, skills, and commands across multiple AI CLI targets.

## Overview

This system enables centralized management of Claude Code configurations with support for multiple target environments including Droid CLI, Qwen CLI, OpenAI Codex CLI, OpenCode, and Amp CLI. It provides automated synchronization, backup management, and governance capabilities.

## Key Components

### 🔧 Configuration Synchronization (`config-sync`)
- **Multi-target support**: Synchronize configurations across different AI CLI environments
- **Automated backup**: Built-in backup and retention policies
- **Phase-based execution**: Structured workflow with collect → analyze → plan → prepare → adapt → execute → verify → cleanup → report
- **Target adapters**: Specialized adapters for each CLI environment

### 🤖 Agent System
Specialized agents for different workflows:
- `agent:config-sync`: Configuration synchronization and management
- `agent:llm-governance`: LLM prompt optimization and governance
- `agent:workflow-helper`: Draft commit messages and shell script review
- `agent:code-architecture-reviewer`: Architecture review and compliance
- `agent:code-refactor-master`: Code refactoring and restructuring
- `agent:plan-reviewer`: Development plan review and validation
- `agent:ts-code-error-resolver`: TypeScript error resolution
- `agent:web-research-specialist`: Research and information gathering
- `agent:refactor-planner`: Complex refactoring planning
- `agent:agent-ops`: Agent system health monitoring

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

```
.
├── agents/                    # Agent definitions and configurations
│   ├── config-sync/          # Configuration sync agent
│   ├── llm-governance/       # LLM governance agent
│   └── ...                   # Other specialized agents
├── commands/                 # Slash command definitions
│   ├── config-sync/          # Config sync commands and utilities
│   │   ├── adapters/         # Target-specific adapters
│   │   ├── lib/              # Shared libraries and phases
│   │   ├── scripts/          # Utility scripts
│   │   └── *.md              # Command documentation
│   ├── draft-commit-message.md
│   └── review-shell-syntax.md
├── skills/                    # Skill definitions
│   ├── language-python/      # Python language expertise
│   ├── language-shell/       # Shell scripting expertise
│   ├── language-go/          # Go language expertise
│   ├── architecture-patterns/
│   ├── security-standards/
│   └── ...                   # Other domain-specific skills
├── rules/                     # Governance and standards rules
│   ├── 01-development-standards.md
│   ├── 03-security-standards.md
│   ├── 10-python-guidelines.md
│   ├── 12-shell-guidelines.md
│   └── ...                   # Additional rule files
├── docs/                      # Documentation and philosophy
│   ├── llm-philosophy.md     # LLM prompt design philosophy
│   ├── permissions.md        # Permission management
│   └── settings.md           # Configuration guide
├── backup/                    # Automatic backup storage
├── settings.json             # Global configuration
├── CLAUDE.md                 # Memory configuration and agent routing
└── README.md                 # This file
```

## Quick Start

### Prerequisites
- Claude Code CLI
- Shell environment (bash/zsh)
- Optional: Python with `toml` module (for Qwen CLI support)

### Basic Usage

1. **Synchronize all configurations**:
   ```bash
   /config-sync/sync-cli --action=sync
   ```

2. **Analyze specific target**:
   ```bash
   /config-sync/sync-cli --action=analyze --target=opencode
   ```

3. **Synchronize specific components**:
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
Configure backup retention in `commands/config-sync/settings.json`:
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
1. Create agent directory under `agents/`
2. Define `AGENT.md` with proper frontmatter
3. Specify required and optional skills
4. Update agent routing in `CLAUDE.md`

### Creating New Skills
1. Create skill directory under `skills/`
2. Define `SKILL.md` with skill specification
3. Include required tools and dependencies
4. Test with `skill:environment-validation`

### Extending Config Sync
1. Add target adapter in `commands/config-sync/adapters/`
2. Update target resolver in `lib/common.sh`
3. Test with `/config-sync/sync-cli --action=analyze`

## Philosophy

This project follows the LLM Prompt Philosophy outlined in `docs/llm-philosophy.md`:
- **Direct and unambiguous**: High-density imperative language
- **Deterministic structures**: Predictable formatting and organization
- **Separation of concerns**: Machine-readable rules separate from human explanations
- **Multi-AI compatibility**: Conservative structures work across different AI systems
