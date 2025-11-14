---
name: "doc-gen:backend-go"
description: "Stub adapter for Go backend documentation workflow"
argument-hint: "--mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(find:*)
disable-model-invocation: true
is_background: false
---

Adapter pending implementation. When using the core orchestrator, capture TODOs for `cmd/` entrypoints, `internal/` service layers, background jobs, and data stores. Mark each TODO with `automation=manual`, check it off as `[x]` with a `(manual follow-up required)` note, and explain the missing coverage so `_reports/todo.json` and README both reflect the gap. Log the adapter stub notice in `<docs target>/_reports/parameters.json` and recommend consulting `rules/11-go-guidelines.md` for language specifics until a dedicated adapter is added. Align interim documentation output with the chosen `--language`.
