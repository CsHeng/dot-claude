# Router: plan-review

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route planning and plan review requests (such as `/review-plan` and `/plan-*`) to the appropriate
execution agents, applying workflow and architecture standards.

## Inputs
- Slash commands / entrypoints:
  - `/review-plan`, `/plan-*` → `governance/entrypoints/plan.md`
- Context:
  - Plan type (refactor, feature, architecture, etc.)
  - Project risk and constraints

## Policy
- Load governance rule-blocks for:
  - `rule-block:workflow-discipline`
  - `rule-block:architecture-patterns`
  - `rule-block:testing-strategy`
  - `rule-block:quality-standards`
  - `rule-block:workflow-patterns`
- Apply planning guidance from:
  - `rules/02-architecture-patterns.md`
  - `rules/04-testing-strategy.md`
  - `rules/21-quality-standards.md`
  - `rules/23-workflow-patterns.md`

## Execution Handoff (Layer 3)
- Default execution agent: `agent:plan-reviewer` (execution layer).

## Notes
- This router focuses on analysis and review of plans; execution agents perform detailed plan
  deconstruction and feedback.
