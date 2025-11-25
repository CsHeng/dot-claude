---
name: rule-block:llm-governance
description: Apply LLM governance rules for manifests, prompts, and LLM-facing files.
layer: governance
sources:
  - rules/99-llm-prompt-writing-rules.md
  - rules/98-communication-protocol.md
  - rules/98-output-styles.md
---

# Rule Block: LLM Governance

## Purpose

Apply LLM governance rules to manifests, prompts, and other LLM-facing content when running
`/llm-governance/optimize-prompts` or related workflows.

## Application

- Enforce TERSE vs EXPLANATORY communication protocol rules.
- Validate output-style usage and invariants.
- Apply prompt-writing constraints (determinism, no-filler, clear constraints, etc.).

