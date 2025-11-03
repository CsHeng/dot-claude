---
name: "doc-gen:android-sdk"
description: Adapter for Android SDK documentation bootstrap/maintenance
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path> [--demo=<path>]
allowed-tools: Read, Bash(rg:*), Bash(ls:*), Bash(find:*), Bash(tree:*), Bash(cat:*)
---

## Scope
Focus on Android libraries distributed to external apps. Capture public APIs, integration contracts, lifecycle guarantees, and backend communication. Honor the chosen `--language` for narrative text.

## Mandatory outputs
- **Actor matrix** (README) with at least: Host App, SDK Public API, SDK Core/Internal, Backend Services, Telemetry/Analytics Pipeline, Sample/Demo App, Background Scheduler/WorkManager. Include repository-relative file references.
- **Validated PlantUML**: at least one diagram covering initialization or event tracking. Run `plantuml --check-syntax <diagram>` and document the command output in README.
- **Integration checklist**: step-by-step host integration covering Gradle setup, permissions, manifest updates, initialization code, Proguard/R8 rules, verification steps.
- **TODO backlog**: use `TODO(doc-gen):` format with paths for API docs, sample updates, telemetry flows, publishing configuration, and diagram tasks.

## Preparation checklist
1. Enumerate Gradle modules (`find <core> -maxdepth 2 -name build.gradle*`).
2. Identify public API surface (packages exported via `consumer-proguard-rules.pro`, `api` vs `implementation` dependencies, `@Keep` annotations).
3. Inspect publishing configuration (groupId, artifactId, versioning) and distribution channels.
4. Locate sample or demo apps demonstrating integration.
5. Document min/target SDK versions and required host dependencies.

## Architecture coverage
- Layer diagram: Public API facade, internal core, networking layer, persistence/cache, telemetry/analytics, utilities.
- Initialization flow: configuration builders, authentication setup, dependency injection, lifecycle callbacks.
- Threading model: coroutines, executors, WorkManager jobs, background services.
- Feature flags or remote configuration that alters SDK behavior.

## Integration guidance
- Gradle coordinates, repository declarations, and version matrix.
- Manifest requirements (permissions, services, providers, receivers).
- Proguard/R8 snippets, consumer Proguard configuration, keep rules.
- Host app initialization snippet (Application.onCreate, first Activity, or lazy init), error handling, retries.
- Callback interfaces, listener registration, events the host must handle.
- Testing recommendations (unit, instrumentation, integration in sample app).

## Backend & telemetry flows
- Authentication/signature flow for API requests.
- Request/response lifecycle with retry/backoff.
- Event capture, batching, upload schedule, offline persistence.
- Error reporting, crash capture, escalation paths.
- Security considerations: key storage, certificate pinning, tamper detection.

## PlantUML guidance
- Recommended diagrams:  
  - `docs-bootstrap/diagrams/A01_sdk_initialization.puml` (host init handshake).  
  - `docs-bootstrap/diagrams/B01_event_pipeline.puml` (event capture → queue → upload).  
  - `docs-bootstrap/diagrams/C01_error_reporting.puml` (exception collection → processing → callback).  
- Maintain alias registry at top; prefix sections with IDs (`== A. Initialization ==`).  
- Record validation results verbatim in README (e.g., `SUCCESS: plantuml --check-syntax docs-bootstrap/diagrams/A01_sdk_initialization.puml`).

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

## Exit criteria
- README covers parameter table, module snapshot, documentation inventory, actor matrix, validated PlantUML results, integration checklist summary, backend/telemetry notes, and open questions.
- TODO backlog populated with `TODO(doc-gen)` entries pointing to actual files (APIs, samples, diagrams, publishing scripts).
- At least one PlantUML diagram validated; failures documented with remediation tasks.
- Integration checklist clearly indicates what the host app team must do to verify the SDK.
