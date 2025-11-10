---
name: "skill:error-patterns"
description: "Apply explicit error handling, fail-fast, and logging rules"
tags: [quality, error]
source:
  - rules/05-error-patterns.md
allowed-tools: []
capability:
  - "Implement fail-fast strategies with early exits and structured logging"
  - "Propagate errors with contextual information (per language guidelines)"
  - "Capture state/inputs alongside errors to aid debugging"
usage:
  - "Load for debugging tasks, incident reviews, or agents that manipulate error handling code"
validation:
  - "Manual review or unit tests confirming error wrapping and logging"
fallback: ""
---

## Notes
- Combine with language-specific skills to ensure implementations follow both general and language rules.
