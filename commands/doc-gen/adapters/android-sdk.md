---
name: "doc-gen:android-sdk"
description: Adapter for Android SDK documentation bootstrap/maintenance
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path> [--demo=<path>]
allowed-tools: Read, Write, Edit, Bash(rg:*), Bash(ls:*), Bash(fd:*), Bash(tree:*), Bash(cat:*), Bash(plantuml --check-syntax:*)
---

## Scope
Focus on Android libraries distributed to external apps. Capture public APIs, integration contracts, lifecycle guarantees, and backend communication. Honor the chosen `--language` for narrative text. Treat any additional documentation bundles discovered during bootstrap (e.g., `docs-release/`) as read-only references: quote their insights, but never modify them.

## Mandatory outputs
- Actor matrix (README) with at least: Host App, SDK Public API, SDK Core/Internal, Backend Services, Telemetry/Analytics Pipeline, Sample/Demo App, Background Scheduler/WorkManager. Include repository-relative file references.
- Validated PlantUML: at least one diagram covering initialization or event tracking. Run `plantuml --check-syntax <diagram>`, append the raw output to `<docs target>/_reports/plantuml.log`, and echo the same line in README.
- Integration checklist: step-by-step host integration covering Gradle setup, permissions, manifest updates, initialization code, Proguard/R8 rules, verification steps.
- TODO backlog & ledger: use `TODO(doc-gen):` format with paths for API docs, sample updates, telemetry flows, publishing configuration, and diagram tasks. Every entry must set `automation=auto`; when a human review is advisable, add `review_required=true` and capture context in the notes. Mirror the items into `<docs target>/_reports/todo.json`.
- Reports bundle: enrich `<docs target>/_reports/parameters.json` and `_reports/todo.json` with adapter metadata (e.g., sdk-version sources, sample paths, read-only doc references such as `docs-release/`). For delta scope, ensure `_reports/changes.txt` reflects which modules were analyzed or skipped.
- SDK / Demo partition: when demo modules are present, produce README sections named `## SDK篇` / `## Demo篇` (`## SDK Section` / `## Demo Section` in English) and mirror the split inside TODO.md so integration tasks stay distinct from core SDK tasks.
- Flow identifiers: assign every major flow an ID matching `[A-Z][0-9][0-9]` (e.g., `A01` for SDK initialization, `D02` for demo login). Reuse the same ID across README headings, PlantUML diagram filenames and `@startuml` bodies, TODO entries, and open-question notes.
- Repository references: in the SDK section cite ≥3 repository-relative paths with line numbers (e.g., `zhiqusdk/.../ZhiquGameSDK.java:55`); in the Demo section cite ≥2 such references. Use the same references to justify TODO entries and diagram narratives.
- TODO syntax: encode metadata as query parameters (`TODO(doc-gen):docs-bootstrap/integration/setup.md?automation=auto&flow=A02[&review_required=true] — description`). Ensure the same `flow=` value appears in README and diagram filenames.

## Preparation checklist
1. Enumerate Gradle modules (`fd --type f --max-depth 2 'build\\.gradle.*' <core>`).
2. Identify public API surface (packages exported via `consumer-proguard-rules.pro`, `api` vs `implementation` dependencies, `@Keep` annotations).
3. Inspect publishing configuration (groupId, artifactId, versioning) and distribution channels.
4. Locate sample or demo apps demonstrating integration.
5. Document min/target SDK versions and required host dependencies.

## Automation defaults
- Treat all SDK deliverables (module inventory, initialization flow, threading model, integration checklists, diagrams) as `automation=auto` and mark TODO entries `[x]` once drafts are generated.
- If something warrants human validation, set `review_required=true` and elaborate in the notes plus README open questions—tasks remain marked complete.
- Use `automation=manual` only when automation is impossible (e.g., access-controlled partner materials). Such cases must be rare and must include exhaustive rationale.
- In `delta` scope, only surface TODO entries for APIs or modules touched in the change list and still complete them during the run.

## Architecture coverage
- Layer diagram: Public API facade, internal core, networking layer, persistence/cache, telemetry/analytics, utilities.
- Initialization flow: configuration builders, authentication setup, dependency injection, lifecycle callbacks.
- Threading model: coroutines, executors, WorkManager jobs, background services.
- Feature flags or remote configuration that alters SDK behavior.

## Integration guidance
- Gradle coordinates, repository declarations, and dependency version table.
- Manifest requirements (permissions, services, providers, receivers).
- Proguard/R8 snippets, consumer Proguard configuration, keep rules.
- Host app initialization snippet (Application.onCreate, first Activity, or lazy init), error handling, retries.
- Callback interfaces, listener registration, events the host must handle.
- Testing recommendations (unit, instrumentation, integration in sample app).
- When demos are available, document how the sample app wires each `Dxx` flow to SDK APIs (e.g., where login is triggered, how floating UI is invoked) and cross-reference the demo section of README.
- Each subsection must anchor statements with concrete references: use repository-relative paths plus line numbers (e.g., `sdk-demo/app/.../MainActivity.java:78`). Avoid placeholder text such as “TBD” or “需要补充”; replace with actionable notes or mark `review_required=true` in TODO.

## Backend & telemetry flows
- Authentication/signature flow for API requests.
- Request/response lifecycle with retry/backoff.
- Event capture, batching, upload schedule, offline persistence.
- Error reporting, crash capture, escalation paths.
- Security considerations: key storage, certificate pinning, tamper detection.

## PlantUML guidance
- Name each diagram `<FlowID>_<slug>.puml` where `<FlowID>` is the shared identifier (e.g., `A01_sdk_initialization.puml`, `D02_demo_login.puml`).  
- Recommended diagrams:  
  - `docs-bootstrap/diagrams/A01_sdk_initialization.puml` (host init handshake).  
  - `docs-bootstrap/diagrams/B01_event_pipeline.puml` (event capture → queue → upload).  
  - `docs-bootstrap/diagrams/C01_error_reporting.puml` (exception collection → processing → callback).  
- Maintain alias registry at top; prefix sections with IDs (`== A. Initialization ==`).  
- Record validation results verbatim in README (e.g., `SUCCESS: plantuml --check-syntax docs-bootstrap/diagrams/A01_sdk_initialization.puml`) and append each line to `<docs target>/_reports/plantuml.log`.
- Diagrams must reference real classes/methods (e.g., `ZhiquGameSDK.init`, `StartupRecordHelper.startupRecord`) rather than generic placeholders.

## Documentation structure recommendations
```
docs-bootstrap/
├── README.md
├── TODO.md
├── integration/
│   ├── setup.md
│   ├── permissions.md
│   └── verification.md
├── architecture/
│   ├── layers.md
│   ├── threading.md
│   └── configuration.md
├── backend/
│   ├── api-contracts.md
│   ├── telemetry.md
│   └── security.md
├── samples/
│   ├── overview.md
│   └── known-issues.md
└── diagrams/
    ├── A01_sdk_initialization.puml
    ├── B01_event_pipeline.puml
    └── C01_error_reporting.puml
```
Highlight any existing materials in `docs/` worth merging once the bootstrap run is approved.
Inside README, follow the sequence: parameter table → repository inventory → `## SDK篇` (`## SDK Section`) → `## Demo篇` (`## Demo Section`, only when demos exist) → cross-cutting appendices (PlantUML status, open questions). Mirror the same grouping in TODO.md, keeping demo-specific checklist items under a dedicated heading and referencing the relevant `Dxx` identifiers.

## Exit criteria
- README covers parameter table, module snapshot, documentation inventory, actor matrix, validated PlantUML results, integration checklist summary, backend/telemetry notes, and open questions.
- TODO backlog populated with `TODO(doc-gen)` entries pointing to actual files (APIs, samples, diagrams, publishing scripts).
- At least one PlantUML diagram validated; failures documented with remediation tasks.
- Integration checklist clearly indicates what the host app team must do to verify the SDK.
- SDK section of README contains ≥3 repository-relative references with line numbers; Demo section (if present) contains ≥2. Any missing references must be added before completion.
- TODO.md has no unchecked entries and every item encodes `flow=` metadata aligned with README headings and diagram filenames.
