---
description: Propose a commit message from current git status (no commit)
name: draft-commit-message
argument-hint: "[--filter=<path>] [--summary-note=<note>]"
allowed-tools:
  - Bash
  - Bash(git rev-parse --git-dir)
  - Bash(git status --short)
  - Bash(git diff --cached)
  - Bash(git diff)
---

## Usage

Execute analysis of current git repository state and generate formatted commit message proposals without executing commits.

## Arguments

- `--filter=<path>`: Restrict analyzed changes to files within this directory and its subdirectories (default: current working directory and its subdirectories)
- `--summary-note=<note>`: Provide additional intent or background context to incorporate into the commit message body

## Workflow

1. Resolve target directory from `--filter` or current working directory
2. Compute global staged/unstaged changes for rename/move detection
3. Compute scoped changes restricted to target directory
4. Classify changes: internal renames, moves, additions, modifications, deletions
5. Generate commit message from staged changes (unstaged in guidance only)
6. Output executable command with analysis summary

Repository State Assessment:
- `git rev-parse --git-dir` to validate repository
- `git status --short -- <target>` to list changes under scope

Global Change Detection:
- `git diff --cached --name-status` (staged)
- `git diff --name-status` (unstaged)

Scoped Change Detection:
- `git diff --cached --name-status -- <target>` (staged scoped)
- `git diff --name-status -- <target>` (unstaged scoped)

Change Categorization:
- feat: New features and functionality additions
- fix: Bug fixes and error corrections
- refactor: Code restructuring without functional changes
- docs: Documentation updates and additions
- style: Formatting and style improvements
- test: Test additions and modifications
- chore: Build process, dependency, and maintenance changes

Rename and Move Classification:
- Internal rename: both paths under target → "rename within scope"
- Move into scope: old outside, new inside → "move into scope"
- Move out of scope: old inside, new outside → "move out of scope"

## Output

**Output a multi-line git commit command with literal newlines for readability.**

**CRITICAL OUTPUT RULES**:
- Output the command as multi-line text with literal newlines inside the quoted message
- Use double quotes `"..."` for the message argument
- Include actual line breaks (not `\n` escape sequences) in the message body
- The entire output block should be copy-paste executable as-is
- Keep subject line under 50 characters

**Commit Message Content Requirements**:
- Single subject line with imperative mood (max 50 characters)
- Blank line after subject
- Optional detailed body with change descriptions and file references derived from staged changes under the target directory
- Proper formatting following conventional commit standards for a single commit and focused on currently staged changes
- Exclude raw `git status` or `git diff` sections such as "Changes not staged for commit" or "Untracked files" from the commit message content

Correct output example:
```
git commit -m "feat: extend rime configuration with new resources

- Add 12 new dictionaries (cuoyin, dikuang, diming, duoyin, jichu, lianxiang, shengwu, shici, shuxue, wu-hua-sheng-yi-yao, wuzhong, zi)
- Add keyboard background themes (default, google_black, google_white)
- Add new Lua modules (alt_jump, auto_phrase, kp_number_processor, super_filter, charset.bin)
- Add iconfont for UI elements
- Update existing dictionaries and schema configurations
- Enhance OpenCC conversion tables (chinese_english, english_chinese, others)"
```

NEVER output this (single-line format prevents preview readability):
```
git commit -m $'subject\n\nbody'
```

Analysis Summary:
- Scope directory
- Files affected (staged + unstaged)
- Change types breakdown

User Guidance:
- Staging recommendations
- Commit splitting suggestions

## Quality Standards

Message Formatting:
- Imperative mood, ≤50 chars subject
- Blank line after subject
- Body lines at ~72 chars when possible

Content Requirements:
- Focus on what/why, not how
- Reference key files for context
- Based on staged changes only
- Unstaged changes in guidance only

## Safety Constraints

- Never execute git commit
- Validate repository before analysis
- User must review before committing

## Examples

```bash
# Generate commit message for current changes
/draft-commit-message

# Filter changes to specific directory and add context
/draft-commit-message --filter=docker/ --summary-note="Update docker configuration"
```

## Error Handling

- Not a git repository: suggest git init or check path
- Invalid --filter path: report must exist inside repo
- No changes detected: inform user, suggest widening scope
- Large change set: recommend splitting into multiple commits
