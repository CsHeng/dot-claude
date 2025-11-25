---
name: rule-block:shell-guidelines
description: Apply shell scripting standards when analyzing or fixing shell scripts.
layer: governance
sources:
  - rules/12-shell-guidelines.md
---

# Rule Block: Shell Guidelines

## Purpose

Apply the shell scripting directives from `rules/12-shell-guidelines.md` whenever shell scripts are
analyzed or modified, for example via `/review-shell-syntax`.

## Application to /review-shell-syntax

When `/review-shell-syntax` is invoked:

- The audit **must**:
  - Enforce strict mode (`set -euo pipefail`) where appropriate.
  - Validate shebang and shell selection based on environment.
  - Check quoting, variable handling, and error handling rules.
  - Respect security requirements (no hardcoded secrets, no unsafe eval/exec).
- Auto-fix patches **must**:
  - Limit changes to violations of these rules.
  - Avoid broad reformatting or stylistic changes unrelated to violations.

