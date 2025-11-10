---
name: "skill:testing-strategy"
description: "Enforce testing strategy, coverage, and tooling rules"
tags: [testing]
source:
  - rules/04-testing-strategy.md
allowed-tools: []
capability:
  - "Define unit/integration/e2e coverage targets (80% overall, 95% critical)"
  - "Ensure appropriate frameworks and fixtures per project type"
usage:
  - "Load when planning or reviewing test suites"
validation:
  - "Run project-specific test commands"
fallback: ""
---

## Notes
- Combine with language skills for tool-specific checks (pytest, Go tests, etc.).
