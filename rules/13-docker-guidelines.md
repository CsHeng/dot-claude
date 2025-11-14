# Docker and Containerization Directives

## Scope
REQUIRED: Apply these standards to all containerization activities, including Dockerfile creation, Docker Compose configurations, multi-architecture builds, and container orchestration.

## Absolute Prohibitions
PROHIBITED: Use `latest` tags in production environments
PROHIBITED: Include version field in docker-compose.yml files
PROHIBITED: Hardcode secrets or credentials in container images
PROHIBITED: Run containers as root user without justification
PROHIBITED: Ignore security scanning results for images
PROHIBITED: Use host.docker.internal for critical network access

## Communication Protocol
REQUIRED: Use clear, descriptive service and image names
REQUIRED: Document container purpose and dependencies
REQUIRED: Provide clear build and deployment instructions
PROHIBITED: Use abbreviations except universally understood ones (`url`, `id`, `api`)

## Structural Rules
### Build Optimization
REQUIRED: Use Go build environment variables for static compilation:
REQUIRED: Set `CGO_ENABLED=0` to disable CGO for static binaries
REQUIRED: Set `GOOS=${TARGETOS}` for target operating system
REQUIRED: Set `GOARCH=${TARGETARCH}` for target architecture
REQUIRED: Set `GOGC=off` to disable GC during compilation
REQUIRED: Set `GOMAXPROCS=1` for single-core compilation efficiency

### Linker Flags
REQUIRED: Use standard optimization flags: `go build -ldflags="-w -s -extldflags=-static"`
REQUIRED: Apply `-w` to remove DWARF debug info (30-50% size reduction)
REQUIRED: Apply `-s` to remove symbol table (10-20% size reduction)
REQUIRED: Apply `-extldflags=-static` to generate static binary

### Multi-Architecture Naming
REQUIRED: Use strict naming pattern for multi-architecture images:
PREFERRED: `<app-name>:amd64` for AMD64 architecture
PREFERRED: `<app-name>:arm64` for ARM64 architecture
PREFERRED: `<app-name>:latest` for development (current arch)
PREFERRED: `<app-name>-slim:amd64` for optimized AMD64
PREFERRED: `<app-name>-slim:arm64` for optimized ARM64
PREFERRED: `<app-name>-slim:latest` for development optimized

## Language Rules
### Dockerfile Standards
REQUIRED: Use multi-stage build for Go applications
REQUIRED: Create non-root user with appropriate permissions
REQUIRED: Set working directory using WORKDIR instruction
REQUIRED: Include HEALTHCHECK instruction for monitoring
REQUIRED: Use specific version tags, never 'latest' in production
PROHIBITED: Include build tools or development dependencies in final image

### Docker Compose Standards
REQUIRED: Use explicit service dependencies with `depends_on`
REQUIRED: Define health checks for critical services
REQUIRED: Use named volumes for persistent data storage
REQUIRED: Set resource limits for production services
PROHIBITED: Include `version:` field in docker-compose.yml files
REQUIRED: Use `172.17.0.1` for host network access from containers
PROHIBITED: Use `host.docker.internal` for critical network access

### Network Configuration
REQUIRED: Create custom bridge networks with specific subnets
REQUIRED: Use internal networks for backend services
REQUIRED: Configure proper service startup ordering
REQUIRED: Implement rolling update strategies for production
PREFERRED: Use network isolation for security boundaries
PROHIBITED: Expose unnecessary ports to external networks

## Formatting Rules
### Security
REQUIRED: Use specific version tags for reproducible builds
REQUIRED: Create non-root user with minimal privileges
REQUIRED: Set appropriate file permissions for sensitive data
REQUIRED: Implement proper secret management strategies
REQUIRED: Scan images for security vulnerabilities
PROHIBITED: Store secrets in environment variables or image layers

### Optimization
REQUIRED: Use multi-stage builds for smaller final images
REQUIRED: Use .dockerignore to exclude unnecessary files
REQUIRED: Order Dockerfile instructions for optimal layer caching
PREFERRED: Use alpine-based images where appropriate for size
REQUIRED: Minimize attack surface by removing unnecessary packages
PROHIBITED: Include debugging tools in production images

### Environment Configuration
PREFERRED: Use Dockerfile.production for production-optimized builds
PREFERRED: Use Dockerfile.development for development with debugging tools
PREFERRED: Use Dockerfile.test for test environment with testing tools
REQUIRED: Maintain consistency between environment-specific Dockerfiles
PROHIBITED: Use development configurations in production deployments

## Naming Rules
### Service Dependencies
REQUIRED: Use explicit dependencies with conditions in docker-compose
REQUIRED: Implement comprehensive health checks for service readiness
REQUIRED: Configure proper startup ordering between services
REQUIRED: Set appropriate resource limits and reservations
PREFERRED: Use descriptive service names indicating purpose
PROHIBITED: Create circular dependencies between services

### Resource Management
REQUIRED: Set CPU and memory limits for production services
REQUIRED: Reserve minimum resources for critical services
REQUIRED: Use appropriate restart policies (unless-stopped)
REQUIRED: Configure scaling policies for horizontal scaling
PREFERRED: Monitor resource usage and adjust limits accordingly
PROHIBITED: Allow services to consume unlimited resources

## Validation Rules
### Development Workflow
REQUIRED: Create .env file from template for local development
REQUIRED: Build and start all services using docker-compose
REQUIRED: Wait for services to be ready before running tests
REQUIRED: Run database migrations and load test data automatically
PREFERRED: Use docker-compose for local development environment
PROHIBITED: Commit .env files with sensitive configuration

### Production Deployment
REQUIRED: Build multi-architecture images for production environments
REQUIRED: Use rolling updates with proper health checks
REQUIRED: Use environment-specific configuration files
REQUIRED: Include comprehensive monitoring and logging
PROHIBITED: Deploy images without security scanning
REQUIRED: Test deployment process in staging environment first

### Monitoring
REQUIRED: Use structured JSON logging for log aggregation
REQUIRED: Configure log rotation to prevent disk space issues
REQUIRED: Forward logs to centralized logging system
REQUIRED: Use appropriate log levels (INFO, WARN, ERROR)
PREFERRED: Include trace IDs and request IDs in all log entries
PROHIBITED: Log sensitive information or credentials

### Health Checks
REQUIRED: Implement application-specific health check endpoints
REQUIRED: Check database connectivity and query performance
REQUIRED: Monitor dependencies and external service connectivity
REQUIRED: Track resource usage (memory, CPU, disk)
PREFERRED: Include readiness and liveness probes for Kubernetes
PROHIBITED: Use health checks that are too slow or resource-intensive

### Tool Requirements
REQUIRED: Build Tools: Docker buildx for multi-architecture builds
REQUIRED: Orchestration: Docker Compose for local development
REQUIRED: Registry: Use container registry for image management
REQUIRED: Scanning: Use security scanning tools for vulnerability detection
PREFERRED: Monitoring: Use Prometheus and Grafana for monitoring
REQUIRED: Testing: Test containers in isolated environments