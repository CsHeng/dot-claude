---
name: rule-block:development-standards
description: Apply cross-language development standards from rules/01-development-standards.md.
layer: governance
sources:
  - rules/01-development-standards.md
---

# Rule Block: Development Standards

## Purpose

Surface the development standards in `rules/01-development-standards.md` as a governance rule-block
that routers can apply across workflows (refactors, plan-review, error-resolution, etc.).

## Key Requirements (Referenced)

- Enforce clear, intent-revealing naming and single-responsibility functions.
- Avoid magic numbers by using named constants with units.
- Keep functions small, with controlled parameter counts and early returns.
- Require explicit, structured error handling instead of silently ignoring failures.

## Application

- Routers such as `router:code-refactor`, `router:plan-review`, and `router:ts-error-resolution`
  SHOULD:
  - Load this rule-block when tasks involve code edits or design changes.
  - Require agents to call out development-standard violations in their analysis.
  - Prefer refactor and plan suggestions that move code toward these standards.

