# Execution Model and LLM Prompt Philosophy

This document explains how this repo organizes `commands/`, `agents/`, `skills/`, and `rules/`, and why
LLM-facing files are written in a strict, deterministic style.

## Core Concepts

- **Rule** (`rules/*.md`): The source of truth for constraints and standards. Keep rule text directive and stable.
- **Skill** (`skills/*/SKILL.md`, `.claude/skills/*/SKILL.md`): Reusable workflows/capabilities. Prefer deterministic steps.
- **Agent** (`agents/*/AGENT.md`, `.claude/agents/*/AGENT.md`): Orchestration across tools and skills.
- **Command** (`commands/*.md`, `.claude/commands/*.md`): Slash command definition and help text (frontmatter).

High-level flow:

```text
User → Command (frontmatter) → Agent → Skills → Rules
```

## Scope and Boundary Model

This repo uses a strict separation between **sync payload** and **project tooling**:

- **User-level workspace (`~/.claude/`)**: Sync payload.
  - Expected to be synchronized to other coding agents/tools.
  - Contains `rules/` (SSOT), plus user-level `commands/`, `agents/`, `skills/`, `output-styles/`.
- **Project-level workspace (`.claude/`)**: Tooling only.
  - Must not be included in synchronized payload.
  - Contains tool implementations (for example llm-governance, lint-markdown).

## Directory Layout (Current)

User-level (`~/.claude/`):

```text
~/.claude/
├── CLAUDE.md
├── AGENTS.md
├── commands/
├── agents/
├── skills/
├── rules/
└── output-styles/
```

Project-level (`.claude/`):

```text
.claude/
├── commands/          # thin wrappers only
├── agents/            # project-scoped tool agents
└── skills/            # project-scoped tool implementations
```

## Discovery Model

Commands, agents, and skills are discovered via YAML frontmatter in their respective files. This repo
avoids additional registration tables.

Rules are loaded based on context described in `CLAUDE.md` and the current working set of files.

## LLM Prompt Philosophy

### Purpose

The goal is clarity, predictability, and safety when multiple models interpret and execute instructions.

### Communication Style

- Prefer compact, imperative language.
- Avoid conversational filler and ambiguous phrasing.
- Make constraints explicit and checkable.

### Determinism and Predictability

- Use stable structures and section headings.
- Prefer small, verifiable steps over large implicit leaps.
- Keep “why” explanations out of enforceable rule/manifest files unless needed for correctness.

### File-Type Specialization

- Command files define user operations and should be unambiguous about inputs/outputs.
- Skill files should describe deterministic workflows and tool choices.
- Agent files should orchestrate and gate tool usage.
- Rule files should remain strict and directive.

### Separation of Concerns

Keep human context in documentation (like this file) and keep enforceable constraints in `rules/*.md`.

