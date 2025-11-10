---
name: "agent:doc-gen"
description: "Manage the /doc-gen:* orchestrator commands"
default-skills:
  - skill:workflow-discipline
  - skill:security-logging
optional-skills:
  - skill:language-python
  - skill:language-go
  - skill:architecture-patterns
supported-commands:
  - /doc-gen:bootstrap
  - /doc-gen:maintain
inputs:
  - Project type
  - repo/docs/core paths
outputs:
  - Updates in `docs-bootstrap/` or `docs/`
  - PlantUML validation results
fail-fast: true
permissions:
  - "Read repo/docs/core"
  - "Write docs-bootstrap/ or docs/"
escalation:
  - "Prompt the user before overwriting documentation"
fallback: ""
---

## Responsibilities
- Load language/architecture skills based on the selected project type.
- Run the orchestrator checklist to produce parameter tables, TODOs, and PlantUML results.
- Emit deliverables and point to next steps.
