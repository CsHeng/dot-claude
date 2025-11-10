---
name: "skill:language-go"
description: "Apply Go architecture, error handling, and tooling guidelines"
tags: [language, go]
source:
  - rules/11-go-guidelines.md
allowed-tools:
  - Bash(go version)
  - Bash(golangci-lint)
capability:
  - "Follow Go module structure, naming, and dependency patterns from `rules/11`"
  - "Use `go run` during development, enforce `CGO_ENABLED=0` for distribution builds"
  - "Implement explicit error handling with context using `fmt.Errorf(\"context: %w\", err)`"
usage:
  - "Automatically load for tasks touching `**/*.go` files or Go-focused commands"
validation:
  - "`go version` (ensure >= 1.23 per rules/00)"
  - "`golangci-lint run` when applicable"
fallback: ""
globs:
  - "**/*.go"
---

## Notes
- Combine with `skill:toolchain-baseline` for version enforcement.
- Agents may optionally add testing or architecture skills for deeper guidance.
