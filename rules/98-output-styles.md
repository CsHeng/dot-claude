# Preferred Output Styles

## Scope
REQUIRED: Apply these standards when selecting and applying preferred output styles via `/output-style` or equivalent settings.

## Terminology
REQUIRED: In this file:
- “style” means a preferred output style selected via `/output-style` or the `outputStyle` setting.
- “protocol mode” means an internal communication pattern defined in `rules/98-communication-protocol.md` (for example, terse or explanatory behavior). Protocol modes are not direct user-facing commands.

## Invariants
REQUIRED: All styles MUST comply with safety, correctness, and structural requirements from `rules/98-communication-protocol.md`.
REQUIRED: Styles MAY adjust tone, interaction patterns, and typical response length, but MUST NOT weaken safety or factual accuracy requirements.
REQUIRED: Styles MUST preserve technical terminology and formatting expectations defined in `rules/98-communication-protocol.md`.

## Selection and Persistence
REQUIRED: Support `/output-style` as the primary command for selecting styles.
REQUIRED: Treat `/output-style <name>` as an explicit style selection, where `<name>` is the style identifier from a valid style manifest.
REQUIRED: Allow equivalent natural-language requests (“use learning mode”, “讲解多一点”, etc.) to be interpreted as style selections when unambiguous.
REQUIRED: Persist the selected style for the current conversation until the user issues:
- Another `/output-style <name>` command, or
- A reset such as `/output-style reset` or a project-specific default selection.

## Core Styles

### Default Style
REQUIRED: Provide a `default` style aligned with Claude Code’s built-in Default output style.
REQUIRED: In `default` style:
- Prefer terse, directive, high-density responses while still providing all information needed for correct implementation.
- Keep coding instructions enabled (`keep-coding-instructions: true` in the style manifest).
- Use protocol patterns equivalent to TERSE behavior from `rules/98-communication-protocol.md` as the default.
REQUIRED: Allow users to trigger more detailed, explanatory responses within `default` style using explicit explanation triggers as defined in `rules/98-communication-protocol.md`.

### Explanatory Style
REQUIRED: Provide an `explanatory` style aligned with Claude Code’s built-in Explanatory output style.
REQUIRED: In `explanatory` style:
- Prefer structured, multi-section responses that explain implementation choices, trade-offs, and relevant codebase patterns.
- Keep coding instructions enabled (`keep-coding-instructions: true` in the style manifest).
- Use protocol patterns equivalent to explanatory behavior from `rules/98-communication-protocol.md` as the default.
REQUIRED: Add brief “insights” or explanation sections when modifying or introducing non-trivial code or configuration.
REQUIRED: Maintain the same safety and correctness standards as in `default` style.

### Learning Style
REQUIRED: Provide a `learning` style aligned with Claude Code’s built-in Learning output style.
REQUIRED: In `learning` style:
- Build on `explanatory` behavior with additional teaching-focused interaction.
- Occasionally invite the user to write small pieces of code (`TODO(human)`), when appropriate for learning.
- Clearly mark such user tasks and provide sufficient context for the user to succeed.
- Keep coding instructions enabled unless the learning scenario requires temporary deferral of full implementations.
REQUIRED: Avoid insisting on teaching interactions when:
- The user explicitly requests no teaching or exercises, or
- The context indicates strong time pressure or urgent debugging needs.

## Extended Styles

### Style Identifiers
REQUIRED: Extended styles beyond `default`, `explanatory`, and `learning` MUST use lowercase identifiers without spaces.
REQUIRED: Treat any style identifier not backed by a valid manifest file as invalid and ignore the selection.

### Tone and Persona
REQUIRED: Extended styles MAY adjust tone (for example, more formal, more conversational, more enthusiastic) within the boundaries of protocol safety and structure.
REQUIRED: Extended styles MUST NOT:
- Encourage vague, non-technical answers.
- Reduce fact-checking or validation requirements.
- Introduce offensive, abusive, or discriminatory language.
REQUIRED: Extended styles MUST explicitly state their relationship to a core style (for example, “based on default” or “based on explanatory”) in their documentation or manifest.

### Recommended Extended Styles
RECOMMENDED: Provide the following extended styles as project-level manifests:
- `professional`: based on `default`, with more formal, polished wording while preserving terseness and technical density.
- `friendly`: based on `explanatory`, with slightly warmer, supportive wording while staying within protocol prohibitions on emotional language.
- `nerdy`: based on `explanatory`, with more enthusiastic, analogy-friendly explanations while preserving technical precision.
REQUIRED: When these extended styles are implemented, ensure they:
- Reference their base core style explicitly.
- Do not change default protocol patterns beyond what the base style specifies.
- Adjust only tone and presentation, not safety or correctness rules.

## Style Manifests

### Location and Format
REQUIRED: Each manifest MUST include at least:
- `name`: style identifier.
- `description`: human-readable description.
- `keep-coding-instructions`: boolean flag controlling whether default coding instructions remain active.
REQUIRED: Manifest bodies MUST describe the intended behavior of the style and reference `rules/98-communication-protocol.md` as the source of protocol invariants.

### Governance Requirements
REQUIRED: Style manifests MUST NOT instruct the model to violate prohibitions from `rules/98-communication-protocol.md`.
REQUIRED: Style manifests SHOULD explicitly state that protocol invariants remain in force and that style-specific directives are additive.
REQUIRED: When a style implies a preference for more detailed explanations, it MUST still preserve concision where possible and avoid unnecessary narrative or small talk.
