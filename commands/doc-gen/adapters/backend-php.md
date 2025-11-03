---
name: "doc-gen:backend-php"
description: Stub adapter for PHP backend documentation workflow
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>
---

Support for `backend-php` projects is forthcoming. During orchestration runs, concentrate on routing definitions, controllers, service providers, queue workers, and deployment routines. Record specific `TODO(doc-gen)` markers with `automation=manual`, mark them `[x] (manual follow-up required)`, and include rationale so `_reports/todo.json` captures the outstanding work. Also add a stub notice to `<docs target>/_reports/parameters.json` and honor the `--language` selection when emitting notes.
