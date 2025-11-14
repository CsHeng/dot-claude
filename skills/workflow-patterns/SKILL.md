---
name: skill:workflow-patterns
description: Apply multi-phase workflow and handoff patterns. Use when workflow patterns
  guidance is required.
---

## Purpose
Enforce structured workflow patterns including state transitions, handoff procedures, communication protocols, and multi-process orchestration as defined in rules/23-workflow-patterns.md.

## IO Semantics
Input: Workflow definitions, process documentation, team communication patterns, orchestration configurations
Output: Structured workflows, handoff procedures, communication protocols, orchestration integration
Side Effects: Improved process efficiency, better coordination, enhanced reliability

## Deterministic Steps

### 1. State Transition Management
Validate workflow state definitions and transition rules
Ensure proper state persistence and recovery mechanisms
Check for atomic state changes and consistency guarantees

### 2. Handoff Procedure Implementation
Validate handoff checklists and responsibility transfers
Ensure proper documentation and context passing between phases
Check for rollback and recovery procedures at handoff points

### 3. Communication Protocol Enforcement
Validate inter-service and inter-team communication patterns
Ensure proper async vs sync communication decisions
Check for message formats and contract definitions

### 4. Workflow Orchestration Integration
Validate workflow engine integration and configuration
Ensure proper error handling and retry logic in workflows
Check for workflow monitoring and observability

### 5. Documentation and Knowledge Transfer
Validate workflow documentation and decision records
Ensure proper training materials and runbooks
Check for knowledge transfer procedures and onboarding

## Tool Safety
Test workflows in development environments before production
Validate workflow changes don't break existing processes
Ensure handoff procedures don't create single points of failure
Backup workflow configurations before modifications
Monitor workflow performance and resource usage

## Validation Criteria
Workflow states and transitions properly defined and documented
Handoff procedures clear, documented, and regularly practiced
Communication patterns consistent and effective
Workflow orchestration properly integrated and monitored
Documentation current and accessible to all participants