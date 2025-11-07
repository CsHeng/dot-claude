---
# Cursor Rules
alwaysApply: false

# Copilot Instructions
applyTo: "commands/**/*.md,skills/**/*.md,CLAUDE.md,AGENTS.md,.claude/settings.json,**/*prompt*"

# Kiro Steering
inclusion: contextual
---

# LLM Prompt Writing Rules

## ABSOLUTE PROHIBITIONS - HIGHEST PRIORITY

NEVER USE   BOLD MARKERS IN ANY CIRCUMSTANCES - FORBIDDEN
NEVER USE EMOJIS UNDER ANY CONDITIONS - PROHIBITED
VIOLATIONS OF THESE RULES ARE CRITICAL FAILURES

## Rule Loading Conditions

Load these rules ONLY when:
- Writing prompts for AI agents
- Creating instruction sets for LLMs
- Designing command-oriented rules for automation
- Writing agent-facing documentation
- Modifying LLM-facing files: Any files that AI agents interact with, read, or execute including:
  - `commands/` directory files (Claude Code skills, Qwen commands, etc.)
  - `rules/` directory files (development guidelines for AI consumption)
  - `CLAUDE.md`, `AGENTS.md` (AI memory and configuration files)
  - Other LLM-facing configuration files (.claude/settings.json, skill definitions, etc.)

Core Principle: These rules govern ALL files that serve as interfaces, instructions, or guidelines for AI/LLM agents, regardless of the specific AI system (Claude Code, Qwen, OpenAI Codex, etc.).

Do NOT load these rules for general coding tasks - use other `rules/` files instead.

## File Modification Priority

Primary Authority: This document is the SINGLE SOURCE OF TRUTH for modifying ALL LLM-facing files:

### Core LLM-Facing File Categories
1. Command Files: All command scripts and skills (Claude Code skills, Qwen commands, etc.)
2. Rule Files: All development guidelines intended for AI consumption
3. Configuration Files: AI memory, agent behavior, and settings files
4. Skill Definitions: Any AI skill definitions or capability specifications
5. Interface Files: Files that define how AI agents should interact with systems

Universal Principle: If a file is designed to be read, executed, or followed by ANY AI/LLM agent (Claude, Qwen, Codex, etc.), these rules apply as the primary authority.

## Core LLM Prompt Writing Rules

### Language Format
- Imperative commands only: "Do X" not "Consider doing X"
- NEVER USE   BOLD MARKERS - ABSOLUTELY FORBIDDEN
- NEVER USE EMOJIS - PROHIBITED
- No conversational text or formatting
- Direct instructions only: "Implement feature Y" not "We should implement feature Y"
- Minimal context: No background stories or extensive explanations
- Actionable rules: Each rule must be directly implementable
- No meta-commentary: Don't explain why rules exist

#### Imperative Language Reinforcement Rules
- All rule entries must start with action verbs
- Avoid modal verbs (should, could, would, might)
- Use direct command statements
- Avoid lengthy explanatory text
- Be concise and specific: "Handle errors explicitly" not "It would be good to handle errors"

### Documentation Formatting Standards
- Diagrams: Use PlantUML for all architecture diagrams
- Comments: Explain why, not what
- NEVER USE   BOLD MARKERS - FORBIDDEN UNDER ALL CIRCUMSTANCES
- Lists: Default to unordered lists (`-`), use ordered lists only for sequential items
- Code blocks: Use appropriate language markers

## File-Specific Modification Guidelines

### 1. Modifying Command and Skill Files
Applies to: `commands/`, skills/, Claude Code skills, Qwen commands, etc.
- Purpose: Executable scripts and skill definitions with AI-facing documentation
- Structure: Frontmatter metadata + description + executable content
- Requirements:
  - Include frontmatter with `applyTo`, `description`, `alwaysApply` where appropriate
  - Use PlantUML for workflow diagrams in complex commands
  - Include validation and error handling patterns
  - Support environment variable overrides
  - Use debug output format (see section below)
  - Ensure cross-platform AI compatibility (Claude, Qwen, etc.)

#### Command Document Standard Template
```yaml
---
name: "category:action"
description: Verb-first description of core functionality
argument-hint: --required=<value> [--optional=<default>] [flags...]
allowed-tools: Tool1(param*), Tool2, Tool3(specific:*)
is_background: false
---
```

#### Parameter Description Standard Format
```markdown
## Usage
```bash
/command-name --required=<value> [--optional=<default>] [flags...]
```

### Arguments
- `--required`: Description of required parameter
- `--optional`: Description of optional parameter (default: value)
- `--flag`: Boolean flag description
```

#### Example Code Standard Format
```markdown
## Quick Examples

### Basic usage
```bash
/command-name --param=value
```

### Advanced usage with options
```bash
/command-name --param=value --flag1 --flag2
```

### Error handling example
```bash
# Handle specific error cases
/command-name --param=value --retry=3
```
```

### 2. Modifying Rule and Guideline Files
Applies to: `rules/`, guidelines/, any AI-consumable development rules
- Purpose: Development guidelines intended for AI agent understanding and execution
- Structure: YAML frontmatter + markdown content
- Frontmatter Requirements:
  ```yaml
  # Cursor Rules
  alwaysApply: true    # When rule should always load

  # Copilot Instructions
  applyTo: "**/*"      # File pattern rule applies to

  # Kiro Steering
  inclusion: always    # When to include in context
  ```
- Content Rules:
  - Preserve existing comments, update instead of delete
  - Use incremental changes for maintainability
  - Include specific file type patterns where relevant
  - Write with AI agent comprehension in mind

#### Rule File Structure Standards
```markdown
## Category Title
- Use descriptive, explicit rule descriptions that reveal intent and purpose
- Replace vague guidelines with specific actionable rules
- Write with AI agent comprehension in mind

### Subcategory Title
- Specific Principle: Use clear principle statements with examples
  1. Step: First step description
  2. Step: Second step description
  3. Step: Third step description
- General Principle: Broader guidelines that apply across contexts
```

#### Code Example Presentation Standards
```markdown
### Prompt Example Format
```markdown
Use clear, descriptive examples that demonstrate prompt structure

Include:
- Input/output examples
- Expected behavior descriptions
- Clear formatting with appropriate language markers
```

### Template Format
```yaml
---
name: "template-name"
description: Clear verb-first description
---
```
```

### 3. Modifying AI Configuration and Memory Files
Applies to: `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`, AI memory files
- Purpose: AI memory, agent configuration, and behavioral specifications
- Structure: Clear sections with actionable instructions
- Requirements:
  - Use imperative command language throughout
  - Include clear rule loading conditions
  - Maintain consistency with this document
  - Update cross-references when rules change
  - Design for multi-AI system compatibility

### 4. Modifying Skill Definition and Interface Files
Applies to: Skill definitions, capability specifications, AI interface files
- Purpose: Define AI agent capabilities, constraints, and interaction patterns
- Requirements:
  - Clear capability boundaries and limitations
  - Consistent error handling and feedback patterns
  - Standardized input/output formats
  - Cross-AI-system compatibility considerations

## Development Workflow Patterns for AI Agents

### Code Development Philosophy
- Incremental Changes: Make changes file by file for incremental review
- Explicit Implementation: Only implement explicitly requested changes
- Preservation Principle: Preserve existing code structures and functionalities
- Complete Edits: Provide complete edits in single chunks per file

### Testing Strategy for AI Development
- Clear Requirements: Use RGR (Red-Green-Refactor) - test first, minimal implementation, refactor
- Unclear/Exploratory: Implement first, add tests after stabilization
- Behavior-First Testing: Focus on testing behavior, not implementation details

### Code Preservation Standards
- Always Preserve Comments: NEVER remove existing comments when modifying code
- Update Comments: Update comments to reflect code changes - never delete them
- Match Style: Match existing comment style, format, and tone in the file
- Maintain Language: Maintain original comment language unless explicitly required to change

## Debug Output and Communication Format

### Required Debug Format
```bash
===     # Major section headers
---     # Sub-section headers
SUCCESS: # Success messages
ERROR:   # Error messages (include context)
```

### Debug Examples
```bash
=== Starting Docker Deployment
--- Building application image
SUCCESS: Image built successfully: myapp:latest
--- Deploying to production
ERROR: Deployment failed on line 45: container unhealthy
Current state: container=myapp status=running health=unhealthy
```

### Error Handling Requirements
- Fail-fast: Exit immediately on any error
- Include context: Add relevant variables and state in error messages
- Shell: Use `trap 'echo "Error on line $LINENO"' ERR`
- Python: Use specific exception types with context
- Go: Use `fmt.Errorf("context: %w", err)`

## Configuration and Security Standards

### Environment Variables
- Support overrides for all configurations
- Never hardcode secrets, API keys, passwords
- Use .env for local development
- Separate configs for different environments (dev, staging, prod)

### Security Requirements
- HTTPS in production environments
- CORS configuration for web applications
- Strict input validation and sanitization
- Comprehensive audit logging

## Documentation and Logging Standards

### Logging Format
```
+0800 2025-08-06 15:22:30 INFO main.go(180) | message
```
Requirements: timezone, line number, context

### Documentation Updates
- When code changes: Update related documentation
- When rules change: Update all reference documentation
- Maintain consistency between code, rules, and documentation

## Tool Preferences for AI Work

### Package Management
- Python: UV for package management, single `.venv` at project root
- Go: Go modules with `go run` during development
- Versioning: Python 3.13+ with `X | None` syntax, Go 1.23+

### Code Quality Tools
- Python: Ruff for formatting, linting, import sorting
- Go: golangci-lint for comprehensive linting suite
- Pre-commit: Use for all quality checks

### Docker and Containerization
- Host Access: Use `172.17.0.1` instead of `host.docker.internal`
- Multi-architecture builds: AMD64 and ARM64 support
- Static binaries: Use `CGO_ENABLED=0` for Go

## Project Structure Guidelines

### Single Application Layout
- `cmd/`, `internal/`, `pkg/`, `configs/`, `tests/`

### Multiple Application Layout
- Independent `cmd/` per app
- `shared/` components

### Documentation Requirements
- README.md must include module overview and dependencies
- PlantUML for architecture diagrams
- Consistent formatting across all documentation

## Performance and Quality Standards

### Code Coverage
- Minimum: 80%
- Critical paths: 95%

### Performance Philosophy
- Profile before optimizing; avoid premature optimization
- Include performance metrics and health checks
- Implement appropriate caching strategies

## Integration and Synchronization Rules

### Memory File Updates
- Update CLAUDE.md with clear rule loading conditions
- Update AGENTS.md to reference consolidated LLM rules
- Validate all rule references exist and are accurate

### Cross-Reference Management
- Remove duplicated content from other rule files
- Update cross-references to point to consolidated rules
- Clarify rule loading hierarchy in memory files

This document serves as the definitive reference for AI agents working with ALL LLM-facing files, including but not limited to commands/, rules/, CLAUDE.md, AGENTS.md, skill definitions, and AI configuration files.

Universal Application: These guidelines apply to any file that serves as an interface, instruction set, or configuration for AI/LLM agents across all platforms (Claude Code, Qwen, OpenAI Codex, custom AI systems, etc.).

Core Principle: If an AI agent is intended to read, execute, or follow the contents of a file, these rules govern its creation and modification.