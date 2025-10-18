---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# Error Handling and Resilience Patterns

## Error Handling Philosophy

### Defensive Programming
- Validate inputs at function boundaries
- Handle edge cases explicitly
- Use meaningful error messages
- Fail fast when preconditions aren't met

### Error Handling Principles
- Fail-fast principle: Exit immediately on any error
- Include relevant variables and state in error messages
- Use consistent debug prefixes: `===`, `---`, `SUCCESS:`, `ERROR:`
- Provide meaningful error messages for debugging and user feedback

## Exception Management

### Exception Hierarchy
- Create custom exception classes inheriting from appropriate base exceptions
- Use specific exception types for different error categories
- Implement proper exception chaining with context
- Design exception hierarchy that matches application domains

### Exception Handling Patterns
- Catch specific exceptions, not generic ones
- Log errors with sufficient context for debugging
- Clean up resources in finally blocks or use-with patterns
- Use structured error information for better debugging

## Error Handling by Language

### Python Error Handling
```python
# Custom exception classes
class ValidationError(Exception):
    """Raised when input validation fails"""
    pass

class DatabaseError(Exception):
    """Raised when database operation fails"""
    pass

# Comprehensive error handling
def process_user_data(user_data):
    try:
        # Validate input
        if not user_data.get('email'):
            raise ValidationError("Email is required")

        # Process data
        result = save_to_database(user_data)
        return result

    except ValidationError as e:
        logger.error(f"Validation failed: {e}")
        raise
    except DatabaseError as e:
        logger.error(f"Database error: {e}")
        # Implement retry logic or fallback
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise RuntimeError("Processing failed") from e
```

### Go Error Handling
```go
// Custom error types
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error for %s: %s", e.Field, e.Message)
}

// Comprehensive error handling
func ProcessUserData(userData map[string]interface{}) error {
    // Validate input
    if email, ok := userData["email"]; !ok || email == "" {
        return &ValidationError{Field: "email", Message: "email is required"}
    }

    // Process data
    result, err := saveToDatabase(userData)
    if err != nil {
        return fmt.Errorf("database error: %w", err)
    }

    return nil
}
```

### Shell Script Error Handling
```bash
#!/bin/bash

# Enable strict mode
set -euo pipefail

# Error handler with context
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "ERROR: Script failed on line $line_number with exit code $exit_code" >&2
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Input validation
validate_input() {
    local input="$1"
    if [[ -z "$input" ]]; then
        echo "ERROR: Input parameter is required" >&2
        exit 1
    fi
}
```

## Resilience Patterns

### Retry Logic
- Implement exponential backoff for transient failures
- Set maximum retry attempts and timeouts
- Use circuit breakers to prevent cascading failures
- Log retry attempts and successes

### Circuit Breaker Pattern
```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN

    def call(self, func, *args, **kwargs):
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit breaker is OPEN")

        try:
            result = func(*args, **kwargs)
            if self.state == "HALF_OPEN":
                self.state = "CLOSED"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()

            if self.failure_count >= self.failure_threshold:
                self.state = "OPEN"

            raise e
```

### Graceful Degradation
- Implement fallback mechanisms for critical services
- Provide alternative functionality when primary services fail
- Use cached data when real-time data is unavailable
- Implement read-only mode during maintenance

### Timeout and Deadlines
- Set appropriate timeouts for all external operations
- Implement deadline propagation across service boundaries
- Use context-based cancellation for long-running operations
- Monitor and alert on timeout occurrences

## Error Recovery Strategies

### Automatic Recovery
- Implement automatic retry for transient failures
- Use health checks to detect service recovery
- Implement automatic failover mechanisms
- Use self-healing patterns where appropriate

### Manual Recovery
- Provide clear error messages for manual intervention
- Implement diagnostic tools for troubleshooting
- Create runbooks for common error scenarios
- Provide rollback mechanisms for failed deployments

### Data Recovery
- Implement regular backup and restore procedures
- Use transaction logs for data recovery
- Implement data consistency checks
- Provide data repair tools for corruption scenarios

## Error Monitoring and Alerting

### Error Logging Standards
- Use structured logging with consistent formats
- Include correlation IDs for request tracking
- Log errors with appropriate context and severity levels
- Implement log aggregation and analysis

### Error Metrics
- Track error rates and types
- Monitor error trends over time
- Set up alerts for error threshold breaches
- Use error metrics for system health assessment

### Alerting Strategies
- Implement multi-level alerting (warning, critical)
- Use different alert channels for different severities
- Implement alert escalation procedures
- Provide actionable alert messages

## Input Validation and Sanitization

### Validation Patterns
- Validate all inputs at system boundaries
- Use whitelist approach for allowed values
- Implement comprehensive validation rules
- Provide clear validation error messages

### Sanitization Strategies
- Remove or escape dangerous characters
- Validate file paths and names
- Sanitize user-generated content
- Implement input length limits

### Boundary Validation
- Validate numeric ranges and formats
- Check date and time validity
- Validate string patterns and formats
- Implement size limits for uploads and inputs

## Resource Management

### Resource Cleanup
- Use context managers for resource cleanup
- Implement proper disposal of connections and files
- Use timeout-based resource cleanup
- Monitor resource usage patterns

### Connection Management
- Implement connection pooling
- Handle connection failures gracefully
- Use health checks for connection validation
- Implement connection retry logic

### Memory Management
- Monitor memory usage patterns
- Implement memory cleanup procedures
- Use memory-efficient data structures
- Set memory limits and monitoring

## Error Communication

### User-Facing Error Messages
- Provide clear, actionable error messages
- Avoid technical jargon in user messages
- Include guidance for error resolution
- Localize error messages for international users

### API Error Responses
- Use consistent error response formats
- Include error codes and descriptions
- Provide debugging information in development
- Implement rate limiting for error responses

### Internal Error Communication
- Use structured error formats for internal systems
- Include correlation IDs for error tracking
- Implement error propagation across service boundaries
- Provide error context for debugging

## Testing Error Scenarios

### Error Injection Testing
- Test system behavior under error conditions
- Simulate various failure scenarios
- Test error recovery mechanisms
- Validate error handling procedures

### Chaos Engineering
- Introduce controlled failures to test resilience
- Test system behavior under stress conditions
- Validate failover and recovery procedures
- Improve system resilience through testing

### Error Scenario Testing
- Test all error paths in code
- Validate error messages and formats
- Test error logging and monitoring
- Verify error recovery procedures