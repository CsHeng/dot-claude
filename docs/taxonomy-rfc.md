# Taxonomy v3: Three-Layer Model for ~/.claude

## 1. Purpose

This document defines a **three-layer model** for how slash commands, governance, and executable agents/skills/commands
fit together across:

- User-level workspace: `~/.claude/`
- Project-level workspace: `<project>/.claude/`
- IDE / CLI entrypoints (Codex CLI, Claude Code, etc.)

## 2. Layer Overview

We distinguish three layers:

- **Layer 1 — UI Entry Layer (User triggers)**
  - Slash commands and UI actions such as `/edit`, `/commit`, `/ask`, `/plan-*`, `/research-*`.
  - Lives primarily in IDE / CLI configuration, but `~/.claude` can define a shared **UI protocol**
    (which commands exist, what they mean, and what they map to conceptually).

- **Layer 2 — Orchestration & Governance Layer**
  - Memory routing, task classification, default agent selection, and output-style selection.
  - Implements **governance logic**: which tasks go where, which rules apply, and how output styles
    are chosen.
  - Must **not** use the terms "agent", "skill", or "command" in the Claude Code sense.

- **Layer 3 — Execution Layer (Claude Code runtime)**
  - Actual Claude Code agents, subagents, skills, and commands (tool APIs such as fs, git, shell).
  - This is where real work is executed, tools are invoked, and subagents are spawned.

High-level flow:

```text
User (IDE / CLI) → Layer 1 (slash command) → Layer 2 (governance / routing) → Layer 3 (execution)
```

Layer 1 and Layer 2 live mostly in `~/.claude`, while Layer 3 is split between `~/.claude` (user-level
execution primitives) and per-project `.claude/` directories (project-specific agents and skills).

## 3. Naming Conventions by Layer

To avoid confusion with official Claude Code terminology, we use **different words** at different layers.

### 3.1 Layer 1 — UI Entry Layer

- **Slash Command**
  - The user-visible command, such as `/plan-architecture`, `/research-topic`, `/fix-errors`.
  - Primary home: IDE / CLI configuration.
  - Optional specification in user workspace: `~/.claude/governance/entrypoints/*.md`.

- **Entry Point**
  - A configuration record that describes how a slash command maps into the governance layer.
  - Lives under `~/.claude/governance/entrypoints/`.

### 3.2 Layer 2 — Orchestration & Governance

Layer 2 is where your existing routing and rule system lives. Here we deliberately avoid official
Claude Code terms (agent/skill/command) and instead use:

- **Router**
  - A workflow router that decides **which execution agent** (Layer 3) or workflow to use.
  - Lives under: `~/.claude/governance/routers/`.

- **Rule Block**
  - A reusable governance / policy module.
  - Wraps or references canonical policy documents under `rules/`.
  - Lives under: `~/.claude/governance/rules/`.

- **Governance Manifest**
  - A memory-like entry that declares routing behavior, default routers, and rule-block loading
    behavior for a given context.
  - Example: `~/.claude/CLAUDE.md`, project-level `.claude/CLAUDE.md`.

- **Output Style**
  - Named system-prompt preset such as `default`, `explanatory`, `learning`.
  - Selected via `/output-style` or settings, but **chosen** at Layer 2.
  - Lives under: `~/.claude/governance/styles/` (user-level) and optionally `.claude/output-styles/`
    (project-level overrides).

Layer 2 is responsible for **deciding** which Layer 3 agent/skill/command is used, but never
implements the tools or execution logic itself.

### 3.3 Layer 3 — Execution Layer

Layer 3 follows official Claude Code semantics:

- **Agent**
  - A reasoning unit with its own system prompt, context, and tool permissions.
  - Executes tasks using skills and commands.
  - User-level agents live under: `~/.claude/agents/`.
  - Project-level agents live under: `<project>/.claude/agents/`.

- **Subagent**
  - An agent spawned via `runAgent` with an isolated context, typically for sub-tasks.

- **Skill**
  - A reusable capability module that encapsulates one or more commands.
  - User-level skills live under: `~/.claude/skills/`.
  - Project-level skills live under: `<project>/.claude/skills/`.

- **Command**
  - A low-level tool API such as filesystem, git, shell, or `runAgent`.
  - User-level commands live under: `~/.claude/commands/`.
  - Project-level commands live under: `<project>/.claude/commands/`.

Layer 3 is the **only** layer that should use the words "agent", "skill", and "command" in the
Claude Code sense.

## 4. Directory Layout

### 4.1 User-Level (`~/.claude/`)

```text
~/.claude/
├── CLAUDE.md                    # User-level governance manifest (Layer 2)
├── governance/                  # All orchestration and governance logic (Layer 1+2)
│   ├── entrypoints/             # Slash command → router mappings (Layer 1)
│   ├── routers/                 # Workflow routers (Layer 2)
│   ├── rules/                   # Governance rule blocks (Layer 2)
│   └── styles/                  # Output-style manifests (Layer 2)
│
├── agents/                      # User-level execution agents (Layer 3)
├── skills/                      # User-level skills (Layer 3)
├── commands/                    # User-level tool commands (Layer 3)
├── rules/                       # Canonical policy content (referenced by governance)
└── docs/                        # Human-facing docs (including this file)
```

Notes:
- Existing `rules/**` remain the canonical source of policy text.
- `governance/rules/**` wrap or reference `rules/**` for orchestration purposes.
- `agents/`, `skills/`, and `commands/` are reserved for **execution** and must not embed
  governance routing logic directly.

### 4.2 Project-Level (`<project>/.claude/`)

```text
.claude/
├── CLAUDE.md                    # Project-level governance manifest (Layer 2)
├── agents/                      # Project-specific execution agents (Layer 3)
├── skills/                      # Project-specific skills (Layer 3)
├── commands/                    # Project-specific commands (Layer 3)
├── output-styles/               # Optional project-specific styles (Layer 2 overrides)
├── config-sync/                 # Config-sync subsystem (project-scoped)
└── agent-ops/                   # Agent operations tooling (project-scoped)
```

User-level `~/.claude` provides shared governance and execution primitives; project-level `.claude/`
adds project-specific agents/skills/commands and may override or extend governance decisions in
`CLAUDE.md`.

## 5. Responsibilities by Layer

### 5.1 Layer 1 — UI Entry

- Define the set of supported slash commands and their intent.
- Provide human-facing help and usage examples.
- Map user actions (e.g., `/plan-architecture`) to a governance entrypoint.

### 5.2 Layer 2 — Orchestration & Governance

- Memory routing and task classification.
- Default (and optional) execution agent selection.
- Output-style selection and enforcement of communication protocol rules.
- Application of governance rules from `rules/**` via rule-blocks.

### 5.3 Layer 3 — Execution

- Implement agents that perform work in explicit phases (plan / act / observe / adjust).
- Implement skills that encapsulate commands and apply rules for specific domains or tools.
- Implement commands that bridge to real tools (filesystem, git, shell, runAgent, etc.).
- Provide consistent inputs/outputs and error handling contracts.

## 6. Design Constraints and Best Practices

- **Single source of truth**
  - Policy text lives in `rules/**`.
  - Layer 2 (governance) references rules and defines how they are applied.
  - Layer 3 (execution) references governance and rules but does not redefine them.

- **Directed Acyclic Graph (DAG) Dependencies**
  - Layer 3 (Skills/Agents) → Layer 2 (Governance Rules) → Layer 2 (Policy Sources)
  - Each layer only references its adjacent layer in the dependency chain
  - **Prohibited**: Direct Layer 3 → Layer 2 (Policy Sources) references
  - **Required**: Layer 3 sources must reference `governance/rules/**` files
  - **Required**: Layer 2 files must reference `rules/**` canonical policy files
  - This eliminates circular dependencies and ensures clean RAG retrieval paths

- **No naming collisions**
  - Only Layer 3 uses "agent", "skill", and "command" with the Claude Code meaning.
  - Governance files and directory names avoid these terms to prevent confusion.

- **Cross-project reuse**
  - User-level `~/.claude/governance/**` and `~/.claude/{agents,skills,commands}/` define
    reusable behaviors that can be applied in any project.
  - Project-level `.claude/` should only add project-specific behavior or overrides.

## 7. Status and Relationship to taxonomy-v1.md

- `docs/taxonomy-rfc.md` is the **normative** taxonomy for layers and naming going forward.
- `docs/taxonomy-v1.md` (formerly `taxonomy-rfc.md`) is retained as a historical RFC and background context.
- Future changes to the conceptual model or directory layout should update this file first and then
  propagate into `CLAUDE.md`, `directory-structure.md`, and other documentation.


## 8. Example Flows

### 9.1 /draft-commit-message

This flow illustrates how a workflow command travels through the three layers.

1. **Layer 1 – UI Entry**
   - User runs `/draft-commit-message [--filter=path] [--summary-note=note]` in the IDE/CLI.
   - The IDE/CLI resolves this to the entrypoint spec in
     `governance/entrypoints/draft-commit-message.md`, which in turn points to
     `commands/draft-commit-message.md` for detailed semantics.

2. **Layer 2 – Orchestration & Governance**
   - The entrypoint specifies that `/draft-commit-message` is handled by
     `router:workflow-helper` (`governance/routers/workflow-helper.md`).
   - The router:
     - Loads governance rule-blocks:
       - `rule-block:workflow-discipline` (`governance/rules/workflow-discipline.md`),
       - `rule-block:automation-language-selection` (`governance/rules/automation-language-selection.md`),
       - `rule-block:commit-messages` (`governance/rules/commit-messages.md`).
     - Selects the execution agent: `agent:draft-commit-message`.
     - Prepares a payload describing the repository context, filter path, and any
       governance-relevant flags (for example, output style).

3. **Layer 3 – Execution**
   - Execution is performed by `agent:draft-commit-message`
     (`agents/draft-commit-message/AGENT.md`), which depends on the execution-layer
     skills:
       - `filesystem` (`skills/filesystem/SKILL.md`),
       - `git` (`skills/git/SKILL.md`).
   - If invoked as a subagent from another agent, the caller uses `runAgent`
     via the `subagents` skill (`skills/subagents/SKILL.md`):
     - `runAgent("agent:draft-commit-message", payload, options)`.
   - The agent executes its DEPTH phases:
     - Validate repository and scope.
     - Collect global and scoped diffs.
     - Classify changes (types and renames/moves).
     - Synthesize a commit message consistent with commit-message rule-blocks.
     - Produce an analysis summary and guidance without ever running `git commit`.

### 9.2 /review-shell-syntax

1. **Layer 1 – UI Entry**
   - User runs `/review-shell-syntax [path/to/script.sh]` in the IDE/CLI.
   - The IDE/CLI resolves this to the entrypoint spec in
     `governance/entrypoints/review-shell-syntax.md`, which references
     `commands/review-shell-syntax.md` for detailed semantics.

2. **Layer 2 – Orchestration & Governance**
   - The entrypoint specifies that `/review-shell-syntax` is handled by
     `router:workflow-helper`.
   - The router:
     - Loads governance rule-blocks:
       - `rule-block:workflow-discipline`,
       - `rule-block:automation-language-selection`,
       - `rule-block:shell-guidelines` (`governance/rules/shell-guidelines.md`).
     - Selects the execution agent: `agent:review-shell-syntax`.
     - Prepares a payload describing the script path and any relevant context
       (for example, style settings or CI/interactive mode).

3. **Layer 3 – Execution**
   - Execution is performed by `agent:review-shell-syntax`
     (`agents/review-shell-syntax/AGENT.md`), which depends on the execution-layer
     `filesystem` skill.
   - The agent:
     - Validates that the target script exists and is readable.
     - Detects the interpreter from the shebang or defaults to bash.
     - Runs syntax validation (e.g., `bash -n`, `sh -n`, `zsh -n`) and static analysis
       (e.g., `shellcheck`).
     - Maps diagnostics to the shell guideline rule-block and generates minimal,
       unified diff patches that fix violations without large-scale reformatting.
     - Produces a structured report with PASS/FAIL status, deviations, raw tool output,
       and an optional auto-fix patch.

As with `/draft-commit-message`, governance (Layer 2) for `/review-shell-syntax` remains separate
from execution details (Layer 3), while Layer 1 only defines the user-facing protocol.

### 9.3 /check-secrets

1. **Layer 1 – UI Entry**
   - User runs `/check-secrets` in the IDE/CLI.
   - The IDE/CLI resolves this to the entrypoint spec in
     `governance/entrypoints/check-secrets.md`, which references
     `commands/check-secrets.md` for detailed semantics.

2. **Layer 2 – Orchestration & Governance**
   - The entrypoint specifies that `/check-secrets` is handled by
     `router:workflow-helper`.
   - The router:
     - Loads governance rule-blocks:
       - `rule-block:workflow-discipline`,
       - `rule-block:automation-language-selection`,
       - `rule-block:secrets-scanning` (`governance/rules/secrets-scanning.md`).
     - Selects the execution agent: `agent:check-secrets`.
     - Prepares a payload describing the repository context and any relevant
       include/ignore information.

3. **Layer 3 – Execution**
   - Execution is performed by `agent:check-secrets`
     (`agents/check-secrets/AGENT.md`), which depends on execution-layer
     `filesystem` and `git` skills.
   - The agent:
     - Discovers candidate files (tracked, unstaged, and common config files).
     - Applies heuristic patterns for API keys, passwords, certificates, connection
       strings, and similar sensitive values.
     - Deduplicates and filters findings, biasing toward false positives with
       clear caveats.
     - Produces a report of suspected secrets, classified by severity and type,
       along with remediation guidance aligned with security standards.

Governance ensures that `/check-secrets` applies the correct security rules and scope selection,
while the execution agent focuses on concrete scanning and reporting.
