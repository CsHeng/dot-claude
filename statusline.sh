#!/bin/bash
# Ref: https://docs.claude.com/en/docs/claude-code/statusline

# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
LINES_ADDED=$(get_lines_added)
LINES_REMOVED=$(get_lines_removed)

# Extract basename for cleaner display
dir_name=$(basename "$DIR" 2>/dev/null || echo "$DIR")

# Colors
CYAN='\033[36m'
GRAY='\033[90m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
NC='\033[0m'

# Format lines changes
if [ "$LINES_ADDED" != "0" ] && [ "$LINES_REMOVED" != "0" ]; then
    lines_info="${GREEN}+${LINES_ADDED}${NC} ${RED}-${LINES_REMOVED}${NC}"
elif [ "$LINES_ADDED" != "0" ]; then
    lines_info="${GREEN}+${LINES_ADDED}${NC}"
elif [ "$LINES_REMOVED" != "0" ]; then
    lines_info="${RED}-${LINES_REMOVED}${NC}"
else
    lines_info=""
fi

# Build final statusline
if [ -n "$lines_info" ]; then
    echo -e "${CYAN}${MODEL}${NC} ${GRAY}in${NC} ${GREEN}${dir_name}${NC} ${GRAY}[${lines_info}${GRAY}]${NC}"
else
    echo -e "${CYAN}${MODEL}${NC} ${GRAY}in${NC} ${GREEN}${dir_name}${NC}"
fi