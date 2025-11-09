---
name: "config-sync:cli"
description: Alias that forwards to `/config-sync/sync-cli`
argument-hint: --action=<sync|analyze|verify|adapt|plan|report> [...]
allowed-tools: Read, Write, ApplyPatch, Bash(rg:*), Bash(ls:*), Bash(find:*), Bash(cat:*)
---

The `/config-sync:cli` slash command has been renamed to `/config-sync/sync-cli`. Invocations continue to work through this shim, but update automations, docs, and personal notes to the new name. All options and behaviors are identical; the wrapper simply prints a migration warning before executing `sync-cli.sh`.
