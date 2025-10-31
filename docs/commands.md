# Custom Command Directory (`~/.claude/commands/`)

Stores personal Claude custom slash commands. Each Markdown file becomes a command named after the filename (without extension). Executable files with a shebang are also supported.

## Current Commands
- `review-shell-syntax.md` – Reviews a shell script, references shell guidelines, and runs syntax checks before reporting results.
- `sync-droid-commands.md` – Slash command wrapper that runs `~/.claude/sync-user-commands.sh` with optional arguments to refresh Droid CLI commands.
- `draft-commit-message.md` – Collects `git status`/`git diff` output, proposes a commit message, and waits for human confirmation before any commit.

## Guidelines
- Keep filenames concise; nested directories are flattened when syncing into Droid CLI (via `sync-user-commands.sh`).
- Use only frontmatter keys supported by both Claude and Droid (`description`, `argument-hint`).
- Use `$ARGUMENTS` instead of positional placeholders so all supported agents behave consistently.
- After modifying commands, run `./sync-user-commands.sh` to mirror them into `~/.factory/commands/`.
