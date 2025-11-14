---
skill: language-python
description: Python language patterns and best practices. Use when language python
  guidance is required.
allowed-tools:
- Bash(uv)
- Bash(ruff)
- Bash(pytest)
---

# Python Architecture Standards

## Project Structure and Organization

### Standard Python Project Layout

Implement consistent project structure:
```
project/
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── main.py
│       ├── api/
│       ├── domain/
│       └── infrastructure/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── pyproject.toml
├── README.md
├── requirements.txt
└── .python-version
```

Package organization principles:
- Use `src/` layout for clean imports
- Separate concerns into logical packages
- Implement proper `__init__.py` files
- Apply consistent naming conventions

### Dependency Management

Modern Python dependency management with uv:
- Use `pyproject.toml` for project configuration
- Implement virtual environments automatically
- Maintain separate dev and production dependencies
- Apply semantic versioning constraints

Dependency configuration:
```toml
[project]
name = "project-name"
version = "1.0.0"
dependencies = [
    "fastapi>=0.100.0",
    "sqlalchemy>=2.0.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
]
```

## Type System Implementation

### Comprehensive Type Annotations

Apply type annotations systematically:
- Annotate all function signatures with input/output types
- Use `typing` module for complex types
- Implement generic types for reusable components
- Apply `TypedDict` for structured data

Type annotation patterns:
```python
from typing import List, Optional, Dict, Any, Union
from dataclasses import dataclass
from abc import ABC, abstractmethod

@dataclass
class UserProfile:
    user_id: int
    username: str
    email: str
    is_active: bool = True

class DataProcessor(ABC):
    @abstractmethod
    def process(self, data: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        pass

def transform_data(
    input_data: List[UserProfile],
    config: Dict[str, Any],
    *,
    strict_mode: bool = False
) -> Union[List[Dict[str, Any]], None]:
    pass
```

### Advanced Type Patterns

Implement sophisticated type patterns:
- Use `Protocol` for structural typing
- Apply `TypeGuard` for type narrowing
- Implement `NewType` for domain-specific types
- Use `Literal` for enumerated values

Type safety examples:
```python
from typing import Protocol, TypeGuard, NewType, Literal

UserId = NewType('UserId', int)
Status = Literal['active', 'inactive', 'pending']

class JSONSerializable(Protocol):
    def to_json(self) -> str: ...

def is_user_profile(data: Dict[str, Any]) -> TypeGuard[UserProfile]:
    required_fields = {'user_id', 'username', 'email'}
    return all(field in data for field in required_fields)
```

## Code Quality and Formatting

### Ruff Configuration and Usage

Implement comprehensive ruff setup:
```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "A", "C4", "T20"]
ignore = ["E501", "B008"]

[tool.ruff.lint.isort]
known-first-party = ["project_name"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

Code formatting enforcement:
- Use `uv tool run ruff format .` for formatting
- Apply `uv tool run ruff check .` for linting
- Configure pre-commit hooks for automatic enforcement
- Integrate with CI/CD pipeline validation

### Static Type Checking with MyPy

Configure mypy for strict type checking:
```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
```

Type validation requirements:
- Enforce 100% type annotation coverage on critical modules
- Use mypy for static analysis before commits
- Implement incremental type checking for large codebases
- Document type-related decisions in comments

## Testing Strategy Implementation

### Comprehensive Testing with Pytest

Apply pytest testing patterns:
- Use parametrized tests for data-driven scenarios
- Implement fixtures for test setup and teardown
- Apply markers for test categorization
- Use mocks for external dependencies

Testing configuration:
```python
# conftest.py
import pytest
from typing import Generator
from fastapi.testclient import TestClient

@pytest.fixture
def test_client() -> Generator[TestClient, None, None]:
    from app.main import app
    with TestClient(app) as client:
        yield client

@pytest.fixture
def sample_user_data() -> dict:
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "securepassword123"
    }

# test_example.py
import pytest
from app.services.user_service import UserService

@pytest.mark.unit
class TestUserService:
    @pytest.mark.parametrize("email,expected", [
        ("valid@example.com", True),
        ("invalid-email", False),
        ("", False),
    ])
    def test_validate_email(self, user_service: UserService, email: str, expected: bool):
        assert user_service.validate_email(email) == expected

    def test_create_user_success(self, test_client, sample_user_data):
        response = test_client.post("/users", json=sample_user_data)
        assert response.status_code == 201
        assert response.json()["username"] == sample_user_data["username"]
```

### Coverage and Quality Gates

Implement comprehensive test coverage:
- Target 80% overall code coverage
- Require 95% coverage for critical business logic
- Use `uv tool run pytest --cov` for coverage analysis
- Integrate coverage reports in CI/CD

Quality gate enforcement:
```bash
#!/bin/bash
# test.sh
set -euo pipefail

echo "Running tests with coverage..."
uv tool run pytest --cov=src --cov-report=term-missing --cov-fail-under=80

echo "Running type checking..."
uv tool run mypy src/

echo "Running linting..."
uv tool run ruff check src/

echo "All quality checks passed!"
```

## Security Implementation

### Secure Coding Practices

Apply Python security best practices:
- Validate all external inputs at boundaries
- Use parameterized queries for database operations
- Implement proper credential management
- Apply security headers for web applications

Security validation patterns:
```python
import re
from typing import Any, Dict, List
from pydantic import BaseModel, validator, EmailStr

class UserRegistration(BaseModel):
    username: str
    email: EmailStr
    password: str

    @validator('username')
    def validate_username(cls: str, v: str) -> str:
        if not re.match(r'^[a-zA-Z0-9_]{3,20}$', v):
            raise ValueError('Username must be 3-20 characters, alphanumeric and underscore only')
        return v

    @validator('password')
    def validate_password(cls: str, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

def sanitize_input(user_input: str) -> str:
    # Remove potentially dangerous characters
    return re.sub(r'[<>"\']', '', user_input)
```

### Dependency Security

Maintain secure Python dependencies:
- Use `uv` for secure dependency resolution
- Regularly update dependencies with security patches
- Scan for known vulnerabilities
- Implement security policies for third-party packages

Security scanning integration:
```bash
#!/bin/bash
# security-scan.sh
echo "Scanning for security vulnerabilities..."
uv tool run safety check
uv tool run bandit -r src/
```

## Performance Optimization

### Efficient Python Patterns

Apply performance optimization techniques:
- Use generators for memory-efficient iteration
- Implement lazy loading for expensive operations
- Apply caching for frequently accessed data
- Use appropriate data structures for the problem

Performance patterns:
```python
from functools import lru_cache
from typing import Iterator
import asyncio

# Use generators for memory efficiency
def process_large_file(file_path: str) -> Iterator[dict]:
    with open(file_path, 'r') as file:
        for line in file:
            yield process_line(line)

# Implement caching for expensive operations
@lru_cache(maxsize=128)
def expensive_calculation(x: int, y: int) -> int:
    # Simulate expensive computation
    result = sum(i * j for i in range(x) for j in range(y))
    return result

# Use asyncio for concurrent operations
async def fetch_multiple_urls(urls: List[str]) -> List[str]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)
```

### Memory and Resource Management

Implement efficient resource usage:
- Use context managers for resource cleanup
- Apply memory profiling to identify leaks
- Implement connection pooling for database operations
- Use efficient data structures for large datasets

Resource management patterns:
```python
from contextlib import contextmanager
from typing import Generator
import psycopg2
from psycopg2 import pool

# Context manager for database connections
@contextmanager
def db_connection(connection_pool: psycopg2.pool.ThreadedConnectionPool) -> Generator[psycopg2.extensions.connection, None, None]:
    conn = connection_pool.getconn()
    try:
        yield conn
    finally:
        connection_pool.putconn(conn)

# Memory-efficient data processing
def process_large_dataset(dataset: List[dict]) -> Iterator[dict]:
    batch_size = 1000
    for i in range(0, len(dataset), batch_size):
        batch = dataset[i:i + batch_size]
        for item in process_batch(batch):
            yield item
```