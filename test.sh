#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Test
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "Folder ID" }
# @raycast.argument2 { "type": "dropdown", "placeholder": "Open file" }
# @raycast.argument2.dropdown.option "Yes"
# @raycast.argument2.dropdown.option "No"

# Documentation:
# @raycast.description Test command

# Load common configuration
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config/gemini/common.sh"

TASK_ID="$1"
OPEN_FILE="$2"
TASK_DIR=$(setup_task_environment "$TASK_ID" "test")
TASK_FILE="$TASK_DIR/task.md"
INSTRUCTIONS_FILE="$DIR/commands/test.md"
OUTPUT_FILE="$TASK_DIR/test.md"

# Generate prompt
PROMPT=$(generate_prompt "$INSTRUCTIONS_FILE" "$TASK_FILE")

# Process response
process_response "$PROMPT" "$OUTPUT_FILE" "$OPEN_FILE"
