---
name: "skill:language-shell"
description: "Enforce shell script standards (bash/sh/zsh) with strict mode and portability"
tags: [language, shell]
source:
  - rules/12-shell-guidelines.md
allowed-tools:
  - Bash(shellcheck)
capability:
  - "Require `set -euo pipefail` (or equivalents) and `trap` error handlers"
  - "Mandate quoting, safe parameter expansion, and portable shebang usage"
  - "Run syntax validation via `bash -n`, `sh -n`, or `zsh -n`"
usage:
  - "Load for commands that review or execute shell scripts (`**/*.sh`)"
validation:
  - "`shellcheck <script>`"
  - "`bash -n <script>` / `sh -n <script>` / `zsh -n <script>` depending on shebang"
fallback: ""
globs:
  - "**/*.sh"
---

## Notes
- Works with `agent:workflow-helper` and `agent:shell-auditor`.
- Extend allowed tools if additional shell linters are introduced.
