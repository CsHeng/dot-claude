---
description: Review shell script, detect violations, and propose auto-fix patches (project)
name: review-shell-syntax
argument-hint: "[path/to/script.sh]"
allowed-tools:
  - Read
  - Bash
  - Bash(bash -n:*)
  - Bash(sh -n:*)
  - Bash(zsh -n:*)
  - Bash(shellcheck :*)
metadata:
  is_background: False
  style: tool-first
---

## Usage

```bash
/review-shell-syntax [path/to/script.sh]
```

## Arguments

- path/to/script.sh: Shell script file to review (required)

## DEPTH Workflow

### D - Decomposition

- Objective: Complete shell script audit with auto-fix suggestions
- Scope: Guidelines compliance, ShellCheck diagnostics, syntax validation
- Output: Structured report with diff-style patches for violations
- Reference: rules/12-shell-guidelines.md

### E - Explicit Reasoning

- Findings: Line number, description, guideline section, explicit reasoning
- Patches: Only modify lines with violations, preserve structure
- Constraints: No stylistic changes, avoid false positives

### P - Parameters

- Strictness: Maximum compliance enforcement
- Fixes: Conservative, rule-driven modifications
- Determinism: Required output consistency
- Format: Unified diff patches

### T - Test Cases

- Failure Case: Missing fi, unquoted variables, no strict mode → generate patch
- Success Case: Proper structure, quoting, strict mode → PASS status

### H - Heuristics

- Minimal Surface: Fix only necessary lines
- No Reformatting: Preserve original structure and logic
- Safe Output: Ensure patches produce valid shell code
- Deterministic Order: Shebang → strict mode → quoting → variables → traps → flow

## Workflow

1. File Validation: Read script and verify file exists and is readable
2. Interpreter Detection: Identify shebang line or default to bash
3. Syntax Validation: Run interpreter-specific syntax checking (bash -n, sh -n, zsh -n)
4. Static Analysis: Execute shellcheck with GCC format for structured output
5. Guidelines Compliance: Check against shell scripting best practices
6. Violation Analysis: Categorize findings by severity and type
7. Patch Generation: Create unified diff patches for identified violations
8. Report Compilation: Generate structured findings with actionable recommendations
9. Validation: Ensure patches produce valid and safe shell code

## Output

- Summary: Pass/fail status with issue count
- Deviations: Line-by-line violations with guideline references
- ShellCheck Output: Raw static analysis results
- Syntax Check: Interpreter validation results
- Auto-Fix Patch: Unified diff format (or "No changes needed")
- Verdict: Final PASS/FAIL determination
