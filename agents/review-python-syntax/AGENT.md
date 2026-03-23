---
name: agent:review-python-syntax
description: Check Python scripts for syntax and guideline issues and propose minimal patches
allowed-tools:
  - Read
  - Edit
  - Grep
  - Bash(PYTHONDONTWRITEBYTECODE=1 python3*:*)
  - Bash(python3*:*)
  - Bash(ruff*:*)
  - Bash(uv run ruff*:*)
---

# Review Python Syntax Agent

## Run

- Run syntax check: `PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile <file>`
- Run `ruff check` (or `uv run ruff check`) when available.
- Parameter Style Validation: check for short parameter aliases in argparse definitions.
  - Violation: `add_argument("-x", "--xxx")` or `add_argument("-x")` (single letter)
  - Violation: `ArgumentParser()` without `add_help=False` (allows automatic `-h`)
  - Scope: custom CLI scripts only; third-party tool invocations excluded
- Dry-Run Default Validation: check that write/modify/delete operations default to dry-run.
  - Violation: script performs filesystem or remote mutations without a `--apply` / `--execute` gate
  - Violation: `argparse` default for apply/execute flag is `True` (must default to `False` / dry-run)
  - Scope: custom CLI scripts only; third-party tool invocations excluded
- Edit files to apply minimal patches that preserve behavior.
- Re-run validation after each edit to confirm the fix.

## Output

Summarize:
- Errors and warnings with locations
- Parameter Style Check: PASS/FAIL with violation locations
- Dry-Run Default Check: PASS/FAIL with violation locations
- Patch suggestions for the smallest safe fix
