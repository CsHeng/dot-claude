# Shell Scripting Directives

## Scope
REQUIRED: Apply these standards to all shell scripting activities, including system administration, automation scripts, CI/CD pipelines, and development tools.
REQUIRED: Treat Shell scripts as simple glue and wrapper mechanisms around tools and Python CLIs, not as primary hosts for complex business logic.

## Absolute Prohibitions
PROHIBITED: Use eval or exec with untrusted user input
PROHIBITED: Ignore errors or use silent error suppression
PROHIBITED: Hardcode secrets or credentials in shell scripts
PROHIBITED: Use shell scripts for complex business logic better suited for high-level languages
PROHIBITED: Create scripts without proper input validation
PROHIBITED: Use relative paths for critical system operations
PROHIBITED: Implement multi-step data processing or validation in Shell when a Python+uv alternative is available and appropriate

## Communication Protocol
REQUIRED: Use clear, descriptive variable and function names
REQUIRED: Provide meaningful error messages with context
REQUIRED: Include usage information and help text
PROHIBITED: Use abbreviations except universally understood ones (`url`, `id`, `api`)

## Structural Rules
### Shell Selection
REQUIRED: Use appropriate shebang based on target environment and required features:
PREFERRED: `#!/bin/sh` with BusyBox ash for embedded/OpenWrt environments (POSIX-only)
REQUIRED: `#!/bin/bash` with GNU bash 5.2+ for production/CI scripts (leverage bash features)
PREFERRED: `#!/bin/zsh` for development and interactive scripts (zsh-specific features)
PREFERRED: `#!/bin/usr/bin/env bash` for cross-platform compatibility

### Script Structure
REQUIRED: Use consistent shebang based on target environment
REQUIRED: Add script description and usage comments at the top
REQUIRED: Use `set -euo pipefail` for bash scripts to enable strict mode
REQUIRED: Organize functions before main execution logic
REQUIRED: Use meaningful variable and function names
PROHIBITED: Mix initialization logic with main execution code

## Language Rules
### Error Handling
REQUIRED: Implement input validation for number and validity of arguments
REQUIRED: Perform tool availability checks before executing commands
REQUIRED: Exit on errors with context: `trap 'echo "Error on line $LINENO"' ERR`
REQUIRED: Use readonly for constants and script directory paths
REQUIRED: Quote variables to prevent word splitting and glob expansion
PROHIBITED: Ignore return codes from external commands

### Variable Handling
REQUIRED: Use readonly for constants: `readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
REQUIRED: Quote all variable expansions: `echo "Processing: $file_name"`
REQUIRED: Use parameter expansion for defaults: `config_file="${CONFIG_FILE:-/etc/default.conf}"`
REQUIRED: Declare local variables inside functions using `local`
PROHIBITED: Use global variables for function-specific data

### Function Design
REQUIRED: Return data via echo and status via return code
REQUIRED: Pass data via parameters, avoid global variables
REQUIRED: Declare all local variables at function start
REQUIRED: Return early to reduce nesting and improve readability
PREFERRED: Use descriptive function names that indicate action and purpose

### Shell-Specific Requirements

#### POSIX Shell (#!/bin/sh)
REQUIRED: Use only POSIX-compliant syntax for maximum portability
REQUIRED: Use `[ ]` not `[[ ]]` for conditional tests
REQUIRED: Use simple variable assignment: `name="value"`
REQUIRED: Use POSIX-compliant loops: `for item in "$@"; do`
PROHIBITED: Use bash-specific extensions in POSIX shell scripts

#### Bash (#!/bin/bash)
PREFERRED: Use `[[ ]]` for advanced conditional testing
PREFERRED: Use `declare` for variable attributes and typing
PREFERRED: Use parameter expansion: `${var:-default}`, `${var#prefix}`, `${var%suffix}`
PREFERRED: Use command substitution: `echo "$(<file)"`
REQUIRED: Maintain compatibility with target bash versions

#### Zsh (#!/bin/zsh)
PREFERRED: Use `typeset` for variable declarations
PREFERRED: Use brace expansion: `for i in {1..10}`
PREFERRED: Use zsh-specific enhancements for interactive scripts
PROHIBITED: Use zsh-specific features in scripts intended for broader compatibility

## Formatting Rules
### Remote Execution
REQUIRED: Let SSH handle tilde expansion: `ssh user@host "cd ~/app && command"`
REQUIRED: Use absolute paths when needed for remote execution: `ssh user@host "cd /opt/app && command"`
PROHIBITED: Over-quote commands preventing expansion: `ssh user@host "cd '~/app' && command"`
REQUIRED: Use proper escaping for complex remote commands
PREFERRED: Use TTY allocation for interactive commands: `ssh -t user@host "docker exec -it container bash"`

### Script Architecture
REQUIRED: Separate concerns into focused, single-responsibility scripts
PREFERRED: Use descriptive naming: `deploy.sh`, `backup.sh`, `monitor.sh`
PREFERRED: Source shared functionality: `source "$(dirname "$0")/lib/common.sh"`
PREFERRED: Create reusable helper functions for common operations
REQUIRED: Use consistent parameter patterns: `script.sh <action> <target> [options]`
PREFERRED: Implement Shell as thin wrappers that resolve SCRIPT_DIR, prepare environment variables, and delegate to Python CLIs for non-trivial logic

### Performance
REQUIRED: Use `find -print0` and `read -r -d ''` for safe filename handling
PREFERRED: Process files in batches when dealing with large datasets
REQUIRED: Use appropriate tools for specific tasks (awk, sed, grep)
PREFERRED: Use cleanup traps for temporary files and resource management
REQUIRED: Implement proper signal handling for graceful termination

## Naming Rules
### Security
REQUIRED: Validate all inputs before processing
REQUIRED: Use parameter expansion and pattern matching for validation
REQUIRED: Remove dangerous characters from user input
PROHIBITED: Execute user input as commands without sanitization
REQUIRED: Use `set -euo pipefail` for bash scripts
REQUIRED: Use absolute paths for critical commands
PROHIBITED: Store secrets in shell scripts or configuration files

## Validation Rules
### Testing
REQUIRED: Create test functions for major functionality
REQUIRED: Test error conditions and edge cases
PREFERRED: Use subshells for isolated testing
PREFERRED: Implement dry-run modes where appropriate
REQUIRED: Run syntax validation: `bash -n "$script"` before execution
PREFERRED: Use `set -x` for debugging execution flow

### Cross-Platform Compatibility
REQUIRED: Test scripts on different platforms and shells
REQUIRED: Use portable commands when possible
REQUIRED: Implement platform-specific workarounds when necessary
REQUIRED: Document platform requirements and limitations
PROHIBITED: Assume command availability without verification

### Tool Requirements
REQUIRED: Environment Management: mise for shell versions and tools
PREFERRED: Testing: Built-in shell testing with subshells
REQUIRED: Linting: shellcheck for script quality and security
PREFERRED: Formatting: Use consistent indentation and style
REQUIRED: Documentation: Inline comments and help text
PREFERRED: Visual Output: Consistent color schemes and formatting patterns

### Logging
REQUIRED: Use consistent log levels: INFO, WARN, ERROR
REQUIRED: Include timestamps and context information
REQUIRED: Log script execution progress and important operations
REQUIRED: Use descriptive log messages that aid troubleshooting
PREFERRED: Use debug flags for conditional verbose output
PREFERRED: Include variable values in debug messages

### Output Formatting
REQUIRED: Ensure fallback support for terminals without color support
PREFERRED: Use consistent color schemes for different message types
REQUIRED: Test color output on different terminal environments
PREFERRED: Provide option to disable colors for automated environments
