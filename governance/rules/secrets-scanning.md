---
name: rule-block:secrets-scanning
description: Apply security standards for detecting and handling secrets in source trees.
layer: governance
sources:
  - rules/03-security-standards.md
  - rules/00-memory-rules.md
---

# Rule Block: Secrets Scanning

## Purpose

Apply security standards from `rules/03-security-standards.md` and related guidance (for example
\"never commit secrets\" directives in `rules/00-memory-rules.md`) when scanning projects for
potential credentials via `/check-secrets`.

## Application to /check-secrets

When `/check-secrets` is invoked:

- The scan **must**:
  - Prioritize hardcoded secrets in source, config, and script files.
  - Include both tracked files and common configuration paths.
  - Treat findings as *suspicions* that require human confirmation.
- The report **should**:
  - Classify findings by severity and likelihood.
  - Recommend remediation steps consistent with security standards (move to env vars, secret
    managers, rotation procedures).

