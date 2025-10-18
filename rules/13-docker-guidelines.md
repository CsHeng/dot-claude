---
# Cursor Rules
globs: /docker-compose*.yml,/Dockerfile*,/*.sh,/Makefile*

# Copilot Instructions
applyTo: "/docker-compose*.yml,/Dockerfile*,/*.sh,/Makefile*"

# Kiro Steering
inclusion: fileMatch
fileMatchPattern: ['/docker-compose*.yml', '/Dockerfile*', '/*.sh', '/Makefile*']
---

# Docker and Containerization Guidelines

## Build Optimization Standards

### Go Build Environment Variables (Required)
- Required environment variables for Go builds:
  - `CGO_ENABLED=0` - Disable CGO for static binaries
  - `GOOS=${TARGETOS}` - Target operating system
  - `GOARCH=${TARGETARCH}` - Target architecture
  - `GOGC=off` - Disable GC during compilation
  - `GOMAXPROCS=1` - Single-core compilation

### Required Linker Flags
- Standard optimization flags: `go build -ldflags="-w -s -extldflags=-static"`
- Breakdown:
  - `-w`: Remove DWARF debug info (30-50% size reduction)
  - `-s`: Remove symbol table (10-20% size reduction)
  - `-extldflags=-static`: Generate static binary

### Additional Build Optimization
- Full build command:
  ```bash
  go build -a -installsuffix cgo \
      -gcflags="-trimpath" \
      -asmflags="-trimpath" \
      -ldflags="-w -s -extldflags=-static"
  ```
- Explanation:
  - `-a`: Force package recompilation
  - `-installsuffix cgo`: Avoid CGO conflicts
  - `-trimpath`: Remove source paths from output

## Multi-Architecture Build Strategy

### Image Naming Convention
- Strict naming pattern for multi-architecture images:
  - `<app-name>:amd64` - AMD64 architecture
  - `<app-name>:arm64` - ARM64 architecture
  - `<app-name>:latest` - Development (current arch)
  - `<app-name>-slim:amd64` - Optimized AMD64
  - `<app-name>-slim:arm64` - Optimized ARM64
  - `<app-name>-slim:latest` - Development optimized

### Multi-Stage Dockerfile
- Multi-stage build for Go applications:
  ```dockerfile
  FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder
  ARG TARGETPLATFORM BUILDPLATFORM TARGETOS TARGETARCH
  ENV CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOGC=off GOMAXPROCS=1
  ```

## Docker Compose Standards

### Critical Requirements
- NEVER include `version:` field in docker-compose.yml files
- Use `172.17.0.1` for host network access from containers
- AVOID `host.docker.internal` (unreliable in some environments)

### Best Practices
- Use explicit service dependencies with `depends_on`
- Define health checks for critical services
- Use named volumes for persistent data
- Set resource limits for production services

## Best Practices

### Security Standards
- Use specific version tags: Never use 'latest' in production
- Create non-root user: Add user and group with appropriate permissions
- Set working directory: Use WORKDIR instruction
- Set health check: Include HEALTHCHECK instruction
- Expose port: Use EXPOSE instruction appropriately

### Optimization Patterns
- Multi-stage for smaller images: Separate build and runtime stages
- Use .dockerignore: Exclude unnecessary files from build context
- Leverage layer caching: Order Dockerfile instructions for optimal caching
- Minimize image size: Use alpine-based images where appropriate

### Environment-Specific Configurations
- Dockerfile.production: Production-optimized build
- Dockerfile.development: Development build with debugging tools
- Dockerfile.test: Test environment with testing tools

## Network Configuration

### Custom Networks
- Create custom networks: Use bridge networks with specific subnets
- Network isolation: Use internal networks for backend services
- Host access: Use 172.17.0.1 for reliable host access

### Service Dependencies
- Explicit dependencies: Use depends_on with service conditions
- Health checks: Implement proper health checks for service readiness
- Startup ordering: Configure proper service startup order

## Orchestration Patterns

### Service Dependencies
- Dependency management: Use depends_on with conditions
- Health checks: All services must include appropriate health checks
- Startup ordering: Configure proper service startup order
- Resource management: Set appropriate resource limits and reservations

### Resource Management
- Resource limits: Set CPU and memory limits for production
- Resource reservations: Reserve minimum resources for services
- Restart policies: Use appropriate restart policies (unless-stopped)
- Update strategies: Configure rolling update strategies

## Development Workflow

### Local Development Setup
- Environment file: Create .env file from template
- Service startup: Build and start all services with docker-compose
- Health checks: Wait for services to be ready before running tests
- Database setup: Run migrations and load test data automatically

### Production Deployment
- Image building: Build multi-architecture images for production
- Service updates: Use rolling updates with health checks
- Configuration: Use environment-specific configuration files
- Monitoring: Include comprehensive health checks and monitoring

## Monitoring and Logging

### Logging Configuration
- Structured logging: Use JSON format for log aggregation
- Log rotation: Configure log rotation to prevent disk space issues
- Centralized logging: Forward logs to centralized logging system
- Log levels: Use appropriate log levels (INFO, WARN, ERROR)

### Health Check Patterns
- Application health: Implement application-specific health check endpoints
- Database health: Check database connectivity and query performance
- Service dependencies: Health checks for external service dependencies
- Resource monitoring: Monitor memory, CPU, and disk usage

## Tool Preferences
- Build Tools: Docker buildx for multi-architecture builds
- Orchestration: Docker Compose for local development
- Registry: Use container registry for image management
- Scanning: Use security scanning tools for image vulnerability detection
- Monitoring: Use Prometheus and Grafana for monitoring containerized applications