---
name: "config-sync:sync-user-config"
description: Complete configuration sync from Claude to target tools
argument-hint: --target=<droid|qwen|opencode|codex|all> [--component=<rules|permissions|commands|settings|memory|all>]
---

## Task
Use Claude Code's intelligence to orchestrate comprehensive configuration synchronization from Claude's configuration to target tool(s) by delegating specialized adaptation tasks to appropriate commands.

## Analysis Steps
1. Inventory Claude's complete configuration:
   - Rules: `~/.claude/rules/*.md`
   - Memory files: `CLAUDE.md`, `AGENTS.md`
   - Permissions: `settings.json`, `docs/permissions.md`
   - Commands: `commands/*.md`
   - Settings: `settings.json`, `docs/settings.md`

2. Parse target specification:
   - If command arguments are missing, prompt the user to interactively select target tool(s) and component(s)
   - Extract target tool(s) from the comma-separated `--target` argument once gathered
   - Extract component(s) from the comma-separated `--component` argument if specified

3. Analyze target tool capabilities:
   - Review target tool's configuration structure
   - Understand supported features and syntax
   - Identify limitations and gaps

4. Create adaptation strategy:
   - Determine which components need synchronization
   - Select appropriate adaptation commands for each component
   - Plan execution order and conflict resolution approach

5. Execute orchestration:
   - Handle rules and memory file synchronization directly
   - Use SlashCommand to execute: `/config-sync:adapt-rules-content --target=<tool>` for rule content adaptation if needed
   - Use SlashCommand to execute: `/config-sync:adapt-permissions --target=<tool>` for permission adaptation
   - Use SlashCommand to execute: `/config-sync:adapt-commands --target=<tool>` for command adaptation
   - Coordinate overall sync process and handle errors

## Target Tool Knowledge Base
- Factory/Droid CLI:
  - Settings: `~/.factory/settings.json` (permissions: commandAllowlist/commandDenylist)
  - Commands: `~/.factory/commands/` (compatible with Claude format)
  - Config: `~/.factory/config.json` (models, API settings)

- Qwen CLI:
  - Settings: `~/.qwen/settings.json` (basic auth/session config)
  - Rules: `~/.qwen/rules/` (markdown files)
  - Memory: `~/.qwen/QWEN.md`, `~/.qwen/AGENTS.md`

- Codex CLI:
  - Rules: `~/.codex/rules/` (markdown files)
  - Memory: `~/.codex/CODEX.md`, `~/.codex/AGENTS.md`
  - Minimal configuration support

- OpenCode CLI:
  - Settings: `~/.config/opencode/opencode.json` (operation-based permissions)
  - Commands: `~/.config/opencode/command/` (dual JSON/markdown support)
  - Memory: `~/.config/opencode/AGENTS.md`

## Synchronization Workflow

### Phase 1: Analysis and Planning
1. Parse command arguments: `--target=<tool[,tool]|all>` and `--component=<type[,type]|all>`
2. Inventory Claude configuration files to be synchronized
3. Analyze target tool capabilities and existing configurations
4. Create sync plan with conflict resolution strategy

### Phase 2: Backup and Preparation
1. Create a timestamped backup directory under the target tool:
   - Factory/Droid CLI: `~/.factory/backup/TIMESTAMP/`
   - Qwen CLI: `~/.qwen/backup/TIMESTAMP/`
   - Codex CLI: `~/.codex/backup/TIMESTAMP/`
   - OpenCode: `~/.config/opencode/backup/TIMESTAMP/`
2. Back up existing target files before any modifications
3. Verify target tool installation and write permissions
4. Prepare working directories and temporary files in `/tmp`

### Phase 3: Component Synchronization
For each requested component:

Rules Synchronization (handled by sync command):
- Use `rsync` with conflict resolution
- Document overwritten customizations
- Verify integrity after sync

Memory and Agent Files (handled by sync command):
- Intelligent merging of existing files
- Update tool references and paths
- Preserve custom sections

Rules Content Adaptation (optional, delegate to `adapt-rules-content.md`):
- Use SlashCommand to execute: `/config-sync:adapt-rules-content --target=<tool>` if rule content needs adaptation
- Monitor for content adaptation results and issues
- Document rule content changes made

Permission Adaptation (delegate to `adapt-permissions.md`):
- Use SlashCommand to execute: `/config-sync:adapt-permissions --target=<tool>`
- Monitor for adaptation results and issues
- Document permission changes made

Command Adaptation (delegate to `adapt-commands.md`):
- Use SlashCommand to execute: `/config-sync:adapt-commands --target=<tool>`
- Monitor for compatibility issues
- Document command modifications

### Phase 4: Verification and Cleanup
1. Verify all synchronized files are properly formatted
2. Test target tool functionality with new configurations
3. Generate synchronization report with all changes made
4. Clean up temporary files in `/tmp`
5. Provide rollback instructions if issues are detected

## Conflict Resolution Strategy

### File Existence Handling
1. Backup before modification:
   - Create timestamped backups inside the tool-specific backup folder above (for example `~/.factory/backup/FILENAME.TIMESTAMP.md`)
   - Backup existing target files before any changes
   - Keep rollback capability for failed syncs

2. Merge priority rules:
   - Source rules (`~/.claude/rules/`) take precedence over target rules
   - Target-specific customizations preserved if marked with `<!-- preserve: local -->`
   - Permission security: Always choose stricter permissions when conflicting
   - Settings: Non-permission settings in target tools are never overwritten

3. Intelligent merge patterns:
   - Memory files: Update core sections, preserve custom tool-specific sections
   - Agent guides: Merge new guidelines, preserve existing tool configurations
   - Commands: Update logic from source, preserve tool-specific argument handling
   - Permissions: Merge allowlists, intersect denylists (always choose security)

### Repeated Sync Behavior
- First sync: Full setup with all configurations
- Subsequent syncs: Intelligent updates only
- Detect existing files and merge changes appropriately
- Document all changes made during sync process
- Provide rollback information for each sync operation

## Execution Logic

### For each target tool:
1. Rules synchronization (if `rules` or `all`):
   - Use `rsync -av --delete` for `~/.claude/rules/*.md` into the tool's rule directory:
     - Factory/Droid CLI: `~/.factory/rules/`
     - Qwen CLI: `~/.qwen/rules/`
     - Codex CLI: `~/.codex/rules/`
     - OpenCode: `~/.config/opencode/rules/`
   - Handle conflicts: source rules take precedence, document any overwritten customizations
   - Preserve file permissions and timestamps
   - Verify rule integrity and completeness after sync

2. Memory file generation/update (if `rules` or `all`):
   - Check if the tool-specific memory file exists:
     - `~/.factory/DROID.md`
     - `~/.qwen/QWEN.md`
     - `~/.codex/CODEX.md`
     - `~/.config/opencode/AGENTS.md`
   - If exists: Compare with current `CLAUDE.md`, merge changes intelligently
   - If new: Create fresh adaptation from `CLAUDE.md`
   - Update tool references and settings paths
   - Preserve existing custom sections while updating core content
   - Update cross-references to rules and other files

3. Agent guide generation/update (if `rules` or `all`):
   - Check for the agent guide in each tool:
     - `~/.factory/AGENTS.md`
     - `~/.qwen/AGENTS.md`
     - `~/.codex/AGENTS.md`
     - `~/.config/opencode/AGENTS.md`
   - If exists: Merge new agent guidelines from source, preserve existing tool-specific sections
   - If new: Create fresh adaptation from source `AGENTS.md`
   - Update memory file references to match target tool
   - Adapt tool-specific execution guidelines
   - Preserve any existing custom agent configurations

4. Rules content adaptation (optional, if `rules` or `all` and content needs adaptation):
   - Use SlashCommand to execute: `/config-sync:adapt-rules-content --target=<tool>`
   - This specialized command handles:
     - Analyzing Claude-specific references in rule content
     - Adapting terminology for universal AI agent compatibility
     - Updating tool references and memory file names
     - Preserving rule structure while universalizing content

5. Permission adaptation (if `permissions` or `all`):
   - Use SlashCommand to execute: `/config-sync:adapt-permissions --target=<tool>`
   - This specialized command handles:
     - Reading existing permissions from target tool
     - Merging new permissions with existing ones
     - Security-first conflict resolution
     - JSON merge operations for Factory/Droid settings.json
     - Operation-based permission mapping for OpenCode opencode.json
     - Permission guidelines generation for Qwen/Codex
     - Backup creation before modifications

6. Command synchronization (if `commands` or `all`):
   - Use SlashCommand to execute: `/config-sync:adapt-commands --target=<tool>`
   - This specialized command handles:
     - Analyzing Claude commands for compatibility
     - Removing Claude-specific features
     - Adapting argument handling for universal compatibility
     - Updating tool references (@CLAUDE.md → @TOOL.md or @AGENTS.md for OpenCode)
     - Generating adapted commands in target directory
     - Creating backups of existing commands
     - Compatibility validation and testing
     - Dual format support for OpenCode (JSON/markdown)
   - Excludes the internal `config-sync` command module (Claude-only functionality)

### Adaptation Command Integration
- adapt-permissions.md: Handles all permission-related adaptations
- adapt-commands.md: Handles all command compatibility adaptations
- adapt-rules-content.md: Handles rule content adaptation if needed
- Each adaptation command creates its own backups and handles conflict resolution
- Sync command orchestrates the overall process and delegates specialized work

## Cleanup Requirements
- NEVER add sync metadata or tracking information to target tool configurations
- NEVER modify target tool settings files
- DO NOT create temporary files in target directories
- If temporary files are needed, create them in /tmp using mktemp
- Clean up any temporary files created during sync process
- Preserve target tools' natural configuration structure

## Decision Making Framework
- Security first: Never weaken permission boundaries when adapting
- Functionality preservation: Maintain core purpose of each configuration
- Compatibility focus: Prioritize universal syntax over tool-specific features
- Documentation: Explain all adaptations and trade-offs made

## Output Requirements
- Generate all necessary configuration files for each target
- Document all adaptations and trade-offs made
- Provide verification checklist for each tool
- Explain any manual steps required
- Generate summary report of synchronization actions

## Safety Considerations
- NEVER modify target tool settings files - this can break tools
- Back up existing target configurations before overwriting
- Validate file permissions and ownership after sync
- Ensure no sensitive data is inappropriately transferred
- Test critical functionality after synchronization
- If temporary files are needed, create them in /tmp using mktemp
- ALWAYS clean up temporary files in /tmp immediately after use
- NEVER leave sync metadata or tracking files in target directories
