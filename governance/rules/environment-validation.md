---
name: rule-block:environment-validation
description: Validate toolchain and environment configuration before running complex workflows.
layer: governance
sources:
  - rules/20-tool-standards.md
  - rules/21-language-tool-selection.md
---

# Rule Block: Environment Validation

## Purpose

Apply environment and toolchain validation rules from `rules/20-tool-standards.md` and
`rules/21-language-tool-selection.md` before running workflows that depend on external tools and
language runtimes, such as `/llm-governance`.

## Application

- Ensure required tools (fd, rg, ast-grep, python, etc.) are available and correctly configured.
- Validate version managers and configuration files where applicable.
- Escalate or fail fast when critical tooling is missing or misconfigured.

