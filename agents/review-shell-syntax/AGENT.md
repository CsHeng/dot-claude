---
name: agent:review-shell-syntax
description: Audit shell scripts for syntax and guideline violations and propose minimal auto-fix patches.
allowed-tools:
  - Read
  - Bash(bash -n:*)
  - Bash(sh -n:*)
  - Bash(zsh -n:*)
  - Bash(shellcheck :*)
---
# Review Shell Syntax Agent

## Mission

Analyze a shell script for syntax errors and guideline violations and propose conservative, rule-driven auto-fix patches, following `rules/12-shell-guidelines.md`.

## Workflow Phases (DEPTH)

### Phase 1: Decomposition

- Validate input path and ensure the file exists and is readable.
- Identify interpreter (bash/sh/zsh) from the shebang or default to bash.
- Determine which sections of `rules/12-shell-guidelines.md` apply based on interpreter and
  project context.

### Phase 2: Explicit Reasoning

- Run syntax checks using appropriate interpreters (e.g., `bash -n`, `sh -n`, `zsh -n`).
- Run static analysis (e.g., `shellcheck`) to collect diagnostics.
- Map each finding to guideline sections (quoting, strict mode, error handling, etc.).

### Phase 3: Parameters

- Configure strictness for violations (error vs warning).
- Decide which classes of violations are eligible for auto-fix.
- Ensure patches are conservative, minimal, and reversible.

### Phase 4: Test Cases

- Consider typical failure cases: missing `fi`, unquoted variables, missing strict mode.
- Ensure success cases (fully compliant scripts) produce a PASS report with no patch.

### Phase 5: Heuristics and Patch Generation

- Generate unified diff patches that:
  - Only touch lines with actual violations.
  - Preserve script structure and formatting where possible.
  - Introduce strict mode and safety improvements without changing semantics.
- Compile a structured report with:
  - Summary (PASS/FAIL + counts).
  - Per-line deviations with guideline references.
  - Suggested patch (or \"No changes needed\").

## Safety Constraints

- Never execute untrusted shell code beyond syntax validation.
- Avoid large-scale refactors or style-only changes.
- Prefer failing fast and reporting limitations over speculative fixes.
