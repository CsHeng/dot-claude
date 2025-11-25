# Router: llm-governance

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route LLM-facing file audits and optimization tasks (such as `/llm-governance/optimize-prompts`)
through the appropriate governance rules, classifiers, and execution agents.

## Inputs
- Slash commands / entrypoints:
  - `/llm-governance/optimize-prompts` → `governance/entrypoints/llm-governance-optimize-prompts.md`
- Context:
  - Target paths or `--all` flag
  - Current project taxonomy and classification rules
  - Active governance rule sets under `rules/**`

## Policy
- Always load governance rule-blocks for:
  - `rule-block:llm-governance`
  - `rule-block:workflow-discipline`
  - `rule-block:environment-validation`
- Use directory-based classification (e.g., `commands/**`, `skills/**/SKILL.md`, `agents/**/AGENT.md`,
  `rules/**/*.md`, `CLAUDE.md`, `.claude/settings.json`) as defined in `commands/llm-governance/optimize-prompts/classification-rules.yaml`.

## Execution Handoff (Layer 3)
- Default execution agent: `agent:llm-governance` (execution layer).
- Expected skills (execution layer, future):
  - File classification and discovery
  - Rule application and validation
  - Candidate generation and apply/rollback helpers

## Notes
- This router captures the governance logic that was previously implicit in
  `agents/llm-governance/AGENT.md` and the optimize-prompts command spec.
- Low-level tool invocations (`python3 commands/llm-governance/optimize-prompts/*.py`, backups,
  etc.) belong to execution-layer commands and agents, not this router.
