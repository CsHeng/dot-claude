---
# Cursor Rules
globs: **/*.py

# Copilot Instructions
applyTo: "**/*.py"

# Kiro Steering
inclusion: fileMatch
fileMatchPattern: '**/*.py'
---

# Python Development Guidelines

## Architecture & Design Patterns
- Prefer class-based architecture over standalone functions
- Follow existing architecture patterns defined in `pyproject.toml`
- Use dependency injection for better testability
- Implement proper separation of concerns
- Apply SOLID principles consistently

## Code Style & Formatting
- Formatting: Use Ruff for code formatting with default settings
- Imports: Use Ruff's import sorting for import organization; prefer absolute imports
- Naming Conventions (PEP 8):
  - `snake_case` for functions, variables, and module names
  - `PascalCase` for classes and exceptions
  - `UPPER_CASE` for constants
  - Descriptive names that clearly indicate purpose

## Type Safety
- Required: Type hints for all function parameters and return values
- Imports: Use `typing` module for complex types
- Union Types: Use `X | None` for modern Python projects (3.10+)
- Custom Types: Define project-specific types in dedicated `types.py` files
- Generics: Use `TypeVar` for generic implementations
- Protocols: Use `Protocol` for structural typing and duck typing

## Error Handling & Resilience
- Create custom exception classes inheriting from appropriate base exceptions
- Use early returns to avoid deeply nested conditional blocks
- Implement comprehensive try-except blocks with specific exception handling
- Log errors with appropriate context and severity levels
- Provide meaningful error messages for debugging and user feedback
- Handle edge cases explicitly rather than relying on implicit behavior

## Testing Strategy
- Framework: Use pytest as the primary testing framework
- Coverage: Implement pytest-cov for code coverage tracking
- Mocking: Use pytest-mock for proper test isolation
- Fixtures: Create reusable fixtures for common test setup
- Scope: Test all error scenarios, edge cases, and happy paths
- Flask Testing: Use Flask's test client for integration testing when applicable

## Security Best Practices
- Validate and sanitize all user inputs
- Use HTTPS in production environments
- Implement proper CORS configuration
- Follow OWASP security guidelines
- Use secure session management
- Implement comprehensive audit logging

## Performance Optimization
- Use appropriate caching strategies (Flask-Caching when applicable)
- Optimize database queries and implement connection pooling
- Implement pagination for large data sets
- Use background tasks for computationally expensive operations
- Monitor and profile application performance regularly

## Documentation Standards
- Docstrings: Use Google-style docstrings for all public methods and classes
- API Documentation: Document all public APIs with examples
- Inline Comments: Use sparingly for complex logic explanation
- Project Documentation: Maintain up-to-date README.md and setup instructions

## Development Workflow
- Use virtual environments (venv/virtualenv) for dependency isolation
- Use UV with `pyproject.toml` for dependency management
- Implement pre-commit hooks for code quality checks
- Follow semantic versioning for releases
- Maintain comprehensive logging throughout the application
- Respect existing project structure and conventions

## Tool Preferences
- Package Management: UV for package management
- Formatting: Ruff for code formatting
- Linting: Ruff for code quality checks
- Testing: pytest for testing framework
- Virtual Environment: Single .venv directory at project root
- Configuration: pyproject.toml for all project configuration

## Environment Management
- Use UV for virtual environment and dependency management
- Single .venv directory at project root managed by mise when needed
- Use `pyproject.toml` with `[project.dependencies]` and `[tool.uv.dev-dependencies]`
- Development tools: via `uv tool run` (no local installation required)
- Linting: Use `uv tool run ruff check` and `uv tool run ruff format`

## Flask Application Guidelines (if applicable)
- Use application factory pattern for Flask apps
- Structure routes using Flask Blueprints by feature/domain
- Use Flask-SQLAlchemy for ORM operations
- Implement proper session management and error handling
- Use Flask-Migrate for database schema changes

## Dependency Management
- Use UV for package management with `pyproject.toml`
- Separate development and production dependencies
- Use semantic versioning for dependency updates
- Regularly update dependencies and check for security vulnerabilities