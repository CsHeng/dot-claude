# Router: code-architecture

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route architecture review requests (such as `/review-code-architecture`) to the appropriate
execution agents, applying development and architecture standards.

## Inputs
- Slash commands / entrypoints:
  - `/review-code-architecture` → `governance/entrypoints/review-code-architecture.md`
- Context:
  - Target files or modules
  - Project architecture and technology stack

## Policy
- Load governance rule-blocks for:
  - `rule-block:workflow-discipline`
- Apply architecture and development standards from:
  - `rules/01-development-standards.md`
  - `rules/02-architecture-patterns.md`

## Execution Handoff (Layer 3)
- Default execution agent: `agent:code-architecture-reviewer` (execution layer).

## Notes
- This router provides the governance view over architecture review; the execution agent implements
  concrete analysis and reporting steps.

