---
file-type: command
command: /config-sync:lib-common
description: Common utility function references for config-sync operations
implementation: commands/config-sync/lib/common.md
scope: Included
related-commands:
  - /config-sync/sync-cli
  - /config-sync/sync-project-rules
related-agents:
  - agent:config-sync
related-skills:
  - skill:toolchain-baseline
  - skill:workflow-discipline
disable-model-invocation: true
---

## Usage

Reference documentation for shared utility functions used across config-sync commands. Implement these functions in your preferred automation framework.

## Arguments

None - This is a utility reference file.

## Workflow

1. Implement required validation functions
2. Set up path resolution utilities
3. Configure logging helpers
4. Initialize environment and backup systems
5. Integrate executor utilities for file operations

## Output

Complete utility function specification including:
- Validation helper function signatures and requirements
- Path resolution logic for target systems
- Logging utility standardization
- Environment setup procedures
- Backup and executor utility integration patterns

## Utility Functions

### Validation Helpers

Implement these validation functions:

```bash
validate_target <name>
# Validate target is one of: droid, qwen, codex, opencode, amp, all
# Return: 0 for valid, 1 for invalid target

validate_component <name>
# Confirm component is one of: rules, permissions, commands, settings, memory
# Return: 0 for valid, 1 for invalid component

check_tool_installed <tool_name>
# Verify required CLI tool exists in PATH
# Return: 0 for available, 1 for missing tool
```

### Path Resolution

Implement these path resolution functions:

```bash
get_target_config_dir <tool>
# Return base configuration directory for specified tool
# Output: Absolute path string to tool config directory

get_target_rules_dir <tool>
# Resolve rules destination path for specified tool
# Output: Absolute path string to rules directory

get_target_commands_dir <tool>
# Resolve commands destination path for specified tool
# Output: Absolute path string to commands directory
```

### Logging Helpers

Implement standardized logging functions:

```bash
log_info <message>
# Display informational message with standard formatting

log_success <message>
# Display success message with standard formatting

log_warning <message>
# Display warning message with standard formatting

log_error <message>
# Display error message with standard formatting
```

### Environment Setup

Implement environment initialization:

```bash
setup_plugin_environment
# Export commonly used paths to environment variables
# Ensure scripts/ directory helpers are available in PATH
# Create required temporary working directories
# Return: 0 for success, 1 for initialization failure
```

### Backup Utilities

Integrate with backup system:

```bash
create_backup <source_path> <destination_root>
# Create timestamped backup of source_path in destination_root
# Guard destructive operations before file overwrites
# Return: 0 for success, 1 for backup failure
```

### Executor Utilities

Integrate with file operation system:

```bash
write_with_checksum <source> <destination>
# Write file with integrity checksum verification
# Return: 0 for success, 1 for write/verification failure

render_template <template_file> <output_file> <variables>
# Process template file with variable substitution
# Return: 0 for success, 1 for template processing failure

sync_with_sanitization <source> <destination>
# Synchronize files with content sanitization
# Return: 0 for success, 1 for sync failure
```

## Implementation Guidelines

1. **Language Independence**: Functions can be implemented in shell, Python, or other automation frameworks
2. **Error Handling**: All functions must return appropriate exit codes (0 for success, non-zero for failure)
3. **Path Safety**: Always resolve to absolute paths and validate directory existence
4. **Atomic Operations**: File operations must be atomic to prevent corruption
5. **Logging Consistency**: Use standardized message formats across all logging functions
6. **Dependency Management**: Verify external tool dependencies before execution
7. **Permission Handling**: Respect file system permissions and access controls