---
name: skill:config-sync-project-rules-sync
description: Synchronize shared Claude rules into project IDE directories with IDE-specific headers.
tags:
  - workflow
  - config-sync
  - project
source:
  - docs/taxonomy-rfc.md
  - commands/config-sync/sync-project-rules.md
capability: >
  Merge global and project-specific rule files into IDE-specific rule
  directories within a project while enforcing project boundary and
  header-injection constraints.
usage:
  - "/config-sync/sync-project-rules from a valid project root."
  - "Update IDE rule directories after rules/ changes."
validation:
  - "Reject ~/.claude as project root unless explicitly overridden."
  - "Create target directories only within the resolved project tree."
  - "Validate header injection result for each processed file."
allowed-tools:
  - Bash(commands/config-sync/sync-project-rules.sh *)
---
