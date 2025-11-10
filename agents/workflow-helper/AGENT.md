---
name: "agent:workflow-helper"
description: "Assist day-to-day collaboration commands (draft commit, shell review, etc.)"
default-skills:
  - skill:workflow-discipline
optional-skills:
  - skill:toolchain-baseline
  - skill:language-shell
supported-commands:
  - /commands:draft-commit-message
  - /review-shell-syntax
inputs:
  - Git status/diff
  - Shell script paths
outputs:
  - Commit message proposal
  - Shell syntax report
fail-fast: true
permissions:
  - "Read access to the Git repository"
escalation:
  - "Prompt the user before running shell validation scripts"
fallback: ""
---

## Responsibilities
- Draft commit: gather Git state, generate a commit summary, and prompt for human confirmation.
- Review shell: run shellcheck or custom scripts, producing syntax/security feedback.
- Load `skill:language-shell` or `skill:security-guardrails` as needed.
