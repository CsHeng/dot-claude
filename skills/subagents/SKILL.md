---
name: subagents
description: "Execution-layer skill for spawning subagents via runAgent"
layer: execution
kind: skill
commands:
  - runAgent
notes:
  - "Governance decides which agent id to call; this skill is a thin wrapper around runAgent."
constraints:
  - "Subagents must run with explicit, limited tool permissions."
  - "Governance-layer routing decisions happen before runAgent is called."
---
