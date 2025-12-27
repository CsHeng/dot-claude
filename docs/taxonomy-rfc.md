# Taxonomy v4: Simplified Discovery Model for ~/.claude

## 1. Purpose

This document defines a **simplified two-layer model** for how slash commands, agents, skills, and rules
fit together across:

- User-level workspace: `~/.claude/`
- Project-level workspace: `<project>/.claude/`
- IDE / CLI entrypoints (Codex CLI, Claude Code, Qwen, etc.)

## 2. Migration from v3

**v3** had a three-layer model with a governance/ intermediate layer that added complexity:
- Layer 1 (UI Entry) → Layer 2 (Orchestration & Governance) → Layer 3 (Execution)

**v4** simplifies to direct discovery via frontmatter:
- Layer 1 (UI Entry) → Layer 2 (Execution)

The governance/ directory has been orphaned. Agents, skills, and commands are now discovered directly via their frontmatter.

## 3. Layer Overview

### 3.1 Layer 1 — UI Entry Layer

- **Slash Commands**: User-visible commands such as `/edit`, `/commit`, `/ask`, `/lint-markdown`.
- **Discovery**: CLI tools automatically discover commands from `commands/*.md` frontmatter.
- **Protocol**: Defines command syntax, arguments, and help text.

### 3.2 Layer 2 — Execution Layer

- **Agents**: Reasoning units with system prompts and tool permissions.
- **Skills**: Reusable capability modules.
- **Commands**: Tool APIs (filesystem, git, shell, runAgent).
- **Rules**: Development standards and best practices (auto-loaded based on context).

High-level flow:

```text
User (IDE / CLI) → Command (frontmatter) → Agent (frontmatter) → Skills (frontmatter) → Rules (CLAUDE.md)
```

## 4. Naming Conventions

| Term | Location | Purpose |
|------|----------|---------|
| **Command** | `commands/*.md` | User-visible slash command with argument hints |
| **Agent** | `agents/*/AGENT.md` | Execution unit with system prompt and tools |
| **Skill** | `skills/*/SKILL.md` | Reusable capability module |
| **Rule** | `rules/*.md` | Development standards (auto-loaded) |

## 5. Directory Layout

### 5.1 User-Level (`~/.claude/`)

```text
~/.claude/
├── CLAUDE.md                    # Rule-loading conditions (55 lines)
├── AGENTS.md                    # Agent discovery documentation
├── commands/                    # User-visible commands (Layer 1)
│   ├── lint-markdown.md
│   ├── llm-governance.md
│   └── ...
├── agents/                      # Execution agents (Layer 2)
│   ├── lint-markdown/AGENT.md
│   ├── llm-governance/AGENT.md
│   └── ...
├── skills/                      # Capability modules (Layer 2)
│   ├── lint-markdown/SKILL.md
│   ├── environment-validation/SKILL.md
│   └── ...
├── rules/                       # Policy content (auto-loaded)
├── output-styles/               # Output style presets
└── docs/                        # Documentation
```

### 5.2 Project-Level (`<project>/.claude/`)

```text
.claude/
├── CLAUDE.md                    # Project-specific rule overrides
├── agents/                      # Project-specific agents
├── skills/                      # Project-specific skills
├── commands/                    # Project-specific commands
└── output-styles/               # Project-specific style overrides
```

## 6. Discovery Mechanism

### 6.1 Frontmatter-Based Discovery

Commands, agents, and skills declare themselves via YAML frontmatter:

**Command** (`commands/lint-markdown.md`):
```yaml
---
name: lint-markdown
description: Validate markdown formatting
argument-hint: "[path] [--strict] [--fix]"
metadata:
  style: minimal-chat
---
```

**Agent** (`agents/lint-markdown/AGENT.md`):
```yaml
---
name: agent:lint-markdown
description: Execute markdown linting with taxonomy rules
metadata:
  capability-level: 2
  loop-style: DEPTH
---
```

**Skill** (`skills/lint-markdown/SKILL.md`):
```yaml
---
name: lint-markdown
description: Execute markdown validation
metadata:
  capability-level: 1
---
```

### 6.2 Rule Loading

Rules are auto-loaded based on context defined in `CLAUDE.md`:

- **Default conditions**: Communication protocol, security rules, testing rules
- **Language-specific**: Python rules for .py files, Go rules for .go files
- **Optional explicit reference**: Skills can reference specific rules via frontmatter:

```yaml
---
name: workflow-discipline
rules:
  - rules/00-memory-rules.md
  - rules/23-workflow-patterns.md
---
```

## 7. Example Flow: /lint-markdown

### Simplified (v4)

1. **User runs**: `/lint-markdown --strict`

2. **CLI discovery**: Reads `commands/lint-markdown.md` frontmatter
   - Finds: `name: lint-markdown`, description, arguments

3. **Direct execution**: Loads `agents/lint-markdown/AGENT.md`
   - Agent loads required skills: `lint-markdown`, `workflow-discipline`, `environment-validation`
   - Skills apply rules from `rules/` based on context

4. **Result**: Validation runs without routing through governance layer

### Comparison with v3

**v3** (removed):
```
/lint-markdown → governance/entrypoints/ → governance/routers/workflow-helper → agent:lint-markdown
```

**v4** (current):
```
/lint-markdown → agent:lint-markdown (direct via frontmatter)
```

## 8. Design Principles

1. **Discovery via Frontmatter**: No manual registration tables
2. **Direct Routing**: Commands reference agents directly
3. **Rule Auto-Loading**: CLAUDE.md defines context-based rule loading
4. **Cross-CLI Compatibility**: Any CLI tool can implement discovery from frontmatter

## 9. Status

- **v4** (this document): Current simplified model (2025-12-26)
- **v3** (`docs/taxonomy-v3.md`): Historical three-layer model with governance/
- **v1** (`docs/taxonomy-v1.md`): Original RFC
