---
name: "commands:draft-commit-message"
description: "Propose a commit message from current git status (no commit)"
argument-hint: "[optional-summary-notes]"
allowed-tools:
  - Bash
  - Bash(git rev-parse --git-dir)
  - Bash(git status --short)
  - Bash(git diff --cached)
  - Bash(git diff)
is_background: false
---

## Usage
```bash
/draft-commit-message [optional-summary-notes]
```

## Arguments
- optional-summary-notes: Additional context to incorporate into the commit message

## DEPTH Workflow

### D - Decomposition
- Objective: Generate commit message proposals from current git repository state
- Scope: Analyze staged and unstaged changes, create formatted commit message
- Output: Commit message with subject line, detailed description, and file summaries
- Reference: rules/01-development-standards.md for commit message formatting

### E - Explicit Reasoning
- Repository Validation: Ensure current directory is a valid git repository
- Change Analysis: Separate staged from unstaged changes for clear categorization
- Message Formatting: Follow conventional commit format with imperative mood
- Context Incorporation: Integrate optional user notes into commit rationale

### P - Parameters
- Repository State: Only analyze actual git changes, not working directory noise
- Message Length: Subject line maximum 50 characters, body as needed
- Change Types: Categorize as feat, fix, refactor, docs, etc.
- Safety: Never execute git commit, only propose and wait for confirmation

### T - Test Cases
- Failure Case: Not a git repository → Error with git init suggestion
- Failure Case: No changes → Message indicating no commits needed
- Success Case: Staged changes → Complete commit message proposal
- Edge Case: Mixed staged/unstaged → Clear separation in output

### H - Heuristics
- Fail Fast: Check git repository before any analysis
- Minimal Surface: Generate message based only on actual changes
- Conventional Format: Use established commit message conventions
- Deterministic: Same repository state produces identical message

## Workflow
1. Repository Validation: Verify current directory contains .git directory
2. Status Collection: Execute git status to identify changed files
3. Change Analysis: Run git diff commands for staged and unstaged changes
4. Pattern Recognition: Identify change types and affected components
5. Message Generation: Create subject line and detailed body with file references
6. User Context: Incorporate optional summary notes if provided
7. Proposal Display: Present formatted commit message for review
8. Confirmation Wait: Require explicit user approval before any commit action

## Output
- Commit Message: Subject line with imperative mood (max 50 chars)
- Changes Summary: Bullet points describing key modifications
- Files Affected: List of modified files
- Staged Changes: Summary of staged modifications
- Unstaged Changes: Summary of unstaged modifications
- Confirmation Prompt: y/n option to proceed with commit
