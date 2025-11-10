---
name: "skill:networking-controls"
description: "Enforce networking and connectivity rules"
tags: [networking]
source:
  - rules/14-networking-guidelines.md
allowed-tools: []
capability:
  - "Define firewall/ACL requirements, connection pooling, timeout/backoff policies"
  - "Document ingress/egress expectations for services"
usage:
  - "Load for tasks impacting network configs or integrations"
validation:
  - "Manual review or integration tests covering network flows"
fallback: ""
---

## Notes
- Often combined with security skills for deployments.
