# Claude Code Settings Configuration

Comprehensive guide to configuring Claude Code settings, including file locations, override hierarchy, and best practices. Agents should refer to `AGENTS.md` for their operating instructions; this document is intended for human operators maintaining the configuration.

## 📁 Settings File Locations and Purposes

Claude Code uses a hierarchical settings system with multiple configuration files:

### 1. Global User Settings (`~/.claude/settings.json`)
**Purpose**: Personal preferences that apply to all projects
**Use cases**:
- Personal preferences (thinking mode, timeouts, status line)
- Environment variables and API keys
- Personal tool configurations
- Base configuration that never changes per project

**Precedence**: ⭐ Lowest (overridden by project-specific settings)

### 2. Home Project Settings (`~/.claude/.claude/settings.json`)
**Purpose**: Shared settings across all projects using the "home as project" pattern
**Use cases**:
- Cross-project permissions and safety rules
- Shared tool configurations
- Base permissions you want available everywhere
- Settings that should apply to all projects but can be overridden

**Precedence**: ⭐⭐ Medium (overrides global, overridden by project-specific)

### 3. Project Settings (`{project_root}/.claude/settings.json`)
**Purpose**: Project-specific configuration for team collaboration
**Use cases**:
- Team-wide permissions and security policies
- Project-specific environment variables
- Build and deployment configurations
- Settings committed to git for team synchronization

**Precedence**: ⭐⭐⭐ Highest (overrides all other settings)

### 4. Local Overrides (`.claude/settings.local.json`)
**Purpose**: Personal overrides that should not be shared
**Use cases**:
- Personal API keys and credentials
- Local development paths
- Temporary debugging settings
- Machine-specific configurations

**Precedence**: ⭐⭐⭐⭐ Highest (overrides all settings, git-ignored)

**Important**: This file should be added to `.gitignore` to prevent committing sensitive information.

## 🏗️ Settings Processing and Override Hierarchy

### Precedence Order (Highest to Lowest)
1. **Local overrides** (`.claude/settings.local.json`) - Personal overrides (git-ignored)
2. **Enterprise policies** - Organizational security policies
3. **Command line arguments** - Runtime CLI overrides
4. **Project settings** (`.claude/settings.json`) - Project-specific configuration
5. **Home project settings** (`~/.claude/.claude/settings.json`) - Cross-project shared settings
6. **Global user settings** (`~/.claude/settings.json`) - Personal preferences

### Settings Merging Logic

#### Permission Merging
- **Allow lists**: Merged together, with higher precedence taking priority in conflicts
- **Deny rules**: Absolute priority within each settings layer
- **Ask rules**: Medium priority, requires user confirmation
- **Final effective permissions**: Respect the complete settings hierarchy

#### Environment Variable Merging
- Environment variables are merged with higher precedence overriding lower values
- Project-specific environment variables override global ones
- Useful for project-specific API endpoints, database connections, etc.

#### Configuration Merge Example
```jsonc
// Global settings (~/.claude/settings.json)
{
  "permissions": {
    "allow": ["Bash(git:*)", "Bash(ls:*)"],
    "ask": ["Bash(npm install:*)"]
  },
  "env": {
    "NODE_ENV": "development",
    "TIMEOUT": "30000"
  }
}

// Home project settings (~/.claude/.claude/settings.json)
{
  "permissions": {
    "allow": ["Bash(docker:*)", "Bash(kubectl:*)"],
    "deny": ["Bash(dd:*)"]
  },
  "env": {
    "KUBECONFIG": "~/.kube/config"
  }
}

// Project settings (.claude/settings.json)
{
  "permissions": {
    "allow": ["Bash(terraform:*)"],
    "ask": ["Bash(terraform apply:*)"]
  },
  "env": {
    "NODE_ENV": "production",
    "AWS_REGION": "us-west-2"
  }
}

// Result: All permissions merged, project env vars override
{
  "permissions": {
    "allow": [
      "Bash(terraform:*)",
      "Bash(docker:*)",
      "Bash(kubectl:*)",
      "Bash(git:*)",
      "Bash(ls:*)"
    ],
    "deny": ["Bash(dd:*)"],
    "ask": [
      "Bash(terraform apply:*)",
      "Bash(npm install:*)"
    ]
  },
  "env": {
    "NODE_ENV": "production",
    "KUBECONFIG": "~/.kube/config",
    "AWS_REGION": "us-west-2",
    "TIMEOUT": "30000"
  }
}
```

## 🎯 Recommended Organization Patterns

### Pattern 1: All-in-One Global (Simple)
```
~/.claude/settings.json           # Everything in one place
```
**Best for**: Individual developers, simple setups

### Pattern 2: Split Personal vs Shared (Balanced)
```
~/.claude/settings.json           # Personal preferences only
~/.claude/.claude/settings.json   # Shared permissions and tools
```
**Best for**: Cross-project consistency with personal customization

### Pattern 3: Full Hierarchy (Advanced)
```
~/.claude/settings.json           # Personal: timeouts, env, thinking mode
~/.claude/.claude/settings.json   # Shared: permissions, safety rules
{project}/.claude/settings.json   # Project: team settings, overrides
```
**Best for**: Teams, complex projects, security-conscious environments

## 📋 Common Configuration Sections

### Permissions Configuration
See [docs/permissions.md](permissions.md) for comprehensive permission lists and examples.

### Environment Variables
```json
{
  "env": {
    "API_TIMEOUT_MS": "300000",
    "BASH_DEFAULT_TIMEOUT_MS": "30000",
    "BASH_MAX_TIMEOUT_MS": "300000",
    "BASH_MAX_OUTPUT_LENGTH": "10000",
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "USE_BUILTIN_RIPGREP": "0"
  }
}
```

### Personal Preferences
```json
{
  "alwaysThinkingEnabled": true,
  "defaultMode": "plan",
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

### Tool-Specific Settings
```json
{
  "tools": {
    "editor": {
      "preferred": "vscode",
      "autoSave": true
    },
    "git": {
      "autoStage": false,
      "signCommits": true
    }
  }
}
```

## 📚 Related Documentation

- [Permissions Configuration](permissions.md) - Comprehensive permission lists and examples
- [Development Guidelines](../rules/01-development-standards.md) - Development standards
- [Security Guidelines](../rules/03-security-standards.md) - Security best practices

## 🆘 Troubleshooting

### Settings Not Applied?
1. Check file locations and permissions
2. Verify JSON syntax: `cat settings.json | jq .`
3. Check settings precedence hierarchy
4. Restart Claude Code after changes

### Permission Errors?
1. Review the permission hierarchy
2. Check for deny rules overriding allow rules
3. Verify correct Bash(command:*) syntax
4. Check project-specific overrides

### Environment Variables Not Working?
1. Verify correct env section format
2. Check if higher-precedence settings override
3. Restart your terminal or Claude Code
4. Check for conflicting system environment variables