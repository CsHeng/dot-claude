# Memory Configuration

## Rule-Loading Conditions

### Default Conditions
Execute communication protocol from `rules/98-communication-protocol.md` in TERSE MODE for all responses unless explanation triggers are present or the active output style prefers explanatory behavior.
Execute EXPLANATORY MODE communication patterns from `rules/98-communication-protocol.md` only when user input contains explicit explanation triggers or the active output style prefers explanatory behavior.
Execute preferred output style behavior from `rules/98-output-styles.md` and the active output-style manifest when the user selects a named output style.
Execute language-specific rules based on file extensions or declared language context.
Execute security rules for all operations involving credentials, permissions, or network access.
Execute testing rules when operations involve test files or test execution.
Execute directory classification from `skills/llm-governance/scripts/config.yaml` before routing `/llm-governance`.
Execute governance exceptions from `skills/llm-governance/rules/99-llm-prompt-writing-rules.md` immediately after classification rules load.
Note: llm-governance manages all LLM-facing files including commands/, skills/, agents/, and rules/ directories.

### Baseline Skill Initialization
Execute `skill:environment-validation` before dispatching any agent to enforce the canonical toolchain, prefer fd/rg/ast-grep automatically, and surface tool availability constraints for downstream skills.

### Directory Reference Mapping
Directory references in this document assume the canonical `~/.claude` layout. When a target CLI (for example OpenCode) consumes these instructions, translate the directories using `.claude/commands/config-sync/directory-manifest.json` before execution. As of the 2025-11-19 manifest, OpenCode maps the `commands` component to the `command/` directory and the `agents` component to the `agent/`, while other components retain their canonical names. Always check the manifest for the latest per-target mapping when new CLI targets are introduced.
