# Go Development Directives

## Scope
REQUIRED: Apply these standards to all Go development activities, including application code, libraries, CLI tools, and system services.

## Absolute Prohibitions
PROHIBITED: Use Go versions below 1.21 for new projects
PROHIBITED: Ignore compilation errors or warnings without proper justification
PROHIBITED: Hardcode secrets or configuration values in source code
PROHIBITED: Use panic for error handling in production code
PROHIBITED: Create circular dependencies between packages
PROHIBITED: Ignore returned errors without explicit handling

## Communication Protocol
REQUIRED: Follow Go idioms and conventions from language specification
REQUIRED: Use clear, concise function and variable names
REQUIRED: Handle errors explicitly and provide meaningful context
PROHIBITED: Use abbreviations except universally understood ones (`url`, `id`, `api`)

## Structural Rules
### Architecture
REQUIRED: Apply Clean Architecture with clear separation of concerns
REQUIRED: Use interface-driven development with explicit dependency injection
REQUIRED: Prioritize composition over inheritance with small, focused interfaces
REQUIRED: Use constructor functions for dependency injection
REQUIRED: Keep business logic separate from framework-specific code
PREFERRED: Create domain models that are independent of external dependencies

### Project Structure
REQUIRED: Use standard Go project layout with clear directory separation:
PREFERRED: `cmd/` for application entry points
REQUIRED: `internal/` for private application code
PREFERRED: `pkg/` for public reusable packages
PREFERRED: `configs/` for configuration files
PREFERRED: `tests/` for test utilities and integration tests
REQUIRED: Organize imports: Standard library → third-party → local packages
PREFERRED: Place built binaries in `./bin/` directory

### Code Quality
REQUIRED: Write short, focused functions with single responsibility
REQUIRED: Handle all errors explicitly using wrapped errors
REQUIRED: Use `context.Context` for request-scoped values and cancellations
REQUIRED: Guard shared state with channels or sync primitives
REQUIRED: Always defer resource cleanup and handle potential errors
PROHIBITED: Write functions that are longer than 20-30 lines without clear justification

## Language Rules
### Error Handling
REQUIRED: Return errors explicitly, never ignore them
REQUIRED: Use custom error types for domain-specific errors
REQUIRED: Wrap errors with context using `fmt.Errorf("operation failed: %w", err)`
PROHIBITED: Use panic in production code except for unrecoverable conditions
REQUIRED: Include relevant context in error messages
PREFERRED: Implement error types that support error inspection and comparison

### Concurrency
REQUIRED: Use goroutines safely with proper synchronization
REQUIRED: Implement context-based cancellation to prevent goroutine leaks
REQUIRED: Use channels for communication between goroutines
PREFERRED: Use sync primitives (mutex, waitgroup) for low-level synchronization
PROHIBITED: Share mutable data between goroutines without proper synchronization
REQUIRED: Always handle potential race conditions in concurrent code

### Security
REQUIRED: Validate and sanitize all external inputs rigorously
REQUIRED: Use secure defaults for JWT tokens, cookies, and configuration
REQUIRED: Implement retries, exponential backoff, and timeouts for external calls
REQUIRED: Apply circuit breakers and rate limiting for service protection
PROHIBITED: Hardcode secrets in source code
REQUIRED: Use environment variables or secure vaults for sensitive configuration

## Formatting Rules
### Documentation
REQUIRED: Write GoDoc-style comments for all public functions and packages
REQUIRED: Include usage examples in package documentation
REQUIRED: Use consistent naming conventions following Go standards
REQUIRED: Format code with `go fmt`, `goimports`, and `golangci-lint`
PROHIBITED: Write comments that simply restate what obvious code does

### Observability
PREFERRED: Use OpenTelemetry for distributed tracing, metrics, and structured logging
REQUIRED: Propagate `context.Context` across all service boundaries
PREFERRED: Use structured JSON logging with appropriate levels
PREFERRED: Include trace IDs and request IDs in all log entries
REQUIRED: Implement proper health check endpoints for services

### Performance
REQUIRED: Profile before optimizing; avoid premature optimization
PREFERRED: Use benchmarks to track performance regressions
REQUIRED: Consider memory allocation patterns in performance-critical code
PREFERRED: Use sync.Pool for object reuse in performance-critical paths
PROHIBITED: Optimize code without proper performance measurements

## Naming Rules
### Development Workflow
REQUIRED: Use `go run` instead of `go build` for development
REQUIRED: Use `CGO_ENABLED=0` for static builds in production
REQUIRED: Integrate linting, testing, and security checks in CI/CD
PREFERRED: Use `make lint` and `make fmt` for Go projects
PREFERRED: Use `make all` workflow: clean, deps, fmt, lint, test, build

## Validation Rules
### Go Version and Tooling
REQUIRED: Use Go 1.21+ for new projects (1.23+ preferred)
REQUIRED: Use Go modules with version-locked dependencies
REQUIRED: Use `golangci-lint` for comprehensive linting
PREFERRED: Prefer standard library over third-party packages when possible
REQUIRED: Keep dependencies minimal and well-maintained

### Technology Stack
PREFERRED: Use Gin for HTTP APIs (speed and simplicity)
PREFERRED: Use PostgreSQL with GORM ORM for database operations
PREFERRED: Use Viper with YAML files for configuration
PREFERRED: Use golang-jwt/jwt for JWT token handling
PREFERRED: Use Redis for sessions and caching
PREFERRED: Use structured logging with zap

### Testing
REQUIRED: Write tests when code stabilizes and is production-ready
PREFERRED: Use table-driven tests for multiple test cases
REQUIRED: Focus on integration tests for database and API endpoints
REQUIRED: Ensure test coverage for all exported functions
REQUIRED: Test error handling paths and edge cases
PROHIBITED: Write tests that depend on external services without proper mocking

### Tool Requirements
REQUIRED: Package Management: Go modules with go.mod
REQUIRED: Code Quality: golangci-lint for comprehensive linting
REQUIRED: Formatting: go fmt and goimports
REQUIRED: Building: `go run` for development, static builds for production
REQUIRED: Testing: Built-in testing with table-driven patterns
REQUIRED: Configuration: Viper with YAML files
REQUIRED: Environment Management: mise for Go and tool versions