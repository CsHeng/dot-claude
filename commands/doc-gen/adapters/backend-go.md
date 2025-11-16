---
name: "doc-gen:backend-go"
description: "Stub adapter for Go backend documentation workflow"
argument-hint: "--mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(fd:*)
disable-model-invocation: true
is_background: false
---

## Usage

This adapter is a stub specification for Go backend projects. Use `/doc-gen:core:bootstrap` with project-type `backend-go`; the core command will consult this file for TODO and documentation expectations.

## Arguments

No additional CLI arguments beyond those accepted by `/doc-gen:core:bootstrap`. Mode, repository, docs, and core paths are inherited from the core command.

## Workflow

1. Treat this adapter as a specification only; no direct execution.
2. When the core orchestrator runs for `backend-go`, capture TODOs for:
   - `cmd/` entrypoints
   - `internal/` service layers
   - background jobs
   - data stores and migrations.
3. Mark each TODO with `automation=manual`, check it off as `[x]` with a `(manual follow-up required)` note, and explain missing coverage so `_reports/todo.json` and README both reflect the gap.
4. Log the adapter stub notice in `<docs target>/_reports/parameters.json` and recommend consulting `rules/11-go-guidelines.md` for language specifics.

## Output

When used by the core orchestrator, this adapter contributes:
- TODO entries describing missing backend documentation coverage.
- Parameters and stub metadata recorded in `_reports/parameters.json`.
- Guidance to consult Go guidelines until a dedicated adapter is implemented.
