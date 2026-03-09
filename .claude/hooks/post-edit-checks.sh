#!/bin/bash
# Post-Edit/Write hook: runs Rubocop and tests after file changes.
# Receives JSON on stdin with tool_input.file_path.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run checks on Ruby files (skip ERB — RuboCop can't parse it)
if [[ -z "$FILE_PATH" ]] || [[ ! "$FILE_PATH" =~ \.rb$ ]]; then
  exit 0
fi

ERRORS=""

# Run Rubocop on the changed file
if ! RUBOCOP_OUTPUT=$(bin/rubocop "$FILE_PATH" 2>&1); then
  ERRORS+="Rubocop violations in $FILE_PATH:
$RUBOCOP_OUTPUT

"
fi

# Run the test suite
if ! TEST_OUTPUT=$(bin/rails test 2>&1); then
  ERRORS+="Test failures:
$TEST_OUTPUT
"
fi

if [[ -n "$ERRORS" ]]; then
  echo "$ERRORS" >&2
  exit 2
fi

exit 0
