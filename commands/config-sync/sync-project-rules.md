---
name: "config-sync:sync-project-rules"
description: "Sync shared Claude rules into project IDE directories with proper headers (project)"
argument-hint: "--target=<cursor|copilot|all> [--all] [--dry-run] [--verify-only] [--project-root=<path>]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(fd:*)
  - Bash(cat:*)
  - Bash(cp:*)
is_background: false
---

## Usage

Synchronize shared Claude rules from `~/.claude/rules` into project-specific IDE directories with IDE-specific headers and validation.

## Arguments

- `--target`: IDE target system
  - `cursor`: Sync to `.cursor/rules` directory
  - `copilot`: Sync to `.github/instructions` directory
  - `all`: Sync to both targets (default)
- `--all`: Sync every supported IDE target without prompting
- `--dry-run`: List destination directories without copying files
- `--verify-only`: Display markdown file counts for each target and exit
- `--project-root`: Specify project directory path explicitly
- `CLAUDE_PROJECT_DIR`: Environment variable for project root (alternative to `--project-root`)

## Workflow

1. Project Detection: Resolve project root from arguments, environment, or current working directory
2. Context Security: Reject execution from `~/.claude` without explicit project root
3. Rule Collection: Merge global rules (`~/.claude/rules`) with project-specific rules (`.claude/rules`)
4. Target Resolution: Determine IDE directories based on target selection
5. Tool Validation: Check availability of `yq` or `python3` for header processing
6. Header Preparation: Load IDE-specific headers from `commands/config-sync/ide-headers.yaml`
7. File Processing: Apply headers and copy files to target directories
8. Verification: Generate file counts and validation summary
9. Progress Reporting: Emit structured logs for troubleshooting

### IDE Header Processing

Requirements:
- `yq` command-line tool OR `python3` with PyYAML module
- Header configuration file: `commands/config-sync/ide-headers.yaml`

Target Directories:
- Cursor: `.cursor/rules/`
- Copilot: `.github/instructions/`

Fallback Behavior:
- If header processing tools unavailable: Simple file copy without YAML processing
- Continue with sync operation while logging limitation

## Output

Generated Files:
- Target directory files with IDE-specific YAML headers
- Preserved rule content with appropriate frontmatter for each IDE

Verification Reports:
- File count per target directory
- Header processing success/failure summary
- Validation warnings for rule conflicts

Exit Codes:
- 0: Successful synchronization
- 1: Invalid project root or execution context
- 2: Target directory creation failure
- 3: File permission errors
- 4: Header processing tool unavailable

## Safety Constraints

1. Project Context: Require valid project root, reject execution from `~/.claude` directory
2. Directory Creation: Create target directories only within project boundaries
3. File Overwrites: Backup existing files before overwriting
4. Permission Validation: Verify read/write access before operations
5. Header Safety: Validate YAML structure before injection
6. Path Traversal: Prevent directory traversal attacks in project root resolution

## Examples

```bash
# Sync rules to both IDE targets in current project
/config-sync/sync-project-rules --target=all

# Dry run to preview target directories
/config-sync/sync-project-rules --target=cursor --dry-run

# Verify only - show file counts without modification
/config-sync/sync-project-rules --verify-only

# Sync to specific project directory
/config-sync/sync-project-rules --target=copilot --project-root=/path/to/project

# Use environment variable for project root
CLAUDE_PROJECT_DIR=/path/to/project /config-sync/sync-project-rules --all
```

## Error Handling

Context Errors:
- No project root: Exit with code 1 and provide setup instructions
- Execution from `~/.claude`: Exit with code 1 with security warning

File System Errors:
- Target directory creation failure: Exit with code 2 after logging path details
- Permission denied: Exit with code 3 after listing affected files

Processing Errors:
- Header processing tool unavailable: Continue with simple copy, log warning
- Invalid YAML headers: Exit with code 4 after validation details
