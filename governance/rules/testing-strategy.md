---
name: rule-block:testing-strategy
description: Apply testing directives from rules/04-testing-strategy.md.
layer: governance
sources:
  - rules/04-testing-strategy.md
---

# Rule Block: Testing Strategy

## Purpose

Provide governance-level access to the testing requirements defined in
`rules/04-testing-strategy.md`, including coverage expectations, testing philosophy, and test
organization standards.

## Key Requirements (Referenced)

- Apply explicit coverage targets, especially for critical paths and security-sensitive code.
- Focus tests on behavior, not implementation details.
- Keep test data minimal and well-scoped; categorize tests as unit/integration/e2e.
- Use Red-Green-Refactor for clear requirements and implementation-first for exploratory code.

## Application

- Routers such as `router:code-refactor`, `router:plan-review`, and `router:ts-error-resolution`
  SHOULD:
  - Load this rule-block whenever changes have testing impact.
  - Require agents to comment on coverage gaps and critical-path tests.
  - Encourage incremental testing improvements rather than large, risky changes.

