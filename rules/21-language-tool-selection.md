# Language and Tool Selection Standards

## Scope
REQUIRED: Apply these standards whenever agents, skills, or commands decide which language or tool stack to use for automation in this repository.
REQUIRED: Treat this file, together with rules/10-python-guidelines.md, rules/12-shell-guidelines.md, rules/15-cross-language-architecture.md, and rules/20-tool-standards.md, as the canonical decision set for language/tool selection.
PROHIBITED: Rely on ad-hoc plan documents or human notes as normative sources for language decisions.

## Python-First Automation
REQUIRED: Prefer Python (managed by uv) for workflows with branching, state, API calls, structured data parsing, validation, or reusable CLIs.
REQUIRED: Implement Python automation as importable modules with CLI entry points exposed via `python -m` or uv-managed scripts declared in `pyproject.toml`.
REQUIRED: Keep Python business logic independent from shell wrappers so it can be tested directly.
PROHIBITED: Fall back to shell when Python is available and the task exceeds simple glue or OS-near chores.

## Shell Usage Boundaries
REQUIRED: Limit shell scripts to OS-near orchestration, short linear pipelines, environment setup, and delegating to Python CLIs.
REQUIRED: Enforce strict-mode patterns (`set -euo pipefail` and safe IFS) for every shell entry point.
PREFERRED: Keep shell scripts under ~30 LOC of core logic and ensure a reader can audit them on one screen.
PROHIBITED: Implement structured data parsing, complex branching, network logic, or business rules directly in shell.

## Hybrid Wrapper Pattern
REQUIRED: Use the hybrid pattern only when shell must do environment discovery or per-target orchestration and Python handles validation or data-heavy logic.
REQUIRED: Call Python modules via `python -m module` or uv-run scripts; do not embed inline Python (`python -c`, here-doc) inside shell.
REQUIRED: Define clear ownership: shell prepares inputs/paths, Python performs computation, shell handles exit codes/logging.
PROHIBITED: Split the same business rule across shell and Python in a way that makes reasoning or testing difficult.

## Toolchain Defaults
REQUIRED: Use uv for Python dependency management, virtual envs, and dev tooling; document CLIs in `pyproject.toml` whenever practical.
REQUIRED: Treat mise as a dev-environment helper only; shell scripts and production tooling must not assume mise is installed.
REQUIRED: Validate Python, uv, and shell availability via `skill:environment-validation` before committing to an implementation plan.

## Taxonomy Integration
REQUIRED: Extend the execution graph to `Memory → Output style → Agent → Skill → Language/Tool selection → Command/Script` and record the selected language in skill/agent outputs when relevant.
REQUIRED: Ensure `skill:automation-language-selection` (or equivalent logic inside agents) loads `skills/language-python` or `skills/language-shell` according to this standard.
REQUIRED: When governance commands (/llm-governance/optimize-prompts, config-sync workflows, etc.) rewrite manifests or scripts, they must confirm the resulting language choice obeys these rules.

## Validation
REQUIRED: Language decisions must cite this rule (and related language rules) in manifests, reviews, or governance diffs.
REQUIRED: Any exception (e.g., selecting shell for a complex workflow due to hard constraints) must be documented with justification and approval in-plan.
PROHIBITED: Landing new automation or refactors that contradict these standards without an approved exception log.
