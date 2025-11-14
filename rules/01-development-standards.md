# Development Standards Directives

## scope
REQUIRED: Apply these standards to all development activities across all programming languages, frameworks, and project types.

## absolute-prohibitions
PROHIBITED: Use abbreviations except universally understood ones (url, id, api)
PROHIBITED: Mix high-level and low-level operations in the same function
PROHIBITED: Ignore errors or use generic exception handling
PROHIBITED: Write tests unless explicitly required or code is production-ready

## communication-protocol
REQUIRED: Focus on implementation over explanations unless requested
REQUIRED: Present verified information only
REQUIRED: Reference actual project files, not generated content
PROHIBITED: Use apologies or understanding confirmations in code or documentation

## structural-rules

### function-design
REQUIRED: Enforce single responsibility per function
REQUIRED: Split functions requiring "and" for description
REQUIRED: Limit function size to 10-20 lines typically
REQUIRED: Extract complex conditionals into named helper functions
REQUIRED: Limit parameters to maximum 3-4, use objects for more
REQUIRED: Return early to reduce nesting
REQUIRED: Use consistent return types
OPTIONAL: Use explicit returns over implicit ones

### variable-and-naming
REQUIRED: Use descriptive names revealing intent and purpose
REQUIRED: Use explicit names: calculateTotalPrice() over calc() or getTotal()
REQUIRED: Use Boolean variables in question format: isValid, hasPermission, canExecute

### constants-and-configuration
REQUIRED: Replace magic numbers with named constants
REQUIRED: Use UPPER_SNAKE_CASE for constants: MAX_RETRY_ATTEMPTS = 3
REQUIRED: Include units in constant names: TIMEOUT_SECONDS, MAX_FILE_SIZE_MB
REQUIRED: Group related constants in dedicated files or sections

### file-organization
REQUIRED: Place imports/dependencies at top of files
REQUIRED: Organize code sections: constants, types, functions, exports
OPTIONAL: Hide implementation details behind clear interfaces
REQUIRED: Use appropriate data structures for problem domain
OPTIONAL: Use consistent naming patterns for files and directories

## language-rules

### architecture
REQUIRED: Require modular design for maintainability and reusability
REQUIRED: Verify compatibility with project language/framework versions
REQUIRED: Use environment variables for configuration management
REQUIRED: Handle edge cases and include assertions for validation
REQUIRED: Keep related functionality together

### error-handling
REQUIRED: Validate inputs at function boundaries
REQUIRED: Handle edge cases explicitly
REQUIRED: Use meaningful error messages
REQUIRED: Fail fast when preconditions aren't met
REQUIRED: Catch specific exceptions, not generic ones
REQUIRED: Log errors with sufficient debugging context
REQUIRED: Clean up resources in finally blocks or use-with patterns

## formatting-rules

### documentation-standards
REQUIRED: Explain decision rationale, not code functionality
REQUIRED: Document complex algorithms and business logic
OPTIONAL: Add context for non-obvious side effects or dependencies
OPTIONAL: Include examples for public APIs
PROHIBITED: Write comments that restate code
REQUIRED: Remove outdated or misleading comments immediately

### code-quality
REQUIRED: Continuously improve code structure
REQUIRED: Address technical debt promptly
REQUIRED: Leave code cleaner than found
REQUIRED: Refactor before adding new features to complex areas
REQUIRED: Extract repeated logic into reusable functions
REQUIRED: Create shared utilities for common operations
REQUIRED: Maintain single sources of truth for configuration and constants
OPTIONAL: Use templates or generators for repetitive code patterns

## naming-rules

### development-workflow
REQUIRED: Make changes file by file for incremental review
REQUIRED: Implement only explicitly requested changes
REQUIRED: Preserve existing code structures and functionalities
REQUIRED: Provide complete edits in single chunks per file

## validation-rules

### testing
REQUIRED: Write tests only when explicitly required
REQUIRED: Test behavior, not implementation
REQUIRED: Test edge cases and error conditions
REQUIRED: Keep tests simple and readable
REQUIRED: Use descriptive test names explaining scenarios
REQUIRED: Group related tests logically
REQUIRED: Keep test data minimal and focused
OPTIONAL: Mock external dependencies appropriately

### version-control
REQUIRED: Use imperative mood for commit messages: "Add feature" not "Added feature"
REQUIRED: Make atomic commits representing single logical changes
OPTIONAL: Include context in commit body for complex changes
REQUIRED: Use descriptive branch names: feature/user-authentication, fix/memory-leak
REQUIRED: Keep branches focused on single features or fixes
REQUIRED: Delete merged branches promptly