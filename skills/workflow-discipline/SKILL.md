---
name: "skill:workflow-discipline"
description: "Maintain incremental delivery, fail-fast behavior, and communication rules"
tags: [workflow, default]
source:
  - rules/00-memory-rules.md#Development-Workflow-Preferences
  - rules/00-memory-rules.md#Communication-Preferences
allowed-tools: []
capability:
  - "Incremental diffs, file-by-file commits, preserve existing comments"
  - "Fail-fast with shell traps that print the failing line number"
  - "Debug output must use `===` / `---` / `SUCCESS` / `ERROR` prefixes"
  - "Respect the file’s existing language; eliminate unnecessary narration"
usage:
  - "Load by default for collaborative commands (config-sync, review, doc-gen)"
validation:
  - "`/review-llm-prompts` confirms command/docs follow the format"
fallback: ""
---

## Notes
- Ensure command implementations emit required debug markers.
- Combine with the agent’s fail-fast strategy.
