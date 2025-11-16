---
name: project-doc-gen-overview
description: Provide structured doc-gen system and plugin overview. Use when doc-gen architecture guidance is required.
tags:
  - project
  - doc-gen
  - architecture
  - docs
mode: project-knowledge
capability-level: 1
style: reasoning-first
source:
  - commands/doc-gen/README.md
  - docs/directory-structure.md
capability: >
  Summarize the doc-gen plugin architecture, core bootstrap workflow, adapter layout,
  and relevant .claude directory semantics so agents can reason about documentation
  generation without re-parsing all documentation.
usage:
  - "Load with agent:doc-gen when high-level doc-gen architecture or directory questions must be answered."
  - "Use to resolve questions about adapter layout, plugin directories, and how doc-gen integrates with .claude structure."
validation:
  - "Keep directory layout and component responsibilities aligned with commands/doc-gen/README.md."
  - "Keep .claude directory descriptions aligned with docs/directory-structure.md."
  - "Verify adapter file paths and core bootstrap command remain valid."
allowed-tools: []
---

## Purpose
Provide a governed entry point for doc-gen system knowledge, including plugin architecture, adapter layout, and relevant .claude directory semantics derived from documentation.

## IO Semantics
Input: Questions or tasks that require understanding of doc-gen architecture, adapter files, or .claude directory structure for documentation generation.
Output: Normalized descriptions of doc-gen components, adapter responsibilities, and directory semantics with pointers to relevant documentation sections.
Side Effects: None. Read-only access to documentation and command reference files.

## Deterministic Steps

1. Documentation Loading
   - Load commands/doc-gen/README.md for doc-gen plugin architecture, directory layout, and adapter responsibilities.
   - Load docs/directory-structure.md for .claude directory semantics and configuration priority.

2. Component and Adapter Extraction
   - Extract the core orchestrator location and purpose.
   - Extract adapter file names and their high-level roles (android-app, android-sdk, backend-go, backend-php, web-admin, web-user).
   - Extract shared library location and its responsibilities.

3. Directory Semantics Extraction
   - Identify which directories under commands/doc-gen/ are orchestration, adapters, and shared utilities.
   - Map those directories into the global .claude directory model described in docs/directory-structure.md.

4. Answer Generation
   - When invoked by agent:doc-gen or related agents, answer using extracted architecture, adapter mapping, and directory semantics.
   - Avoid inventing new directory names or flows; answer strictly within the documented model.
   - When information is missing, direct agents to consult the underlying documentation rather than guessing.

## Validation Criteria
- Doc-gen directory layout in this skill matches commands/doc-gen/README.md.
- Adapter names and roles match commands/doc-gen/adapters/*.md.
- .claude directory semantics match docs/directory-structure.md.
- Responses remain consistent with documentation and do not introduce undocumented behaviors.
