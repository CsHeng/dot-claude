# Doc Gen Plugin

Provides the `/doc-gen:*` command namespace for architecture documentation workflows. The plugin separates shared orchestration logic from project-type adapters so that future updates remain modular.

## Components

- `core/` – Self-contained orchestrator prompt that gathers inputs, validates context, enforces output format, and delegates to adapters.
- `adapters/` – Project-type specific guidance loaded on demand.
- `lib/` – Shared conventions (logging, tables, TODO format, PlantUML notes) used across adapters.
- `settings.json` – Default runtime options for the plugin (optional for now).

## Usage

Invoke the orchestrator command directly from Claude Code, passing the target project type:

```
/doc-gen:bootstrap --project-type=android-app --mode=bootstrap --language=en --repo=<path> --docs=<path> --core=<path>
/doc-gen:bootstrap --project-type=android-sdk --mode=maintain --language=zh --repo=<path> --docs=<path> --core=<path> --demo=<path>
```

During runtime the command presents a consolidated checklist for `mode`, `project-type`, and `language`, minimizing free-text input. Paths still accept manual entry, but the orchestrator attempts to auto-suggest common directories. Bootstrap runs stage output in `docs-bootstrap/` so existing `docs/` content remains read-only; maintain runs operate on `docs/` unless overridden. The orchestrator now enforces deliverables directly (parameter table, asset counts, actor matrix, validated PlantUML results, `TODO(doc-gen)` backlog) before handing off control. It then merges in project-type specifics from `adapters/`. Add new project types by creating additional adapter files and referencing them in the orchestrator registry.
