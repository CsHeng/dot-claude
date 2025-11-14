---
name: "config-sync:sync-project-rules"
description: "Sync shared Claude rules into project IDE directories with IDE-specific headers (project)"
argument-hint: "--target=<cursor|copilot|all> [--all] [--dry-run] [--verify-only] [--project-root=<path>]"
allowed-tools:
  - Bash
  - Bash(cp:*)
  - Bash(cat:*)
  - Bash(fd:*)
  - Bash(ls:*)
  - Read
  - Write
is_background: false
---

## Execution Requirements

Resolve project root from arguments, environment, or current working directory. Reject execution from `~/.claude` without explicit project root.

## Arguments

- `--target`: IDE target system (`cursor`, `copilot`, `all`)
  - `cursor`: Sync to `.cursor/rules` directory
  - `copilot`: Sync to `.github/instructions` directory
  - `all`: Sync to both targets (default)
- `--all`: Sync every supported IDE target without prompting
- `--dry-run`: List destination directories without copying files
- `--verify-only`: Display markdown file counts and exit
- `--project-root`: Specify project directory path
- `CLAUDE_PROJECT_DIR`: Environment variable for project root

## Execution Procedure

### 1. Project Validation
Validate project root existence and accessibility. Verify execution context is not `~/.claude`.

### 2. Rule Collection
Merge global rules from `~/.claude/rules` with project-specific rules from `.claude/rules`.

### 3. Target Resolution
Determine IDE directories:
- Cursor: `.cursor/rules/`
- Copilot: `.github/instructions/`

### 4. Tool Validation
Check availability of `yq` or `python3` with PyYAML module for header processing.

### 5. Header Processing
Load IDE-specific headers from `commands/config-sync/ide-headers.yaml`. Apply headers to target files.

### 6. File Operations
Copy files to target directories with proper headers. Create directories within project boundaries only.

### 7. Verification
Generate file counts per target directory. Validate header processing success.

## Error Handling

### Context Errors
Exit code 1: Invalid project root or execution from `~/.claude`

### File System Errors
Exit code 2: Target directory creation failure
Exit code 3: File permission errors

### Processing Errors
Exit code 4: Header processing tool unavailable - continue with simple copy

## Safety Constraints

Require valid project context. Create target directories only within project boundaries. Backup existing files before overwriting. Validate YAML structure before injection. Prevent directory traversal attacks.