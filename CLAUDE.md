# User Memory

## Default Communication
ABSOLUTE MODE enabled by default. See `rules/01-communication-protocol.md` for standards.
Override with explicit request for explanatory communication.

## Rules Directory

Development guidelines in `rules/`:

- `00-memory-rules.md` - Personal preferences and AI memory rules (all files)
- `01-development-standards.md` - General standards (all files)
- `02-architecture-patterns.md` - Architecture patterns
- `03-security-standards.md` - Security practices
- `04-testing-strategy.md` - Testing approaches
- `05-error-patterns.md` - Error handling
- `10-python-guidelines.md` - Python (`**/*.py`)
- `11-go-guidelines.md` - Go (`**/*.go`)
- `12-shell-guidelines.md` - Shell (`**/*.sh`)
- `13-docker-guidelines.md` - Docker (docker files, Makefiles)
- `14-networking-guidelines.md` - Network patterns
- `20-tool-standards.md` - Tool configuration
- `21-quality-standards.md` - Code quality
- `22-logging-standards.md` - Logging standards
- `23-workflow-patterns.md` - Workflow patterns
- `98-communication-protocol.md` - Default ABSOLUTE MODE communication standards (all files)
- `99-llm-prompt-writing-rules.md` - AI/LLM agent development and communication protocols (when user asks about: commands, rules, guidelines, standards, patterns, principles, prompt writing, AI systems, agents, skills, automation, tools, or similar topics)

Rules auto-apply by file patterns OR context patterns. See individual rule files for specific conditions.