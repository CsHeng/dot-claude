---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# Architecture Patterns and Design Principles

## Core Architectural Principles

### Modular Design
- Encourage modular design for maintainability and reusability
- Keep business logic separate from framework-specific code
- Use interface-driven development with explicit dependency injection
- Prioritize composition over inheritance with small, focused interfaces

### Separation of Concerns
- Apply SOLID principles consistently
- Ensure compatibility with project's language/framework versions
- Use dependency injection for better testability
- Implement proper separation of concerns

### Clean Architecture Patterns
- Structure code using layered approach: handlers → services → repositories → domain models
- Apply domain-driven design principles for complex business logic
- Use constructor functions for dependency injection, avoid global state
- Create small, purpose-specific interfaces rather than large ones

## Project Structure Patterns

### Single Application Structure
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

### Multi-Application Structure
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

## Language-Specific Patterns

### Python Project Structure
```
app/                       # Single app structure
├── __init__.py           # Application factory
├── models/               # Database models
├── routes/               # Route blueprints
├── templates/            # Jinja2 templates
├── static/               # CSS, JS, images
└── utils/                # Helper functions
```

### Flask Application Factory
- Always use application factory pattern for Flask apps
- Structure: `create_app(config_name=None)` function in `__init__.py`
- Register blueprints, extensions, and error handlers within the factory
- Use `current_app` for accessing app instance in request context

### Go Project Organization
- Use `internal/` for private application code
- Use `pkg/` for reusable public libraries
- Import order: standard library → third-party → local packages
- Place binaries in `./bin/` directory

## Configuration Management

### Environment-Based Configuration
- Use environment variables for configuration management
- Define separate classes: `DevelopmentConfig`, `ProductionConfig`, `TestingConfig`
- Store sensitive data in environment variables
- Use separate configuration files for different environments (dev, staging, prod)

### Configuration Classes
- Use class-based configuration for better organization
- Implement validation for configuration values
- Provide default values where appropriate
- Document all configuration options

## API Design Patterns

### RESTful API Structure
- Use consistent JSON response structure:
```json
{
    "code": 200,
    "message": "Success",
    "data": {...}
}
```

### Error Handling in APIs
- Implement custom error handlers for each HTTP status code
- Use appropriate HTTP status codes
- Return consistent error response format
- Log errors appropriately with context

### Request Lifecycle Management
- Use middleware for authentication/authorization checks
- Implement proper request/response modification
- Handle cleanup operations (database sessions, etc.)

## Data Layer Patterns

### Repository Pattern
- Abstract data access behind repository interfaces
- Implement specific repositories for different data sources
- Use dependency injection to provide repositories to services
- Handle database transactions at repository level

### ORM Integration
- Use appropriate ORM tools for the language/framework
- Define models in separate modules
- Handle database sessions properly with try/catch/finally
- Implement database migrations for schema changes

### Data Validation and Serialization
- Create schema classes for each model
- Use separate schemas for input validation and output serialization
- Implement comprehensive validation rules
- Sanitize and validate all external inputs

## Dependency Management

### Module Dependencies
- Keep dependencies minimal and well-maintained
- Use version-locked dependencies
- Prefer standard library over third-party packages when possible
- Document all external dependencies with versions

### Service Dependencies
- Use dependency injection containers where appropriate
- Define clear interfaces between services
- Implement proper service lifecycle management
- Handle service failures gracefully

## Performance Architecture

### Caching Strategies
- Implement appropriate caching levels (application, database, CDN)
- Use cache invalidation strategies
- Monitor cache hit rates and performance
- Consider distributed caching for multi-instance deployments

### Database Optimization
- Implement connection pooling
- Use database indexes effectively
- Optimize queries to prevent N+1 problems
- Consider read replicas for read-heavy applications

### Scalability Patterns
- Design for horizontal scaling where possible
- Implement load balancing strategies
- Use message queues for async processing
- Consider microservices architecture for large applications

## Security Architecture

### Authentication and Authorization
- Implement secure authentication mechanisms
- Use role-based access control (RBAC)
- Secure session management
- Implement proper logout and session invalidation

### Data Protection
- Encrypt sensitive data at rest and in transit
- Implement proper input validation and sanitization
- Use secure defaults for all configurations
- Follow principle of least privilege

### API Security
- Implement rate limiting
- Use CORS properly
- Validate all inputs
- Implement audit logging for security events