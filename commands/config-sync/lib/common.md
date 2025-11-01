# Common Utilities Reference

The config-sync command suite refers to these shared helper concepts when outlining shell snippets. Implementations can live in shell scripts, Python modules, or other automation tooling as long as they provide equivalent behavior.

## Validation Helpers

- **validate_target <name>** – Ensure target is one of `droid`, `qwen`, `codex`, `opencode`, or `all`.
- **validate_component <name>** – Confirm component value is `rules`, `permissions`, `commands`, `settings`, or `memory`.
- **check_tool_installed <name>** – Verify required CLI is available in `PATH`.

## Path Resolution

- **get_target_config_dir <tool>** – Return base config directory for the tool.
- **get_target_rules_dir <tool>** – Resolve rule destination path.
- **get_target_commands_dir <tool>** – Resolve command destination path.

## Logging

Provide lightweight wrappers such as `log_info`, `log_success`, `log_warning`, and `log_error` to standardize output formatting.

## Environment Setup

- **setup_plugin_environment** – Export commonly used paths, ensure `scripts/` helpers are on `PATH`, and create temporary working directories.

## Backup Utilities

Use `scripts/backup.sh` to expose a `create_backup <source> <destRoot>` function that guards any destructive operations before files are overwritten.

## Executor Utilities

`scripts/executor.sh` should expose helpers for safe file writes, e.g. `write_with_checksum`, `render_template`, or `copy_with_sanitization` depending on your automation approach.

These utilities are intentionally abstract so the plugin can operate across different environments. When wiring this plugin into your own workflows, implement the functions above to match your preferred automation stack.
