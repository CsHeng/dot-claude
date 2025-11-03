#!/usr/bin/env bash
# Helper routines referenced by config-sync commands.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
readonly SCRIPT_DIR
LIB_DIR="${SCRIPT_DIR%/scripts}/lib"
readonly LIB_DIR
CLAUDE_CONFIG_DIR="${HOME}/.claude"
readonly CLAUDE_CONFIG_DIR

if [[ -f "$LIB_DIR/common.sh" ]]; then
  # Optional: load shell-specific helpers if provided.
  source "$LIB_DIR/common.sh"
fi

# Error handling and logging utilities
log_info() {
  echo "[INFO] $*" >&2
}

log_warn() {
  echo "[WARN] $*" >&2
}

log_error() {
  echo "[ERROR] $*" >&2
}

# Pre-flight checks for dependencies
check_dependencies() {
  local missing_deps=()

  # Check for required commands
for cmd in python3 rsync mv mkdir; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_deps+=("$cmd")
    fi
  done

  # Optional but recommended dependencies
  local optional_deps=()
  for cmd in jq rsync sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      optional_deps+=("$cmd")
    fi
  done

  # Report missing required dependencies
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    return 1
  fi

  # Report missing optional dependencies
  if [[ ${#optional_deps[@]} -gt 0 ]]; then
    log_warn "Missing optional dependencies (some features may be limited): ${optional_deps[*]}"
  fi

  return 0
}

# Check target tool installation and directory structure
check_target_tool() {
  local target_tool="$1"

  case "$target_tool" in
    qwen)
      # Check if qwen directories exist or can be created
      local qwen_dir="${HOME}/.qwen"
      if [[ -d "$qwen_dir" ]] || mkdir -p "$qwen_dir" 2>/dev/null; then
        log_info "Qwen directory accessible: $qwen_dir"
        return 0
      else
        log_error "Cannot create/access Qwen directory: $qwen_dir"
        return 1
      fi
      ;;
    droid|factory)
      # Check for Factory directories
      local factory_dir
      factory_dir="$(get_target_config_dir droid)"
      if [[ -d "$factory_dir" ]] || mkdir -p "$factory_dir" 2>/dev/null; then
        log_info "Factory/Droid directory accessible: $factory_dir"
        return 0
      else
        log_error "Cannot create/access Factory/Droid directory: $factory_dir"
        return 1
      fi
      ;;
    opencode)
      # Check for opencode configuration
      local opencode_dir
      opencode_dir="$(get_target_config_dir opencode)"
      if [[ -d "$opencode_dir" ]] || mkdir -p "$opencode_dir" 2>/dev/null; then
        log_info "OpenCode directory accessible: $opencode_dir"
        return 0
      else
        log_error "Cannot create/access OpenCode directory: $opencode_dir"
        return 1
      fi
      ;;
    codex)
      # Check for codex configuration
      local codex_dir="${HOME}/.codex"
      if [[ -d "$codex_dir" ]] || mkdir -p "$codex_dir" 2>/dev/null; then
        log_info "Codex directory accessible: $codex_dir"
        return 0
      else
        log_error "Cannot create/access Codex directory: $codex_dir"
        return 1
      fi
      ;;
    *)
      log_error "Unsupported target tool: $target_tool"
      return 1
      ;;
  esac
}

# Validate source configuration
validate_source_config() {
  local source_dir="$1"

  [[ -d "$source_dir" ]] || {
    log_error "Source directory not found: $source_dir"
    return 1
  }

  # Check for essential configuration components
  local required_dirs=("commands" "rules")
  local missing_dirs=()

  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$source_dir/$dir" ]]; then
      missing_dirs+=("$dir")
    fi
  done

  if [[ ${#missing_dirs[@]} -gt 0 ]]; then
    log_warn "Missing optional source directories: ${missing_dirs[*]}"
  fi

  return 0
}

# Atomic write with backup and verification
write_with_backup() {
  local src="$1"
  local dest="$2"
  local backup_dir="$3"

  # Validate inputs
  [[ -f "$src" ]] || {
    echo "[ERROR] Source file not found: $src" >&2
    return 1
  }

  # Create backup directory if it doesn't exist
  if [[ -n "$backup_dir" ]]; then
    mkdir -p "$backup_dir" || {
      echo "[ERROR] Failed to create backup directory: $backup_dir" >&2
      return 1
    }

    # Create timestamped backup if destination exists
    if [[ -f "$dest" ]]; then
      local timestamp
      timestamp="$(date +%Y%m%d-%H%M%S-%N)"
      local backup_file="$backup_dir/$(basename "$dest").$timestamp.bak"

      rsync -a --quiet "$dest" "$backup_file" || {
        echo "[ERROR] Failed to create backup: $backup_file" >&2
        return 1
      }
      echo "[INFO] Created backup: $backup_file" >&2
    fi
  fi

  # Create destination directory
  mkdir -p "$(dirname "$dest")" || {
    echo "[ERROR] Failed to create destination directory: $(dirname "$dest")" >&2
    return 1
  }

  # Atomic write: use temp file + move
  local temp_file="${dest}.tmp.$$"

  # Sync to temporary file first
  if rsync -a --quiet "$src" "$temp_file"; then
    # Verify sync succeeded
    if [[ -f "$temp_file" ]]; then
      # Move temp file to final destination (atomic operation)
      if mv "$temp_file" "$dest"; then
        echo "[INFO] Successfully wrote: $dest" >&2
        return 0
      else
        echo "[ERROR] Failed to move temporary file to destination: $dest" >&2
        rm -f "$temp_file"  # Clean up temp file
        return 1
      fi
    else
      echo "[ERROR] Temporary file not created: $temp_file" >&2
      return 1
    fi
  else
    echo "[ERROR] Failed to sync source to temporary file: $src -> $temp_file" >&2
    rm -f "$temp_file"  # Clean up temp file
    return 1
  fi
}

# Safe sync with verification
sync_with_verification() {
  local src="$1"
  local dest="$2"

  # Validate inputs
  [[ -f "$src" ]] || {
    echo "[ERROR] Source file not found: $src" >&2
    return 1
  }

  # Create destination directory
  mkdir -p "$(dirname "$dest")" || {
    echo "[ERROR] Failed to create destination directory: $(dirname "$dest")" >&2
    return 1
  }

  # Sync file
  if rsync -a --quiet "$src" "$dest"; then
    # Verify sync was successful
    if [[ -f "$dest" && -s "$dest" ]]; then
      # Optional: checksum verification for critical files
      if command -v sha256sum >/dev/null 2>&1; then
        local src_checksum dest_checksum
        src_checksum="$(sha256sum "$src" | cut -d' ' -f1)"
        dest_checksum="$(sha256sum "$dest" | cut -d' ' -f1)"

        if [[ "$src_checksum" == "$dest_checksum" ]]; then
          echo "[INFO] Verified sync: $src -> $dest" >&2
          return 0
        else
          echo "[ERROR] Checksum mismatch during sync: $src -> $dest" >&2
          rm -f "$dest"  # Remove corrupted output
          return 1
        fi
      else
        echo "[INFO] Synced: $src -> $dest" >&2
        return 0
      fi
    else
      echo "[ERROR] Sync verification failed: $dest" >&2
      return 1
    fi
  else
    echo "[ERROR] Failed to sync: $src -> $dest" >&2
    return 1
  fi
}

render_template() {
  local template="$1"
  local output="$2"
  envsubst < "$template" > "$output"
}

sync_with_sanitization() {
  local src="$1"
  local dest="$2"

  # Use the safe sync function as base
  if sync_with_verification "$src" "$dest"; then
    # TODO: Add markdown sanitization or other transforms here if needed
    return 0
  else
    return 1
  fi
}

backup_file() {
  local src="$1"
  local backup_dir="${2:-$(dirname "$src")/backup}"

  if [[ ! -f "$src" ]]; then
    log_warn "No existing file to back up: $src"
    return 0
  fi

  mkdir -p "$backup_dir" || {
    log_error "Failed to create backup directory: $backup_dir"
    return 1
  }

  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S-%N)"
  local backup_file_path="$backup_dir/$(basename "$src").$timestamp.bak"

  if rsync -a --quiet "$src" "$backup_file_path"; then
    log_info "Created backup: $backup_file_path"
    return 0
  else
    log_error "Failed to create backup: $backup_file_path"
    return 1
  fi
}

# Convert Markdown command with YAML frontmatter to Qwen TOML format
convert_markdown_to_toml() {
  local md_file="$1"
  local toml_file="$2"
  local target_tool="${3:-qwen}"

  [[ -f "$md_file" ]] || {
    echo "[ERROR] Source file not found: $md_file" >&2
    return 1
  }

  # Create target directory
  mkdir -p "$(dirname "$toml_file")"

  # Use python3 for proper YAML frontmatter parsing and TOML generation
  python3 << EOF
import re
import sys
import os

md_file = "$md_file"
toml_file = "$toml_file"
target_tool = "$target_tool"

try:
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Parse YAML frontmatter
    description = ""
    frontmatter_match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)$', content, re.DOTALL)

    is_background = False

    if frontmatter_match:
        frontmatter, command_content = frontmatter_match.groups()
        # Extract description from frontmatter
        desc_match = re.search(r'description:\s*["\']?([^"\'\n]+)["\']?', frontmatter)
        if desc_match:
            description = desc_match.group(1).strip()
        background_match = re.search(r'is_background:\s*([^\n]+)', frontmatter)
        if background_match:
            value = background_match.group(1).strip().strip('"\'').lower()
            if value in {"true", "yes", "1"}:
                is_background = True
            elif value in {"false", "no", "0"}:
                is_background = False
        body_content = command_content.strip()
    else:
        # No frontmatter found, treat entire file as content
        body_content = content.strip()

    # Generate description if not found
    if not description:
        base_name = os.path.basename(md_file)
        name_without_ext = os.path.splitext(base_name)[0]
        description = f"Converted from {base_name} for {target_tool}"

    # Convert content for target tool
    if target_tool == "qwen":
        body_content = re.sub(r'\$ARGUMENTS', '{{args}}', body_content)
        body_content = re.sub(r'\$[0-9]+', '{{args}}', body_content)
        body_content = re.sub(r'@CLAUDE\.md', '@QWEN.md', body_content)

    # Escape quotes in content for TOML
    body_content_escaped = body_content.replace('"""', r'\"\"\"')
    description_escaped = description.replace('"', r'\"')

    toml_lines = [
        f"# Generated from {md_file} by Claude Code config-sync",
        "",
        f'description = "{description_escaped}"'
    ]

    if target_tool == "qwen":
        toml_lines.append(f"is_background = {'true' if is_background else 'false'}")

    toml_lines.extend([
        "",
        f'prompt = """{body_content_escaped}"""',
        ""
    ])

    toml_content = "\n".join(toml_lines)

    # Write TOML file
    with open(toml_file, 'w', encoding='utf-8') as f:
        f.write(toml_content)

    print(f"[SUCCESS] Converted {md_file} to {toml_file}", file=sys.stderr)

except Exception as e:
    print(f"[ERROR] Failed to convert {md_file}: {e}", file=sys.stderr)
    sys.exit(1)
EOF

  [[ $? -eq 0 ]] || {
    echo "[ERROR] TOML conversion failed for $md_file" >&2
    return 1
  }
}

# Sync config-sync commands to target tool with TOML conversion
sync_config_sync_commands() {
  local target_tool="${1:-qwen}"
  local source_dir="${2:-$HOME/.claude/commands/config-sync}"
  local target_base="${3:-$HOME/.$target_tool/commands/config-sync}"

  log_info "Syncing config-sync commands for $target_tool"

  # Pre-flight checks
  check_dependencies || return 1
  check_target_tool "$target_tool" || return 1
  validate_source_config "$source_dir" || return 1

  # Create target base directory
  if ! mkdir -p "$target_base"; then
    log_error "Failed to create target directory: $target_base"
    return 1
  fi

  local processed_files=0
  local failed_files=0

  # Convert core commands
  if [[ -d "$source_dir/core" ]]; then
    log_info "Processing core commands..."
    mkdir -p "$target_base/core"

    for cmd_file in "$source_dir/core"/*.md; do
      if [[ -f "$cmd_file" ]]; then
        cmd_name="$(basename "$cmd_file" .md)"
        toml_file="$target_base/core/${cmd_name}.toml"

        if convert_markdown_to_toml "$cmd_file" "$toml_file" "$target_tool"; then
          ((processed_files += 1))
          log_info "✓ Converted: $cmd_name"
        else
          ((failed_files += 1))
          log_error "✗ Failed to convert: $cmd_name"
        fi
      fi
    done
  fi

  # Convert adapter commands
  if [[ -d "$source_dir/adapters" ]]; then
    log_info "Processing adapter commands..."
    mkdir -p "$target_base/adapters"

    for cmd_file in "$source_dir/adapters"/*.md; do
      if [[ -f "$cmd_file" ]]; then
        cmd_name="$(basename "$cmd_file" .md)"
        toml_file="$target_base/adapters/${cmd_name}.toml"

        if convert_markdown_to_toml "$cmd_file" "$toml_file" "$target_tool"; then
          ((processed_files += 1))
          log_info "✓ Converted: $cmd_name"
        else
          ((failed_files += 1))
          log_error "✗ Failed to convert: $cmd_name"
        fi
      fi
    done
  fi

  # Convert root-level commands
  for cmd_file in "$source_dir"/*.md; do
    if [[ -f "$cmd_file" ]]; then
      cmd_name="$(basename "$cmd_file" .md)"
      toml_file="$target_base/${cmd_name}.toml"

      if convert_markdown_to_toml "$cmd_file" "$toml_file" "$target_tool"; then
        ((processed_files += 1))
        log_info "✓ Converted: $cmd_name"
      else
        ((failed_files += 1))
        log_error "✗ Failed to convert: $cmd_name"
      fi
    fi
  done

  # Summary
  log_info "Sync complete: $processed_files files processed, $failed_files files failed"

  if [[ $failed_files -gt 0 ]]; then
    log_warn "Some files failed to convert. Check logs above for details."
    return 1
  else
    log_info "All config-sync commands synced successfully to $target_base"
    return 0
  fi
}

echo "[executor] helper script loaded" >&2
