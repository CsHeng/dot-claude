---
name: draft-commit-message
description: Propose a commit message from current git status (no commit)
argument-hint: '[--filter=<path>] [--summary-note=<note>]'
allowed-tools:
  - Bash
  - Bash(git rev-parse --git-dir)
  - Bash(git status --short)
  - Bash(git diff --cached)
  - Bash(git diff)
is_background: false
style: reasoning-first
---

## Usage

Execute analysis of current git repository state and generate formatted commit message proposals without executing commits.

## Arguments

- `--filter=<path>`: Restrict analyzed changes to files within this directory and its subdirectories (default: current working directory and its subdirectories)
- `--summary-note=<note>`: Provide additional intent or background context to incorporate into the commit message body

## Workflow

## Usage
2. Scope resolution: Resolve target directory from `--filter` or current working directory and restrict analysis to this directory and its subdirectories
3. Global diff analysis: Compute global staged and unstaged change sets for the repository to identify renames and moves
4. Scoped diff analysis: Compute staged and unstaged change sets restricted to the target directory and intersect them with global results
5. Rename and move classification: Classify changes touching the target directory as internal renames, moves into scope, moves out of scope, or regular additions, modifications, and deletions
6. Commit message proposal: Generate a commit message describing staged changes within the target directory and summarize unstaged changes separately
7. Next-step guidance: Display the generated commit message with a concise analysis summary and recommendations for staging and splitting commits; never execute git commit

### analysis-process

Repository State Assessment:
- Run `git rev-parse --git-dir` to validate git repository existence and accessibility
- Determine target directory from `--filter` or current working directory
- Apply directory filter to limit scope of analyzed changes to the target directory and its subdirectories
- Run `git status --short -- <target-directory>` to list changed files within the target directory and verify that the directory resides inside the repository
- Treat invalid or non-existent `--filter` paths as errors and report that the target directory must exist inside the current repository
- Use `git status --short` status codes to classify new, modified, and deleted files and treat `??` entries as untracked working tree files, not as direct commit content

Global Change Detection:
- Run `git diff --cached --name-status -M` to collect staged changes for the entire repository and detect renames and moves
- Run `git diff --name-status -M` to collect unstaged changes for the entire repository and detect renames and moves
- Build rename maps for staged and unstaged changes from global results using old path and new path pairs

Scoped Change Detection:
- Run `git diff --cached --name-status -M -- <target-directory>` to collect staged changes scoped to the target directory
- Run `git diff --name-status -M -- <target-directory>` to collect unstaged changes scoped to the target directory
- Intersect scoped results with global rename maps to determine whether each path participates in a rename or move

Change Categorization:
- feat: New features and functionality additions
- fix: Bug fixes and error corrections
- refactor: Code restructuring without functional changes
- docs: Documentation updates and additions
- style: Formatting and style improvements
- test: Test additions and modifications
- chore: Build process, dependency, and maintenance changes

Rename and Move Classification:
- Internal rename: Old path and new path both reside under the target directory; describe as a rename within the current scope
- Move into scope: Old path resides outside the target directory and new path resides under the target directory; describe as a file moved into the current scope
- Move out of scope: Old path resides under the target directory and new path resides outside the target directory; describe as a file moved out of the current scope
- Regular additions, modifications, and deletions: Changes that do not participate in renames or moves and reside under the target directory

## Output

Generated Commit Message:
- Single subject line with imperative mood (max 50 characters)
- Optional detailed body with change descriptions and file references derived from staged changes under the target directory
- Proper formatting following conventional commit standards for a single commit and focused on currently staged changes
- Exclude raw `git status` or `git diff` sections such as "Changes not staged for commit" or "Untracked files" from the commit message content

Analysis Summary:
- Scope: Directory used for change analysis
- Files affected: Complete list of modified files under the target directory
- Staged changes: Summary of staged modifications under the target directory used as the basis for the commit message
- Unstaged changes: Summary of unstaged modifications under the target directory that are not included in the commit message
- Change types: Categorization of modifications by change type and classification as internal renames, moves into scope, moves out of scope, or regular additions, modifications, and deletions

User Guidance:
- Commit suggestions based on analysis
- Recommendations for staging specific changes
- Context for understanding commit impact

## Quality Standards

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
- Base commit message content on staged changes under the target directory and describe unstaged changes only in the analysis summary and guidance
- Do not describe untracked files explicitly as "untracked"; describe only files that are intended for the commit and instruct users to stage new files and rerun the command if they should be included

## Safety Constraints

1. Read-Only Operation: Never execute git commit automatically
2. Repository Validation: Ensure valid git repository before analysis
3. User Confirmation: Instruct user to review and confirm the generated message before using git commit
4. Backup Awareness: Remind user of current repository state

## Examples

```bash
# Generate commit message for current changes
/draft-commit-message

# Filter changes to specific directory and add context
/draft-commit-message --filter=docker/ --summary-note="Update docker configuration"
```

## Error Handling

Repository Errors:
- Not a git repository: Error with git init suggestion
- Permission denied: Provide guidance for repository access
- Corrupted repository: Suggest repository repair steps

Analysis Failures:
- No changes detected: Inform user no commit needed
- Conflicts detected: Suggest conflict resolution before commit
- Large change set: Recommend breaking into smaller commits

Format Issues:
- Complex changes: Provide explicit guidance for splitting changes into multiple commits while still generating a single message for the current scope
- Mixed change types: Suggest separating different types of changes
- Unclear purpose: Request additional context from user
