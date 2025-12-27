---
description: Run llm-governance design-time audits and optional deterministic fixes for LLM-facing files using rule-driven schemas and dedicated analysis tools
name: llm-governance
argument-hint: '[path/to/file] [--all]'
allowed-tools:
  - Read
  - Write
  - Execute
  - Bash(python3 skills/llm-governance/scripts/optimize-prompts.py *)
  - Bash(python3 skills/llm-governance/scripts/system_test.py *)
---

## Usage

/llm-governance [path]
/llm-governance --all

## Arguments

- `path`: Target file or directory inside the current project. When omitted, use the default LLM-facing scope.
- `--all`: Audit all LLM-facing files defined by taxonomy and rule configuration. When present, ignore `path`.

## Workflow

1. Route the request to `agent:llm-governance` and load default skills:
   - `skill:llm-governance`
   - `skill:workflow-discipline`
   - `skill:environment-validation`
2. Validate the toolchain with `python3 skills/llm-governance/scripts/tool_checker.py` and select fd, rg, and ast-grep fallbacks when available.
3. Resolve target files from the repository root using taxonomy rules and `skills/llm-governance/scripts/config.yaml`:
   - Include `commands/**/*.md`, `skills/**/SKILL.md`, `agents/**/AGENT.md`, `rules/**/*.md`, `CLAUDE.md`, `AGENTS.md`, and `.claude/settings.json`.
   - Exclude documentation, examples, tests, IDE metadata, and backup directories.
4. Apply governance rules from `skills/llm-governance/rules/99-llm-prompt-writing-rules.md` and related rule files through `skill:llm-governance` using `skills/llm-governance/scripts/validator.py` (which uses `config.yaml` as SSOT).
5. Analyze cross-file dependencies with `skills/llm-governance/scripts/dependency_analyzer.py` to validate the `rules → skill → agent → command` graph and detect cycles or invalid directions.
6. Generate per-file candidates and batch summaries with `skills/llm-governance/scripts/optimize-prompts.py`:
   - Keep original files unchanged until explicit approval.
   - Derive suggested fixes based on validation results and rule mappings.
7. Apply approved changes:
   - Create backups under `.claude/backup/rollback-<timestamp>/` before any write.
   - Write only approved candidates to disk.
   - Optionally run `skills/llm-governance/scripts/system_test.py` for full-system validation after changes.

## Output

- Per file:
  - Governance issues with severity and rule references.
  - Suggested fixes when available.
- Batch:
  - Counts for analyzed, written, skipped, and error files.
  - Dependency issues and classification by severity.
  - Backup root directory for the run.
- Exit codes:
  - `0`: Audit completed without fatal errors.
  - `1`: Tooling or validation failure.
  - `130`: Operation cancelled by user.

