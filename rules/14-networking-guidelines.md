# RouterOS and Networking Directives

## Scope
REQUIRED: Apply these standards to all RouterOS v7 scripting, network automation, and system management activities.

## Absolute Prohibitions
PROHIBITED: Use RouterOS scripts without proper error handling and validation
PROHIBITED: Hardcode credentials or API keys in RouterOS scripts
PROHIBITED: Execute RouterOS commands without verifying system state
PROHIBITED: Create network configurations without backup and rollback plans
PROHIBITED: Use RouterOS scripts for complex business logic better suited for external systems

## Communication Protocol
REQUIRED: Use descriptive variable and function names in RouterOS scripts
REQUIRED: Include comprehensive error logging with context information
REQUIRED: Document script purpose, dependencies, and requirements
PROHIBITED: Use abbreviations except universally understood ones (`url`, `id`, `api`)

## Structural Rules
### Script Organization
REQUIRED: Use consistent header format for all RouterOS scripts:
REQUIRED: Include script name, author, creation date, description, and version
REQUIRED: Document dependencies and RouterOS version requirements
REQUIRED: Organize global variables at script beginning with clear grouping
REQUIRED: Separate configuration constants from runtime variables

### Variable Management
REQUIRED: Use `:local` for script-scoped variables
REQUIRED: Use `:global` for persistent variables across script executions
REQUIRED: Group related variables in configuration objects
REQUIRED: Use descriptive naming with consistent patterns
REQUIRED: Initialize all variables before use

### Control Flow
REQUIRED: Implement comprehensive input validation before processing
REQUIRED: Use explicit error checking and handling for all operations
REQUIRED: Provide meaningful error messages with context
REQUIRED: Use early returns to reduce nesting complexity
REQUIRED: Log all significant operations and state changes

## Language Rules
### RouterOS Script Syntax
REQUIRED: Use proper RouterOS scripting syntax for all operations
REQUIRED: Implement proper command execution with error checking
REQUIRED: Use appropriate RouterOS built-in functions and operators
REQUIRED: Follow RouterOS best practices for performance and reliability
REQUIRED: Test scripts on target RouterOS versions before deployment

### API Integration
REQUIRED: Validate API endpoints and connectivity before making requests
REQUIRED: Implement proper HTTP request/response handling
REQUIRED: Use appropriate authentication methods for API calls
REQUIRED: Handle API errors and rate limiting gracefully
REQUIRED: Log all API interactions for debugging and auditing

### Network Operations
REQUIRED: Verify interface status before performing network operations
REQUIRED: Validate IP address formats and ranges
REQUIRED: Implement proper routing table management
REQUIRED: Use appropriate network monitoring and health checks
REQUIRED: Handle network failures and recovery procedures

## Formatting Rules
### Code Style
REQUIRED: Use consistent indentation for RouterOS scripts
REQUIRED: Add comments for complex logic and business rules
REQUIRED: Group related operations into logical sections
REQUIRED: Use meaningful variable and function names
REQUIRED: Follow RouterOS scripting conventions and best practices

### Logging Standards
REQUIRED: Use structured logging with consistent message format
REQUIRED: Include timestamps, context, and severity levels
REQUIRED: Log all configuration changes and their outcomes
REQUIRED: Implement debug logging for troubleshooting
PROHIBITED: Log sensitive information like passwords or API keys

### Error Handling
REQUIRED: Implement comprehensive error checking for all operations
REQUIRED: Use appropriate error recovery strategies
REQUIRED: Provide clear error messages with actionable information
REQUIRED: Log errors with sufficient context for debugging
REQUIRED: Implement graceful degradation for non-critical failures

## Naming Rules
### Interface and Network Naming
REQUIRED: Use descriptive interface names indicating purpose and connection
REQUIRED: Follow consistent naming patterns for network segments
REQUIRED: Use clear, meaningful names for routing rules and firewall policies
REQUIRED: Document all network configurations and their purposes
PREFERRED: Use standardized naming conventions across all network devices

### Script Organization
REQUIRED: Use descriptive script names indicating their primary function
REQUIRED: Organize scripts in logical directory structure
REQUIRED: Implement proper version control for all RouterOS scripts
REQUIRED: Document script dependencies and requirements
PREFERRED: Use consistent file naming patterns for easy identification

## Validation Rules
### Testing Requirements
REQUIRED: Test all RouterOS scripts in development environment first
REQUIRED: Validate script syntax before deployment
REQUIRED: Verify script functionality with test data
REQUIRED: Test error handling and recovery procedures
REQUIRED: Perform integration testing with actual network equipment

### Security Validation
REQUIRED: Validate all user inputs and API parameters
REQUIRED: Implement proper authentication and authorization checks
REQUIRED: Use secure communication protocols for remote management
REQUIRED: Regularly audit RouterOS configurations for security issues
REQUIRED: Implement proper access control for script execution

### Performance Requirements
REQUIRED: Monitor script execution performance and resource usage
REQUIRED: Optimize scripts for efficient operation on RouterOS hardware
REQUIRED: Implement proper resource cleanup and management
REQUIRED: Test scripts under realistic network load conditions
REQUIRED: Document performance characteristics and limitations

### Tool Requirements
REQUIRED: RouterOS Version: v7.12+ for all scripting activities
REQUIRED: Development Tools: RouterOS console and scripting environment
REQUIRED: Testing: Dedicated test environment for script validation
REQUIRED: Monitoring: RouterOS logging and monitoring capabilities
REQUIRED: Documentation: Comprehensive script documentation and version control