---
# Cursor Rules
globs: **/*.go

# Copilot Instructions
applyTo: "**/*.go"

# Kiro Steering
inclusion: fileMatch
fileMatchPattern: '**/*.go'
---

# Go Development Guidelines

## Core Go Standards
- Go Version: Use Go 1.21+ for new projects (1.23+ preferred)
- Modules: Use Go modules with version-locked dependencies
- Build Targets: Use `CGO_ENABLED=0` for static builds
- Development: Use `go run` instead of `go build` for development
- Code Style: Use `go fmt` and `goimports` for code formatting
- Linting: Use `golangci-lint` for comprehensive linting

## Architecture Patterns
- Clean Architecture: Apply Clean Architecture with clear separation of concerns
- Interface-Driven: Use interface-driven development with explicit dependency injection
- Composition: Prioritize composition over inheritance with small, focused interfaces
- Domain Models: Use constructor functions for dependency injection, avoid global state
- Business Logic: Keep business logic separate from framework-specific code

## Project Structure
- Standard Layout:
  - `cmd/` - Application entry points
  - `internal/` - Private application code
  - `pkg/` - Public reusable packages
  - `configs/` - Configuration files
  - `tests/` - Test utilities and integration tests
- **Import Order**: Standard library → third-party → local packages
- **Binaries**: Place binaries in `./bin/` directory

## Code Quality Standards
- Function Design: Write short, focused functions with single responsibility
- Error Handling: Handle all errors explicitly using wrapped errors
- Context Usage: Use `context.Context` for request-scoped values and cancellations
- Concurrency: Guard shared state with channels or sync primitives
- Resource Management: Always defer resource cleanup and handle potential errors

## Error Handling Patterns
- Explicit Errors: Return errors explicitly, never ignore them
- Custom Errors: Use custom error types for domain-specific errors
- Error Wrapping: Wrap errors with context using `fmt.Errorf("operation failed: %w", err)`
- No Panic: Avoid panic in production code
- Context: Include relevant context in error messages

## Security Requirements
- Input Validation: Validate and sanitize all external inputs rigorously
- Secure Defaults: Use secure defaults for JWT tokens, cookies, and configuration
- External Calls: Implement retries, exponential backoff, and timeouts
- Service Protection: Apply circuit breakers and rate limiting for service protection
- Secrets: Never hardcode secrets; use environment variables or secure vaults

## Documentation Standards
- GoDoc Comments: Write GoDoc-style comments for all public functions and packages
- Usage Examples: Include usage examples in package documentation
- Naming: Use consistent naming conventions following Go standards
- Formatting: Format code with `go fmt`, `goimports`, and `golangci-lint`

## Observability
- OpenTelemetry: Use OpenTelemetry for distributed tracing, metrics, and structured logging
- Context Propagation: Propagate `context.Context` across all service boundaries
- Structured Logging: Use structured JSON logging with appropriate levels
- Trace Correlation: Include trace IDs and request IDs in all log entries

## Performance & Concurrency
- Goroutine Safety: Use goroutines safely with proper synchronization
- Context Cancellation: Implement context-based cancellation to prevent goroutine leaks
- Profiling: Profile before optimizing; avoid premature optimization
- Benchmarks: Use benchmarks to track performance regressions

## Dependency Management
- Standard Library: Prefer standard library over third-party packages when possible
- Version Locking: Use Go modules with version-locked dependencies
- Minimal Dependencies: Keep dependencies minimal and well-maintained
- CI/CD Integration: Integrate linting, testing, and security checks in CI/CD

## Technology Stack Preferences
- Go Version: Use Go 1.21+ for new projects
- Web Framework: Gin for HTTP APIs (speed and simplicity)
- Database: PostgreSQL with GORM ORM
- Configuration: Viper with YAML files
- Authentication: golang-jwt/jwt for JWT tokens
- Caching: Redis for sessions and caching
- Logging: Structured logging with zap

## Testing Approach
- Testing Timing: Write tests when code stabilizes and is production-ready
- Test Patterns: Use table-driven tests for multiple test cases
- Integration Testing: Focus on integration tests for database and API endpoints
- Coverage: Ensure test coverage for all exported functions
- Error Testing: Test error handling paths and edge cases

## Build and Development
- Development Command: Use `go run` instead of `go build` for development
- Static Builds: Use `CGO_ENABLED=0` for static builds
- Linting Tools: Managed by mise:
  - `golangci-lint`: Comprehensive linter suite
  - `goimports`: Auto-format and organize imports
  - `go vet`: Built-in static analysis
  - `staticcheck`: Advanced static analysis
- Make Commands: Use `make lint` and `make fmt` for Go projects
- Development Workflow: `make all` runs clean, deps, fmt, lint, test, build

## Tool Preferences
- Package Management: Go modules with go.mod
- Code Quality: golangci-lint for comprehensive linting
- Formatting: go fmt and goimports
- Building: `go run` for development, static builds for production
- Testing: Built-in testing with table-driven patterns
- Configuration: Viper with YAML files
- Environment Management: mise for Go and tool versions