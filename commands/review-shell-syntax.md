---
description: Review shell script syntax and guideline compliance
argument-hint: [path/to/script.sh]
allowed-tools: Read, Bash(bash -n:*), Bash(sh -n:*), Bash(zsh -n:*)
---

## Goal
Ensure the target shell script follows our shell guidelines and passes syntax validation.

## Instructions
- If no path argument is provided, ask for one before proceeding.
- Load the guidelines in @rules/12-shell-guidelines.md for reference.
- Inspect the target script `$1`, noting shebang, strict mode usage, quoting, traps, and other checklist items.
- Point out any deviations with line references and cite relevant guideline sections.
- Run the matching syntax check command for the script type:
  - `bash -n "$1"`
  - `sh -n "$1"`
  - `zsh -n "$1"`
- Report the syntax check output and confirm whether the script complies or needs changes.
