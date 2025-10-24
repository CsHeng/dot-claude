# Claude Global Command Permissions Configuration

Command permissions configuration documentation in `~/.claude/settings.json`.

## 📋 Command Categories

### ✅ Automatically Allowed Commands (allow)

These commands are considered safe and do not modify system state or cause destructive impact.

#### Basic File Operations
- `ls`, `la`, `ll` - List directory contents
- `cat`, `head`, `tail`, `less`, `more` - Read file contents
- `file`, `stat` - View file information
- `wc`, `du`, `df` - File statistics and disk usage
- `pwd`, `which`, `whereis`, `type` - Path and type queries

#### System Information
- `echo`, `printf` - Output text
- `date`, `cal`, `uptime` - Time and system status
- `whoami`, `id`, `uname` - User and system information
- `env`, `printenv`, `export`, `alias` - Environment variables and aliases

#### Git Read-only Operations
- `git status`, `git log`, `git diff`, `git show`
- `git branch`, `git tag`, `git remote`, `git config`
- `git help`, `git --version`

#### Basic Network Tools
- `ping -c:*`, `ping -w:*` - Limited count ping
- `netstat`, `ss`, `lsof -i:*` - Network connection viewing
- `curl --:*` - curl information queries (--help, --version, etc.)
- `wget --:*` - wget information queries (--help, --version, etc.)

*Note: Commands with `--:*` pattern cover all -- flags for the tool, consolidating --help and --version permissions.*

#### Process and System Monitoring
- `ps aux:*`, `ps -ef:*` - Process lists
- `top -n:*`, `htop --version` - System monitoring

#### Development Tools
- `terraform plan/validate/fmt/show` - Terraform read-only operations
- `docker images/ps/network ls/volume ls` - Docker information viewing
- `kubectl get/describe/config view/version` - Kubernetes read-only operations
- `pip list/show/check`, `pip --:*` - Python tools (pip with -- flags)
- `npm list/view`, `npm --:*` - Node.js tools (npm with -- flags)
- `yarn list/info`, `yarn --:*` - Yarn tools (yarn with -- flags)
- `go version`, `go mod download/verify/tidy/why` - Go tools
- `rustc --:*`, `cargo --:*` - Rust tools (with -- flags)

#### Data Processing
- `sort`, `uniq`, `cut`, `awk`, `sed -n:*`, `tr` - Text processing
- `base64`, `xxd`, `hexdump`, `od` - Encoding and hex viewing
- `diff:*`, `cmp`, `comm` - File comparison
- `sha1sum`, `sha256sum`, `md5sum`, `cksum` - Checksum calculation
- `xargs:*` - Execute commands from standard input

#### Safe Creation Operations
- `mkdir:*` - Create directories
- `ln -s:*` - Create symbolic links
- `tree:*` - Directory tree viewing

#### Compression and Archives
- `tar:*` - Archive operations
- `unzip -l:*`, `unzip --:*`, `zip --:*` - Zip operations (viewing, -- flags)

#### Testing and Conditions
- `test:*`, `[*`, `[[*` - Conditional testing
- `history:*`, `fc -l:*` - History viewing

#### Specific Tools
- `Bash(plantuml:*)` - PlantUML diagram generation
- `Bash(grep:*)`, `Bash(find:*)` - Search and find
- `Bash(gdiff:*)` - GNU diff
- `Bash(mkdir:*)`, `Bash(chmod:*)` - Directory creation and permission setting

### ❌ Explicitly Forbidden Commands (deny)

These commands are destructive or potentially dangerous, completely forbidden from execution.

- `dd :*` - Low-level disk operations
- `mkfs :*`, `format :*` - File system formatting
- `fdisk :*`, `sfdisk :*`, `parted :*` - Disk partitioning
- `shred :*`, `wipe :*` - Secure deletion tools

### ❓ Commands Requiring Confirmation (ask)

These commands may modify system state and require user confirmation.

#### Java and Basic File Operations
- `Bash(java:*)` - Java program execution
- `Bash(rm:*)`, `Bash(rmdir:*)` - Delete files and directories
- `Bash(mv:*)`, `Bash(cp:*)` - Move and copy files
- `Bash(chown:*)`, `Bash(chmod -R :*)` - Modify file permissions (recursive)

#### Git Write Operations
- `git add:*`, `git commit:*`, `git push:*`, `git pull:*`
- `git merge:*`, `git rebase:*`, `git reset:*`
- `git checkout:*`, `git switch:*`, `git restore:*`
- `git stash:*`, `git clean:*`

#### Containers and Orchestration
- `docker run:*`, `docker rmi:*`, `docker rm:*`
- `docker stop:*`, `docker kill:*`, `docker build:*`
- `docker compose up:*`, `docker compose down:*`, `docker compose restart:*`
- `kubectl apply:*`, `kubectl delete:*`, `kubectl create:*`
- `kubectl edit:*`, `kubectl exec:*`, `kubectl logs:*`

#### Infrastructure as Code
- `terraform apply:*`, `terraform destroy:*`, `terraform import:*`
- `terraform taint:*`, `terraform state rm:*`

#### Package Managers
- `pip install:*`, `pip uninstall:*`, `python -m pip install:*`
- `npm install:*`, `npm uninstall:*`, `npm run:*`
- `yarn add:*`, `yarn remove:*`, `yarn install:*`, `yarn run:*`
- `go get:*`, `cargo install:*`, `cargo uninstall:*`, `cargo build:*`
- `mise install:*`, `mise uninstall:*`, `mise use:*`

#### Network Requests
- `curl -X POST:*`, `curl -X PUT:*`, `curl -X DELETE:*`
- `curl -d:*`, `curl --data:*`
- `wget --post-data:*`, `wget --method:*`

#### Remote Operations
- `ssh --:*`, `scp --:*`, `rsync:*` - SSH/SCP with -- flags, and rsync

#### System Scripting
- `osascript -e:*` - AppleScript execution (single line)

#### Permission Modifications
- `chmod +x :*`, `chmod 755 :*`, `chmod 644 :*`

## 🔧 Permission System Details

### Wildcard Syntax Rules

⚠️ **Important**: Always use `:*` for prefix matching, not `*`

- ✅ **Correct**: `Bash(rm:*)`, `Bash(git status:*)`, `Bash(npm run:*)`
- ❌ **Incorrect**: `Bash(rm *)`, `Bash(git status *)`, `Bash(npm run *)`

The `:*` syntax matches any arguments after the specified command prefix, while `*` is not supported and will cause validation errors.

### Permission Priority Mechanism

#### Permission Type Priority (High to Low)
```
Deny (Highest Priority) > Ask > Allow (Lowest Priority)
```

#### Execution Logic
1. **Check deny list** - If matched, directly reject
2. **Check ask list** - If matched, require user confirmation
3. **Check allow list** - If matched, allow execution
4. **Other cases** - Default to deny

### Configuration File Merging Logic

#### Layered Permission System
1. **Enterprise policies** - Organizational security policies (highest precedence)
2. **CLI arguments** - Runtime command-line overrides
3. **Project settings** (`.claude/settings.json`) - Project-specific permission layer
4. **User settings** (`~/.claude/settings.json`) - Base permission layer
5. **Deny rules** - Highest priority within each settings layer, overrides allow rules
6. **Ask rules** - Medium priority, requires user confirmation

#### Permission Merging Method
- **Project allow list** is **merged** with User allow list, taking precedence where conflicts exist
- **deny rules** have absolute priority within each settings layer
- Final effective permissions respect the settings hierarchy
- Project settings automatically override user settings

### Practical Examples

#### Example 1: Project vs User Settings
```json
// User settings (~/.claude/settings.json) - Personal preferences
{
  "permissions": {
    "allow": [
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(personal-tool:*)"  // User's personal development tool
    ],
    "ask": ["Bash(npm install:*)"]
  }
}

// Project settings (.claude/settings.json) - Team configuration
{
  "permissions": {
    "defaultMode": "plan",
    "allow": [
      "Bash(grep:*)",
      "Bash(find:*)",
      "Bash(project-specific-deploy:*)"  // Project deployment tool
    ],
    "ask": [
      "Bash(terraform apply:*)"
    ]
  }
}
```
**Result**:
- User can use `personal-tool` but project settings take precedence
- Team gets `project-specific-deploy` permission automatically
- Both user and project ask permissions are respected
- Project's `defaultMode: "plan"` overrides user preferences

#### Example 2: Multi-Project Team Setup
```json
// User settings - Base configuration for all projects
{
  "permissions": {
    "allow": ["Bash(git status:*)", "Bash(ls:*)"],
    "ask": ["Bash(npm install:*)"]
  }
}

// Project A - Frontend development (.claude/settings.json)
{
  "permissions": {
    "allow": [
      "Bash(npm run dev:*)",
      "Bash(npm run build:*)",
      "Bash(yarn:*)"
    ]
  }
}

// Project B - Infrastructure (.claude/settings.json)
{
  "permissions": {
    "allow": [
      "Bash(terraform plan:*)",
      "Bash(terraform validate:*)",
      "Bash(kubectl get:*)"
    ],
    "ask": [
      "Bash(terraform apply:*)",
      "Bash(kubectl apply:*)"
    ]
  }
}
```
**Result**:
- **Project A**: Frontend team gets Node.js tools, user's base permissions
- **Project B**: DevOps team gets infrastructure tools with safety confirmations
- **Consistency**: User always has basic git and file operations across projects

#### Example 3: Security-First Project Configuration
```json
// Project settings - High security financial application (.claude/settings.json)
{
  "permissions": {
    "defaultMode": "plan",
    "allow": [
      "Bash(git status:*)",
      "Bash(git log:*)",
      "Bash(cat:*)",
      "Bash(grep:*)"
    ],
    "deny": [
      "Bash(rm:*)",
      "Bash(curl:*-X POST:*)",
      "Bash(curl:*-X PUT:*)",
      "Bash(kubectl apply:*)",
      "Bash(terraform apply:*)"
    ]
  }
}
```
**Result**: Even if user has broad permissions locally, project security policy takes precedence and blocks destructive operations regardless of user settings.

## 🎯 Settings Precedence Hierarchy

Claude Code settings follow this precedence hierarchy (highest to lowest):

1. **Enterprise policies** - Organizational security policies
2. **Command line arguments** - Runtime CLI overrides
3. **Project settings** (`.claude/settings.json`) - Project-specific configuration
4. **User settings** (`~/.claude/settings.json`) - Personal preferences

### Project vs User Settings

#### Project Settings (`.claude/settings.json`)
- **Purpose**: Team-wide permissions and project-specific configurations
- **Precedence**: Higher than user settings, overrides personal preferences
- **Management**: Committed to git for team collaboration
- **Benefits**:
  - Consistent security posture across team members
  - Project-tailored command access
  - Version control for permission changes
  - Onboarding automation for new team members

#### User Settings (`~/.claude/settings.json`)
- **Purpose**: Personal preferences and individual overrides
- **Precedence**: Lower priority, overridden by project settings
- **Management**: Local configuration, not committed to git
- **Use cases**: Personal development tools, individual workflow preferences

## 🤖 LLM-Driven Configuration Generation

### Generate Settings from Documentation

Instead of copying configuration files directly, use LLMs to generate tailored settings based on project requirements:

#### Example Generation Prompt
```
Generate Claude Code settings.json based on docs/permissions.md with:
1. Project-specific permissions for a web development team
2. Focus on Node.js, React, and AWS deployments
3. Security-conscious approach (deny by default)
4. Use correct Bash(command:*) syntax format
5. Separate project settings (commit to git) from personal settings
```

#### Decision Trees for Permission Selection

**Consider these questions when generating settings:**

1. **Team size and expertise**: More experienced teams can have broader permissions
2. **Project criticality**: Production systems need stricter controls
3. **Development environment**: Local vs remote development needs
4. **Compliance requirements**: Industry regulations may dictate security levels
5. **Technology stack**: Different tools require different permissions

### Project Override
Projects automatically override user settings through the precedence hierarchy. Simply create `.claude/settings.json` in your project root and commit it to git.

### Adjusting Permissions

**Project Settings** (`.claude/settings.json`):
- Edit to define team-wide permissions
- Commit to git for team synchronization
- Override user settings automatically

**User Settings** (`~/.claude/settings.json`):
- Edit for personal preferences
- Keep local, don't commit to git
- Override only when project settings allow

### Configuration File Locations
- **Project**: `{project_root}/.claude/settings.json` (committed to git, higher precedence)
- **User**: `~/.claude/settings.json` (personal config, lower precedence)