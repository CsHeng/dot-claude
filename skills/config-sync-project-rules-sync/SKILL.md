---
name: config-sync-project-rules-sync
description: Synchronize shared Claude rules into project IDE directories with IDE-specific headers.
tags:
  - workflow
  - config-sync
  - project
mode: stateful-sync
capability-level: 2
style: tool-first
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

## Purpose
Synchronize shared Claude rules into project IDE rule directories with appropriate headers while respecting project boundaries.

## IO Semantics
Input: Project root path, target IDE selection, runtime flags (--all, --dry-run, --verify-only), and existing rule files under ~/.claude/rules and .claude/rules.  
Output: Updated IDE rule directories under `.cursor/rules/` and `.github/instructions/`, plus verification counts.  
Side Effects: Creates or updates files under project IDE rule directories; performs dry-run or verification-only operations when requested.

## Deterministic Steps

1. Project Root Resolution
   - Resolve project root from CLI arguments, environment, or current directory.
   - Reject execution from `~/.claude` unless an explicit project root is provided.

2. Rule Set Assembly
   - Merge global rules from `~/.claude/rules` with project-specific rules from `.claude/rules`.

3. Target Directory Resolution
   - Resolve IDE-specific rule directories based on target selection (cursor, copilot, all).
   - Ensure target directories reside within the resolved project tree.

4. Header Injection and Copy
   - Select header templates from `commands/config-sync/ide-headers.yaml`.
   - Apply headers to each rule file and copy into target directories.

5. Verification
   - Generate markdown file counts per target directory.
   - Validate that header injection completed successfully for each processed file.
