#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title test
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "Identyfikator folderu taska" }

# Documentation:
# @raycast.description Komenda testowa

DIR="/Users/tkowalski/Documents/scripts"
OUTPUT_FILE="$DIR/test.md"

echo "Hello World! Parametr1: $1" > "$OUTPUT_FILE"

echo "Odpowiedź zapisana w $OUTPUT_FILE"
