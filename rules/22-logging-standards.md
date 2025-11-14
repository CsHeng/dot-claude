# Logging and Observability Directives

## Scope
REQUIRED: Apply these standards to all logging, monitoring, and observability implementations across applications and services.

## Absolute Prohibitions
PROHIBITED: Log sensitive information (passwords, tokens, PII)
PROHIBITED: Use different log formats inconsistently across applications
PROHIBITED: Log excessive DEBUG messages in production environments
PROHIBITED: Include stack traces in user-facing error messages
PROHIBITED: Use logging for control flow or application logic branching

## Communication Protocol
REQUIRED: Use structured logging with consistent format across all services
REQUIRED: Include relevant context (user IDs, request IDs, correlation IDs) in log entries
REQUIRED: Provide clear, actionable log messages that aid troubleshooting
PROHIBITED: Use conversational tone or unnecessary filler text in log messages

## Structural Rules
### Required Log Format
REQUIRED: Use standard log format: `+0800 2025-08-06 15:22:30 INFO main.go(180) | Descriptive message`
REQUIRED: Include timezone offset (+0800 or appropriate timezone)
REQUIRED: Include timestamp in YYYY-MM-DD HH:MM:SS format
REQUIRED: Include log level (DEBUG, INFO, WARN, ERROR, FATAL)
REQUIRED: Include file and line number in format file.extension(line)
REQUIRED: Use pipe character (|) as separator before message
REQUIRED: Provide descriptive, actionable message content

### Log Level Guidelines
REQUIRED: DEBUG: Detailed diagnostic information for development only
REQUIRED: INFO: General information about application flow and state changes
REQUIRED: WARN: Unexpected situations that don't prevent application continuation
REQUIRED: ERROR: Error events that allow application to continue
REQUIRED: FATAL: Critical errors that will cause application termination

## Language Rules
### Implementation Standards
REQUIRED: Implement structured logging with consistent format across all languages
REQUIRED: Use appropriate logging libraries for each programming language
REQUIRED: Configure log levels appropriately for each environment
REQUIRED: Implement proper log rotation and retention policies
PREFERRED: Use JSON format for machine parsing in production environments

### Context and Correlation
REQUIRED: Include request IDs for request-related log entries
REQUIRED: Add correlation IDs for distributed tracing across services
REQUIRED: Include relevant user context (user_id, session_id) when appropriate
REQUIRED: Add performance metrics (duration_ms, memory_usage) for operations
PREFERRED: Include trace IDs and span IDs for OpenTelemetry integration

### Error Logging Standards
REQUIRED: Log errors with full context and available debugging information
REQUIRED: Include error types, messages, and stack traces in structured format
REQUIRED: Log error recovery attempts and their outcomes
REQUIRED: Use structured fields for error context (error_code, error_type)
PREFERRED: Implement error aggregation and alerting based on error patterns

## Formatting Rules
### Structured Logging
REQUIRED: Use structured log formats with key-value pairs for context
REQUIRED: Maintain consistent field naming across all log entries
REQUIRED: Use appropriate data types for log fields (strings, numbers, booleans)
REQUIRED: Serialize complex objects as JSON when necessary
PREFERRED: Use schema validation for structured log fields

### Security Logging
REQUIRED: Log all authentication attempts with success/failure status
REQUIRED: Record authorization failures with resource and action details
REQUIRED: Log access to sensitive data with purpose and user context
REQUIRED: Implement audit logging for security-relevant events
PROHIBITED: Log passwords, API keys, or other sensitive credentials

### Performance Logging
REQUIRED: Log operation durations for performance monitoring
REQUIRED: Track resource usage (memory, CPU, disk) in production
REQUIRED: Monitor database query performance and connection pool status
REQUIRED: Log external API call latency and success rates
PREFERRED: Use distributed tracing for end-to-end performance visibility

## Naming Rules
### Log Message Standards
REQUIRED: Use clear, descriptive messages that indicate what happened
REQUIRED: Start messages with action verbs for events (User logged in, Database connected)
REQUIRED: Include relevant entities and identifiers in messages
REQUIRED: Use consistent terminology across all log messages
PROHIBITED: Use vague messages like "Error occurred" or "Something went wrong"

### Field Naming Conventions
REQUIRED: Use snake_case for log field names (user_id, request_id, error_code)
REQUIRED: Use consistent naming for common fields across all services
REQUIRED: Use standard field names for well-known concepts (timestamp, level, message)
PREFERRED: Use established standards like Elastic Common Schema (ECS) when possible
REQUIRED: Document custom field names and their meanings in project documentation

## Validation Rules
### Configuration Management
REQUIRED: Configure log levels appropriately for each environment (development, staging, production)
REQUIRED: Implement log rotation to prevent disk space issues
REQUIRED: Set appropriate log retention periods based on compliance requirements
REQUIRED: Configure log aggregation for centralized monitoring
PREFERRED: Use environment-specific configuration files for log settings

### Monitoring and Alerting
REQUIRED: Implement log-based monitoring for critical application events
REQUIRED: Set up alerts for error rates, response times, and system health
REQUIRED: Monitor log volumes and patterns for anomaly detection
REQUIRED: Test alerting configurations regularly for effectiveness
PREFERRED: Use automated dashboards for log visualization and analysis

### Compliance and Audit
REQUIRED: Implement audit logging for all sensitive operations
REQUIRED: Maintain log integrity and prevent unauthorized modification
REQUIRED: Ensure logs are available for required retention periods
REQUIRED: Implement secure log archival and retrieval processes
PREFERRED: Use write-once storage mediums for compliance-critical logs

### Tool Requirements
REQUIRED: Logging Libraries: Structured logging with language-appropriate libraries
REQUIRED: Log Aggregation: Centralized logging system (ELK stack, Splunk, etc.)
REQUIRED: Monitoring: Real-time log monitoring and alerting
REQUIRED: Analysis: Log search and analysis capabilities
PREFERRED: Observability: Integration with metrics and tracing systems