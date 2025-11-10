---
name: "skill:security-logging"
description: "Enforce security controls and structured logging standards"
tags: [security, logging]
source:
  - rules/00-memory-rules.md#Security
  - rules/22-logging-standards.md
allowed-tools:
  - Bash(shellcheck)
capability:
  - "Ensure inputs are validated/sanitized before use"
  - "Emit logs with timezone, timestamp, level, file, and message per rules/22"
  - "Avoid secret exposure in logs; use environment variables for credentials"
usage:
  - "Load for agents handling deployment, permissions, or sensitive workflows (config-sync, doc-gen reporting, etc.)"
validation:
  - "Manual inspection or automated tests verifying log format"
fallback: ""
---

## Notes
- Works alongside `skill:security-guardrails` for deeper security requirements.
