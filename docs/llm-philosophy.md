# LLM Prompt Philosophy

This document provides high-level context and reasoning for the standards and constraints applied to LLM-facing files. It is intended only for human maintainers and is not consumed or enforced by any Claude Code command or agent.

## Purpose
The philosophy behind LLM prompt rules is to ensure clarity, predictability, and safety in environments where large language models interpret and execute instructions. Consistent structures and precise language reduce ambiguity and improve multi-model compatibility.

## Communication Philosophy
Instructions addressed to an LLM should be direct, compact, and unambiguous. High-density imperative language minimizes model drift and prevents misinterpretation. Avoiding conversational tone and stylistic variation creates consistent behaviors across runs.

## Determinism and Predictability
Deterministic structures improve both human and machine understanding. Predictable sectioning, formatting, and language styles help maintain stable tool behavior and simplify debugging. They also support automated scanning and validation.

## File-Type Specialization
LLM-facing files fall into categories with specific roles:
- Command files define user operations and must provide strict input/output schemas.
- Skill files encapsulate reusable steps and must describe deterministic workflows.
- Agent files define orchestration logic across multiple tools or steps.
- Rule files define constraints and must be machine-parsable and directive.
By contrast, philosophy documents remain human-facing and are excluded from automated processing.

## Separation of Concerns
Enforceable rules and human explanations should not reside in the same file. Mixing them creates ambiguity for automated enforcement tools and complicates system behavior. Philosophy files retain context and intent, while rule files remain strict and atomic.

## Multi-AI Considerations
Different AI systems vary in interpretation patterns. Deterministic and conservative prompt structures reduce discrepancies across models. This principle informs many of the strict constraints in machine-rules files.

## Documentation Value
Philosophy documents help maintainers understand:
- Why strict rules exist
- How LLM behavior influences rule design
- The rationale for deterministic structures
- The intent behind file-type distinctions

This context supports long-term maintainability without affecting machine-driven enforcement pipelines.

## Closing Notes
This document is non-normative. It does not define rules or enforce constraints. Its purpose is to preserve conceptual understanding for human readers while keeping the machine-rules separate, strict, and deterministic.