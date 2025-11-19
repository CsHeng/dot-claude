---
name: workflow-discipline
description: Maintain incremental delivery, fail-fast behavior, and structured communication.
  Use when workflow discipline guidance is required.
mode: cross-cutting-governance
capability-level: 1
allowed-tools: []
style: reasoning-first
source:
  - rules/00-memory-rules.md
  - rules/23-workflow-patterns.md
---

## Purpose
Enforce workflow discipline including incremental development practices, fail-fast error handling, structured communication patterns, and debug output standards as defined in rules/00-memory-rules.md and rules/23-workflow-patterns.md.

## Deterministic Steps

### 1. Atomic Commit Validation
- Check: Execute `git log --oneline -1` to validate commit message focuses on single logical change
- Verify: Run `git diff --name-only HEAD~1..HEAD` to ensure related files grouped together
- Validate: Confirm no mixed concerns within single commit using code review
- Enforce: Return specific error if commit violates atomic change principle

### 2. Fail-Fast Mechanism Implementation
- Check: Verify shell trap configuration with `set -euo pipefail` in all scripts
- Validate: Confirm error handling provides line numbers and context
- Test: Execute error conditions to ensure immediate failure propagation
- Enforce: Require explicit error handling for all failure paths

### 3. Structured Communication Compliance
- Check: Scan output for required prefixes using pattern matching: `===`, `---`, `SUCCESS`, `ERROR`
- Validate: Confirm debug messages follow concise, directive communication without narration when no explanation triggers are present
- Validate: Confirm structured, detailed communication patterns are used only when explicit explanation triggers are present or the active output style prefers explanatory behavior
- Validate: Confirm any active output style matches established workflow requirements and structural communication standards
- Test: Verify communication eliminates filler content and conversational elements in all modes
- Enforce: Return specific errors for non-compliant communication patterns

### 4. Language and Context Preservation
- Check: Validate existing code language and style patterns preserved
- Verify: Confirm original comments and documentation maintained
- Test: Ensure modifications respect established code context
- Enforce: Require explicit justification for style deviations

### 5. Collaborative Workflow Integration
- Check: Validate agent handoff protocols and communication patterns
- Verify: Confirm consistent workflow discipline across team interactions
- Test: Ensure proper escalation and fallback mechanisms
- Enforce: Require documentation of collaborative process changes

## IO Semantics
Input: Code modifications, workflow processes, communication patterns, debug output
Output: Incremental changes, fail-fast behaviors, structured communication, enhanced collaboration
Side Effects: Improved development flow, faster error detection, better communication clarity

## Tool Safety
- Test fail-fast mechanisms in controlled environments
- Validate debug output does not expose sensitive information
- Ensure incremental changes do not break system functionality
- Backup code before applying automated modifications
- Monitor workflow performance and error handling effectiveness

## Validation Criteria
- Commits atomic and focused on single logical changes
- Fail-fast behavior implemented with proper error handling
- Debug output follows structured prefix patterns
- Communication respects concise, directive patterns and existing code context
- Collaborative workflows consistent and efficient
