---
name: agent:review-golang-syntax
description: Check Go code for syntax and guideline issues and propose minimal patches
allowed-tools:
  - Read
  - Bash(go build:*)
  - Bash(go vet:*)
  - Bash(gofmt:*)
  - Bash(golangci-lint:*)
---

# Review Go Syntax Agent

## Run

- Run syntax check (`go build` or `go vet`) on the Go file.
- Run `golangci-lint` when available.
- Run `gofmt -d` to detect formatting issues.
- Propose minimal patches that preserve behavior.

## Output

Summarize:
- Errors and warnings with locations
- Patch suggestions for the smallest safe fix
