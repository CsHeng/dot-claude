---
name: skill:config-sync-cli-workflow
description: Orchestrate multi-target CLI configuration synchronization using config-sync phase runners and planners.
tags:
  - toolchain
  - workflow
  - config-sync
source:
  - docs/taxonomy-rfc.md
  - commands/config-sync/sync-cli.md
capability: >
  Execute the config-sync CLI workflow across supported targets using
  deterministic phases (collect, analyze, plan, prepare, adapt, execute,
  verify, cleanup, report) with backup and audit support.
usage:
  - "/config-sync/sync-cli --action=* across CLI targets."
  - "Replay existing sync plan files for CLI synchronization."
validation:
  - "Normalize parameters against commands/config-sync/settings.json."
  - "Precede all write phases with backup and permission checks."
  - "Enforce phase order and behavior defined in sync-cli.md."
allowed-tools:
  - Bash(commands/config-sync/sync-cli.sh *)
  - Bash(commands/config-sync/lib/phases/*.sh *)
  - Bash(commands/config-sync/lib/planners/*.sh *)
---
