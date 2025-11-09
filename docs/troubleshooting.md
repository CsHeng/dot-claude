# Troubleshooting Guide

Comprehensive troubleshooting guide for the Claude Code configuration system, covering common issues, error patterns, and solutions.

## 🔧 Configuration Issues

### Settings Not Loading

**Symptoms**: Claude ignores configuration, uses default behavior

**Solutions**:
1. **Check file locations**:
   ```bash
   # Verify files exist in expected locations
   ls -la ~/.claude/settings.json
   ls -la ~/.claude/.claude/settings.json
   ls -la .claude/settings.json
   ```

2. **Validate JSON syntax**:
   ```bash
   # Check for JSON syntax errors
   cat ~/.claude/settings.json | jq .
   ```

3. **Check file permissions**:
   ```bash
   # Ensure files are readable
   chmod 644 ~/.claude/settings.json
   ```

4. **Verify settings precedence** - Local overrides take priority

### Permission Errors

**Symptoms**: "Permission denied", "Command not allowed", or unexpected confirmations

**Solutions**:
1. **Check permission syntax**:
   ```json
   {
     "permissions": {
       "allow": ["Bash(git:*)", "Bash(ls:*)"],
       "ask": ["Bash(npm install:*)"],
       "deny": ["Bash(rm:*)"]
     }
   }
   ```

2. **Review permission hierarchy** - Local overrides can override project settings

3. **Check for conflicting rules**:
   ```bash
   # Use the review commands to validate
   /review-shell-syntax
   /review-llm-prompts
   ```

### Environment Variables Not Working

**Symptoms**: Environment variables not available to Claude

**Solutions**:
1. **Check env section format**:
   ```json
   {
     "env": {
       "NODE_ENV": "production",
       "API_TIMEOUT": "30000"
     }
   }
   ```

2. **Verify no higher-precedence overrides** - Check all settings files

3. **Restart Claude Code** after changing environment variables

## 🔄 Config-Sync Issues

### Sync Operations Fail

**Symptoms**: Config-sync commands fail with errors

**Solutions**:
1. **Run analysis first**:
   ```bash
   /config-sync/sync-cli --action=analyze --target=<tool>
   ```

2. **Check tool installation**:
   ```bash
   # Verify target tools are installed
   which qwen  # or droid, codex, etc.
   ```

3. **Check directory permissions**:
   ```bash
   # Ensure write permissions to target directories
   ls -la ~/.factory ~/.qwen ~/.codex ~/.config/opencode
   ```

4. **Use dry-run to preview**:
   ```bash
   /config-sync/sync-cli --action=sync --dry-run
   ```

### Backup System Issues

**Symptoms**: Cannot create backups, restore failures

**Solutions**:
1. **Check backup directory**:
   ```bash
   ls -la ~/.claude/backup/
   ```

2. **Verify plan files**:
   ```bash
   # Check plan file syntax
   cat ~/.claude/backup/plan-*.json | jq .
   ```

3. **Manual restore if needed**:
   ```bash
   # Restore from backup
   cp -r ~/.claude/backup/droid-*/ ~/.factory/
   ```

### Resume Operations Fail

**Symptoms**: Cannot resume interrupted sync operations

**Solutions**:
1. **Find plan files**:
   ```bash
   find ~/.claude/backup/ -name "plan-*.json" -ls
   ```

2. **Use correct plan file**:
   ```bash
   /config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json
   ```

3. **Resume from specific phase**:
   ```bash
   /config-sync/sync-cli --action=sync --plan-file=plan.json --from-phase=prepare
   ```

## 📂 Project Rules Sync Issues

### IDE Sync Fails

**Symptoms**: `/config-sync/sync-project-rules` fails

**Solutions**:
1. **Check project detection**:
   ```bash
   # Verify git repository
   git status

   # Or set project directory manually
   CLAUDE_PROJECT_DIR=/path/to/project /config-sync/sync-project-rules --all
   ```

2. **Check IDE directories**:
   ```bash
   # Verify IDE directories can be created
   mkdir -p .cursor/rules .github/instructions
   ```

3. **Run verification**:
   ```bash
   /config-sync/sync-project-rules --verify-only
   ```

### Rules Not Loading in IDE

**Symptoms**: IDE doesn't show Claude rules

**Solutions**:
1. **Check file locations**:
   ```bash
   # Cursor
   ls -la .cursor/rules/

   # VS Code Copilot
   ls -la .github/instructions/
   ```

2. **Verify file contents**:
   ```bash
   # Check if files have content
   head .cursor/rules/*.md
   ```

3. **Restart IDE** after syncing rules

## 🐛 Command Issues

### Slash Commands Not Found

**Symptoms**: "Command not found" for slash commands

**Solutions**:
1. **Check command files exist**:
   ```bash
   find ~/.claude/commands -name "*.md" -ls
   ```

2. **Validate frontmatter**:
   ```bash
   # Check YAML frontmatter in command files
   head -10 ~/.claude/commands/*/command.md
   ```

3. **Check command name**:
   ```yaml
   ---
   name: "my-command"
   description: "Command description"
   ---
   ```

### Command Execution Fails

**Symptoms**: Command found but fails during execution

**Solutions**:
1. **Check allowed-tools** in command frontmatter
2. **Verify file paths in commands**
3. **Use verbose mode** (if supported):
   ```bash
   /command-name --verbose
   ```

## 📝 Documentation Generation Issues

### PlantUML Rendering Fails

**Symptoms**: Cannot generate SVG diagrams

**Solutions**:
1. **Check PlantUML installation**:
   ```bash
   plantuml -version
   ```

2. **Test diagram syntax**:
   ```bash
   plantuml --check-syntax docs/config-sync-cli-sequence-diagram.puml
   ```

3. **Render manually**:
   ```bash
   plantuml -tsvg docs/config-sync-cli-sequence-diagram.puml -o /tmp/
   ```

### Doc-Gen Commands Fail

**Symptoms**: `/doc-gen:*` commands fail

**Solutions**:
1. **Check required parameters**:
   ```bash
   /doc-gen:core:bootstrap --help
   ```

2. **Verify project type**:
   ```bash
   /doc-gen:core:bootstrap --project-type=backend-go --mode=bootstrap
   ```

3. **Check target directories**:
   ```bash
   # Ensure docs directory exists
   mkdir -p docs
   ```

## 🔍 Debugging Tools

### Enable Debug Mode

```bash
# Set debug environment variable
export CLAUDE_DEBUG=1

# Or add to settings
{
  "env": {
    "CLAUDE_DEBUG": "1"
  }
}
```

### Check Configuration

```bash
# Doctor command to check configuration
claude /doctor

# Review commands for validation
/review-shell-syntax
/review-llm-prompts
```

### Log Locations

- **Debug logs**: `~/.claude/debug/`
- **File history**: `~/.claude/file-history/`
- **Session logs**: `~/.claude/session-env/`
- **Shell snapshots**: `~/.claude/shell-snapshots/`

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Permission denied" | Command not in allow list | Add to permissions.allow |
| "Command not found" | Slash command missing | Create command file |
| "Invalid JSON" | Syntax error in settings | Validate with `jq` |
| "Tool not installed" | Target CLI missing | Install target tool |
| "Directory not found" | Backup/config dir missing | Create directory |
| "Plan file invalid" | Corrupted plan file | Use new plan file |

## 🚨 Recovery Procedures

### Complete Reset

If configuration is completely corrupted:

1. **Backup current state**:
   ```bash
   cp -r ~/.claude ~/.claude.backup.$(date +%Y%m%d)
   ```

2. **Reset to basics**:
   ```bash
   # Keep only essential files
   mkdir -p ~/.claude.new
   cd ~/.claude.new
   # Rebuild configuration step by step
   ```

3. **Restore gradually**:
   ```bash
   # Restore settings one by one
   cp ~/.claude.backup/settings.json ~/.claude/
   # Test each component before restoring next
   ```

### Git Recovery

If git state is corrupted:

1. **Check git status**:
   ```bash
   cd ~/.claude
   git status
   ```

2. **Reset to last known good**:
   ```bash
   git reset --hard HEAD
   ```

3. **Clean untracked files**:
   ```bash
   git clean -fd
   ```

## 📞 Getting Help

### Command Help

Most commands support help:
```bash
/command-name --help
```

### Documentation Links

- **[Directory Structure](./directory-structure.md)** - File organization
- **[Settings Reference](./settings.md)** - Configuration hierarchy
- **[Commands Reference](./commands.md)** - Available commands
- **[Config-Sync Guide](./config-sync-guide.md)** - Sync system documentation

### Community Resources

- Check GitHub issues for known problems
- Review configuration examples in documentation
- Use diagnostic commands to identify issues