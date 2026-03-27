#!/bin/bash

# Claude Attention Notification Script
# This script opens the Claude attention HTML file in the default browser

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HTML_FILE="$SCRIPT_DIR/claude-attention.html"

# Check if the HTML file exists
if [ ! -f "$HTML_FILE" ]; then
    echo "Error: claude-attention.html not found at $HTML_FILE"
    exit 1
fi

# Log the notification (optional - can be useful for debugging)
echo "$(date): Claude requesting user attention" >> "$SCRIPT_DIR/claude-attention.log"

# Determine the operating system and open the HTML file
case "$(uname -s)" in
    Darwin)
        # macOS
        open "$HTML_FILE"
        ;;
    Linux)
        # Linux
        if command -v xdg-open > /dev/null 2>&1; then
            xdg-open "$HTML_FILE"
        elif command -v sensible-browser > /dev/null 2>&1; then
            sensible-browser "$HTML_FILE"
        elif command -v firefox > /dev/null 2>&1; then
            firefox "$HTML_FILE"
        elif command -v chromium-browser > /dev/null 2>&1; then
            chromium-browser "$HTML_FILE"
        elif command -v google-chrome > /dev/null 2>&1; then
            google-chrome "$HTML_FILE"
        else
            echo "Error: No suitable browser found"
            exit 1
        fi
        ;;
    MINGW*|CYGWIN*|MSYS*)
        # Windows (Git Bash, Cygwin, etc.)
        start "$HTML_FILE"
        ;;
    *)
        echo "Error: Unsupported operating system"
        exit 1
        ;;
esac

# Optional: Send a desktop notification as well (if available)
if command -v osascript > /dev/null 2>&1; then
    # macOS notification
    osascript -e 'display notification "Claude needs your attention!" with title "Claude Code" sound name "default"'
elif command -v notify-send > /dev/null 2>&1; then
    # Linux notification
    notify-send "Claude Code" "Claude needs your attention!"
elif command -v powershell.exe > /dev/null 2>&1; then
    # Windows notification
    powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Claude needs your attention!', 'Claude Code')"
fi

# Bring the terminal/Claude Code to front if possible
if command -v osascript > /dev/null 2>&1; then
    # macOS - activate the terminal
    osascript -e 'tell application "Terminal" to activate'
fi

echo "Claude attention notification displayed"