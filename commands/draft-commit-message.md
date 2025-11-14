---
file-type: command
command: /draft-commit-message
description: Propose a commit message from current git status (no commit)
implementation: commands/draft-commit-message.md
argument-hint: "[optional-summary-notes]"
scope: Included
allowed-tools:
  - Bash
  - Bash(git rev-parse --git-dir)
  - Bash(git status --short)
  - Bash(git diff --cached)
  - Bash(git diff)
disable-model-invocation: true
related-commands:
  - /config-sync/sync-cli
related-agents:
  - agent:workflow-helper
related-skills:
  - skill:workflow-discipline
  - skill:automation-language-selection
---

## usage

Execute analysis of current git repository state and generate formatted commit message proposals without executing commits.

## arguments

- `optional-summary-notes`: Additional context to incorporate into the commit message

## workflow

1. Repository Validation: Verify current directory contains .git directory
2. Status Collection: Execute git status to identify changed files
3. Change Analysis: Run git diff commands for staged and unstaged changes
4. Pattern Recognition: Identify change types and affected components
5. Message Generation: Create subject line and detailed body with file references
6. User Context: Incorporate optional summary notes if provided
7. Proposal Display: Present formatted commit message for review
8. Confirmation Wait: Require explicit user approval before any commit action

### analysis-process

Repository State Assessment:
- Validate git repository existence and accessibility
- Separate staged from unstaged changes for clear categorization
- Identify new, modified, and deleted files
- Detect branch status and merge operations

Change Categorization:
- feat: New features and functionality additions
- fix: Bug fixes and error corrections
- refactor: Code restructuring without functional changes
- docs: Documentation updates and additions
- style: Formatting and style improvements
- test: Test additions and modifications
- chore: Build process, dependency, and maintenance changes

## output

Generated Commit Message:
- Subject line with imperative mood (max 50 characters)
- Detailed body with change descriptions and file references
- Proper formatting following conventional commit standards

Analysis Summary:
- Files affected: Complete list of modified files
- Staged changes: Summary of staged modifications
- Unstaged changes: Summary of unstaged modifications
- Change types: Categorization of modifications

User Guidance:
- Commit suggestions based on analysis
- Recommendations for staging specific changes
- Context for understanding commit impact

## quality-standards

Message Formatting:
- Use imperative mood in subject line
- Limit subject line to 50 characters maximum
- Separate subject from body with blank line
- Wrap body lines at 72 characters when possible

Content Requirements:
- Focus on what changes accomplish, not how
- Include specific file references for context
- Explain why changes are necessary
- Reference relevant issue numbers when applicable

## safety-constraints

1. Read-Only Operation: Never execute git commit automatically
2. Repository Validation: Ensure valid git repository before analysis
3. Confirmation Required: Always wait for explicit user approval
4. Backup Awareness: Remind user of current repository state

## examples

```bash
# Generate commit message for current changes
/draft-commit-message

# Include additional context in commit analysis
/draft-commit-message "Fix authentication bug and add error handling"

# Analyze staged changes for feature completion
/draft-commit-message "Complete user profile feature implementation"
```

## error-handling

Repository Errors:
- Not a git repository: Error with git init suggestion
- Permission denied: Provide guidance for repository access
- Corrupted repository: Suggest repository repair steps

Analysis Failures:
- No changes detected: Inform user no commit needed
- Conflicts detected: Suggest conflict resolution before commit
- Large change set: Recommend breaking into smaller commits

Format Issues:
- Complex changes: Provide multiple commit message suggestions
- Mixed change types: Suggest separating different types of changes
- Unclear purpose: Request additional context from user
