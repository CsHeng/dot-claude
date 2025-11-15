---
name: skill:config-sync-target-adaptation
description: Coordinate target-specific adapters for Droid, Qwen, Codex, OpenCode, and Amp CLI environments.
tags:
  - toolchain
  - config-sync
  - adapters
source:
  - docs/taxonomy-rfc.md
  - commands/config-sync/README.md
capability: >
  Select and execute target-specific adapter scripts to synchronize
  rules, permissions, commands, settings, and memory for each supported
  CLI environment.
usage:
  - "Invoked from /config-sync/sync-cli when --target is set."
  - "Apply adapter logic for each target/component combination in the plan."
validation:
  - "Driver uses sync-cli plan; adapters are not invoked ad-hoc."
  - "Each adapter enforces documented safety and permission constraints."
  - "Backups exist for all modified target configuration files."
allowed-tools:
  - Bash(commands/config-sync/adapters/*.sh *)
---
