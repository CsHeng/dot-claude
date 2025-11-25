---
name: rule-block:workflow-patterns
description: Apply workflow pattern directives from rules/23-workflow-patterns.md.
layer: governance
sources:
  - rules/23-workflow-patterns.md
---

# Rule Block: Workflow Patterns

## Purpose

Expose workflow pattern directives from `rules/23-workflow-patterns.md` so routers can enforce
incremental development, clear handoffs, and TERSE MODE communication across workflows.

## Key Requirements (Referenced)

- Prefer incremental, file-by-file changes for easier review.
- Preserve and update existing comments rather than removing them.
- Maintain TERSE, high-density communication without filler text.
- Apply clear state transitions and handoff procedures during multi-phase work.

## Application

- Routers such as `router:workflow-helper`, `router:code-refactor`, and `router:plan-review`
  SHOULD:
  - Load this rule-block for multi-step or long-running workflows.
  - Encourage agents to break down work into well-defined phases with explicit handoffs.
  - Ensure communication remains concise and aligned with TERSE MODE standards.

