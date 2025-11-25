---
name: workflow-discipline
description: Maintain incremental delivery, fail-fast behavior, and structured communication.
  Use when workflow discipline guidance is required.
layer: execution
mode: cross-cutting-governance
capability-level: 1
style: reasoning-first
---
## Purpose
Apply workflow-discipline rule-blocks to concrete tasks: help agents maintain incremental changes,
fail-fast behavior, and structured communication once a router has decided that workflow discipline
is required.

## IO Semantics
Input: Task descriptions, planned changes, communication/output streams.
Output: Adjusted plans and communication patterns that respect workflow discipline constraints.
Side Effects: More incremental edits, clearer error handling, and TERSE-mode communication.
