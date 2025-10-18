---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# User Preferences and Personal Development Settings

These are personal preferences that complement the general development rules. This file serves as both Claude Memory and is synchronized to other AI tools for consistent behavior.

## Tool Version Preferences

### Core Preferences
- Python: Prefer 3.13+ versions with modern type annotation syntax `X | None`
- Go: Prefer 1.23+ versions, use `go run` instead of `go build` during development
- Shell: Prefer `#!/bin/zsh` for interactive scripts during development

### Virtual Environment Management
- Python: Single `.venv` directory at project root
- Package Management: Use UV as package manager
- Environment Variables: Support environment variable overrides for all configurations

## Specific Tool Configurations

### PlantUML
- Installed version: 1.2025.8 (use syntax compatible with this version)
- Testing: Use `PLANTUML_TEMP_DIR=/tmp/plantuml-$$` once per session, then `plantuml -o $PLANTUML_TEMP_DIR` to maintain consistency for batch operations
- Diagrams: Preferred tool for architecture diagrams

### Docker and Containerization
- Host Access: Use `172.17.0.1` instead of `host.docker.internal`
- Docker Compose: Do not include version field
- Go Builds: Use `CGO_ENABLED=0` to generate static binaries

## Communication Preferences

### Language Consistency
- Use the existing natural language of target files for all comments and documentation

### Communication Style
- Concise: Be direct, avoid unnecessary explanations
- Action-oriented: Focus on what needs to be done

## Development Workflow Preferences

### Code Development Style
- Incremental Changes: Make changes file by file for incremental review
- Testing Strategy: Add tests after code stabilizes, not during initial development
- Comment Preservation: Preserve existing comments, do not delete when updating
- Fail Fast: Exit immediately on errors

### Debug Output Format
- Prefixes: `=== Title` (main), `--- Title` (sub), `SUCCESS: msg`, `ERROR: msg (context)`

## Error Handling

### Debugging Format
- Error messages: Include relevant variables and state
- Shell: Use `trap 'echo "Error on line $LINENO"' ERR`
- Python: Use specific exception types with context
- Go: Use `fmt.Errorf("context: %w", err)`

## Documentation

### Documentation Standards
- Diagrams: Use PlantUML for architecture diagrams
- Comments: Explain why rather than what
- Updates: Update related documentation when code or rules change
- Formatting: Use sparing and minimal formatting - avoid excessive use of bold markers (`**`) in documentation
- Lists: Default to unordered lists (`-` or `*`). Use ordered lists only when items have clear sequential relationships

### Logging Format
- Standard: `+0800 2025-08-06 15:22:30 INFO main.go(180) | message`
- Requirements: Include timezone, line number, context

## Code Quality

### Coverage
- Minimum: 80%, Critical paths: 95%
- Pre-commit: Use pre-commit for all quality checks

## Security

### Configuration
- Environment variables: Support overrides for all configurations
- Security: Never hardcode API keys, passwords, secrets
- Input validation: Strictly validate and sanitize all input

## Project Structure

### Layout
- Single app: `cmd/`, `internal/`, `pkg/`, `configs/`, `tests/`
- Multiple apps: Independent `cmd/` per app, `shared/` components
- Configuration: Use environment variables, `.env` for local development
- Documentation: README.md must include module overview and dependencies

## Performance

### Preferences
- Analysis: Analyze performance bottlenecks before optimizing
- Monitoring: Include performance metrics and health checks
- Caching: Implement appropriate caching strategies
- Database: Query optimization, connection pooling, indexing

### Deployment
- Docker: Multi-architecture builds with optimized image sizes
- Security: HTTPS in production, CORS configuration, input validation
- Logging: Structured logging with standard format