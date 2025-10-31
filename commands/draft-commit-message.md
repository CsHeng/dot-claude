---
description: Propose a commit message from current git status (no commit)
argument-hint: [optional-summary-notes]
allowed-tools: Bash(git status --short), Bash(git diff --cached), Bash(git diff)
---

## Context gathering
- Run the following commands and include their outputs in your reasoning (do not modify the working tree):
  - `git status --short`
  - `git diff --cached`
  - `git diff`
- If any command fails, stop and report the error.

## Your task
- Summarize the intent of the changes and draft a commit message proposal:
  - A one-line subject (~50 chars, imperative mood)
  - Bullet points for key modifications and files touched
- Incorporate optional human notes from `$ARGUMENTS` if provided.
- Highlight any files with unstaged changes that may need review.
- Explicitly confirm with the human before running any commit commands; never execute `git commit` yourself.
