# Python Development Directives

## Scope
REQUIRED: Apply these standards to all Python development activities, including application code, libraries, scripts, and test files.
REQUIRED: Treat Python as the default implementation language for non-trivial automation when Python and uv are available.

## Absolute Prohibitions
PROHIBITED: Write Python functions without type hints for parameters and return values
PROHIBITED: Ignore ruff linting errors or warnings
PROHIBITED: Hardcode secrets or configuration values in source code
PROHIBITED: Use mutable default arguments in function definitions
PROHIBITED: Mix application logic with configuration or dependency injection code

## Communication Protocol
REQUIRED: Use class-based architecture over standalone functions for complex logic
REQUIRED: Apply dependency injection for better testability and maintainability
REQUIRED: Implement proper separation of concerns between modules and components
REQUIRED: Focus on behavior testing over implementation testing
PROHIBITED: Use apologies or understanding confirmations in code or documentation

## Structural Rules
REQUIRED: Follow existing architecture patterns defined in `pyproject.toml`
REQUIRED: Apply SOLID principles consistently across the codebase
PREFERRED: Create small, focused interfaces rather than large, monolithic classes
REQUIRED: Implement proper separation of concerns between modules
PREFERRED: Use absolute imports over relative imports when possible

## Language Rules
### Type Safety
REQUIRED: Add type hints for all function parameters and return values
REQUIRED: Use `typing` module for complex types and generic programming
PREFERRED: Use `X | None` syntax for modern Python projects (3.10+)
REQUIRED: Define project-specific types in dedicated `types.py` files
PREFERRED: Use `TypeVar` for generic implementations when appropriate
PREFERRED: Use `Protocol` for structural typing and duck typing interfaces
PROHIBITED: Use `typing.Any` unless absolutely necessary

### Error Handling
REQUIRED: Create custom exception classes inheriting from appropriate base exceptions
REQUIRED: Use early returns to avoid deeply nested conditional blocks
REQUIRED: Implement comprehensive try-except blocks with specific exception handling
REQUIRED: Log errors with appropriate context and severity levels
REQUIRED: Provide meaningful error messages for debugging and user feedback
REQUIRED: Handle edge cases explicitly rather than relying on implicit behavior
PROHIBITED: Catch generic exceptions without specific handling
PROHIBITED: Use bare `except:` clauses in production code

## Formatting Rules
### Code Style
REQUIRED: Use Ruff for code formatting with default settings
REQUIRED: Use Ruff's import sorting for import organization
REQUIRED: Follow PEP 8 naming conventions:
PREFERRED: Use `snake_case` for functions, variables, and module names
PREFERRED: Use `PascalCase` for classes and exceptions
PREFERRED: Use `UPPER_CASE` for constants
REQUIRED: Use descriptive names that clearly indicate purpose and intent

### Testing
REQUIRED: Use pytest as the primary testing framework
REQUIRED: Implement pytest-cov for code coverage tracking
PREFERRED: Use pytest-mock for proper test isolation and mocking
REQUIRED: Create reusable fixtures for common test setup scenarios
REQUIRED: Test all error scenarios, edge cases, and happy paths
PREFERRED: Use Flask's test client for integration testing when applicable

### Documentation
REQUIRED: Use Google-style docstrings for all public methods and classes
REQUIRED: Document all public APIs with usage examples
PREFERRED: Use inline comments sparingly for complex logic explanation only
REQUIRED: Maintain up-to-date README.md and setup instructions
PROHIBITED: Write comments that simply restate what the code does

## Naming Rules
### Project Structure
REQUIRED: Use virtual environments (venv/virtualenv) for dependency isolation
REQUIRED: Use UV with `pyproject.toml` for dependency management
PREFERRED: Implement pre-commit hooks for automated code quality checks
REQUIRED: Follow semantic versioning for releases
REQUIRED: Maintain comprehensive logging throughout the application
REQUIRED: Respect existing project structure and conventions
PREFERRED: Implement reusable Python CLIs for automation instead of complex Shell scripts when business logic or structured data processing is involved

## Validation Rules
### Environment Management
REQUIRED: Use UV for virtual environment and dependency management
REQUIRED: Maintain single .venv directory at project root managed by mise when needed for development environments
REQUIRED: Use `pyproject.toml` with `[project.dependencies]` and `[tool.uv.dev-dependencies]`
REQUIRED: Use development tools via `uv tool run` (no local installation required)
REQUIRED: Run `uv tool run ruff check` and `uv tool run ruff format` for code quality

### Flask Applications (if applicable)
REQUIRED: Use application factory pattern for Flask apps
REQUIRED: Structure routes using Flask Blueprints by feature/domain
PREFERRED: Use Flask-SQLAlchemy for ORM operations
REQUIRED: Implement proper session management and error handling
PREFERRED: Use Flask-Migrate for database schema changes

### Dependencies
REQUIRED: Use UV for package management with `pyproject.toml`
REQUIRED: Separate development and production dependencies clearly
PREFERRED: Use semantic versioning for dependency updates
REQUIRED: Regularly update dependencies and check for security vulnerabilities

### Tool Requirements
REQUIRED: Package Management: UV for package management
REQUIRED: Formatting: Ruff for code formatting
REQUIRED: Linting: Ruff for code quality checks
REQUIRED: Testing: pytest for testing framework
REQUIRED: Virtual Environment: Single .venv directory at project root
REQUIRED: Configuration: pyproject.toml for all project configuration
PREFERRED: Expose automation entrypoints via `python -m module` or uv-managed scripts instead of relying on Shell wrappers
