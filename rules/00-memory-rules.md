# Memory Rules

## Scope
Define mandatory personal development preferences, tool requirements, and workflow standards synchronized across all AI tools and environments.

## Absolute-Prohibitions
- NEVER hardcode API keys, passwords, secrets, or sensitive credentials
- NEVER use bold markers in any documentation or comments
- NEVER commit configuration files containing secrets to version control
- NEVER bypass environment variable override mechanisms

## Communication-Protocol
- Use existing natural language patterns of target files for comments and documentation
- Write concise, action-oriented communication avoiding narrative explanations
- Focus on implementation details over explanatory text
- Default to unordered lists unless sequential relationships exist

## Structural-Rules

### Tool Version Requirements
- Python: REQUIRED Python 3.13+ with modern union syntax X | None
- Go: REQUIRED Go 1.23+ with go run for development activities
- Shell: REQUIRED #!/bin/zsh for interactive development scripts
- Lua: REQUIRED Lua 5.4+ with luac -p <path> for syntax validation
- PlantUML: REQUIRED version >=1.2025.9 with plantuml --check-syntax <path> validation

### Environment Management Rules
- Python: REQUIRED single .venv directory at project root
- Package Management: REQUIRED UV as primary package manager
- Environment Variables: MANDATORY support for environment variable overrides on all configurations
- Docker Compose: PROHIBITED version field in docker-compose.yml files

## Language-Rules

### Python Requirements
- Use union syntax X | None instead of Optional[X]
- Maintain type hints for all public interfaces
- Use f-strings for string formatting

### Go Requirements
- Use go run for development activities
- Build with CGO_ENABLED=0 for static binary generation
- Use structured error wrapping with fmt.Errorf("context: %w", err)

### Shell Requirements
- Use #!/bin/zsh shebang for interactive development
- Use trap 'echo "Error on line $LINENO"' ERR for error handling
- Fail immediately on errors with set -euo pipefail

### Dbml Requirements
- Use dbml2sql <path> for syntax validation
- Use original table names in Ref statements
- PROHIBITED table aliases in reference statements

## Formatting-Rules

### Development Workflow Standards
- Make incremental changes file by file for review
- Add tests after code stabilization, not during initial development
- Preserve existing comments when updating code
- Exit immediately on errors (fail-fast principle)

### Debug Output Format
- Main sections: === Title
- Sub-sections: --- Title
- Status messages: SUCCESS: msg, ERROR: msg (context)

### Documentation Standards
- Use PlantUML for architecture diagrams
- Explain implementation rationale, not functionality
- Update related documentation when code or rules change
- Use minimal formatting without bold markers

### Logging Format Standard
- REQUIRED format: +0800 2025-08-06 15:22:30 INFO main.go(180) | message
- MANDATORY inclusion: timezone, line number, and execution context

## Naming-Rules

### Error Handling Requirements
- Include relevant variables and state in all error messages
- Use specific exception types with implementation context
- Provide actionable error information for debugging

### Project Structure Requirements
- Single app: REQUIRED cmd/, internal/, pkg/, configs/, tests/ structure
- Multiple apps: Independent cmd/ per app with shared/ components
- Configuration: MANDATORY environment variable support, .env for local development only
- Documentation: REQUIRED README.md with module overview and dependencies

## Validation-Rules

### Code Quality Standards
- REQUIRED minimum 80% test coverage, 95% for critical execution paths
- MANDATORY pre-commit hooks for all quality checks
- PROHIBITED code that fails static analysis

### Security Standards
- MANDATORY environment variable override support for all configurations
- REQUIRED strict validation and sanitization of all input data
- PROHIBITED hardcoded credentials in any form

### Performance Standards
- REQUIRED performance analysis before optimization activities
- MANDATORY inclusion of performance metrics and health checks
- REQUIRED appropriate caching strategies for all external calls
- REQUIRED database connection pooling and query optimization

### Deployment Standards
- Docker: REQUIRED multi-architecture builds with optimized image sizes
- Security: REQUIRED HTTPS enforcement in production with CORS configuration
- Logging: REQUIRED structured logging with standard format compliance
- Host Access: REQUIRED use of 172.17.0.1 instead of host.docker.internal