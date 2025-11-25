---
name: rule-block:error-patterns
description: Apply error-handling pattern directives from rules/05-error-patterns.md.
layer: governance
sources:
  - rules/05-error-patterns.md
---

# Rule Block: Error Patterns

## Purpose

Provide governance-level access to the error-handling and logging patterns defined in
`rules/05-error-patterns.md`, so routers can enforce fail-fast behavior and structured error
reporting when selecting and configuring execution agents.

## Key Requirements (Referenced)

- Prefer fail-fast handling at system boundaries with descriptive errors.
- Preserve error context (stack traces, parameters, state) through call chains.
- Use structured logging with appropriate severity levels for error events.
- Apply clear recovery strategies (retries, fallbacks, or explicit failures) instead of silent
  degradation.

## Application

- Routers such as `router:ts-error-resolution` SHOULD:
  - Load this rule-block whenever tasks involve diagnosing or fixing runtime or compile-time errors.
  - Require agents to describe both immediate fixes and underlying error-pattern violations.
  - Bias toward solutions that improve long-term error hygiene, not just quick patches.

