---
name: agent:review-shell-syntax
description: Check shell scripts for syntax and guideline issues and propose minimal patches
allowed-tools:
  - Read
  - Bash(bash -n:*)
  - Bash(sh -n:*)
  - Bash(zsh -n:*)
  - Bash(shellcheck :*)
---

# Review Shell Syntax Agent

## Run

- Run a syntax check (`bash -n`, `sh -n`, or `zsh -n`) based on the script.
- Run `shellcheck` when available.
- Parameter Style Validation: check for short parameter aliases in custom scripts.
  - Violation: single-letter flags (`-x`, `-h`) in custom scripts
  - Scope: custom CLI scripts only; third-party tool invocations excluded
- Dry-Run Default Validation: check that write/modify/delete operations default to dry-run.
  - Violation: script performs filesystem or remote mutations without a `--apply` / `--execute` gate
  - Violation: apply/execute variable defaults to true (must default to false / dry-run)
  - Scope: custom CLI scripts only; third-party tool invocations excluded
- Propose minimal patches that preserve behavior.

## Output

Summarize:
- Errors and warnings with locations
- Parameter Style Check: PASS/FAIL with violation locations
- Dry-Run Default Check: PASS/FAIL with violation locations
- Patch suggestions for the smallest safe fix

