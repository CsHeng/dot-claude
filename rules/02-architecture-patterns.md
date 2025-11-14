---
file-type: rule
scope: architecture-patterns
---

# Architecture Patterns Directives

## scope
REQUIRED: Apply these architectural patterns to all software system designs across all programming languages and frameworks.

## absolute-prohibitions
PROHIBITED: Couple business logic to framework-specific code
PROHIBITED: Create circular dependencies between modules
PROHIBITED: Implement God objects or anti-patterns
PROHIBITED: Ignore SOLID principles in new code

## communication-protocol
REQUIRED: Apply interface-driven development with explicit dependency injection
REQUIRED: Prioritize composition over inheritance with small, focused interfaces
REQUIRED: Use clean architecture with clear separation of concerns

## structural-rules

### core-architectural-principles
REQUIRED: Encourage modular design for maintainability and reusability
REQUIRED: Keep business logic separate from framework-specific code
REQUIRED: Use interface-driven development with explicit dependency injection
REQUIRED: Prioritize composition over inheritance with small, focused interfaces
REQUIRED: Apply SOLID principles consistently
REQUIRED: Ensure compatibility with project's language/framework versions
REQUIRED: Use dependency injection for better testability
REQUIRED: Implement proper separation of concerns
REQUIRED: Structure code using layered approach: handlers → services → repositories → domain models
OPTIONAL: Apply domain-driven design principles for complex business logic
REQUIRED: Use constructor functions for dependency injection
REQUIRED: Create small, purpose-specific interfaces rather than large ones

### project-structure-patterns
REQUIRED: Use single application structure for simple projects:
```
myapp/
├── cmd/                   # Application entry points
├── internal/              # Private application code
│   ├── config/            # Configuration management
│   ├── handlers/          # Request/response handlers
│   ├── services/          # Business logic
│   ├── repositories/      # Data access layer
│   └── models/            # Domain models
├── pkg/                   # Public reusable packages
├── configs/               # Configuration files
└── tests/                 # Test utilities and integration tests
```

REQUIRED: Use multi-application structure for complex projects:
```
project/
├── cmd/
│   ├── api/               # API application
│   └── worker/            # Background worker
├── internal/
│   ├── shared/            # Shared components
│   │   ├── config/        # Common configuration
│   │   └── database/      # Database setup
│   ├── api/               # API-specific components
│   └── worker/            # Worker-specific components
├── pkg/                   # Shared public libraries
└── tests/                 # Integration tests
```

## language-rules

### python-project-structure
REQUIRED: Use single app structure:
```
app/                       # Single app structure
├── __init__.py           # Application factory
├── models/               # Database models
├── routes/               # Route blueprints
├── templates/            # Jinja2 templates
├── static/               # CSS, JS, images
└── utils/                # Helper functions
```

### flask-application
REQUIRED: Always use application factory pattern for Flask apps
REQUIRED: Structure: create_app(config_name=None) function in __init__.py
REQUIRED: Register blueprints, extensions, and error handlers within the factory
REQUIRED: Use current_app for accessing app instance in request context

### go-project-organization
REQUIRED: Use internal/ for private application code
REQUIRED: Use pkg/ for reusable public libraries
REQUIRED: Use import order: standard library → third-party → local packages
OPTIONAL: Place binaries in ./bin/ directory

## formatting-rules

### configuration-management
REQUIRED: Use environment variables for configuration management
REQUIRED: Define separate classes: DevelopmentConfig, ProductionConfig, TestingConfig
REQUIRED: Store sensitive data in environment variables
OPTIONAL: Use separate configuration files for different environments (dev, staging, prod)
REQUIRED: Use class-based configuration for better organization
REQUIRED: Implement validation for configuration values
OPTIONAL: Provide default values where appropriate
REQUIRED: Document all configuration options

### api-design-patterns
REQUIRED: Use consistent JSON response structure:
```json
{
    "code": 200,
    "message": "Success",
    "data": {...}
}
```
REQUIRED: Implement custom error handlers for each HTTP status code
REQUIRED: Use appropriate HTTP status codes
REQUIRED: Return consistent error response format
REQUIRED: Log errors appropriately with context
REQUIRED: Use middleware for authentication/authorization checks
REQUIRED: Implement proper request/response modification
REQUIRED: Handle cleanup operations (database sessions, etc.)

## naming-rules

### data-layer-patterns
REQUIRED: Abstract data access behind repository interfaces
REQUIRED: Implement specific repositories for different data sources
REQUIRED: Use dependency injection to provide repositories to services
REQUIRED: Handle database transactions at repository level
REQUIRED: Use appropriate ORM tools for the language/framework
REQUIRED: Define models in separate modules
REQUIRED: Handle database sessions properly with try/catch/finally
REQUIRED: Implement database migrations for schema changes
REQUIRED: Create schema classes for each model
REQUIRED: Use separate schemas for input validation and output serialization
REQUIRED: Implement comprehensive validation rules
REQUIRED: Sanitize and validate all external inputs

## validation-rules

### dependency-management
REQUIRED: Keep dependencies minimal and well-maintained
REQUIRED: Use version-locked dependencies
OPTIONAL: Prefer standard library over third-party packages when possible
REQUIRED: Document all external dependencies with versions
REQUIRED: Use dependency injection containers where appropriate
REQUIRED: Define clear interfaces between services
REQUIRED: Implement proper service lifecycle management
REQUIRED: Handle service failures gracefully

### performance-architecture
REQUIRED: Implement appropriate caching levels (application, database, CDN)
REQUIRED: Use cache invalidation strategies
REQUIRED: Monitor cache hit rates and performance
OPTIONAL: Consider distributed caching for multi-instance deployments
REQUIRED: Implement connection pooling
REQUIRED: Use database indexes effectively
REQUIRED: Optimize queries to prevent N+1 problems
OPTIONAL: Consider read replicas for read-heavy applications
OPTIONAL: Design for horizontal scaling where possible
OPTIONAL: Implement load balancing strategies
OPTIONAL: Use message queues for async processing
OPTIONAL: Consider microservices architecture for large applications

### security-architecture
REQUIRED: Implement secure authentication mechanisms
REQUIRED: Use role-based access control (RBAC)
REQUIRED: Secure session management
REQUIRED: Implement proper logout and session invalidation
REQUIRED: Encrypt sensitive data at rest and in transit
REQUIRED: Implement proper input validation and sanitization
REQUIRED: Use secure defaults for all configurations
REQUIRED: Follow principle of least privilege
REQUIRED: Implement rate limiting
REQUIRED: Use CORS properly
REQUIRED: Validate all inputs
REQUIRED: Implement audit logging for security events