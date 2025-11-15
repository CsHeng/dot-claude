# Taxonomy RFC

## Background
The current CLI relies on `CLAUDE.md` and numerous `rules/*.md` files to describe behavior, but there is no organized mapping between commands, rules, and memory entries. Without an explicit agent/skill structure:
- Tasks cannot be routed quickly to the right agent.
- `rules/*` are hard to reuse and often conflict or overlap.
- Commands such as review or config-sync cannot validate future skills or agents.

This RFC defines a unified taxonomy (Memory → Agent → Skill → Command) to guide the directory refactor and supporting tooling.

The taxonomy is derived from and aligned with external Claude Code specifications:
- Subagents: https://code.claude.com/docs/en/sub-agents
- Slash commands: https://code.claude.com/docs/en/slash-commands
- Agent skills: https://code.claude.com/docs/en/skills

## Scope
- Entry file: `CLAUDE.md`
- Directories: `rules/`, `skills/`, `agents/`, `commands/`, `requirements/`, `docs/`
- Supported commands: config-sync, optimize-prompts, doc-gen, draft-commit-message, review-shell-syntax, etc.
- Execution environments: Codex CLI, Claude Code, Qwen CLI, IDE/CI sync destinations

## Goals
1. Establish the Memory → Agent → Skill load order and selection logic.
2. Define consistent naming, directory layout, manifest fields, tags, and `source` references.
3. Standardize versioning, approval, synchronization, rollback, and monitoring processes.
4. Provide milestones, task templates, and acceptance criteria for the migration.

## LLM-Facing Governance Domain

This taxonomy treats LLM-facing assets as a first-class domain. LLM-facing content is any file whose primary reader is a model rather than a human, including:
- System and routing manifests (`CLAUDE.md`, `AGENTS.md`).
- Agent and skill manifests (`agents/**/AGENT.md`, `skills/**/SKILL.md`).
- Slash command manifests and usage files under `commands/`.
- Governance and prompt-writing rules under `rules/`.
- Core configuration such as `.claude/settings.json`.

Human-facing documentation (for example `docs/**`, project READMEs, and troubleshooting guides) is not governed by this taxonomy unless explicitly referenced by rules.

The `llm-governance` domain is responsible for:
- Defining rules and standards for all LLM-facing assets.
- Providing skills that apply those rules deterministically.
- Providing agents (such as `agent:llm-governance`) that orchestrate governance workflows.
- Exposing user-facing commands (such as `/optimize-prompts`) that optimize, validate, and report on LLM-facing assets.

## Concepts
- **Memory**: entry points (CLAUDE) that route tasks and declare default agents/skills.
- **Rule**: canonical policy documents under `rules/` that define requirements and constraints. Rules are never executed directly; skills reference them as their normative source of truth.
- **Agent**: orchestration unit (subagent) that binds default/optional skills to commands with clear inputs, outputs, fail-fast rules, and permissions.
- **Skill**: single capability module that encapsulates how to apply one or more `rules/` sections with defined scope and validation steps.
- **Command**: executable slash command or script that serves as a user entry point. Commands describe parameters and usage but must not embed rule logic; they route work to agents/skills.
- **Adapter**: command-specific extension for particular targets (e.g., config-sync adapters).
- **Workflow**: higher-order coordination across multiple commands handled by agents.

There are two complementary dependency graphs:
- **Execution graph**: `Memory → Agent → Skill` (commands are user-facing entry points that select an agent/skill stack).
- **Policy graph**: `Rule → Skill → Agent → Command` (rules define behavior; skills implement rules; agents orchestrate skills; commands expose capabilities to users).

## Naming Rules
- Skill IDs: `skill:<category>-<name>` (e.g., `skill:environment-validation`).
- Agent IDs: `agent:<domain>-<role>` (e.g., `agent:config-sync`).
- Directories: `skills/<category>-<name>/SKILL.md`, `agents/<domain>-<role>/AGENT.md`.
- Tags: controlled vocabulary (toolchain, workflow, language, security, memory, testing, etc.) for routing.
- Source references: `rules/<file>.md` as the stable rule identifier, listed in manifests for traceability.
- Manifest required fields:
  - Skill: `name`, `description`, `tags`, `source`, `capability`, `usage`, `validation`, `allowed-tools`.
  - Agent: `name`, `description`, `default-skills`, `optional-skills`, `supported-commands`, `inputs`, `outputs`, `fail-fast`, `escalation`, `permissions`.

## Load Order
1. Memory chooses candidate agents based on task context (command, files, language, request).
2. Agents load default skills and append optional skills based on task tags.
3. Skills load and apply the rule sections they declare in their manifests (for example via `source` fields).
4. Commands emit the agent and skill versions used.
5. Review/config-sync commands read the same mapping to keep tooling consistent.

### Selection Mechanisms
- Command prefixes (`/config-sync/*`, `/doc-gen:*`, etc.) map to agents.
- File types (e.g., `**/*.py`) trigger language skills.
- Metadata (security, testing, LLM-facing) activates corresponding skills.
- If multiple agents qualify, Memory selects the higher-priority one or prompts the user.

## Tooling Guidance: ast-grep vs ripgrep
Codifying search/edit behavior as a skill requires clear defaults for when to rely on structural versus textual tooling:

- Use `ast-grep` when structure matters. It parses code, ignores comments/strings, understands syntax, and can safely rewrite nodes. Reach for it when building refactors/codemods (rename APIs, change import styles, rewrite call sites), enforcing repo policies (`scan` + `test` rules), or powering editors/automation (LSP mode, `--json` output).
- Use `ripgrep` when text is enough. It is the fastest way to scan literals/regex across files for reconnaissance (strings, TODOs, logs, config values, non-code assets) or for pre-filtering candidate files before a precise pass.
- Rule of thumb. Prefer `ast-grep` whenever correctness matters or you plan to apply fixes; prefer `rg` when you only need quick textual hunting. A common workflow is `rg` to shortlist files, followed by `ast-grep` to match or modify with precision.

### Snippets
Find structured Go code (ignores comments/strings):

```bash
ast-grep run -l Go -p 'for $K, $V := range $MAP { $BODY }'
```

Codemod (`ioutil.ReadFile` → `os.ReadFile` only where it is an actual call):

```bash
ast-grep run -l Go -p 'ioutil.ReadFile($PATH)' -r 'os.ReadFile($PATH)' -U
```

Quick textual hunt:

```bash
rg -n 'fmt\.Printf\(' -t go
```

Combine speed and precision:

```bash
rg -l -t go 'time\.Sleep' | xargs ast-grep run -l Go -p 'time.Sleep($DUR)' -r 'testclock.Sleep($DUR)' -U
```

### Mental Model
- Match unit: `ast-grep` operates on AST nodes; `rg` operates on lines.
- False positives: `ast-grep` stays low; `rg` depends entirely on your regex quality.
- Rewrite safety: `ast-grep` is first-class; `rg` rewrites require ad-hoc `sed`/`awk` logic and risk collateral edits.

### fd vs find (gitignore-aware discovery)
- Default to `fd` for file discovery so `.gitignore`, `.ignore`, and `.fdignore` are honored automatically, mirroring the ignore rules that `rg` uses for searches.
- Reach for `fd --no-ignore` when ignored paths (vendor bundles, build output) must be inspected, or `fd --ignore-vcs` when you only want to bypass `.gitignore` but still respect `.ignore`/`.fdignore`.
- Combine `fd` with `rg`/`ast-grep` rather than invoking legacy `find`; when `find` is unavoidable (exotic predicates), wrap the call with `git check-ignore -q "$path"` so ignored files stay filtered.

```bash
# Tracked Gradle scripts within two directory levels
fd --type f --max-depth 2 'build\.gradle.*' android/

# Inspect ignored artifacts explicitly
fd --no-ignore --hidden --type f 'report\.json' .
```

## Directory Layout and Sync
```
.claude/
├── CLAUDE.md
├── (IDE-specific memory files as needed)
├── rules/
├── skills/<category>-<name>/SKILL.md
├── agents/<domain>-<role>/AGENT.md
├── commands/
├── docs/
└── scripts/tests/agent-matrix.sh
```

- config-sync copies `rules/`, `skills/`, `agents/`, and `CLAUDE.md` to IDE/CI targets.
- optimize-prompts expands its default targets to include the new directories and validates manifest structure.

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
3. Run `/optimize-prompts --target=<files>` and attach results.
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
See `requirements/01-claude.md` for the Phase 0‑5 timeline:
1. Phase 0: RFC and CLAUDE notice.
2. Phase 1: `skills/` directory and core skills.
3. Phase 2: config-sync and llm-governance agents.
4. Phase 3: Updated review/config-sync tooling.
5. Phase 4: Agents such as doc-gen and workflow-helper.
6. Phase 5: Advanced skills, rollback validation, release notes.

## Acceptance Criteria
- CLAUDE references agents only and links to this RFC.
- At least four skills (toolchain, workflow, llm-governance, language-python) implemented with the template.
- At least two agents (config-sync, llm-governance) defined and passing optimize-prompts.
- optimize-prompts, config-sync, and agent-matrix scripts updated.
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
