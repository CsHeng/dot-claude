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
  # Load common functions including logging utilities
  source "$LIB_DIR/common.sh"
fi

# Note: Logging functions (log_info, log_warn, log_warning, log_error, log_success)
# are now loaded from common.sh to ensure consistency across all scripts

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
    amp)
      local amp_dir
      amp_dir="$(get_target_config_dir amp)"
      if ! command -v amp >/dev/null 2>&1; then
        log_warning "Amp CLI not found in PATH; install via https://ampcode.com/manual#cli"
      fi
      if [[ -d "$amp_dir" ]] || mkdir -p "$amp_dir" 2>/dev/null; then
        log_info "Amp directory accessible: $amp_dir"
        return 0
      else
        log_error "Cannot create/access Amp directory: $amp_dir"
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

# Atomic write without backup (backup handled by prepare phase)
write_with_backup() {
  local src="$1"
  local dest="$2"
  # backup_dir parameter removed - backup handled by prepare phase

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

  # Atomic write: use temp file + move
  local temp_file="${dest}.tmp.$$"

  # Copy to temporary file first
  if rsync -a --quiet "$src" "$temp_file"; then
    # Verify copy succeeded
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
    echo "[ERROR] Failed to copy source to temporary file: $src -> $temp_file" >&2
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

sync_claude_memory_file() {
  local destination_file="$1"
  local force_overwrite="${2:-false}"
  local source_file="$CLAUDE_CONFIG_DIR/CLAUDE.md"

  if [[ ! -f "$source_file" ]]; then
    log_error "Source CLAUDE.md not found: $source_file"
    return 1
  fi

  mkdir -p "$(dirname "$destination_file")"

  # Note: Backup is now handled by prepare phase, no individual backup here

  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$source_file" "$destination_file"
  else
    cp "$source_file" "$destination_file"
  fi

  log_info "Copied CLAUDE.md to $destination_file"
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

  # Use Python module for YAML frontmatter parsing and TOML generation
  if ! python3 -m config_sync.markdown_to_toml convert "$md_file" "$toml_file" --target-tool "$target_tool" 1>/dev/null; then
    echo "[ERROR] TOML conversion failed for $md_file" >&2
    return 1
  fi
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

# Only show loading message once if not already loaded
if [[ -z "${EXECUTOR_HELPER_LOADED:-}" ]]; then
  log_info "[executor] helper script loaded"
  export EXECUTOR_HELPER_LOADED=1
fi
