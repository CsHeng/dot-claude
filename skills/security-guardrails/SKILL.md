---
name: "skill:security-guardrails"
description: "Apply security standards for credentials, networking, and deployments"
tags: [security]
source:
  - rules/03-security-standards.md
allowed-tools: []
capability:
  - "Enforce secret management (env vars, no hardcoding)"
  - "Validate/sanitize inputs and configure HTTPS/CORS per rules/03"
  - "Define auditing/monitoring requirements"
usage:
  - "Load for agents that modify deployments, permissions, or external integrations"
validation:
  - "Security review or automated checks (linting, secret scanners)"
fallback: ""
---

## Notes
- Use with `skill:security-logging` for comprehensive coverage.
