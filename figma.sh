#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Figma
# @raycast.mode compact
# @raycast.packageName Gemini

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "Folder ID" }
# @raycast.argument2 { "type": "dropdown", "placeholder": "Open file", "default": "No", "data": [{ "title": "No", "value": "0" },{ "title": "Yes", "value": "1" }]}

# Documentation:
# @raycast.description Generates a response based on the task using Gemini AI

# Load common configuration
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DIR" && pwd)"
source "$PROJECT_ROOT/script/common.sh"

# START CONFIG
INSTRUCTIONS_FILE="$PROJECT_ROOT/commands/figma.md"
CONFIG_PATH="$PROJECT_ROOT/config/gemini/figma.json"
TASK_TYPE="figma"
# END CONFIG

TASK_ID="$1"
OPEN_FILE="$2"
TASK_DIR=$(setup_task_environment "$TASK_ID" "$TASK_TYPE")
SESSION_DIR=$(find "$TASK_DIR/sessions" -maxdepth 1 -type d -name "[0-9]*" | sort -V | tail -n 1)
TASK_FILE="$TASK_DIR/task.md"

# Setup Gemini config for Figma MCP
setup_gemini_config "$CONFIG_PATH"

# Generate prompt
PROMPT=$(generate_prompt "$INSTRUCTIONS_FILE" "$TASK_FILE")

# Process response
process_response "$PROMPT" "$SESSION_DIR" "$OPEN_FILE"
