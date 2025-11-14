# Code Quality and Standards Directives

## Scope
REQUIRED: Apply these standards to maintain high code quality across all projects and programming languages.

## Absolute Prohibitions
PROHIBITED: Commit code that fails automated quality checks
PROHIBITED: Ignore security vulnerability findings without remediation
PROHIBITED: Bypass code review processes for any changes
PROHIBITED: Merge code with known critical quality issues
PROHIBITED: Disable quality gates in CI/CD pipelines without justification

## Communication Protocol
REQUIRED: Use consistent code quality standards across all team members
REQUIRED: Document all quality-related decisions and exceptions
REQUIRED: Provide clear rationale for quality standard deviations
PROHIBITED: Use subjective quality assessments without objective criteria

## Structural Rules
### Quality Gates
REQUIRED: Implement automated quality checks in CI/CD pipelines
REQUIRED: Define minimum quality thresholds for code coverage and complexity
REQUIRED: Enforce security scanning for all code changes
REQUIRED: Require code review approval for all changes
PREFERRED: Use quality metrics to guide code improvement efforts

### Code Review Standards
REQUIRED: Review all code changes before merging
REQUIRED: Use standardized review checklist for consistency
REQUIRED: Document review findings and required actions
REQUIRED: Ensure reviewers have appropriate domain expertise
PREFERRED: Use automated tools to supplement manual review process

## Language Rules
### Code Quality Principles
REQUIRED: Consistency: All code follows consistent style and formatting
REQUIRED: Readability: Code is self-documenting and easy to understand
REQUIRED: Maintainability: Code is easy to modify and extend
REQUIRED: Testability: Code is structured to enable effective testing

### Language-Specific Standards

#### Python Quality Standards
REQUIRED: Use Ruff for comprehensive code analysis and formatting
REQUIRED: Configure strict rule sets for security, complexity, and style
REQUIRED: Maintain minimum 80% test coverage for critical paths
REQUIRED: Use type hints for all function parameters and return values
PREFERRED: Enable all available Ruff rules for maximum code quality

#### Go Quality Standards
REQUIRED: Use golangci-lint with comprehensive rule configuration
REQUIRED: Enforce strict error handling and resource management
REQUIRED: Maintain minimum test coverage for all exported functions
REQUIRED: Use go fmt and goimports for consistent code formatting
PREFERRED: Enable additional linters for security and performance

## Formatting Rules
### Linting Configuration
REQUIRED: Configure linting tools with project-specific rules
REQUIRED: Store linting configurations in version control
REQUIRED: Use consistent linting settings across development environments
REQUIRED: Update linting rules regularly to incorporate best practices
PREFERRED: Use linting tools with auto-fix capabilities

### Code Style Enforcement
REQUIRED: Use automated formatting tools for all code
REQUIRED: Configure IDE integration for real-time quality feedback
REQUIRED: Enforce consistent naming conventions and patterns
REQUIRED: Validate code style in pre-commit hooks
PREFERRED: Use tools that integrate with popular IDEs and editors

## Naming Rules
### Quality Metrics
REQUIRED: Track cyclomatic complexity with maximum threshold of 15
REQUIRED: Monitor function length with maximum of 50 lines
REQUIRED: Maintain file length under 500 lines when possible
REQUIRED: Limit nesting depth to maximum 4 levels
PREFERRED: Use automated tools to measure and track quality metrics

### Performance Standards
REQUIRED: Profile code before making performance optimizations
REQUIRED: Use appropriate data structures for the problem domain
REQUIRED: Implement proper resource cleanup and management
REQUIRED: Consider memory usage and computational complexity
PROHIBITED: Optimize code without proper performance measurements

## Validation Rules
### Automated Quality Checks
REQUIRED: Integrate quality checks in all CI/CD pipelines
REQUIRED: Fail builds when quality thresholds are not met
REQUIRED: Generate quality reports for tracking and improvement
REQUIRED: Scan dependencies for known security vulnerabilities
PREFERRED: Use quality gates to prevent regression

### Security Standards
REQUIRED: Zero tolerance for high-severity security vulnerabilities
REQUIRED: Regular dependency scanning and vulnerability assessment
REQUIRED: Input validation coverage of 100% for external inputs
REQUIRED: Secure defaults for all configuration options
PROHIBITED: Store secrets or credentials in source code

### Testing Requirements
REQUIRED: Minimum 80% line coverage for all code
REQUIRED: 95% coverage for critical business logic paths
REQUIRED: Comprehensive integration tests for major workflows
REQUIRED: Edge case testing for all error conditions
PREFERRED: Behavior-focused testing over implementation testing

### Documentation Requirements
REQUIRED: Public APIs must have comprehensive documentation
REQUIRED: Complex algorithms require clear explanatory comments
REQUIRED: Configuration options must be documented with examples
REQUIRED: Dependencies must be documented with version requirements
PREFERRED: Include usage examples in all documentation

### Tool Requirements
REQUIRED: Quality Tools: Ruff (Python), golangci-lint (Go)
REQUIRED: Security Scanning: Automated vulnerability scanning
REQUIRED: Testing: pytest (Python), built-in testing (Go)
REQUIRED: Coverage: Minimum thresholds enforced in CI/CD
REQUIRED: Code Review: Mandatory review process for all changes