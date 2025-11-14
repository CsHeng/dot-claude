# Workflow Patterns and Development Directives

## Scope
REQUIRED: Apply these standards to all development workflows, tool preferences, and coding practices integrated into AI memory.

## Absolute Prohibitions
PROHIBITED: Remove existing comments when modifying code
PROHIBITED: Implement changes without explicit user requests
PROHIBITED: Mix initialization logic with main execution code
PROHIBITED: Hardcode secrets or configuration values in source code
PROHIBITED: Use conversational filler in technical communications

## Communication Protocol
REQUIRED: Use ABSOLUTE MODE precision communication by default
REQUIRED: Provide terse, directive, high-density content only
REQUIRED: Deliver complete executable or verifiable output
PROHIBITED: Use emotional language, compliments, or motivational tone
PROHIBITED: Include conversational transitions or unnecessary explanations

## Structural Rules
### Development Philosophy
REQUIRED: Incremental Development: Make changes file by file for incremental review
REQUIRED: Explicit Implementation: Only implement explicitly requested changes
REQUIRED: Preservation Principle: Preserve existing code structures and functionalities
REQUIRED: Complete Edits: Provide complete edits in single chunks per file

### Code Preservation Standards
REQUIRED: Always Preserve Comments: NEVER remove existing comments when modifying code
REQUIRED: Update Comments: Update comments to reflect code changes - never remove them
REQUIRED: Match Style: Match existing comment style, format, and tone in the file
REQUIRED: Maintain Language: Maintain original comment language unless explicitly required to change

### Testing Philosophy
REQUIRED: Clear Requirements: Use RGR (Red-Green-Refactor) - test first, minimal implementation, refactor
PREFERRED: Unclear/Exploratory: Implement first, add tests after stabilization
REQUIRED: Behavior-First Testing: Focus on testing behavior, not implementation

## Language Rules
### Package Management
REQUIRED: Python Projects: Use UV for package management with pyproject.toml
REQUIRED: Go Projects: Use Go modules with go.mod and semantic versioning
REQUIRED: Shell Scripts: Use appropriate shebang based on target environment
REQUIRED: Environment Management: Use mise for tool version management
PREFERRED: Virtual Environment: Single .venv directory at project root

### Code Quality Tools
REQUIRED: Python: Use ruff for formatting, linting, and import sorting
REQUIRED: Go: Use golangci-lint for comprehensive code analysis
REQUIRED: Pre-commit: Configure automated quality checks before commits
REQUIRED: CI/CD: Integrate quality gates in all pipelines
PREFERRED: Testing: pytest for Python, table-driven tests for Go

## Formatting Rules
### Build and Deployment Standards
REQUIRED: Docker Optimization: Use multi-stage builds with specific environment variables
REQUIRED: Go Build Flags: Use CGO_ENABLED=0 and proper linker flags for static binaries
REQUIRED: Image Naming: Use consistent multi-architecture naming patterns
REQUIRED: Resource Management: Set appropriate CPU and memory limits
PREFERRED: Security: Create non-root users and scan for vulnerabilities

### Debug Output Standards
REQUIRED: Consistent Format: Use === for major sections, --- for sub-sections
REQUIRED: Status Indicators: Use SUCCESS: and ERROR: prefixes consistently
REQUIRED: Fail-Fast: Exit immediately on any error with relevant state information
REQUIRED: Context: Include variables and state in error messages
PROHIBITED: Vague Messages: Avoid generic error messages without context

### Documentation Standards
REQUIRED: Diagram Format: Use PlantUML for all flowcharts and architecture diagrams
REQUIRED: Testing: Validate PlantUML grammar with `plantuml -o /tmp` before committing
REQUIRED: Integration: Update documentation when code or rules change
REQUIRED: Consistency: Maintain consistency between code, rules, and documentation
PREFERRED: Examples: Include usage examples in all documentation

## Naming Rules
### Configuration Management
REQUIRED: Environment Variables: Use environment variables for all environment-specific configuration
REQUIRED: Security: NEVER hardcode API keys, secrets, or credentials in source code
REQUIRED: Structure: Store sensitive data in .env files or configuration management systems
REQUIRED: Separation: Use separate configuration files for different environments
PREFERRED: Validation: Validate all configuration values on application startup

### Error Handling Preferences
REQUIRED: Debug Output: Use consistent debug prefixes (===, ---, SUCCESS:, ERROR:)
REQUIRED: Fail-Fast: Exit immediately on any error with comprehensive context
REQUIRED: Actionability: Provide actionable error messages for debugging
REQUIRED: State: Include relevant variables and application state in error messages
PROHIBITED: Ambiguity: Avoid generic or unclear error messages

## Validation Rules
### Performance Preferences
REQUIRED: Profiling: Profile before optimizing; avoid premature optimization
REQUIRED: Data Structures: Use appropriate data structures for the problem domain
REQUIRED: Resource Management: Implement proper resource cleanup and management
REQUIRED: Considerations: Consider memory usage and computational complexity
PROHIBITED: Optimization: Optimize code without proper performance measurements

### Security Integration
REQUIRED: Secure Defaults: Implement secure defaults for all configurations
REQUIRED: HTTPS: Use HTTPS in production environments for all communications
REQUIRED: CORS: Implement proper CORS configuration for web applications
REQUIRED: Guidelines: Follow OWASP security guidelines for web security
PREFERRED: Validation: Implement comprehensive input validation and sanitization

### Memory Integration Requirements
REQUIRED: Tool Preferences: Store UV (Python), Go modules, mise in AI memory
REQUIRED: Code Quality: Store Ruff (Python), golangci-lint (Go) configurations
REQUIRED: Build Tools: Store Docker multi-arch builds and Make targets
REQUIRED: Testing: Store pytest (Python), table-driven tests (Go) frameworks
REQUIRED: Environment: Store mise for tool version management
REQUIRED: Documentation: Store PlantUML for diagrams, markdown standards
REQUIRED: Logging: Store structured logging format requirements
REQUIRED: Debug: Store consistent prefix-based debug formatting
REQUIRED: Security: Store environment variable patterns, no hardcoded credentials
REQUIRED: Philosophy: Store fail-fast, comment preservation, stabilization testing

### Integration Patterns
REQUIRED: Single Responsibility: Use focused, single-responsibility scripts
REQUIRED: Common Libraries: Implement common library patterns for shared functionality
REQUIRED: Parameters: Use standardized parameter patterns across scripts
REQUIRED: Functions: Apply consistent function design principles
REQUIRED: Remote Execution: Use proper SSH and remote execution patterns
REQUIRED: Architecture: Store class-based (Python), clean architecture (Go) patterns