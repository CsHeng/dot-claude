## Shared Conventions

These notes are bundled with the doc-gen module so adapters can stay consistent without referencing external rule files. Copy wording as needed.

### Logging
- Use `=== Stage` for high-level headings, `--- Detail` for sub-items.
- Prefix successful actions with `SUCCESS:` and errors with `ERROR:` followed by short context.

### Parameter Summary Table (README)
```
| Parameter      | Value |
| -------------- | ----- |
| Mode           | bootstrap |
| Project Type   | android-app |
| Language       | English |
| Repository     | <repo> |
| Core Path      | <core> |
| Docs Target    | <docs> |
| Demo Path      | <demo or n/a> |
```

### TODO Format
- Every actionable item must start with `TODO(doc-gen):`.
- Append a repository-relative path in parentheses: `TODO(doc-gen): document login ViewModel state machine (app/src/main/java/.../LoginViewModel.kt)`.

### Actor Matrix Template
```
Actor | Role | Code references | Notes
--- | --- | --- | ---
End User | Uses the Android UI | app/src/.../MainActivity.kt | Primary persona
Android App UI | Presentation layer | app/src/.../ui | Connects users to ViewModels
...
```

### PlantUML Validation Notes
- Store diagrams under the selected docs directory (e.g., `docs-bootstrap/diagrams/`).
- Maintain alias registry at the top of each diagram.
- After running `plantuml --check-syntax <diagram>`, capture the output string and place it in README under the PlantUML section.

### Inventory Checklist
- Count markdown files with `find <docs> -name "*.md" -type f | wc -l`.
- Count PlantUML files with `find <docs> -name "*.puml" -type f | wc -l`.
- List significant documentation assets (README, ADRs, flow charts) with relative paths.
