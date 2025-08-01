#!/bin/bash

# Common configuration and functions for Gemini scripts
# Used by epic.sh and figma.sh

# Common variables
TEST_MODE=0
OPEN_FILE=0
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DIR/.." && pwd)"

# Function to setup task environment
setup_task_environment() {
    local task_id="$1"
    local task_dir="$PROJECT_ROOT/spec/$task_id"
    local task_file="$task_dir/task.md"
    local output_file="$task_dir/$2.md"
    
    # Check if task directory and file exist
    if [ ! -d "$task_dir" ]; then
        echo "❌ Katalog zadania nie istnieje: $task_dir"
        exit 1
    fi
    
    if [ ! -f "$task_file" ]; then
        echo "❌ Plik zadania nie istnieje: $task_file"
        exit 1
    fi
    
    echo "$task_dir"
}

# Function to setup Gemini config
setup_gemini_config() {
    local config_path="$1"
    local gemini_config_dir="$HOME/.gemini"
    local gemini_config="$gemini_config_dir/settings.json"
    
    if [ -n "$config_path" ]; then
        mkdir -p "$gemini_config_dir"
        if cp "$config_path" "$gemini_config"; then
            echo "✅ Skopiowano MCP config do $gemini_config"
        else
            echo "❌ Błąd podczas kopiowania configu"
            exit 1
        fi
    fi
}

# Function to generate prompt
generate_prompt() {
    local instructions_file="$1"
    local task_file="$2"
    
    cat <<EOF
<instructions>
$(cat "$instructions_file")
</instructions>

<task>
### Zawartość pliku \`spec/$TASK_ID/task.md\`:
$(cat "$task_file")
</task>
EOF
}

# Function to process response
process_response() {
    local prompt="$1"
    local output_file="$2"
    local open_file="$3"
    
    if [ "$TEST_MODE" = "1" ]; then
        echo "$prompt" > "$DIR/test_prompt.txt"
    fi
    
    RESPONSE=$(gemini -p "$prompt")
    echo "$RESPONSE" > "$output_file"
    echo "Result saved in $output_file"
    
    if [ "$open_file" = "1" ]; then
        open -a "TextEdit" "$output_file"
    fi
} 