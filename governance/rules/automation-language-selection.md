---
name: rule-block:automation-language-selection
description: Choose appropriate automation language (Shell vs Python) for workflows that generate or run automation code.
layer: governance
sources:
  - rules/21-language-tool-selection.md
  - rules/15-cross-language-architecture.md
---

# Rule Block: Automation Language Selection

## Purpose

Apply automation language selection rules from `rules/21-language-tool-selection.md` and
`rules/15-cross-language-architecture.md` when workflows involve generating or modifying
automation code (Shell, Python, or mixed).

## Application Notes

- For `/draft-commit-message`, this rule-block is typically not central (no automation code
  generation), but `router:workflow-helper` may still load it as a cross-cutting governance
  rule for other workflows it handles.\n+
