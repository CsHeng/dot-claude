---
name: "skill:toolchain-baseline"
description: "Unify toolchain versions and validation rules"
tags: [toolchain, default]
source:
  - rules/00-memory-rules.md#Tool-Version-Preferences
  - rules/00-memory-rules.md#Specific-Tool-Configurations
allowed-tools:
  - Bash(python3 --version)
  - Bash(go version)
  - Bash(plantuml --version)
  - Bash(dbml2sql --version)
capability:
  - "Python >= 3.13, Go >= 1.23, default interactive shell = zsh, Lua >= 5.4"
  - "Single `.venv` managed by UV; use mise for tool installation"
  - "PlantUML >= 1.2025.9 and dbml2sql available; Go builds enforce CGO_ENABLED=0"
usage:
  - "Load by default for every agent; ensure toolchain matches rules/00 requirements"
validation:
  - "python3 --version | rg '3\\.1[3-9]'"
  - "go version | rg 'go1\\.2[3-9]'"
  - "plantuml --version"
  - "dbml2sql --version"
fallback: ""
---

## Notes
- When dependencies are missing, instruct the user to run `mise install` or `uv tool install <name>`.
- Record validation results in logs so auditors can confirm the environment state.
