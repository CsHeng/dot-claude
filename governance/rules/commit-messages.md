---
name: rule-block:commit-messages
description: Apply commit message standards when generating or reviewing commit messages.
layer: governance
sources:
  - rules/01-development-standards.md#validation-rules.version-control
---

# Rule Block: Commit Messages

## Purpose

Ensure that all generated commit messages (for example via `/draft-commit-message`) comply with
the commit message requirements defined in `rules/01-development-standards.md` under
`validation-rules.version-control`.

## Normative Requirements (Referenced)

From `rules/01-development-standards.md`:

- REQUIRED: Use imperative mood for commit messages: "Add feature" not "Added feature".
- REQUIRED: Make atomic commits representing single logical changes.
- OPTIONAL: Include context in commit body for complex changes.
- REQUIRED: Use descriptive branch names and keep branches focused on single features or fixes.

## Application to /draft-commit-message

When `/draft-commit-message` is invoked:

- The proposed commit subject **must**:
  - Be written in imperative mood.
  - Reflect a single logical change in the scoped directory.
- The proposed body **should**:
  - Provide sufficient context for complex changes.
  - Reference files or components when helpful, without duplicating raw `git diff` output.
- The agent **must**:
  - Avoid suggesting messages that clearly mix unrelated concerns.
  - Prefer recommending that the user split changes into multiple commits when needed.

