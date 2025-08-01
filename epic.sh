#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Epic
# @raycast.mode compact
# @raycast.packageName Gemini

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "Identyfikator folderu taska" }

# Documentation:
# @raycast.description Generuje odpowiedź na podstawie zadania używając Gemini AI

DIR="/Users/tkowalski/Documents/scripts"
TASK_ID="$1"
TASK_DIR="spec/$TASK_ID"
TASK_FILE="$TASK_DIR/task.md"
INSTRUCTIONS_FILE="$DIR/commands/epic.md"
OUTPUT_FILE="$TASK_DIR/epic.md"

# Generowanie prompta
PROMPT=$(cat <<EOF
<instructions>
$(cat "$INSTRUCTIONS_FILE")
</instructions>

<task>
### Zawartość pliku `spec/$TASK_ID/task.md`:
$(cat "$TASK_FILE")
</task>
EOF
)

# Zapis prompta do pliku testowego
# echo "$PROMPT" > "$DIR/test_prompt.txt"

# Wywołanie Gemini CLI z promptem
RESPONSE=$(gemini -p "$PROMPT")

# Zapis do pliku
echo "$RESPONSE" > "$OUTPUT_FILE"

echo "Odpowiedź zapisana w $OUTPUT_FILE"
