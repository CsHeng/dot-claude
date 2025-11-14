---
file-type: skill
skill: language-go
description: Go language patterns and best practices
implementation: skills/language-go/SKILL.md
scope: Included
allowed-tools:
  - Bash(go version)
  - Bash(golangci-lint)
related-skills:
  - skill:environment-validation
  - skill:development-standards
  - skill:testing-strategy
---

# Go Architecture Standards

## Module Structure and Organization

### Project Layout Requirements

Execute standard Go project structure:
```
project/
├── cmd/
│   └── application/
│       └── main.go
├── internal/
│   ├── domain/
│   ├── infrastructure/
│   └── application/
├── pkg/
│   └── public-apis/
├── api/
│   └── protobuf/
├── go.mod
├── go.sum
└── README.md
```

Package organization principles:
- Use `internal/` for code not intended for external use
- Organize packages by feature, not technical layer
- Keep packages focused with single responsibility
- Apply clear package naming conventions

### Dependency Management

Execute clean dependency graph maintenance:
- Keep dependencies minimal and well-maintained
- Use semantic versioning for dependency constraints
- Regularly update dependencies for security patches
- Implement dependency injection for testability

Module best practices:
- Pin specific versions in go.mod
- Use `go mod tidy` to maintain clean dependencies
- Implement vendor directory management for reproducible builds
- Document dependency decisions in go.mod comments

## Error Handling Patterns

### Explicit Error Handling

Execute Go error handling conventions:
- Always handle returned errors explicitly
- Use multiple return values for error information
- Implement proper error wrapping with context
- Create descriptive error messages with context

Error wrapping implementation:
```go
// Use fmt.Errorf with %w for error wrapping
if err := validateInput(data); err != nil {
    return fmt.Errorf("input validation failed: %w", err)
}

// Create custom error types for domain errors
type BusinessError struct {
    Code    string
    Message string
    Cause   error
}

func (e BusinessError) Error() string {
    return fmt.Sprintf("business error [%s]: %s", e.Code, e.Message)
}
```

### Error Interface Implementation

Execute proper error interface implementation:
- Use `errors.Is()` for error type checking
- Use `errors.As()` for error type assertion
- Create sentinel errors for expected conditions
- Implement temporary and timeout error interfaces

Interface compliance examples:
```go
// Implement temporary interface for retryable errors
func (e NetworkError) Temporary() bool {
    return true
}

// Implement timeout interface for deadline errors
func (e TimeoutError) Timeout() bool {
    return true
}
```

## Code Quality Standards

### Go Formatting and Style

Execute consistent formatting standards:
- Use `gofmt` for all code formatting
- Implement `goimports` for import management
- Use `golint` for style guidance
- Apply `golangci-lint` for comprehensive analysis

Naming conventions:
- Use CamelCase for exported names
- Use camelCase for unexported names
- Use short, descriptive names in local scope
- Use meaningful names for exported APIs

### Static Analysis Implementation

Execute golangci-lint integration in development:
- Configure comprehensive rule set
- Run analysis in CI/CD pipeline
- Fix all high-severity issues
- Document rule exceptions with justification

Linting configuration:
```yaml
# .golangci.yml
linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - unused
    - gosimple
    - structcheck
    - varcheck
    - ineffassign
    - deadcode
```

## Build and Deployment Standards

### Build Configuration

Execute standardized build process:
- Set minimum Go version to 1.23
- Use `CGO_ENABLED=0` for static binaries
- Implement cross-compilation for multiple targets
- Use build flags for version information

Build script implementation:
```bash
#!/bin/bash
set -euo pipefail

# Build configuration
VERSION=${VERSION:-$(git describe --tags --always --dirty)}
LDFLAGS="-ldflags=-X main.Version=${VERSION} -X main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Build for multiple architectures
GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o bin/app-linux-amd64 cmd/app/main.go
GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o bin/app-darwin-amd64 cmd/app/main.go
```

### Testing Implementation

Execute comprehensive testing strategy:
- Implement table-driven tests for data-driven scenarios
- Use benchmark tests for performance-critical code
- Apply race condition testing with `-race` flag
- Maintain 80%+ code coverage

Testing patterns:
```go
func TestProcessInput(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    string
        wantErr bool
    }{
        {
            name:    "valid input",
            input:   "test",
            want:    "processed: test",
            wantErr: false,
        },
        {
            name:    "empty input",
            input:   "",
            want:    "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := processInput(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("processInput() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("processInput() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## Performance and Concurrency

### Goroutine Management

Execute proper goroutine pattern implementation:
- Use worker pools for managing concurrent tasks
- Implement graceful shutdown with context cancellation
- Avoid goroutine leaks by proper cleanup
- Use buffered channels for communication

Concurrency patterns:
```go
// Worker pool implementation
type Worker struct {
    id   int
    jobs <-chan Job
    results chan<- Result
}

func (w Worker) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case job := <-w.jobs:
                result := processJob(job)
                w.results <- result
            case <-ctx.Done():
                return
            }
        }
    }()
}
```

### Resource Management

Execute efficient resource usage implementation:
- Use sync.Pool for object reuse
- Implement proper connection pooling
- Apply memory profiling to identify leaks
- Use context for timeout and cancellation

Memory optimization techniques:
- Pre-allocate slices when size is known
- Use strings.Builder for efficient string concatenation
- Implement streaming for large data processing
- Avoid memory allocations in hot paths

## Security Implementation

### Secure Coding Practices

Execute Go security best practices:
- Validate all external inputs at boundaries
- Use constant-time comparison for sensitive data
- Implement proper random number generation
- Apply secure default configurations

Security validation examples:
```go
import (
    "crypto/subtle"
    "golang.org/x/crypto/bcrypt"
)

// Constant-time comparison for sensitive data
func secureCompare(a, b []byte) bool {
    return subtle.ConstantTimeCompare(a, b) == 1
}

// Secure password hashing
func hashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    return string(bytes), err
}
```

### Dependency Security

Execute secure dependency maintenance:
- Regularly scan for known vulnerabilities
- Use tools like `govulncheck` for security analysis
- Update dependencies with security patches promptly
- Document security decisions and trade-offs