# Workflow Patterns and Development Practices

Guidelines for development workflows, tool preferences, and coding practices that should be integrated into Claude memory.

## Development Workflow Preferences

### Change Management Philosophy
- **Incremental Development**: Make changes file by file to enable incremental review
- **Explicit Implementation**: Only implement explicitly requested changes
- **Preservation Principle**: Preserve existing code structures and functionalities
- **Complete Edits**: Provide complete edits in single chunks per file

### Code Preservation Standards
- **Always Preserve Comments**: NEVER remove existing comments when modifying code
- **Update Comments**: Update comments to reflect code changes - never remove them
- **Match Style**: Match existing comment style, format, and tone in the file
- **Maintain Language**: Maintain original comment language unless explicitly required to change

### Testing Philosophy
- **Initial Development**: Do NOT add tests during initial development
- **Production-Ready Testing**: Tests are added manually after code stabilizes and reaches production-ready state
- **Behavior-First Testing**: Focus on testing behavior, not implementation
- **Manual Test Addition**: Tests are added manually after stabilization, not automatically

## Tool Preferences and Configuration

### Package Management
```bash
# Python Projects
- Primary: UV for package management and tool execution
- Configuration: pyproject.toml with [project.dependencies] and [tool.uv.dev-dependencies]
- Development Tools: uv tool run ruff, uv tool run pytest
- Virtual Environment: Single .venv directory at project root managed by mise

# Go Projects
- Primary: Go modules with go.mod and go.sum
- Build: go run instead of go build for development
- Dependencies: go mod vendor for reproducible builds
- Version Specification: Go version specified in go.mod

# Shell Scripts
- Embedded/OpenWrt: #!/bin/sh with BusyBox ash (POSIX-only features)
- Production/CI: #!/bin/bash with GNU bash 5.2+ (bash features)
- Development: #!/bin/zsh for interactive scripts (zsh-specific features)
- Portable: #!/usr/bin/env bash for cross-platform compatibility
```

### Code Quality Tools
```yaml
# Python (via ruff configuration)
Tools: ruff for formatting, linting, import sorting
Configuration: pyproject.toml under [tool.ruff]
Required Checks:
  - Code formatting and style (E, W)
  - Import sorting and organization (I)
  - Unused imports and variables (F)
  - Security issues (S)
  - Complexity checks (C)

# Go (via golangci-lint configuration)
Tools: golangci-lint for comprehensive linting suite
Configuration: .golangci.yml for project configuration
Required Linters:
  - gosimple: Simplify code suggestions
  - govet: Built-in Go analysis
  - ineffassign: Detect ineffectual assignments
  - unused: Find unused code
  - misspell: Detect misspelled words
  - gocyclo: Cyclomatic complexity (max 15)
  - gofmt: Code formatting
  - goimports: Import organization
  - staticcheck: Advanced static analysis
  - errcheck: Check for unhandled errors
  - gosec: Security-focused linting
  - revive: Fast, configurable linter
  - whitespace: Whitespace consistency
```

### Environment Management
```toml
# mise configuration (.mise.toml or .tool-versions)
[tools]
go = "1.23.0"
golangci-lint = "latest"
python = "3.13"
ruff = "latest"

[env]
GOLANGCI_LINT_CACHE = ".cache/golangci-lint"
UV_CACHE_DIR = ".cache/uv"
```

## Build and Deployment Patterns

### Docker Optimization Standards
```dockerfile
# Go Build Environment Variables (Required)
CGO_ENABLED=0          # Disable CGO for static binaries
GOOS=${TARGETOS}       # Target operating system
GOARCH=${TARGETARCH}   # Target architecture
GOGC=off              # Disable GC during compilation
GOMAXPROCS=1          # Single-core compilation

# Required Linker Flags
go build -ldflags="-w -s -extldflags=-static"
# -w: Remove DWARF debug info (30-50% size reduction)
# -s: Remove symbol table (10-20% size reduction)
# -extldflags=-static: Generate static binary

# Additional Build Flags
go build -a -installsuffix cgo -gcflags="-trimpath" -asmflags="-trimpath"
# -a: Force package recompilation
# -installsuffix cgo: Avoid CGO conflicts
# -trimpath: Remove source paths from output
```

### Image Naming Convention
```
<app-name>:amd64         # AMD64 architecture
<app-name>:arm64         # ARM64 architecture
<app-name>:latest        # Development (current arch)

<app-name>-slim:amd64    # Optimized AMD64
<app-name>-slim:arm64    # Optimized ARM64
<app-name>-slim:latest   # Development optimized
```

## Debug Output Standards

### Consistent Debug Format
```bash
# Required debug prefixes
===     # Major section headers
---     # Sub-section headers
SUCCESS: # Success messages
ERROR:   # Error messages

# Fail-fast principle: Exit immediately on any error
# Include relevant variables and state in error messages
```

### Example Debug Output
```bash
=== Starting Docker Deployment
--- Building application image
SUCCESS: Image built successfully: myapp:latest
--- Deploying to production
ERROR: Deployment failed on line 45: container unhealthy
Current state: container=myapp status=running health=unhealthy
```

## Documentation Standards

### Diagram Format Preference
- **Primary Format**: PlantUML for all flowcharts and architecture diagrams
- **Testing**: Use `plantuml -o /tmp` for PlantUML grammar testing
- **Integration**: Update corresponding markdown documentation when code or rules change

### Documentation Updates
- When code changes, update related documentation
- When rules change, update all reference documentation
- Maintain consistency between code, rules, and documentation

## Logging Standards

### Required Log Format
```
+0800 2025-08-06 15:22:30 INFO main.go(180) | Descriptive message
```

### Log Configuration Requirements
- **Handler**: Both console and file output
- **Level**: INFO (default)
- **Components**:
  - Timezone (+0800)
  - Timestamp (YYYY-MM-DD HH:MM:SS)
  - Level (INFO, WARN, ERROR)
  - File and line number (file.go(line))
  - Separator (|)
  - Message
- **Additional**: Include request ID for request-related logs
- **Security**: Never log sensitive information

## Configuration Management

### Environment Variables Philosophy
- **NEVER hardcode** API keys, secrets, or credentials in source code
- Store sensitive data in `.env` files or configuration files
- Use separate configuration files for different environments (dev, staging, prod)
- Use environment variables for all configuration that varies between environments

### Configuration File Structure
```toml
# Production Configuration Example
[database]
host = "${DB_HOST:localhost}"
port = "${DB_PORT:5432}"
user = "${DB_USER}"
password = "${DB_PASSWORD}"
dbname = "${DB_NAME}"

[logging]
level = "${LOG_LEVEL:INFO}"
format = "json"
output = ["stdout", "file"]

[security]
jwt_secret = "${JWT_SECRET}"
cors_origins = "${CORS_ORIGINS:*}"
```

## Error Handling Preferences

### Debug Output Format
- Use consistent debug prefixes: `===`, `---`, `SUCCESS:`, `ERROR:`
- Fail-fast principle: Exit immediately on any error
- Include relevant variables and state in error messages
- Provide actionable error messages for debugging

### Error Message Examples
```bash
# Good error messages
ERROR: Database connection failed on line 67: host=localhost port=5432 user=admin
SUCCESS: Database connected successfully: db=production latency=23ms
--- Processing user data: count=1500 batch_size=100

# Bad error messages (avoid)
ERROR: Failed
Something went wrong
```

## Performance Preferences

### Code Optimization Philosophy
- Profile before optimizing; avoid premature optimization
- Use appropriate data structures for the problem domain
- Implement proper resource cleanup and management
- Consider memory usage and computational complexity

### Build Optimization
- Use static builds for Go applications (CGO_ENABLED=0)
- Implement multi-architecture Docker builds
- Use optimized linker flags for smaller binaries
- Minimize image sizes for production deployments

## Security Integration

### Security by Default
- Implement secure defaults for all configurations
- Use HTTPS in production environments
- Implement proper CORS configuration
- Follow OWASP security guidelines

### Security Testing
- Implement comprehensive input validation
- Use secure session management
- Implement comprehensive audit logging
- Regular security assessments and updates

## Memory Integration Topics

### Tool Preferences to Store in Claude Memory
1. **Package Management**: UV for Python, Go modules for Go
2. **Code Quality**: Ruff for Python, golangci-lint for Go
3. **Build Tools**: Docker multi-arch builds, Make standardized targets
4. **Testing Frameworks**: pytest for Python, table-driven tests for Go
5. **Environment Management**: mise for tool version management
6. **Documentation**: PlantUML for diagrams, markdown for documentation
7. **Logging**: Structured logging with specific format requirements
8. **Debug Output**: Consistent prefix-based debug formatting
9. **Security**: Environment variables for secrets, never hardcode credentials
10. **Development Philosophy**: Fail-fast, preserve comments, test after stabilization

### Project Structure Preferences
- Class-based architecture for Python
- Clean architecture patterns for Go
- Environment-specific shell scripting
- Modular Docker organization
- Comprehensive documentation integration

### Integration Patterns
- Single responsibility scripts
- Common library patterns
- Parameter standardization
- Function design principles
- Remote execution patterns