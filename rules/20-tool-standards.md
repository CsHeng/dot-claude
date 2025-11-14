# Development Tools and Configuration Directives

## Scope
REQUIRED: Apply these standards to all development tool selection, configuration, and workflow management activities.

## Absolute Prohibitions
PROHIBITED: Use development tools without proper configuration management
PROHIBITED: Hardcode tool versions in scripts without version management
PROHIBITED: Mix different package managers for the same language ecosystem
PROHIBITED: Use development tools in production without security validation
PROHIBITED: Skip tool updates when security vulnerabilities are identified

## Communication Protocol
REQUIRED: Use consistent tool configuration across development environments
REQUIRED: Document tool selection rationale and configuration decisions
REQUIRED: Provide clear setup instructions for all required tools
PROHIBITED: Use abbreviations except universally understood ones (`url`, `id`, `api`)

## Structural Rules
### Primary Tool Manager: mise
REQUIRED: Use mise for language version management and environment configuration
REQUIRED: Configure mise using `.mise.toml` or `.tool-versions` files
PREFERRED: Use mise for development environment consistency across team members
REQUIRED: Integrate mise with CI/CD pipelines for reproducible builds

### Language-Specific Tooling

#### Python Development Stack
REQUIRED: Package Management: UV for Python package management and tool execution
REQUIRED: Configuration: pyproject.toml with [project.dependencies] and [tool.uv.dev-dependencies]
REQUIRED: Development Tools: Execute via `uv tool run` (ruff, pytest, etc.)
REQUIRED: Virtual Environment: Single .venv directory at project root managed by mise
PREFERRED: Pre-commit Hooks: Automated code quality checks before commits

#### Go Development Stack
REQUIRED: Package Management: Go modules with go.mod and go.sum
REQUIRED: Development: Use `go run` instead of `go build` for development
REQUIRED: Dependencies: Use `go mod vendor` for reproducible builds when needed
REQUIRED: Version Specification: Go version specified in go.mod
REQUIRED: Linting: golangci-lint for comprehensive code quality analysis

#### Shell Scripting
REQUIRED: Embedded/OpenWrt: #!/bin/sh with BusyBox ash (POSIX-only features)
REQUIRED: Production/CI: #!/bin/bash with GNU bash 5.2+ (bash features)
PREFERRED: Development: #!/bin/zsh for interactive scripts (zsh-specific features)
PREFERRED: Portable: #!/bin/usr/bin/env bash for cross-platform compatibility

## Language Rules
### Tool Configuration Standards
REQUIRED: Use consistent configuration file formats across projects
REQUIRED: Store tool configurations in version control
REQUIRED: Separate development and production tool configurations
REQUIRED: Document all tool configuration options and their purposes
PREFERRED: Use environment-specific configuration overrides when necessary

### Code Quality Tools

#### Python: Ruff Configuration
REQUIRED: Use ruff for formatting, linting, and import sorting
REQUIRED: Configure ruff in pyproject.toml under [tool.ruff] section
PREFERRED: Enable comprehensive rule sets for maximum code quality
REQUIRED: Configure per-file ignores for specific patterns (tests, migrations)
PREFERRED: Use ruff's auto-fix capabilities for automated code improvements

#### Go: golangci-lint Configuration
REQUIRED: Use golangci-lint for comprehensive Go code analysis
REQUIRED: Configure golangci-lint using .golangci.yml file
REQUIRED: Enable essential linters: govet, errcheck, staticcheck, ineffassign
PREFERRED: Configure project-specific linters and rules
REQUIRED: Set appropriate complexity limits and coding standards

### Pre-commit Hooks
REQUIRED: Configure pre-commit hooks using .pre-commit-config.yaml
REQUIRED: Include hooks for code formatting, linting, and security scanning
REQUIRED: Test pre-commit hooks in CI/CD pipelines
PREFERRED: Include hooks for documentation formatting and validation
REQUIRED: Ensure hooks work efficiently without significant performance impact

## Formatting Rules
### Environment Configuration
REQUIRED: Use mise for consistent development environment setup
REQUIRED: Define all tool versions in mise configuration files
REQUIRED: Use environment variables for configuration that varies between environments
REQUIRED: Document environment setup procedures and requirements
PREFERRED: Use mise tasks for common development workflows

### IDE Configuration
REQUIRED: Configure IDE settings to match project tooling configurations
REQUIRED: Include IDE configuration files (.vscode/settings.json, extensions.json) in version control
REQUIRED: Ensure IDE extensions match project requirements
PREFERRED: Configure consistent formatting and linting integration across IDEs
REQUIRED: Document IDE setup procedures for new team members

### Documentation Standards
REQUIRED: Use PlantUML for all architecture diagrams and flowcharts
REQUIRED: Test PlantUML diagrams with `plantuml -o /tmp` before committing
REQUIRED: Include PlantUML diagrams in markdown documentation
REQUIRED: Update documentation when code or tool configurations change
PREFERRED: Use standardized markdown formatting for all documentation

## Naming Rules
### Tool Selection
REQUIRED: Choose tools with active maintenance and security support
REQUIRED: Prefer tools with good integration capabilities
REQUIRED: Use tools that support team collaboration and code review workflows
PREFERRED: Select tools with comprehensive documentation and community support
REQUIRED: Evaluate tools for performance and resource usage impact

### Configuration Organization
REQUIRED: Organize configuration files logically within project structure
REQUIRED: Use clear, descriptive naming for configuration files and sections
REQUIRED: Group related configuration options together
PREFERRED: Use environment-specific configuration files when needed
REQUIRED: Document all configuration options and their default values

## Validation Rules
### Tool Management
REQUIRED: Regularly update tools to latest stable versions with security patches
REQUIRED: Test tool updates in development environment before deployment
REQUIRED: Monitor tool deprecation notices and migration requirements
REQUIRED: Validate tool configurations for syntax and correctness
PREFERRED: Use automated dependency scanning for security vulnerabilities

### Performance Requirements
REQUIRED: Monitor tool performance impact on development workflow
REQUIRED: Optimize tool configurations for fast execution
REQUIRED: Use caching strategies where appropriate to improve performance
PREFERRED: Configure tools to run in parallel when possible
REQUIRED: Measure and track development environment setup times

### Security Standards
REQUIRED: Scan tools and dependencies for known vulnerabilities
REQUIRED: Use signed tool downloads when available
REQUIRED: Validate tool integrity after installation
REQUIRED: Implement principle of least privilege for tool access
PREFERRED: Use tools with built-in security features and best practices

### Integration Requirements
REQUIRED: Integrate all tools with CI/CD pipelines
REQUIRED: Ensure consistent tool behavior across development, testing, and production
REQUIRED: Test tool integration with deployment and monitoring systems
REQUIRED: Configure tools for automated quality gates and checks
PREFERRED: Use tools that support containerization and cloud-native workflows