---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# Testing Strategy and Guidelines

## Testing Philosophy

### Core Principle
- Write tests only when explicitly required or when code reaches production-ready state
- Focus on testing behavior, not implementation details

### Hybrid Approach: Choose Based on Requirement Clarity
- Clear Requirements: Use RGR (Red-Green-Refactor)
  1. Red: Write failing test
  2. Green: Write minimal code to pass
  3. Refactor: Clean up while tests pass
- Unclear/Exploratory: Implement first, add tests after stabilization

## Test Organization

### Test Structure
- Use descriptive test names that explain the scenario
- Group related tests logically by feature or functionality
- Keep test data minimal and focused on the test case
- Mock external dependencies appropriately

### Test Categories
1. Unit Tests: Test individual functions and components in isolation
2. Integration Tests: Test interactions between components
3. End-to-End Tests: Test complete user workflows
4. Performance Tests: Test system performance under load

### Test File Organization
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

## Language-Specific Testing Guidelines

### Python Testing (pytest)
- Framework: Use pytest as the primary testing framework
- Coverage: Implement pytest-cov for code coverage tracking
- Mocking: Use pytest-mock for proper test isolation
- Fixtures: Create reusable fixtures for common test setup

#### pytest Best Practices
```python
# Descriptive test names
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

### Go Testing
- Use table-driven tests for multiple test cases
- Focus on integration tests for database and API endpoints
- Ensure test coverage for all exported functions
- Test error handling paths and edge cases

#### Go Test Patterns
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
        // More test cases...
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### Shell Script Testing
- Test script functionality with different input scenarios
- Verify error handling and exit codes
- Test script behavior in different environments
- Validate script dependencies and prerequisites

## Test Data Management

### Test Fixtures
- Create reusable fixtures for common test scenarios
- Use factory patterns for test data generation
- Keep test data minimal and focused
- Clean up test data after test execution

### Mock and Stub Strategies
- Mock external dependencies (APIs, databases, file systems)
- Use stubs for deterministic behavior
- Verify mock interactions and calls
- Reset mocks between tests to prevent test pollution

### Database Testing
- Use in-memory databases for unit tests
- Implement database transactions for test isolation
- Create and clean up test data efficiently
- Test database constraints and validations

## Integration Testing

### API Testing
- Test all API endpoints with various inputs
- Verify HTTP status codes and response formats
- Test authentication and authorization
- Test error handling and edge cases

### Database Integration
- Test database interactions and transactions
- Verify data integrity and constraints
- Test database migrations and schema changes
- Test connection handling and error recovery

### External Service Integration
- Test interactions with external APIs
- Implement service virtualization for reliable testing
- Test network failure scenarios
- Verify retry logic and error handling

## Performance Testing

### Load Testing
- Test system behavior under expected load
- Identify performance bottlenecks
- Test system scalability
- Monitor resource usage during tests

### Stress Testing
- Test system limits and failure modes
- Verify graceful degradation under load
- Test recovery after overload conditions
- Monitor system stability during stress tests

### Performance Regression Testing
- Establish performance baselines
- Monitor performance over time
- Detect performance regressions
- Set performance thresholds and alerts

## Test Automation and CI/CD

### Automated Testing Pipeline
- Integrate tests into CI/CD pipeline
- Run tests automatically on code changes
- Fail builds on test failures
- Provide clear test results and feedback

### Test Environment Management
- Create isolated test environments
- Automate test environment setup and teardown
- Use containerization for consistent test environments
- Manage test data and state across test runs

### Test Reporting
- Generate comprehensive test reports
- Track test coverage over time
- Monitor test execution times
- Provide actionable test failure information

## Quality Assurance Practices

### Code Coverage
- Set minimum code coverage thresholds
- Monitor coverage trends over time
- Focus on critical path coverage
- Balance coverage with meaningful tests

### Test Review Process
- Review test code for quality and maintainability
- Ensure tests cover edge cases and error scenarios
- Verify test isolation and independence
- Review test data and fixture management

### Regression Testing
- Maintain comprehensive regression test suites
- Run regression tests before releases
- Prioritize regression tests based on risk
- Update regression tests as functionality evolves

## Debugging and Troubleshooting

### Test Debugging
- Use debugging tools to understand test failures
- Implement detailed logging for test scenarios
- Create reproducible test failure scenarios
- Document common test issues and solutions

### Test Maintenance
- Regular review and cleanup of test suites
- Update tests to match code changes
- Remove obsolete or redundant tests
- Refactor tests for better maintainability

## Documentation and Knowledge Sharing

### Test Documentation
- Document testing strategies and approaches
- Create test case documentation for critical scenarios
- Maintain test environment setup guides
- Document testing tools and frameworks

### Knowledge Transfer
- Share testing best practices across teams
- Conduct testing training sessions
- Create testing guidelines and standards
- Maintain testing knowledge base