---
name: rule-block:architecture-patterns
description: Apply architecture pattern directives from rules/02-architecture-patterns.md.
layer: governance
sources:
  - rules/02-architecture-patterns.md
---

# Rule Block: Architecture Patterns

## Purpose

Expose architectural directives from `rules/02-architecture-patterns.md` to governance routers so
they can enforce layering, dependency, and boundary rules when choosing or configuring execution
agents.

## Key Requirements (Referenced)

- Enforce clean layering (handlers → services → repositories → domain models).
- Prevent circular dependencies and God objects.
- Keep business logic decoupled from frameworks and infrastructure.
- Prefer interface-driven development and composition over inheritance.

## Application

- Routers such as `router:code-architecture` and `router:code-refactor` SHOULD:
  - Load this rule-block when tasks involve structural or architectural changes.
  - Bias agent selection toward behaviors that preserve or improve layering and boundaries.
  - Treat violations of core architecture rules as high-priority findings in reports.

