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
    local task_type="$2"
    local task_dir="$PROJECT_ROOT/spec/$task_id"
    local task_file="$task_dir/task.md"
    
    # Check if task directory and file exist
    if [ ! -d "$task_dir" ]; then
        echo "❌ Task directory does not exist: $task_dir"
        exit 1
    fi
    
    if [ ! -f "$task_file" ]; then
        echo "❌ Task file does not exist: $task_file"
        exit 1
    fi
    
    # Setup session environment
    local session_dir=$(setup_session_environment "$task_id" "$task_type" | tail -n 1)
    
    # Set session variables for global use
    export SESSION_DIR="$session_dir"
    
    echo "$task_dir"
}

# Function to setup session environment
setup_session_environment() {
    local task_id="$1"
    local task_type="$2"
    local task_dir="$PROJECT_ROOT/spec/$task_id"
    local sessions_dir="$task_dir/sessions"
    
    # Create sessions directory if it doesn't exist
    mkdir -p "$sessions_dir"
    
    # Get next session number
    local session_number=1
    if [ -d "$sessions_dir" ]; then
        local max_session=$(find "$sessions_dir" -maxdepth 1 -type d -name "[0-9]*" | sort -V | tail -n 1 | xargs basename 2>/dev/null || echo "0")
        if [ "$max_session" != "0" ]; then
            session_number=$((max_session + 1))
        fi
    fi
    
    # Create session directory
    local session_dir="$sessions_dir/$session_number"
    mkdir -p "$session_dir"
    
    # Create session.json with basic session data
    local session_data=$(cat <<EOF
{
    "session_id": $session_number,
    "task_id": "$task_id",
    "task_type": "$task_type",
    "created_at": "$(date '+%Y-%m-%d %H:%M:%S')",
    "status": "created"
}
EOF
)
    echo "$session_data" > "$session_dir/session.json"
    
    # Copy task file to session
    cp "$task_dir/task.md" "$session_dir/task.md"
    
    # Copy instructions file to session
    local instructions_file="$PROJECT_ROOT/commands/$task_type.md"
    if [ -f "$instructions_file" ]; then
        cp "$instructions_file" "$session_dir/instructions.md"
    fi
    
    # Set session variables for global use
    export SESSION_DIR="$session_dir"
    export SESSION_NUMBER="$session_number"
    
    echo "✅ Session $session_number created in: $session_dir"
    
    # Return session directory path
    echo "$session_dir"
}

# Function to setup Gemini config
setup_gemini_config() {
    local config_path="$1"
    local gemini_config_dir="$HOME/.gemini"
    local gemini_config="$gemini_config_dir/settings.json"
    
    if [ -n "$config_path" ]; then
        mkdir -p "$gemini_config_dir"
        if cp "$config_path" "$gemini_config"; then
            echo "✅ Copied MCP config to $gemini_config"
        else
            echo "❌ Error copying config"
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
### Content of the file \`spec/$TASK_ID/task.md\`:
$(cat "$task_file")
</task>
EOF
}

# Function to process response
process_response() {
    local prompt="$1"
    local session_dir="$2"
    local open_file="$3"
    
    # Extract session number from session directory path
    local SESSION_NUMBER=$(basename "$session_dir")
    
    if [ "$TEST_MODE" = "1" ]; then
        echo "$prompt" > "$DIR/test_prompt.txt"
    fi
    
    RESPONSE=$(gemini -p "$prompt")
    
    # Use session directory for output file
    local session_output_file="$session_dir/result.md"
    
    # Debug: check if session_dir is set
    if [ -z "$session_dir" ]; then
        echo "❌ Error: session_dir is not set"
        exit 1
    fi
    
    # Add current date to the response
    CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    echo "# Generated on: $CURRENT_DATE" > "$session_output_file"
    echo "" >> "$session_output_file"
    echo "$RESPONSE" >> "$session_output_file"
    
    # Update session.json with completion status
    update_session_status "$session_dir" "completed"
    
    if [ "$open_file" = "1" ]; then
        open -a "TextEdit" "$session_output_file"
    fi

    echo "✅: #$SESSION_NUMBER, 📁: $session_output_file"
}

# Function to update session status
update_session_status() {
    local session_dir="$1"
    local status="$2"
    local session_json="$session_dir/session.json"
    
    # Update status in session.json
    if [ -f "$session_json" ]; then
        local temp_file=$(mktemp)
        sed "s/\"status\": \"[^\"]*\"/\"status\": \"$status\"/" "$session_json" > "$temp_file"
        mv "$temp_file" "$session_json"
    fi
} 