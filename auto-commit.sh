#!/bin/bash

# Auto-commit script for Claude Code UserPromptSubmit hook
# Commits any unstaged changes with a timestamped message

# Generate timestamp in ISO 8601 format
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not in a git repository, skipping auto-commit"
    exit 0
fi

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit"
    exit 0
fi

# Add all changes (modified and untracked files)
git add .

# Create commit with timestamped message
commit_message="claude-code-auto-commit-${timestamp}"

# Commit the changes
if git commit -m "$commit_message"; then
    echo "Auto-committed changes with message: $commit_message"
else
    echo "Failed to create auto-commit"
    exit 1
fi