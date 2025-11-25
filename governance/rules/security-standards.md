---
name: rule-block:security-standards
description: Apply security directives from rules/03-security-standards.md.
layer: governance
sources:
  - rules/03-security-standards.md
  - rules/22-logging-standards.md
---

# Rule Block: Security Standards

## Purpose

Provide governance-level access to security directives (including credential handling, secret
rotation, input validation, and security logging) from `rules/03-security-standards.md` and
`rules/22-logging-standards.md`.

## Key Requirements (Referenced)

- Never commit or log secrets, credentials, or sensitive tokens.
- Enforce secure credential storage and rotation using appropriate secret-management tooling.
- Validate inputs at system boundaries to mitigate common attack vectors.
- Implement structured security logging and auditing for authentication and authorization events.

## Application

- Routers such as `router:workflow-helper`, `router:ts-error-resolution`, and `router:web-research`
  SHOULD:
  - Load this rule-block when tasks involve security-sensitive operations or configuration.
  - Require agents to avoid exposing secrets in reports and to recommend remediation steps aligned
    with security standards.
  - Treat security standard violations as high-priority findings in recommendations.

