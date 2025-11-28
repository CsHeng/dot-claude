---
name: rule-block:unified-search-discover
description: Apply search and refactor tool selection guidance at the governance layer.
layer: governance
sources:
  - rules/21-language-tool-selection.md
  - rules/20-tool-standards.md
---

# Rule Block: Search and Refactor Strategy

## Purpose

Provide governance-level guidance for choosing between structural (`ast-grep`) and textual
(`ripgrep`) search, as well as `.gitignore`-aware discovery tools (`fd`), by referencing
tool-selection and tool-standard rules.

## Key Requirements (Referenced)

- Prefer `.gitignore`-aware discovery tools where possible (e.g., `fd`) to avoid noise.
- Use structural tools (such as `ast-grep`) when precision and safety matter more than speed.
- Use fast textual search (`rg`) for reconnaissance and narrowing candidate sets.
- Apply dry-run modes and small-scope pilots before large-scale refactors.

## Application

- Routers such as `router:code-refactor` and `router:ts-error-resolution` SHOULD:
  - Load this rule-block when tasks require large-scale search or codemods.
  - Bias agents toward safe, incremental refactors with explicit dry-run steps.
  - Require agents to explain tool choices when suggesting automated refactors.

