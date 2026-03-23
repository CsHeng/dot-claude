# User-Level Claude Code Configuration

User-level Claude Code configuration harness (`~/.claude/`). Manages user-specific agents, rules, output styles, and global settings.

## ⚠️ Migration Notice

**Skills, commands, and most agents have been migrated to the Claude Code plugin system.**

See [MIGRATION.md](./MIGRATION.md) for details.

## Architecture: User-Level vs Project-Level

The configuration operates across two complementary levels:

- **User-Level** (`~/.claude/`): Global configuration applied to all projects. Synchronized across environments.
- **Project-Level** (`.claude/` within projects): Project-specific tooling scoped to individual projects. Not synchronized.

When Claude Code runs in the `~/.claude/` directory itself, it merges both levels for development purposes.

## Directory Structure

### User-Level (`~/.claude/`)

```
~/.claude/
├── CLAUDE.md                 # Symlink to AGENTS.md
├── AGENTS.md                 # AI agent instructions and coding standards
├── agents/                   # User-level agent definitions
├── rules/                    # Development standards (auto-loaded)
├── output-styles/            # Named output style manifests
├── plugins/                  # Plugin cache and installed plugin registry
├── docs/                     # Architecture and philosophy documentation
└── settings.json             # Global Claude Code configuration
```

### Project-Level (`.claude/`)

```
.claude/
├── agents/                   # Project-scoped tool agents
├── commands/                 # Project-level slash commands
└── skills/                   # Project-scoped tool implementations
```

## Agents

User-level agents available globally:

| Agent | Purpose |
|-------|---------|
| `check-secrets` | Detect sensitive information in code |
| `code-architecture-reviewer` | Architecture review and compliance |
| `code-refactor-master` | Code refactoring and restructuring |
| `draft-commit-message` | Draft conventional commit messages |
| `plan-reviewer` | Development plan review and validation |
| `refactor-planner` | Complex refactoring planning |
| `review-golang-syntax` | Go syntax review |
| `review-python-syntax` | Python syntax review |
| `review-shell-syntax` | Shell script syntax review |
| `ts-code-error-resolver` | TypeScript error resolution |
| `web-research-specialist` | Research and information gathering |
| `workflow-helper` | General workflow assistance |

## Skills (Migrated to Plugin)

Skills have been migrated to the `coding` plugin. Install via:

```bash
claude plugin install coding
```

**Plugin Repository**: https://github.com/CsHeng/csheng-skills

The plugin includes 28 skills covering:
- Language guidelines (Python, Go, Shell, PowerShell, Lua)
- Tool selection and workflows
- Architecture and design patterns
- Quality, security, and testing standards
- Git utilities (smart-commit, smart-squash)
- Cross-model review workflows

## Rules

Rules in `rules/` are auto-loaded and apply globally:

- `00-memory-rules.md`: Cross-cutting development constraints
- `98-communication-protocol.md`: Communication style and output standards
- `default.rules`: Default rule set

## Configuration

Edit `settings.json` to configure:
- Environment variables
- Permission settings
- Hook behaviors
- Status line configuration

## Philosophy

See [docs/model.md](./docs/model.md) for the execution model, layer boundaries, and LLM prompt philosophy.

## Plugin Repository

- **Repository**: https://github.com/CsHeng/csheng-skills
- **Plugin Name**: `coding`
- **License**: MIT
- **AgentSkills.io Compatible**: ✅

## For Agents

AI-specific instructions, coding standards, and workflow preferences are in [AGENTS.md](./AGENTS.md).
