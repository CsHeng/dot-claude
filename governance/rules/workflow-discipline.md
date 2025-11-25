---
name: rule-block:workflow-discipline
description: Enforce workflow discipline for incremental delivery and structured collaboration.
layer: governance
sources:
  - rules/00-memory-rules.md
  - rules/23-workflow-patterns.md
---

# Rule Block: Workflow Discipline

## Purpose

Apply workflow discipline requirements from `rules/00-memory-rules.md` and
`rules/23-workflow-patterns.md` to day-to-day collaboration workflows such as
`/draft-commit-message` and `/review-shell-syntax`.

## Key Requirements (Referenced)

- Incremental, file-by-file changes for easier review.
- Fail-fast behavior and explicit error handling.
- Clear, concise, and structured communication patterns.
- Respect for existing language, style, and project conventions.

## Application

- Routers such as `router:workflow-helper` should ensure:
  - Tasks are scoped narrowly where feasible (e.g., via `--filter`).
  - Agents explain when a workflow would benefit from further breakdown.
  - Communication stays within the TERSE / reasoning-first boundaries defined in
    `rules/98-communication-protocol.md` and the active output style.

