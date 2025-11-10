---
name: "skill:workflow-patterns"
description: "Apply multi-phase workflow and handoff patterns"
tags: [workflow]
source:
  - rules/23-workflow-patterns.md
allowed-tools: []
capability:
  - "Define state transitions, handoff checklists, and communication touchpoints"
  - "Ensure workflows follow the prescribed fail-fast and documentation rules"
usage:
  - "Load for agents orchestrating multi-step processes (config-sync, doc-gen)"
validation:
  - "Manual review of workflow docs or state machines"
fallback: ""
---

## Notes
- Complements `skill:workflow-discipline` (which covers day-to-day coding behavior).
