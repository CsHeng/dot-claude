---
# Cursor Rules
alwaysApply: true

# Copilot Instructions
applyTo: "**/*"

# Kiro Steering
inclusion: always
---

# General Development Guidelines

## Code Quality Standards
- Use descriptive, explicit variable names that reveal intent and purpose
- Replace hardcoded values with named constants
- Adhere to existing project coding style and conventions
- Prioritize code performance and security in all suggestions

## Naming Conventions

### Variables and Functions
- Use descriptive names that reveal intent and purpose
- Prefer `calculateTotalPrice()` over `calc()` or `getTotal()`
- Boolean variables should be questions: `isValid`, `hasPermission`, `canExecute`
- Don't use abbreviations unless universally understood (`url`, `id`, `api`)

### Constants and Configuration
- Replace magic numbers with named constants
- Use UPPER_SNAKE_CASE for constants: `MAX_RETRY_ATTEMPTS = 3`
- Group related constants in dedicated files or sections
- Include units in names when applicable: `TIMEOUT_SECONDS`, `MAX_FILE_SIZE_MB`

## Function Design

### Single Responsibility
- Each function should have one clear purpose
- If you need "and" to describe what a function does, split it
- Functions should be small (typically 10-20 lines)
- Extract complex conditionals into well-named helper functions

### Parameters and Return Values
- Limit function parameters (max 3-4, use objects for more)
- Return early to reduce nesting
- Use consistent return types
- Prefer explicit returns over implicit ones

## Architecture Patterns
- Encourage modular design for maintainability and reusability
- Ensure compatibility with project's language/framework versions
- Use environment variables for configuration management
- Handle edge cases and include assertions to validate assumptions
- Keep related functionality together
- Use consistent naming patterns for files and directories

## Code Organization

### File Structure
- Keep related functionality together
- Use consistent naming patterns for files and directories
- Place imports/dependencies at the top
- Organize code sections logically (constants, types, functions, exports)

### Abstraction Levels
- Don't mix high-level and low-level operations in the same function
- Hide implementation details behind clear interfaces
- Use appropriate data structures for the problem domain

## Error Handling

### Defensive Programming
- Validate inputs at function boundaries
- Handle edge cases explicitly
- Use meaningful error messages
- Fail fast when preconditions aren't met

### Exception Management
- Catch specific exceptions, not generic ones
- Log errors with sufficient context for debugging
- Clean up resources in finally blocks or use-with patterns

## Documentation and Comments

### When to Comment
- Explain **why** decisions were made, not **what** the code does
- Document complex algorithms and business logic
- Add context for non-obvious side effects or dependencies
- Include examples for public APIs

### When NOT to Comment
- Don't write comments that restate the code
- Don't use comments to explain poorly named variables or functions
- Remove outdated or misleading comments immediately

## Code Quality Practices

### Refactoring
- Continuously improve code structure
- Address technical debt promptly
- Leave code cleaner than you found it
- Refactor before adding new features to complex areas

### DRY Principle
- Extract repeated logic into reusable functions
- Create shared utilities for common operations
- Maintain single sources of truth for configuration and constants
- Use templates or generators for repetitive code patterns

## Development Workflow
- Make changes file by file to enable incremental review
- Only implement explicitly requested changes
- Preserve existing code structures and functionalities
- Provide complete edits in single chunks per file
- Suggest unit tests for new or modified code when explicitly required

## Testing Guidelines

### Test Strategy
- Write tests only when explicitly required
- Focus on testing behavior, not implementation
- Test edge cases and error conditions
- Keep tests simple and readable

### Test Organization
- Use descriptive test names that explain the scenario
- Group related tests logically
- Keep test data minimal and focused
- Mock external dependencies appropriately

## Version Control Standards

### Commit Practices
- Write clear, concise commit messages
- Use imperative mood: "Add feature" not "Added feature"
- Make atomic commits that represent single logical changes
- Include context in commit body for complex changes

### Branch Management
- Use descriptive branch names: `feature/user-authentication`, `fix/memory-leak`
- Keep branches focused on single features or fixes
- Delete merged branches promptly

## Communication Guidelines
- Present verified information; don't speculate
- Reference actual project files, not generated content
- Focus on implementation over explanations unless requested
- No apologies or understanding confirmations in code/docs