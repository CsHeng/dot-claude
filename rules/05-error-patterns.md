---
file-type: rule
scope: error-patterns
---

# Error Handling Directives

## scope
REQUIRED: Apply these error handling patterns to all development activities across all programming languages and frameworks.

## absolute-prohibitions
PROHIBITED: Ignore errors or continue execution with invalid state
PROHIBITED: Use generic exception handling without specific error types
PROHIBITED: Log sensitive information in error messages
PROHIBITED: Fail silently without error reporting

## communication-protocol
REQUIRED: Validate inputs at function boundaries
REQUIRED: Handle edge cases explicitly
REQUIRED: Use meaningful error messages
REQUIRED: Fail fast when preconditions aren't met
REQUIRED: Include relevant variables and state in error messages
REQUIRED: Use consistent debug prefixes: ===, ---, SUCCESS:, ERROR:

## structural-rules

### defensive-programming
REQUIRED: Validate inputs at function boundaries
REQUIRED: Handle edge cases explicitly
REQUIRED: Use meaningful error messages
REQUIRED: Fail fast when preconditions aren't met
REQUIRED: Include relevant variables and state in error messages
REQUIRED: Use consistent debug prefixes: ===, ---, SUCCESS:, ERROR:

### exception-management
REQUIRED: Create custom exception classes inheriting from appropriate base exceptions
REQUIRED: Use specific exception types for different error categories
REQUIRED: Implement proper exception chaining with context
REQUIRED: Design exception hierarchy that matches application domains
REQUIRED: Catch specific exceptions, not generic ones
REQUIRED: Log errors with sufficient context for debugging
REQUIRED: Clean up resources in finally blocks or use-with patterns
REQUIRED: Use structured error information for better debugging

### language-specific-patterns

#### python-error-handling
REQUIRED: Follow Python error handling patterns:
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

#### go-error-handling
REQUIRED: Follow Go error handling patterns:
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

#### shell-script-error-handling
REQUIRED: Follow shell script error handling patterns:
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

## language-rules

### resilience-patterns
REQUIRED: Implement exponential backoff for transient failures
REQUIRED: Set maximum retry attempts and timeouts
REQUIRED: Use circuit breakers to prevent cascading failures
REQUIRED: Log retry attempts and successes
REQUIRED: Implement circuit breaker pattern when appropriate:
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

### recovery-strategies
REQUIRED: Implement fallback mechanisms for critical services
REQUIRED: Provide alternative functionality when primary services fail
OPTIONAL: Use cached data when real-time data is unavailable
OPTIONAL: Implement read-only mode during maintenance
REQUIRED: Implement automatic retry for transient failures
REQUIRED: Use health checks to detect service recovery
OPTIONAL: Implement automatic failover mechanisms
OPTIONAL: Use self-healing patterns where appropriate
REQUIRED: Provide clear error messages for manual intervention
REQUIRED: Implement diagnostic tools for troubleshooting
OPTIONAL: Create runbooks for common error scenarios
REQUIRED: Provide rollback mechanisms for failed deployments

## formatting-rules

### resource-management
REQUIRED: Use context managers for resource cleanup
REQUIRED: Implement proper disposal of connections and files
REQUIRED: Use timeout-based resource cleanup
REQUIRED: Monitor resource usage patterns
REQUIRED: Implement connection pooling
REQUIRED: Handle connection failures gracefully
REQUIRED: Use health checks for connection validation
REQUIRED: Implement connection retry logic
REQUIRED: Monitor memory usage patterns
REQUIRED: Implement memory cleanup procedures
REQUIRED: Use memory-efficient data structures
REQUIRED: Set memory limits and monitoring

### error-communication
REQUIRED: Provide clear, actionable error messages
PROHIBITED: Use technical jargon in user messages
REQUIRED: Include guidance for error resolution
OPTIONAL: Localize error messages for international users
REQUIRED: Use consistent error response formats
REQUIRED: Include error codes and descriptions
OPTIONAL: Provide debugging information in development
REQUIRED: Implement rate limiting for error responses
REQUIRED: Use structured error formats for internal systems
REQUIRED: Include correlation IDs for error tracking
REQUIRED: Implement error propagation across service boundaries
REQUIRED: Provide error context for debugging

## naming-rules

### error-classification
REQUIRED: Categorize errors by severity: critical, error, warning, info
REQUIRED: Use descriptive error names indicating the error type and context
REQUIRED: Maintain consistent error naming conventions across projects
REQUIRED: Document all custom error types and their usage scenarios

## validation-rules

### input-validation-and-sanitization
REQUIRED: Validate all inputs at system boundaries
REQUIRED: Use whitelist approach for allowed values
REQUIRED: Implement comprehensive validation rules
REQUIRED: Provide clear validation error messages
REQUIRED: Remove or escape dangerous characters
REQUIRED: Validate file paths and names
REQUIRED: Sanitize user-generated content
REQUIRED: Implement input length limits
REQUIRED: Validate numeric ranges and formats
REQUIRED: Check date and time validity
REQUIRED: Validate string patterns and formats
REQUIRED: Implement size limits for uploads and inputs

### monitoring-and-alerting
REQUIRED: Use structured logging with consistent formats
REQUIRED: Include correlation IDs for request tracking
REQUIRED: Log errors with appropriate context and severity levels
REQUIRED: Implement log aggregation and analysis
REQUIRED: Track error rates and types
REQUIRED: Monitor error trends over time
REQUIRED: Set up alerts for error threshold breaches
REQUIRED: Use error metrics for system health assessment
REQUIRED: Implement multi-level alerting (warning, critical)
REQUIRED: Use different alert channels for different severities
REQUIRED: Implement alert escalation procedures
REQUIRED: Provide actionable alert messages

### error-testing
REQUIRED: Test system behavior under error conditions
REQUIRED: Simulate various failure scenarios
REQUIRED: Test error recovery mechanisms
REQUIRED: Validate error handling procedures
REQUIRED: Introduce controlled failures to test resilience
REQUIRED: Test system behavior under stress conditions
REQUIRED: Validate failover and recovery procedures
REQUIRED: Test all error paths in code
REQUIRED: Validate error messages and formats
REQUIRED: Test error logging and monitoring
REQUIRED: Verify error recovery procedures

### data-recovery
REQUIRED: Implement regular backup and restore procedures
OPTIONAL: Use transaction logs for data recovery
REQUIRED: Implement data consistency checks
OPTIONAL: Provide data repair tools for corruption scenarios
REQUIRED: Implement comprehensive security logging
REQUIRED: Conduct regular security audits and penetration testing
REQUIRED: Maintain security incident response plans
REQUIRED: Document all security configurations and procedures
REQUIRED: Follow relevant industry standards (PCI-DSS, HIPAA, GDPR)
REQUIRED: Implement data retention and deletion policies
REQUIRED: Maintain compliance documentation
REQUIRED: Conduct regular compliance assessments
REQUIRED: Implement security incident response procedures
REQUIRED: Maintain security incident contact lists
REQUIRED: Conduct regular security incident response training
REQUIRED: Document and learn from security incidents
REQUIRED: Implement regular security testing
REQUIRED: Use static application security testing (SAST)
REQUIRED: Use dynamic application security testing (DAST)
REQUIRED: Implement regular penetration testing
REQUIRED: Conduct regular security code reviews
REQUIRED: Use automated security scanning tools
REQUIRED: Perform manual security testing for critical components
REQUIRED: Include security testing in CI/CD pipelines
REQUIRED: Implement vulnerability scanning processes
REQUIRED: Prioritize and track vulnerability remediation
REQUIRED: Maintain vulnerability disclosure procedures
REQUIRED: Conduct regular security assessments and updates