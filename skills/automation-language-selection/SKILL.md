---
name: automation-language-selection
description: Choose between Shell and Python for generated automation code based on
  task traits. Use when automation language selection guidance is required.
mode: decision-support
capability-level: 1
---

## Purpose
Provide deterministic guidance for selecting appropriate programming languages (Shell vs Python) for automation tasks based on complexity, data requirements, and maintenance considerations as defined in the agentization taxonomy and language guidelines.

## IO Semantics
Input: Task descriptions, automation requirements, complexity assessments
Output: Language selection decision with rationale, loaded language skill
Side Effects: Appropriate tool selection for automation tasks, consistent language choices

## Deterministic Steps

### 1. Task Complexity Assessment
Evaluate logical complexity: >2 levels branching → Python
Assess script length estimate: >30 LOC → Python
Identify state management requirements: complex state → Python

### 2. Data Processing Analysis
Identify structured data handling: JSON/YAML/CSV → Python
Assess network/API requirements: HTTP requests → Python
Evaluate cross-platform needs: multiple OS → Python

### 3. CLI Orchestration Evaluation
Identify command chaining: multiple CLI tools → Shell
Assess streaming text processing: grep/sed/awk → Shell
Evaluate batch operations: shallow jobs (<30 LOC) → Shell

### 4. Cross-Language Architecture Decision
PROHIBITED: Default to inline Python (`python -c`) in shell scripts
REQUIRED: Use Python modules when both languages needed
PREFERRED: Shell orchestrates workflow, Python provides specialized functionality
REQUIRED: Apply library-first architecture for mixed-language solutions

### 5. Anti-Inline Pattern Detection
ALWAYS: Scan for `python -c` patterns and reject as anti-pattern
ALWAYS: Flag here-doc Python (`python <<'PY'`) as architectural violation
ALWAYS: Recommend module extraction for any Python code > 3 lines
REQUIRED: Use `python -m module.name` for all shell→Python integration

### 6. Language Integration Decision
Load appropriate language skill based on decision
Apply cross-language architecture patterns from rules/15-cross-language-architecture.md
Validate decision criteria against task requirements
Escalate to human when both branches apply equally

## Tool Safety
Validate language selection before implementation
Ensure chosen language skill properly loaded and available
Test automation code in isolated environments
Backup existing automation before replacements
Monitor resource usage of generated automation

## Validation Criteria
Language selection follows deterministic criteria consistently
Complex tasks (branching, state management) assigned to Python
CLI orchestration tasks assigned to Shell
Data processing tasks appropriately matched to language strengths
Language skills properly loaded after selection decision
Anti-inline patterns are detected and corrected to module-based architecture
Cross-language integration follows library-first principles

## Language Selection Matrix

### Shell-Only Tasks
- File system operations (mkdir, cp, rm, find)
- Process management and monitoring
- Simple text filtering and transformation
- Environment variable handling
- Permission and ownership management
- Command chaining and pipeline orchestration

### Python-Only Tasks
- Complex data structure manipulation
- API calls and HTTP requests
- Database operations
- Mathematical computations
- Business logic implementation
- Complex error handling and state management

### Hybrid Tasks (Shell + Python Integration)
- Configuration file processing (Shell finds files, Python parses content)
- Data transformation pipelines (Shell orchestrates, Python processes)
- Validation workflows (Shell manages I/O, Python implements logic)
- System integration (Shell handles environment, Python interfaces with services)

### Anti-Pattern Detection and Correction
- Detect: `python -c` usage → Replace with module call
- Detect: here-doc Python → Extract to dedicated module
- Detect: Complex inline logic → Create library module
- Enforce: Standard CLI interfaces with argparse
- Require: Proper error handling and exit codes
