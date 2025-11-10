---
name: "skill:language-python"
description: "Apply Python architecture, typing, security, and testing rules"
tags: [language, python]
source:
  - rules/10-python-guidelines.md
allowed-tools:
  - Bash(uv)
  - Bash(ruff)
  - Bash(pytest)
capability:
  - "Follow Rule 10 guidance on architecture, naming, typing, error handling, security, performance"
  - "Use Ruff for formatting, linting, and import ordering"
  - "Run pytest + pytest-cov, meeting coverage targets"
usage:
  - "Auto-load for agents or commands touching `**/*.py`"
validation:
  - "`uv tool run ruff format` / `uv tool run ruff check`"
  - "`uv tool run pytest --maxfail=1`"
fallback: ""
globs:
  - "**/*.py"
---

## Notes
- Use together with `skill:toolchain-baseline`.
- Agents can load `skill:testing-strategy` when deeper testing guidance is required.
