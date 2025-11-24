# Taxonomy RFC

## Background
The current CLI relies on `CLAUDE.md` and numerous `rules/*.md` files to describe behavior, but there is no organized mapping between commands, rules, and memory entries. Without an explicit agent/skill structure:
- Tasks cannot be routed quickly to the right agent.
- `rules/*` are hard to reuse and often conflict or overlap.
- Commands such as review or config-sync cannot validate future skills or agents.

This RFC defines a unified taxonomy that operates across two distinct architectural levels:
- **User-level** (`~/.claude/`): Global configuration, governance, and personal automation tools
- **Project-level** (`.claude/` within each project): Project-specific management, config-sync, and agent operations

The separation ensures that personal Claude configuration remains private to the user while project-specific management tools (like config-sync and agent-ops) are scoped to individual projects without leaking into other workspaces.

The taxonomy is derived from and aligned with external Claude Code specifications:
- Subagents: https://code.claude.com/docs/en/sub-agents
- Slash commands: https://code.claude.com/docs/en/slash-commands
- Agent skills: https://code.claude.com/docs/en/skills

## Scope
- Entry files: `CLAUDE.md` (user-level), `.claude/CLAUDE.md` (project-level)
- User-level directories: `~/.claude/{rules,skills,agents,commands,output-styles,docs}/`
- Project-level directories: `.claude/{skills,agents,commands,config-sync,agent-ops}/`
- Execution environments: Codex CLI, Claude Code, Qwen CLI, IDE/CI sync destinations

## Goals
1. Establish the Memory → Agent → Skill load order and selection logic.
2. Define consistent naming, directory layout, manifest fields, tags, and `source` references.
3. Standardize versioning, approval, synchronization, rollback, and monitoring processes.
4. Provide milestones, task templates, and acceptance criteria for the migration.

## LLM-Facing Governance Domain

This taxonomy treats LLM-facing assets as a first-class domain. LLM-facing content is any file whose primary reader is a model rather than a human, including:
- System and routing manifests (`CLAUDE.md`, `AGENTS.md`)
- Agent and skill manifests (`agents/**/AGENT.md`, `skills/**/SKILL.md`)
- Slash command manifests and usage files under `commands/`
- Governance and prompt-writing rules under `rules/`
- Core configuration such as `.claude/settings.json`
- Output style manifests under `output-styles/`

Human-facing documentation (for example `docs/**`, project READMEs, and troubleshooting guides) is not governed by this taxonomy unless explicitly referenced by rules.
Roadmap-style plans (including any copies stored under `docs/` or `requirements/`) remain human-facing background; agents and skills must rely on `rules/**` for normative language/tool requirements.

The `llm-governance` domain is responsible for:
- Defining rules and standards for all LLM-facing assets.
- Providing skills that apply those rules deterministically.
- Providing agents (such as `agent:llm-governance`) that orchestrate governance workflows.
- Exposing user-facing commands (such as `/llm-governance/optimize-prompts`) that optimize, validate, and report on LLM-facing assets.

## Concepts
- Memory: entry points (CLAUDE) that route tasks and declare default agents/skills.
- Output style: a named system-prompt preset selected via `/output-style` or settings, stored as Markdown with frontmatter in `output-styles/`. Output styles configure the main delegate agent’s behavior (for example, Default, Explanatory, Learning) while remaining subject to protocol invariants under `rules/98-communication-protocol.md`.
- Rule: canonical policy documents under `rules/` that define requirements and constraints. Rules are never executed directly; skills reference them as their normative source of truth.
- Agent: orchestration unit (subagent) that binds default/optional skills to commands with clear inputs, outputs, fail-fast rules, and permissions. Agents execute work in a small number of explicit phases (for example, variants of “plan / act / observe / adjust”) so that behavior can be inspected and tested.
- Skill: single capability module that encapsulates how to apply one or more `rules/` sections and any associated implementation artefacts (scripts, templates, tools, config) with defined scope and validation steps. Rules remain normative; implementations may change without rewriting the rule text.
- Command: executable slash command or script that serves as a user entry point. Commands describe parameters and usage but must not embed rule logic; they route work to agents/skills.
- Adapter: command-specific extension for particular targets (e.g., config-sync adapters).
- Workflow: higher-order coordination across multiple commands handled by agents.
- Language and tool selection: a governed decision step that applies rules/10-python-guidelines.md, rules/12-shell-guidelines.md, rules/15-cross-language-architecture.md, rules/20-tool-standards.md, and rules/21-language-tool-selection.md to choose Python, Shell, or hybrid wrapper implementations.

## User vs Project Level Separation

The taxonomy operates across two complementary levels:

**User-Level** (`~/.claude/`):
- Global governance, rules, and policies that apply to all projects
- Personal automation tools, commands, and agent configurations
- LLM-facing assets that define user preferences and default behaviors
- Source of truth for agent routing and skill selection logic

**Project-Level** (`.claude/` within projects):
- Project-specific Claude Code management subsystems (config-sync, agent-ops)
- Project-scoped skills and agents for local automation
- IDE/CI synchronization targets populated by config-sync
- Project boundaries and validation rules

**Routing Behavior:**
1. User-level `CLAUDE.md` is loaded first to establish global routing rules
2. Project-level `CLAUDE.md` inherits user-level defaults and adds project-specific overrides
3. Commands route to user-level agents/skills by default
4. Project-level agents (config-sync, agent-ops) handle project-specific management tasks
5. config-sync bridges the two levels by synchronizing user-level assets to project targets

There are two complementary dependency graphs:
- Execution graph: `Memory → Output style → Agent → Skill → Language/Tool selection` (commands such as `/output-style` and task-specific slash commands select an output style, then an agent/skill stack, then a language/tool stack for concrete implementations).
- Policy graph: `Rule → Output-style manifest → Skill → Agent → Command` (rules define behavior; style manifests implement output-style rules; skills implement both rules and style manifests; agents orchestrate skills; commands expose capabilities to users).

## Spec Alignment (Informative)

This taxonomy reuses terminology from Claude Code and related agent documentation but does not depend on any single external framework. The intended mapping is:

- Memory ≈ project-level routing and default configuration (main entrypoint for agents and skills).
- Agent ≈ subagent with its own system behavior, tools, and execution phases.
- Skill ≈ reusable capability unit, backed by rule sections and implementation artefacts.
- Command ≈ slash command or IDE entrypoint that binds user input to an agent/skill stack.
- Rule ≈ normative policy specification that skills implement.

Projects may additionally define long-lived workspaces, knowledge bases, or other higher-level constructs; those become LLM-facing only when surfaced through skills (for example, by adding a skill that exposes selected `docs/**` content as governed context).

## Capability Axis (Informative)

In addition to structural roles (Memory, Agent, Skill, Rule, Command, Adapter), agents and skills can be described along a capability axis. Implementations MAY use the following informal levels:

- Level 0 – Single-shot behavior with no tools and no cross-step state.
- Level 1 – Tool-using behavior that remains effectively stateless across steps.
- Level 2 – Multi-step workflows with local task memory.
- Level 3 – Planning and coordination across sub-goals or subagents.
- Level 4 – Long-running, monitored systems with metrics, rollback, and self-healing behavior.

Each agent SHOULD make its internal loop explicit in terms of a small set of phases (for example, “sense / plan / act / observe / learn”), but the choice of phase names and decomposition is implementation-defined. Specific conventions (for example, DEPTH-style decompositions) MAY be adopted where they fit naturally; they are not required by this RFC.

Capability levels are descriptive in this document. Future rules and tooling MAY add stricter requirements for particular domains or levels, but the core taxonomy remains valid independent of any specific capability labelling scheme.

## Naming Rules
- Skill IDs: `skill:<category>-<name>` (e.g., `skill:environment-validation`).
- Agent IDs: `agent:<domain>-<role>` (e.g., `agent:config-sync`).
- Directories: `skills/<category>-<name>/SKILL.md`, `agents/<domain>-<role>/AGENT.md`.
- Tags: controlled vocabulary (toolchain, workflow, language, security, memory, testing, etc.) for routing.
- Source references: `rules/<file>.md` as the stable rule identifier, listed in manifests for traceability.
- Manifest required fields:
  - Skill: `name`, `description`, `tags`, `source`, `capability`, `usage`, `validation`, `allowed-tools`.
  - Agent: `name`, `description`, `default-skills`, `optional-skills`, `supported-commands`, `inputs`, `outputs`, `fail-fast`, `escalation`, `permissions`.

Agents and skills MAY additionally declare optional capability-related fields (for example, an agent-level capability indicator or a skill “mode” flag) where this is useful for governance or tooling. Such fields are advisory unless made mandatory by explicit rules under `rules/`.

## Load Order
1. Memory chooses candidate agents based on task context (command, files, language, request).
2. Agents load default skills and append optional skills based on task tags.
3. Skills load and apply the rule sections they declare in their manifests (for example via `source` fields).
4. Commands emit the agent and skill versions used.
5. Review/config-sync commands read the same mapping to keep tooling consistent.

### Selection Mechanisms
- File types (e.g., `**/*.py`) trigger language skills from user-level skills directory
- Metadata (security, testing, LLM-facing) activates corresponding skills from user-level
- Project-level agents (config-sync, agent-ops) are invoked for project-specific commands
- User-level agents handle general routing and default behaviors
- If multiple agents qualify, user-level Memory selects the higher-priority one or prompts the user

## Frameworks and Styles

The system MAY adopt named execution and prompt frameworks for LLM-facing assets, such as:
- SIMPLE-style frontmatter for skills.
- DEPTH-like phase decompositions for commands or agents.
- Other community styles for reasoning, tool use, or planning, as documented under `rules/99-llm-prompt-writing-rules.md`.

These frameworks are optional and layered on top of the taxonomy:
- They MUST NOT introduce additional required schema fields beyond those defined in this RFC unless such requirements are explicitly codified in `rules/`.
- They SHOULD be applied only where they improve clarity, robustness, or governance.
- They MUST NOT change the fundamental relationships between Memory, Agent, Skill, Rule, Command, and Adapter.

## Tooling Expectations
- `skills/environment-validation` and related language skills enforce tool availability and selection; they remain the canonical location for detailed commands and snippets. This RFC only defines when those skills should be consulted.
- Structural editing (AST-aware tooling such as `ast-grep`) is preferred when modifying code semantics; textual search/discovery tooling (`rg`, `fd`) is used for reconnaissance. Rules/skills capture the exact heuristics so agents stay deterministic.
- Tool usage policies (strict mode shells, uv-backed Python CLIs, etc.) live under `rules/20-tool-standards.md` and skill manifests. Agents MUST reference those rules instead of embedding ad-hoc tooling guidance here.

## Directory Layout and Sync

The taxonomy operates across two levels with distinct purposes:

### User-Level (`~/.claude/`)
Global configuration available across all projects:
```
.claude/
├── CLAUDE.md                          # User-level routing and agent declarations
├── rules/                             # Global rules and policies
├── skills/                            # User-level skills (e.g., environment-validation)
├── agents/                            # User-level agents (e.g., llm-governance)
├── commands/                          # User-level commands (e.g., draft-commit-message)
├── output-styles/                     # Named output style manifests
└── docs/                              # Documentation (taxonomy-rfc.md, etc.)
```

### Project-Level (`.claude/` within projects)
Project-specific Claude Code management tools:
```
.claude/
├── CLAUDE.md                          # Project-level routing (inherits user-level defaults)
├── skills/                            # Project-specific skills
├── agents/                            # Project-specific agents
├── commands/                          # Project-level commands
├── config-sync/                       # Config-sync subsystem
│   ├── sync-cli.sh
│   ├── settings.json
│   └── lib/                           # Phase runners and planners
└── agent-ops/                         # Agent operations subsystem
    ├── AGENT.md
    └── scripts/
        ├── agent-matrix.sh
        └── skill-matrix.sh
```

**Synchronization:**
- User-level assets (`rules/`, `skills/`, `agents/`, `CLAUDE.md`) are synchronized to project-level IDE/CI targets via config-sync
- Project-level `config-sync/` and `agent-ops/` subsystems remain project-scoped and do not propagate to other projects
- LLM-governance operates across both levels, validating user-level governance rules and project-level implementations

## Conflict Handling
- A rule section can map to only one core skill; if multiple skills need it, wrap it as a child skill or reference another skill explicitly.
- When skills overlap, the agent loads only the higher-priority skill unless optional skills are specified.
- CLAUDE agent lists are the single authority; commands must not hardcode skills or rules.
- Rules remain the single normative source; skills implement rules and may be refactored or replaced without changing the rule documents themselves.

## Versioning and Release
- Use `MAJOR.MINOR.PATCH` with per-manifest `CHANGELOG.md`.
- config-sync logs the agent/skill versions used for each run so environments can be audited.
- Release cadence:
  - Phase 1-2: Beta (verify agents/skills in controlled scope).
  - Phase 3-4: GA (agents/skills default on).
  - Phase 5+: Monthly releases.
- Each release updates manifest versions, changelogs, and CLAUDE references.

## Approval Flow
1. Submit a PR with the agentization issue template (goals, commands, skills, risks, checklist).
2. Require two reviewers (command owner and prompt/rule owner).
3. Run `/llm-governance/optimize-prompts --target=<files>` and attach results.
4. If scripts or tools change, run relevant linters/tests (shellcheck, `plantuml --check-syntax`, `dbml2sql`, etc.).
5. Perform a config-sync dry run to confirm new directories are recognized.

## Sync Matrix
Maintain a lightweight sync log (plan path, targets, timestamp, commit hash) so you can audit which environments have been updated and reproduce or roll back runs as needed.

## Rollback Strategy
- Every manifest includes a `fallback` pointer to the previous version.
- config-sync keeps at least two historical copies for `--from-backup=<timestamp>`.
- Configurable backup retention maintains `maxRuns` backups with automatic cleanup (default: 5).
- Backup retention settings simply cap the number of stored runs (latest N only).
- CLAUDE contains an emergency note describing how to recover if agents fail (no automatic rule loading).

## Milestones
Phase 0-5 timeline (summarized for agents/skills):
1. Phase 0: RFC and CLAUDE notice.
2. Phase 1: `skills/` directory and core skills.
3. Phase 2: config-sync and llm-governance agents.
4. Phase 3: Updated review/config-sync tooling.
6. Phase 5: Advanced skills, rollback validation, release notes.

## Acceptance Criteria
- CLAUDE references agents only and links to this RFC.
- At least four skills (toolchain, workflow, llm-governance, language-python) implemented with the template.
- At least two agents (config-sync, llm-governance) defined and passing llm-governance:optimize-prompts.
- Capability axis fields (`capability-level`, `mode`, `loop-style`) present for all core agents and key skills, consistent with `rules/96-capability-levels.md`.
- llm-governance:optimize-prompts, config-sync, agent-matrix, and skill-matrix scripts updated to reflect capability and style metadata.
- Version matrix, changelog, and regression logs available.

## Terminology
- Memory: routing entry file.
- Agent: task orchestration unit.
- Skill: capability module.
- Command: executable action.
- Adapter: target-specific extension.
- Manifest: `SKILL.md`/`AGENT.md`.
- Version Matrix: mapping of environments to versions.
- Fallback: previous configuration for rollback.
