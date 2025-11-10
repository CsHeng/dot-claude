---
name: "agent:config-sync"
description: "Orchestrate /config-sync/sync-cli and related adapters"
default-skills:
  - skill:toolchain-baseline
  - skill:workflow-discipline
  - skill:security-logging
optional-skills:
  - skill:language-python
  - skill:language-go
  - skill:language-shell
supported-commands:
  - /config-sync/sync-cli
  - /config-sync/sync-project-rules
  - /config-sync:adapt-*
inputs:
  - CLAUDE_PROJECT_DIR
  - commands/config-sync/settings.json targets
outputs:
  - sync plan
  - verify/report logs
fail-fast: true
permissions:
  - "Read/write access to rules/ skills/ agents/"
  - "Prompt before running adapters"
escalation:
  - "Notify the user before writing to IDE/CI or invoking adapters"
fallback: ""
---

## Responsibilities
1. Collect repository and rule directories.
2. Run skill-driven validation for toolchain, workflow, and security.
3. Load language skills and adapters per target.
4. Emit plan/report artifacts so future audits can replay the run.

## Notes
- `sync-cli.sh` must invoke the agent so logs include skill versions.
- Adapters should not load rules directly; skills inject required context.
