#!/usr/bin/env bash
set -euo pipefail

# Skill Capability Matrix
# Summarize skills, their capability levels, modes, styles, and tags.
# Usage:
#   commands/agent-ops/scripts/skill-matrix.sh [root-dir]
#
# Defaults to current directory as repo root.

ROOT_DIR="${1:-.}"

printf "%-32s %-5s %-16s %-16s %-40s\n" "Skill" "Lvl" "Mode" "Style" "Tags"
printf "%-32s %-5s %-16s %-16s %-40s\n" "$(printf '%.0s-' {1..32})" "$(printf '%.0s-' {1..5})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..40})"

for f in "${ROOT_DIR}"/skills/*/SKILL.md; do
  [ -f "$f" ] || continue

  name=$(rg -n '^name:' -m 1 "$f" 2>/dev/null | sed 's/^.*name:[[:space:]]*//')
  level=$(rg -n '^capability-level:' -m 1 "$f" 2>/dev/null | awk '{print $2}')
  mode=$(rg -n '^mode:' -m 1 "$f" 2>/dev/null | sed 's/^.*mode:[[:space:]]*//')
  style=$(rg -n '^style:' -m 1 "$f" 2>/dev/null | sed 's/^.*style:[[:space:]]*//')

  tags=$(
    awk '
      /^tags:/ {flag=1; next}
      flag && /^[[:space:]]*-/ {
        gsub(/^[[:space:]]*-[[:space:]]*/, "", $0);
        if (out == "") { out = $0 } else { out = out "," $0 }
      }
      flag && !/^[[:space:]]*-/ {flag=0}
      END { print out }
    ' "$f"
  )

  printf "%-32s %-5s %-16s %-16s %-40s\n" \
    "${name:-}" "${level:-}" "${mode:-}" "${style:-}" "${tags:-}"
done

