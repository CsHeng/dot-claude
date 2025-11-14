# Testing Strategy Directives

## scope
REQUIRED: Apply these testing standards to all testing activities across all programming languages, frameworks, and project types.

## absolute-prohibitions
PROHIBITED: Write tests that check implementation details instead of behavior
PROHIBITED: Commit tests without proper cleanup of test data
PROHIBITED: Use production databases or external services in unit tests
PROHIBITED: Ignore test coverage requirements for critical paths

## communication-protocol
REQUIRED: Focus on testing behavior, not implementation details
REQUIRED: Write tests only when explicitly required or code is production-ready
REQUIRED: Use descriptive test names that explain scenarios
REQUIRED: Test edge cases and error conditions thoroughly

## structural-rules

### testing-philosophy
REQUIRED: Write tests only when explicitly required or when code reaches production-ready state
REQUIRED: Focus on testing behavior, not implementation details

### hybrid-testing-approach
REQUIRED: Use RGR (Red-Green-Refactor) for clear requirements:
1. Red: Write failing test
2. Green: Write minimal code to pass
3. Refactor: Clean up while tests pass
REQUIRED: Use implementation-first approach for unclear/exploratory requirements
REQUIRED: Add tests after stabilization for exploratory code

### test-organization
REQUIRED: Use descriptive test names that explain the scenario
REQUIRED: Group related tests logically by feature or functionality
REQUIRED: Keep test data minimal and focused on the test case
OPTIONAL: Mock external dependencies appropriately
REQUIRED: Categorize tests as:
1. Unit Tests: Test individual functions and components in isolation
2. Integration Tests: Test interactions between components
3. End-to-End Tests: Test complete user workflows
4. Performance Tests: Test system performance under load

### test-file-structure
REQUIRED: Use standardized test directory structure:
```
tests/
├── unit/                   # Unit tests
│   ├── test_models.py
│   ├── test_services.py
│   └── test_utils.py
├── integration/            # Integration tests
│   ├── test_api.py
│   └── test_database.py
├── fixtures/              # Test data and fixtures
└── conftest.py            # Test configuration
```

## language-rules

### python-testing-pytest
REQUIRED: Use pytest as the primary testing framework
REQUIRED: Implement pytest-cov for code coverage tracking
REQUIRED: Use pytest-mock for proper test isolation
REQUIRED: Create reusable fixtures for common test setup
REQUIRED: Use descriptive test names following this pattern:
```python
def test_user_creation_with_valid_data_returns_user_object():
    # Test implementation

def test_user_creation_with_invalid_email_raises_validation_error():
    # Test implementation

# Fixtures for common setup
@pytest.fixture
def sample_user_data():
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "securepassword"
    }
```

### go-testing
REQUIRED: Use table-driven tests for multiple test cases
REQUIRED: Focus on integration tests for database and API endpoints
REQUIRED: Ensure test coverage for all exported functions
REQUIRED: Test error handling paths and edge cases
REQUIRED: Follow Go test patterns:
```go
func TestUserService(t *testing.T) {
    tests := []struct {
        name    string
        input   User
        want    error
        wantErr bool
    }{
        {
            name: "valid user creation",
            input: User{Name: "John", Email: "john@example.com"},
            want: nil,
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### shell-script-testing
REQUIRED: Test script functionality with different input scenarios
REQUIRED: Verify error handling and exit codes
REQUIRED: Test script behavior in different environments
REQUIRED: Validate script dependencies and prerequisites

## formatting-rules

### test-data-management
REQUIRED: Create reusable fixtures for common test scenarios
OPTIONAL: Use factory patterns for test data generation
REQUIRED: Keep test data minimal and focused
REQUIRED: Clean up test data after test execution
REQUIRED: Mock external dependencies (APIs, databases, file systems)
OPTIONAL: Use stubs for deterministic behavior
REQUIRED: Verify mock interactions and calls
REQUIRED: Reset mocks between tests to prevent test pollution
REQUIRED: Use in-memory databases for unit tests
REQUIRED: Implement database transactions for test isolation
REQUIRED: Create and clean up test data efficiently
REQUIRED: Test database constraints and validations

### integration-testing
REQUIRED: Test all API endpoints with various inputs
REQUIRED: Verify HTTP status codes and response formats
REQUIRED: Test authentication and authorization
REQUIRED: Test error handling and edge cases
REQUIRED: Test database interactions and transactions
REQUIRED: Verify data integrity and constraints
REQUIRED: Test database migrations and schema changes
REQUIRED: Test connection handling and error recovery
REQUIRED: Test interactions with external APIs
OPTIONAL: Implement service virtualization for reliable testing
REQUIRED: Test network failure scenarios
REQUIRED: Verify retry logic and error handling

## naming-rules

### performance-testing
REQUIRED: Test system behavior under expected load
REQUIRED: Identify performance bottlenecks
REQUIRED: Test system scalability
REQUIRED: Monitor resource usage during tests
REQUIRED: Test system limits and failure modes
REQUIRED: Verify graceful degradation under load
REQUIRED: Test recovery after overload conditions
REQUIRED: Monitor system stability during stress tests
REQUIRED: Establish performance baselines
REQUIRED: Monitor performance over time
REQUIRED: Detect performance regressions
REQUIRED: Set performance thresholds and alerts

## validation-rules

### test-automation-and-cicd
REQUIRED: Integrate tests into CI/CD pipeline
REQUIRED: Run tests automatically on code changes
REQUIRED: Fail builds on test failures
REQUIRED: Provide clear test results and feedback
REQUIRED: Create isolated test environments
REQUIRED: Automate test environment setup and teardown
OPTIONAL: Use containerization for consistent test environments
REQUIRED: Manage test data and state across test runs
REQUIRED: Generate comprehensive test reports
REQUIRED: Track test coverage over time
REQUIRED: Monitor test execution times
REQUIRED: Provide actionable test failure information

### quality-assurance
REQUIRED: Set minimum code coverage thresholds
REQUIRED: Monitor coverage trends over time
REQUIRED: Focus on critical path coverage
REQUIRED: Balance coverage with meaningful tests
REQUIRED: Review test code for quality and maintainability
REQUIRED: Ensure tests cover edge cases and error scenarios
REQUIRED: Verify test isolation and independence
REQUIRED: Review test data and fixture management
REQUIRED: Maintain comprehensive regression test suites
REQUIRED: Run regression tests before releases
REQUIRED: Prioritize regression tests based on risk
REQUIRED: Update regression tests as functionality evolves

### debugging-and-maintenance
REQUIRED: Use debugging tools to understand test failures
REQUIRED: Implement detailed logging for test scenarios
REQUIRED: Create reproducible test failure scenarios
REQUIRED: Document common test issues and solutions
REQUIRED: Conduct regular review and cleanup of test suites
REQUIRED: Update tests to match code changes
REQUIRED: Remove obsolete or redundant tests
REQUIRED: Refactor tests for better maintainability
REQUIRED: Document testing strategies and approaches
OPTIONAL: Create test case documentation for critical scenarios
OPTIONAL: Maintain test environment setup guides
REQUIRED: Document testing tools and frameworks
REQUIRED: Share testing best practices across teams
OPTIONAL: Conduct testing training sessions
OPTIONAL: Create testing guidelines and standards
OPTIONAL: Maintain testing knowledge base