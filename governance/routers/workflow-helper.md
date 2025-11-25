# Router: workflow-helper

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route day-to-day collaboration workflows (such as drafting commit messages or reviewing shell
scripts) to appropriate execution agents and skills, while enforcing workflow-discipline and
automation-language-selection policies.

## Inputs
- Slash commands / entrypoints:
  - `/draft-commit-message` → `governance/entrypoints/draft-commit-message.md`
  - `/review-shell-syntax` → `governance/entrypoints/review-shell-syntax.md`
  - `/check-secrets` → `governance/entrypoints/check-secrets.md`
- Context:
  - Current project type and language mix
  - Git repository state (when available)
  - Active output-style (from `/output-style` or settings)

## Policy
- Always load governance rule-blocks for:
  - `rule-block:workflow-discipline`
  - `rule-block:automation-language-selection`
- Prefer TERSE MODE + reasoning-first styles unless explicitly overridden.

## Execution Handoff (Layer 3)
- For `/draft-commit-message`:
  - Primary execution agent: `agent:draft-commit-message` (execution layer).
  - Expected skills: `filesystem`, `git`.
  - Additional rule-block: `rule-block:commit-messages`.
- For `/review-shell-syntax`:
  - Primary execution agent: `agent:review-shell-syntax` (execution layer).
  - Expected skills: `filesystem`.
  - Additional rule-block: `rule-block:shell-guidelines`.
- For `/check-secrets`:
  - Primary execution agent: `agent:check-secrets` (execution layer).
  - Expected skills: `filesystem`, `git`.
  - Additional rule-block: `rule-block:secrets-scanning`.

## Notes
- This router is the governance-layer counterpart of the existing `agents/workflow-helper/AGENT.md`.
- During migration, both this router and the original AGENT manifest may coexist; routing logic
  should treat this file as the canonical governance description.
