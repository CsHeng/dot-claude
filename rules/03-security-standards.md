---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# Security Guidelines and Best Practices

## Credential Management

### Principle of Secure Storage
- NEVER hardcode API keys, secrets, or credentials in source code
- Store sensitive data in `.env` files or configuration files
- Use separate configuration files for different environments (dev, staging, prod)
- Implement proper access controls for configuration files

### Environment Variables
- Use environment variables for all sensitive configuration
- Implement validation for required environment variables
- Use secure defaults for all configuration options
- Document all required environment variables

### Configuration File Security
- Never commit configuration files with secrets to version control
- Use encryption for sensitive configuration at rest
- Implement configuration file integrity checks
- Use configuration management tools for production environments

## Input Validation and Sanitization

### Input Validation Principles
- Validate and sanitize all user inputs rigorously
- Use whitelist approach for input validation
- Implement comprehensive input validation at application boundaries
- Validate all data types, formats, and ranges

### Web Application Security
- Implement proper CORS configuration
- Use HTTPS in production environments
- Validate all HTTP headers and parameters
- Implement secure session management

### Command Injection Prevention
- Never execute user input as system commands
- Use parameterized queries for database operations
- Sanitize file paths and user-provided filenames
- Implement proper shell escaping when necessary

## Authentication and Authorization

### Authentication Best Practices
- Implement strong password policies
- Use secure password hashing algorithms (bcrypt, Argon2)
- Implement multi-factor authentication where appropriate
- Use secure session token generation and validation

### Authorization Patterns
- Implement role-based access control (RBAC)
- Use principle of least privilege
- Implement proper permission checking at all levels
- Log all authorization decisions and access attempts

### Session Management
- Use secure, HTTP-only cookies for session tokens
- Implement proper session timeout and invalidation
- Generate cryptographically secure session identifiers
- Implement session fixation prevention

## API Security

### API Authentication
- Use secure API key management
- Implement rate limiting to prevent abuse
- Use OAuth 2.0 or JWT for API authentication
- Implement API versioning for security updates

### Data Protection in Transit
- Use TLS 1.2+ for all communications
- Implement certificate pinning where appropriate
- Validate SSL certificates properly
- Use secure cipher suites

### API Rate Limiting
- Implement comprehensive rate limiting strategies
- Use different limits for different user types
- Implement gradual penalty for abuse
- Monitor and alert on rate limit violations

## Database Security

### Database Connection Security
- Use encrypted database connections
- Implement database connection pooling securely
- Use database-specific user accounts with limited privileges
- Implement database connection timeout and retry logic

### Data Encryption
- Encrypt sensitive data at rest using strong encryption
- Use transparent data encryption where available
- Implement key rotation for encryption keys
- Secure encryption keys using hardware security modules where possible

### SQL Injection Prevention
- Use parameterized queries exclusively
- Never concatenate user input into SQL queries
- Implement stored procedures with proper parameterization
- Use ORM frameworks that provide built-in SQL injection protection

## Network Security

### Firewall Configuration
- Implement proper firewall rules
- Use network segmentation to isolate sensitive systems
- Implement ingress and egress filtering
- Monitor and log all network traffic

### Secure Communications
- Use VPNs for administrative access
- Implement secure remote access protocols
- Use secure file transfer protocols (SFTP, SCP)
- Disable insecure protocols (telnet, FTP, HTTP)

### Network Monitoring
- Implement intrusion detection systems
- Monitor network traffic for anomalies
- Log all network access attempts
- Implement real-time security alerting

## Application Security

### Secure Coding Practices
- Follow OWASP secure coding guidelines
- Implement proper error handling without information disclosure
- Use secure memory management practices
- Implement proper logging without sensitive data

### Dependency Security
- Regularly update all dependencies
- Use dependency scanning tools
- Implement software composition analysis
- Monitor for security advisories

### Runtime Security
- Implement application sandboxing where possible
- Use secure runtime configurations
- Implement proper process isolation
- Monitor application behavior for anomalies

## Container and Infrastructure Security

### Container Security
- Use minimal base images for containers
- Implement container image scanning
- Use non-root users in containers
- Implement container runtime security

### Infrastructure Security
- Use secure cloud configurations
- Implement proper identity and access management
- Use security groups and network ACLs
- Implement infrastructure monitoring

### Secret Management
- Use dedicated secret management systems
- Implement secret rotation policies
- Audit secret access logs
- Use hardware security modules for critical secrets

## Compliance and Auditing

### Security Auditing
- Implement comprehensive security logging
- Regular security audits and penetration testing
- Maintain security incident response plans
- Document all security configurations and procedures

### Compliance Requirements
- Follow relevant industry standards (PCI-DSS, HIPAA, GDPR)
- Implement data retention and deletion policies
- Maintain compliance documentation
- Regular compliance assessments

### Incident Response
- Implement security incident response procedures
- Maintain security incident contact lists
- Regular security incident response training
- Document and learn from security incidents

## Security Testing

### Security Testing Strategy
- Implement regular security testing
- Use static application security testing (SAST)
- Use dynamic application security testing (DAST)
- Implement regular penetration testing

### Code Security Review
- Regular security code reviews
- Use automated security scanning tools
- Manual security testing for critical components
- Security testing in CI/CD pipelines

### Vulnerability Management
- Implement vulnerability scanning processes
- Prioritize and track vulnerability remediation
- Maintain vulnerability disclosure procedures
- Regular security assessments and updates