---
name: "skill:tooling-code-tool-selection"
description: "Choose between Shell and Python for generated automation code based on task traits"
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

### 4. Operational Context Assessment
Identify ops/SSH/Docker/Git tasks: glue work → Shell
Assess one-off script requirements: temporary → Shell
Evaluate maintainability needs: long-term → Python

### 5. Language Integration Decision
Load appropriate language skill based on decision
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