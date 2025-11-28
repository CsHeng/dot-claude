---
name: rule-block:llm-governance
description: Apply LLM governance rules for manifests, prompts, and LLM-facing files.
layer: governance
sources:
  - skills/llm-governance/rules/99-llm-prompt-writing-rules.md
  - rules/98-communication-protocol.md
  - rules/98-output-styles.md
---

# Rule Block: LLM Governance

## Purpose

Apply LLM governance rules to manifests, prompts, and other LLM-facing content when running
`/llm-governance` or related workflows.

## Application

- Enforce TERSE vs EXPLANATORY communication protocol rules.
- Validate output-style usage and invariants.
- Apply prompt-writing constraints (determinism, no-filler, clear constraints, etc.).

## Schema Single Source of Truth

The validation schema is defined in `skills/llm-governance/scripts/config.yaml` (Layer 3 execution asset, SSOT). Execution-layer validators (`skills/llm-governance/scripts/validator.py`) read from this config file. When policy rules in `skills/llm-governance/rules/99-llm-prompt-writing-rules.md` and the schema diverge, update the rules to mirror the schema rather than broadening constraints.

