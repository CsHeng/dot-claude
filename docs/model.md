# Execution Model and LLM Prompt Philosophy

This document explains how this repository organizes agents, skills, rules, and commands, and why LLM-facing files are written in a strict, deterministic style.

## Core Concepts

- **Rule** (`rules/*.md`): Source of truth for constraints and standards. Keep rule text directive and stable.
- **Skill**: Reusable workflows/capabilities. Now provided via plugin system.
- **Agent** (`agents/*/AGENT.md`): Orchestration across tools and skills.
- **Command**: Slash command definitions. Now provided via plugin system.

High-level flow:

```text
User → Command (via plugin) → Agent → Skills (via plugin) → Rules
```

## Architecture

This repository uses a strict separation between **user-level configuration** and **project-level tooling**:

### User-Level Workspace (`~/.claude/`)

Synchronized configuration that travels across environments:

```text
~/.claude/
├── CLAUDE.md              # Symlink to AGENTS.md
├── AGENTS.md              # AI agent instructions
├── README.md              # Project overview
├── RTK.md                 # RTK CLI proxy documentation
├── agents/                # User-level agent definitions (12 agents)
├── rules/                 # Development standards (3 files)
├── output-styles/         # Named output style manifests
├── plugins/               # Plugin cache and registry
├── docs/                  # Architecture documentation
├── commands/              # Empty (migrated to plugins)
└── skills/                # Empty (migrated to plugins)
```

### Project-Level Workspace (`.claude/`)

Project-specific tooling (not synchronized):

```text
.claude/
├── agents/                # Project-scoped tool agents
├── commands/              # Project-scoped commands
└── skills/                # Project-scoped tool implementations
```

**Note:** `.claude/` directory should be in `.gitignore` and not tracked in version control.

## Plugin System

Skills and commands are now managed through the Claude Code plugin system:

- **Benefits**: Hot-swappable updates, better maintainability, reusable across projects
- **Installation**: `claude plugin install <plugin-name>`
- **Registry**: Plugins tracked in `plugins/installed_plugins.json`

See [MIGRATION.md](../MIGRATION.md) for migration details.

## Discovery Model

- **Agents**: Discovered via YAML frontmatter in `agents/*/AGENT.md`
- **Skills**: Provided by installed plugins
- **Commands**: Provided by installed plugins
- **Rules**: Loaded based on context in `CLAUDE.md`

## LLM Prompt Philosophy

### Purpose

Clarity, predictability, and safety when multiple models interpret and execute instructions.

### Communication Style

- Compact, imperative language
- No conversational filler or ambiguous phrasing
- Explicit, checkable constraints

### Determinism and Predictability

- Stable structures and section headings
- Small, verifiable steps over large implicit leaps
- "Why" explanations in documentation, not in rule files

### File-Type Specialization

- **Command files**: Unambiguous about inputs/outputs
- **Skill files**: Deterministic workflows and tool choices
- **Agent files**: Orchestrate and gate tool usage
- **Rule files**: Strict and directive

### Separation of Concerns

Human context in documentation (like this file), enforceable constraints in `rules/*.md`.
