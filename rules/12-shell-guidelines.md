---
# Cursor Rules
globs: **/*.sh

# Copilot Instructions
applyTo: "**/*.sh"

# Kiro Steering
inclusion: fileMatch
fileMatchPattern: '**/*.sh'
---

# Shell Scripting Guidelines

## Shell Selection and Environment Targets

### Environment-Specific Shell Usage
- Embedded/OpenWrt: `#!/bin/sh` with BusyBox ash (POSIX-only features)
- Production/CI: `#!/bin/bash` with GNU bash 5.2+ (leverage bash features)
- Development: `#!/bin/zsh` for interactive scripts (zsh-specific features)
- Portable: `#!/usr/bin/env bash` for cross-platform compatibility

#### Current Environment
- Development: zsh 5.9 (arm64-apple-darwin24.0) - Interactive scripts and terminal
- Bash Scripts: GNU bash 5.3.3 (aarch64-apple-darwin24.4.0) - Modern bash features available
- System Default: macOS bash 3.2.57 - Legacy fallback only, avoid modern features

### Shell Feature Guidelines

#### POSIX Shell (#!/bin/sh) - BusyBox Compatible
- Use only POSIX-compliant syntax
- Use `[ ]` not `[[ ]]` for conditions
- Simple variable assignment: `name="value"`
- POSIX-compliant loops: `for item in "$@"; do`

#### Bash (#!/bin/bash) - Modern Features
- Use `[[ ]]` for advanced conditions
- Use `declare` for variable attributes
- Parameter expansion: `${var:-default}`
- Command substitution: `echo "$(<file)"`

#### Zsh (#!/bin/zsh) - Advanced Features
- Use `typeset` for variable declarations
- Brace expansion: `for i in {1..10}`
- Zsh-specific enhancements for interactive scripts

## Code Style and Best Practices

### Script Structure
- Use consistent shebang based on target environment
- Add script description and usage comments at the top
- Use `set -euo pipefail` for bash scripts to enable strict mode
- Organize functions before main execution logic
- Use meaningful variable and function names

### Error Handling & Validation
- Input validation: check number and validity of arguments
- Tool availability checks: verify required commands are installed
- Exit on errors with context: `trap 'echo "Error on line $LINENO"' ERR`
- Use readonly for constants and script directory
- Quote variables to prevent word splitting

### Variable Handling
- Use readonly for constants: `readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Quote variables: `echo "Processing: $file_name"`
- Parameter expansion for defaults: `config_file="${CONFIG_FILE:-/etc/default.conf}"`
- Use local for function variables

### Function Design & Return Values
- Return data via echo + status via return code
- Pass data via parameters, don't use global variables
- Declare all local variables at function start
- Return early to reduce nesting

## SSH and Remote Execution Patterns

### Path Handling
- CORRECT: Let SSH handle tilde expansion: `ssh user@host "cd ~/app && command"`
- CORRECT: Use absolute paths when needed: `ssh user@host "cd /opt/app && command"`
- AVOID: Over-quoting prevents expansion: `ssh user@host "cd '~/app' && command"`

### Remote Command Execution
- Simple remote commands: `ssh user@host "systemctl status nginx"`
- Complex commands with proper escaping: `ssh user@host "cd ~/app && docker-compose up -d"`
- TTY allocation for interactive commands: `ssh -t user@host "docker exec -it container bash"`

## Script Architecture Patterns

### Single Responsibility Scripts
- Separate concerns into focused scripts
- Example naming: `deploy.sh`, `backup.sh`, `monitor.sh`

### Common Library Pattern
- Source shared functionality: `source "$(dirname "$0")/lib/common.sh"`
- Create reusable helper functions

### Parameter Standardization
- Consistent parameter patterns: `script.sh <action> <target> [options]`
- Examples: `deploy.sh start production --force`
- Validation and help text for all parameters

### Function Design Principles
- Declare all local variables at function start
- Pass data via parameters, don't use global variables
- Return data via echo, status via return code

## Performance and Optimization

### Efficient File Processing
- Use `find -print0` and `read -r -d ''` for safe filename handling
- Process files in batches when dealing with large datasets
- Use appropriate tools for specific tasks (awk, sed, grep)

### Resource Management
- Use cleanup traps for temporary files
- Implement proper signal handling
- Monitor script performance with timing information

## Security Best Practices

### Input Sanitization
- Validate all inputs before processing
- Use parameter expansion and pattern matching for validation
- Remove dangerous characters from user input
- Never execute user input as commands without sanitization

### Safe Execution
- Use `set -euo pipefail` for bash scripts
- Implement proper error handling and logging
- Use absolute paths for critical commands
- Validate environment variables before use

### Credential Management
- Never hardcode secrets in scripts
- Use environment variables or secure credential stores
- Implement proper file permissions for sensitive files
- Use SSH keys for authentication instead of passwords

## Testing and Debugging

### Testing Shell Scripts
- Create test functions for major functionality
- Test error conditions and edge cases
- Use subshells for isolated testing
- Implement dry-run modes where appropriate
- Run `bash -n "$script"` (or `sh -n`/`zsh -n`) to validate syntax before execution

### Debugging Techniques
- Use `set -x` for debugging execution flow
- Implement verbose logging with debug flags
- Use temporary files for intermediate results
- Create test environments for script validation

## Error Handling Strategies

### Comprehensive Error Handling
- Input validation at script boundaries
- Tool availability checks before execution
- Graceful error messages with context
- Cleanup procedures on script termination

### Retry Logic
- Implement exponential backoff for transient failures
- Set maximum retry attempts and timeouts
- Use circuit breaker patterns for external services
- Log retry attempts and failures

## Logging Standards

### Structured Logging
- Use consistent log levels: INFO, WARN, ERROR
- Include timestamps and context information
- Log script execution progress
- Use descriptive log messages

### Debug Output
- Use debug flags for conditional verbose output
- Include variable values in debug messages
- Log function entry and exit points
- Use consistent formatting for debug information

## Environment and Configuration

### Configuration Management
- Use environment variables for configuration
- Provide default values for optional settings
- Support configuration files for complex setups
- Validate configuration values before use

### Cross-Platform Compatibility
- Test scripts on different platforms
- Use portable commands when possible
- Implement platform-specific workarounds
- Document platform requirements and limitations

## Visual Output Formatting

### Basic Separation and Color Guidelines
- Use horizontal lines and colors to distinguish different sections
- Main operations: blue headers with `===` lines
- Sub-sections: cyan headers with `---` lines
- Status colors: green (success), yellow (warning), red (error)
- Ensure fallback support for terminals without color support

### Color Variables
```bash
if [[ "$USE_COLORS" == "true" ]] && command -v tput >/dev/null 2>&1; then
    COLOR_RESET=$(tput sgr0)
    COLOR_BLUE=$(tput setaf 4)
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
else
    COLOR_RESET=""; COLOR_BLUE=""; COLOR_GREEN=""; COLOR_YELLOW=""; COLOR_CYAN=""; BOLD=""
fi
```

## Tool Preferences
- Environment Management: mise for shell versions and tools
- Testing: Built-in shell testing with subshells
- Linting: shellcheck for script quality
- Formatting: Use consistent indentation and style
- Documentation: Inline comments and help text
- Visual Output: Consistent color schemes and formatting patterns