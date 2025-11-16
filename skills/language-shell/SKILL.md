---
name: language-shell
description: Shell scripting standards and safety practices. Use when language shell
  guidance is required.
mode: language-guidelines
capability-level: 1
allowed-tools:
- Bash(shellcheck)
---

# Shell Script Safety Standards

## Strict Mode Implementation

### Mandatory Strict Mode Configuration

Apply strict mode to all shell scripts:
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

Strict mode components:
- `set -e`: Exit immediately on command failure
- `set -u`: Treat unset variables as errors
- `set -o pipefail`: Exit on pipeline failures
- `IFS=$'\n\t'`: Safe field separator handling

### Error Handling and Traps

Implement comprehensive error handling:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Error handling function
error_handler() {
    local line_number=$1
    local exit_code=$2
    echo "Error occurred in script at line ${line_number} with exit code ${exit_code}" >&2
    cleanup_resources
    exit ${exit_code}
}

# Set up error trap
trap 'error_handler ${LINENO} $?' ERR

# Cleanup function
cleanup_resources() {
    # Remove temporary files
    # Kill background processes
    # Restore original state
    rm -f /tmp/script_temp_*
}
```

## Variable Safety and Quoting

### Safe Variable Practices

Apply safe variable handling:
- Quote all variable expansions: `"$variable"`
- Use parameter expansion for defaults: `"${VAR:-default}"`
- Validate variables before use
- Use arrays for lists instead of space-separated strings

Safe variable expansion patterns:
```bash
# Always quote variables
echo "Processing file: $filename"          # Unsafe
echo "Processing file: $filename"          # Safe

# Use parameter expansion for defaults
OUTPUT_DIR="${1:-/tmp/output}"

# Validate variables before use
if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "DATABASE_URL is required" >&2
    exit 1
fi

# Use arrays for lists
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    process_file "$file"
done
```

### Parameter Expansion Safety

Use safe parameter expansion:
```bash
# Length checking
if [[ ${#input_string} -gt 100 ]]; then
    echo "Input too long" >&2
    exit 1
fi

# Pattern matching and replacement
clean_filename="${filename//[[:space:]]/_}"
safe_path="${path//\//_}"

# Conditional assignment
DEBUG="${DEBUG:-0}"
VERBOSE="${VERBOSE:-0}"

# Remove prefix/suffix
basename="${filename#prefix_}"
extension="${filename%.txt}"
```

## Portable Shell Programming

### POSIX Compliance Standards

Write portable shell scripts:
- Use `#!/bin/sh` for POSIX compliance when Bash features not needed
- Avoid Bash-specific extensions in portable scripts
- Test with multiple shell interpreters
- Use standard Unix utilities with portable options

Portable scripting patterns:
```bash
#!/bin/sh
# POSIX-compliant script

# Portable variable assignment
output_file="/tmp/output.txt"

# Portable command substitution
current_date=$(date '+%Y-%m-%d')

# Portable conditional statements
if [ -f "$output_file" ]; then
    echo "File exists"
fi

# Portable loop
for file in *.txt; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
    fi
done
```

### Bash-Specific Features

Use Bash features appropriately:
```bash
#!/usr/bin/env bash
# Bash-specific script

# Arrays
declare -a files=("input1.txt" "input2.txt")

# Associative arrays
declare -A config
config[host]="localhost"
config[port]="8080"

# Process substitution
while read -r line; do
    echo "Processing: $line"
done < <(find . -name "*.log")

# Extended globbing
shopt -s extglob
rm -rf !(*.txt|*.md)
```

## Input Validation and Security

### Input Sanitization

Validate all external inputs:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Validate filename input
validate_filename() {
    local filename="$1"
    if [[ ! "$filename" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Invalid filename: $filename" >&2
        exit 1
    fi
    if [[ ${#filename} -gt 255 ]]; then
        echo "Filename too long: $filename" >&2
        exit 1
    fi
}

# Validate directory path
validate_directory() {
    local dir="$1"
    if [[ ! "$dir" =~ ^/tmp/|^/var/tmp/ ]]; then
        echo "Directory must be in /tmp or /var/tmp: $dir" >&2
        exit 1
    fi
}

# Validate numeric input
validate_number() {
    local num="$1"
    if [[ ! "$num" =~ ^[0-9]+$ ]]; then
        echo "Invalid number: $num" >&2
        exit 1
    fi
}
```

### Secure File Operations

Apply secure file handling:
```bash
# Secure temporary file creation
create_temp_file() {
    local temp_file
    temp_file=$(mktemp /tmp/script_temp_XXXXXX)
    chmod 600 "$temp_file"
    echo "$temp_file"
}

# Safe file operations
safe_write_file() {
    local content="$1"
    local target_file="$2"
    local temp_file
    temp_file=$(create_temp_file)

    echo "$content" > "$temp_file"
    chmod 644 "$temp_file"
    mv "$temp_file" "$target_file"
}

# Atomic directory operations
safe_directory_operation() {
    local target_dir="$1"
    local temp_dir="${target_dir}.tmp.$$"

    mkdir "$temp_dir"
    # Perform operations in temp directory
    mv "$temp_dir" "$target_dir"
}
```

## Process and Resource Management

### Process Handling

Manage processes safely:
```bash
# Background process management
start_background_process() {
    local command="$1"
    local pid_file="$2"

    # Start process in background
    $command &
    local pid=$!

    # Save PID
    echo $pid > "$pid_file"

    # Set up cleanup trap
    trap 'kill $pid 2>/dev/null || true; rm -f $pid_file' EXIT

    return 0
}

# Process monitoring
monitor_process() {
    local pid="$1"
    local timeout="$2"

    local count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt $timeout ]; do
        sleep 1
        ((count++))
    done

    if kill -0 "$pid" 2>/dev/null; then
        echo "Process timeout, killing PID: $pid" >&2
        kill "$pid"
        return 1
    fi

    return 0
}
```

### Resource Cleanup

Implement proper resource cleanup:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Resource tracking
declare -a temp_files=()
declare -a background_pids=()

# Register temp file for cleanup
register_temp_file() {
    local temp_file="$1"
    temp_files+=("$temp_file")
}

# Register background process for cleanup
register_background_process() {
    local pid="$1"
    background_pids+=("$pid")
}

# Cleanup function
cleanup_resources() {
    # Kill background processes
    for pid in "${background_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done

    # Remove temp files
    for temp_file in "${temp_files[@]}"; do
        rm -f "$temp_file" 2>/dev/null || true
    done
}

# Set up cleanup traps
trap cleanup_resources EXIT
trap 'cleanup_resources; trap - SIGTERM; kill -s SIGTERM $$' SIGTERM
trap 'cleanup_resources; trap - SIGINT; kill -s SIGINT $$' SIGINT
```

## ShellCheck Integration

### Static Analysis Configuration

Use ShellCheck for quality assurance:
```bash
#!/usr/bin/env bash
# shellcheck disable=SC2001  # Allow sed substitution
# shellcheck disable=SC2086  # Allow word splitting when needed

# Function with proper ShellCheck annotations
process_files() {
    local input_dir="$1"
    local pattern="$2"

    # SC2086: Intentional word splitting
    # shellcheck disable=SC2086
    find "$input_dir" -name "$pattern" -print0 | while IFS= read -r -d $'\0' file; do
        echo "Processing: $file"
    done
}

# Disable specific checks for legacy code
legacy_function() {
    # shellcheck disable=SC2001
    local result=$(echo "$1" | sed "s/old/new/g")
    echo "$result"
}
```

### Automated ShellCheck Integration

Integrate ShellCheck in development workflow:
```bash
#!/bin/bash
# check-shell-scripts.sh

set -euo pipefail

# Find and check all shell scripts
check_shell_scripts() {
    local failed=0

    while IFS= read -r -d $'\0' script; do
        if ! shellcheck "$script"; then
            echo "ShellCheck failed for: $script" >&2
            failed=1
        fi
    done < <(find . -type f \( -name "*.sh" -o -name "*.bash" \) -print0)

    return $failed
}

# Check specific script with custom severity
check_script_with_severity() {
    local script="$1"
    local severity="${2:-warning}"

    shellcheck -S "$severity" "$script"
}

# Main execution
main() {
    echo "Checking shell scripts with ShellCheck..."

    if check_shell_scripts; then
        echo "All shell scripts passed ShellCheck"
        return 0
    else
        echo "Some shell scripts failed ShellCheck" >&2
        return 1
    fi
}

main "$@"
```
