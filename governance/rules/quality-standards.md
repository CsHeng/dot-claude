---
name: rule-block:quality-standards
description: Apply quality and gatekeeping directives from rules/21-quality-standards.md.
layer: governance
sources:
  - rules/21-quality-standards.md
---

# Rule Block: Quality Standards

## Purpose

Make the quality and gatekeeping requirements in `rules/21-quality-standards.md` available at the
governance layer so routers can enforce consistent expectations for code quality and CI behavior.

## Key Requirements (Referenced)

- Require automated quality gates in CI/CD (linting, tests, security scans).
- Forbid merging code with known critical quality or security issues.
- Use objective metrics (coverage, complexity, maintainability) over subjective judgments.
- Require documented rationale for exceptions or relaxations of quality standards.

## Application

- Routers such as `router:code-refactor`, `router:plan-review`, and `router:llm-governance`
  SHOULD:
  - Load this rule-block when tasks affect quality-related configuration or standards.
  - Ask execution agents to highlight how proposed changes interact with quality gates.
  - Treat disabling or bypassing quality checks as a high-risk action requiring justification.

