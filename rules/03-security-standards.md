---
file-type: rule
scope: security-standards
---

# Security Standards Directives

## scope
REQUIRED: Apply these security standards to all development activities, including credential management, input validation, and secure coding practices across all projects.

## absolute-prohibitions
PROHIBITED: Hardcode API keys, secrets, or credentials in source code
PROHIBITED: Commit configuration files with secrets to version control
PROHIBITED: Execute user input as system commands without sanitization
PROHIBITED: Use weak cryptographic algorithms or insecure defaults

## communication-protocol
REQUIRED: Implement security-by-default principles
REQUIRED: Use principle of least privilege for all access controls
REQUIRED: Validate all inputs at application boundaries
REQUIRED: Log security events without exposing sensitive data

## structural-rules

### credential-management
REQUIRED: Store sensitive data in .env files or configuration files
OPTIONAL: Use separate configuration files for different environments (dev, staging, prod)
REQUIRED: Implement proper access controls for configuration files
REQUIRED: Use environment variables for all sensitive configuration
REQUIRED: Implement validation for required environment variables
REQUIRED: Use secure defaults for all configuration options
REQUIRED: Document all required environment variables
OPTIONAL: Use encryption for sensitive configuration at rest
OPTIONAL: Implement configuration file integrity checks
OPTIONAL: Use configuration management tools for production environments

## language-rules

### input-validation-and-sanitization
REQUIRED: Validate and sanitize all user inputs rigorously
REQUIRED: Use whitelist approach for input validation
REQUIRED: Implement comprehensive input validation at application boundaries
REQUIRED: Validate all data types, formats, and ranges
REQUIRED: Implement proper CORS configuration
REQUIRED: Use HTTPS in production environments
REQUIRED: Validate all HTTP headers and parameters
REQUIRED: Implement secure session management
REQUIRED: Use parameterized queries for database operations
REQUIRED: Sanitize file paths and user-provided filenames
OPTIONAL: Implement proper shell escaping when necessary

### authentication-and-authorization
REQUIRED: Implement strong password policies
REQUIRED: Use secure password hashing algorithms (bcrypt, Argon2)
OPTIONAL: Implement multi-factor authentication where appropriate
REQUIRED: Use secure session token generation and validation
REQUIRED: Implement role-based access control (RBAC)
REQUIRED: Use principle of least privilege
REQUIRED: Implement proper permission checking at all levels
REQUIRED: Log all authorization decisions and access attempts
REQUIRED: Use secure, HTTP-only cookies for session tokens
REQUIRED: Implement proper session timeout and invalidation
REQUIRED: Generate cryptographically secure session identifiers
REQUIRED: Implement session fixation prevention

## formatting-rules

### api-security
REQUIRED: Use secure API key management
REQUIRED: Implement rate limiting to prevent abuse
REQUIRED: Use OAuth 2.0 or JWT for API authentication
OPTIONAL: Implement API versioning for security updates
REQUIRED: Use TLS 1.2+ for all communications
OPTIONAL: Implement certificate pinning where appropriate
REQUIRED: Validate SSL certificates properly
REQUIRED: Use secure cipher suites
REQUIRED: Implement comprehensive rate limiting strategies
REQUIRED: Use different limits for different user types
REQUIRED: Implement gradual penalty for abuse
REQUIRED: Monitor and alert on rate limit violations

## naming-rules

### database-security
REQUIRED: Use encrypted database connections
REQUIRED: Implement database connection pooling securely
REQUIRED: Use database-specific user accounts with limited privileges
REQUIRED: Implement database connection timeout and retry logic
REQUIRED: Encrypt sensitive data at rest using strong encryption
OPTIONAL: Use transparent data encryption where available
REQUIRED: Implement key rotation for encryption keys
OPTIONAL: Secure encryption keys using hardware security modules where possible
REQUIRED: Use parameterized queries exclusively
PROHIBITED: Concatenate user input into SQL queries
OPTIONAL: Implement stored procedures with proper parameterization
REQUIRED: Use ORM frameworks that provide built-in SQL injection protection

## validation-rules

### network-security
REQUIRED: Implement proper firewall rules
OPTIONAL: Use network segmentation to isolate sensitive systems
REQUIRED: Implement ingress and egress filtering
REQUIRED: Monitor and log all network traffic
OPTIONAL: Use VPNs for administrative access
REQUIRED: Implement secure remote access protocols
REQUIRED: Use secure file transfer protocols (SFTP, SCP)
PROHIBITED: Use insecure protocols (telnet, FTP, HTTP)
REQUIRED: Implement intrusion detection systems
REQUIRED: Monitor network traffic for anomalies
REQUIRED: Log all network access attempts
REQUIRED: Implement real-time security alerting

### application-security
REQUIRED: Follow OWASP secure coding guidelines
REQUIRED: Implement proper error handling without information disclosure
REQUIRED: Use secure memory management practices
REQUIRED: Implement proper logging without sensitive data
REQUIRED: Regularly update all dependencies
REQUIRED: Use dependency scanning tools
REQUIRED: Implement software composition analysis
REQUIRED: Monitor for security advisories
OPTIONAL: Implement application sandboxing where possible
REQUIRED: Use secure runtime configurations
OPTIONAL: Implement proper process isolation
REQUIRED: Monitor application behavior for anomalies

### container-and-infrastructure-security
REQUIRED: Use minimal base images for containers
REQUIRED: Implement container image scanning
REQUIRED: Use non-root users in containers
REQUIRED: Implement container runtime security
REQUIRED: Use secure cloud configurations
REQUIRED: Implement proper identity and access management
REQUIRED: Use security groups and network ACLs
REQUIRED: Implement infrastructure monitoring
REQUIRED: Use dedicated secret management systems
REQUIRED: Implement secret rotation policies
REQUIRED: Audit secret access logs
OPTIONAL: Use hardware security modules for critical secrets

### compliance-and-auditing
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

### security-testing
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