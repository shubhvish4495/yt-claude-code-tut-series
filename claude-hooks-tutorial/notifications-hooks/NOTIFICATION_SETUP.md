# Claude Attention Notification Setup

This directory contains files for creating an animated notification when Claude needs your attention.

## Files

- `claude-attention.html` - Animated HTML notification page with beautiful UI
- `claude-attention.sh` - Cross-platform shell script to launch the notification
- `NOTIFICATION_SETUP.md` - This documentation file

## Features

The animated notification includes:
- Eye-catching animations with pulsing logo and bouncing text
- Cross-platform compatibility (macOS, Linux, Windows)
- Auto-close after 30 seconds
- Floating particle effects
- Desktop notifications (when supported)
- Keyboard shortcuts (ESC to close)
- Responsive design

## Setup Instructions

### Option 1: Replace Current Notification (Recommended)

Edit your `.claude/settings.local.json` file to replace the current notification hook:

```json
{
  "permissions": {
    "allow": [
      "Bash(go test:*)",
      "Bash(make test:*)",
      "Bash(git add:*)",
      "Bash(git fetch:*)",
      "Bash(git push:*)"
    ],
    "deny": [],
    "ask": []
  },
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/ssaurav/go-tut/claude-tut/claude-attention.sh"
          }
        ]
      }
    ]
  }
}
```

### Option 2: Add as Additional Notification

To keep both the dialog and the animated notification:

```json
{
  "permissions": {
    "allow": [
      "Bash(go test:*)",
      "Bash(make test:*)",
      "Bash(git add:*)",
      "Bash(git fetch:*)",
      "Bash(git push:*)"
    ],
    "deny": [],
    "ask": []
  },
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display dialog \"Claude Code needs your attention\" with title \"Claude Code\" buttons {\"OK\"} default button 1'"
          },
          {
            "type": "command",
            "command": "/Users/ssaurav/go-tut/claude-tut/claude-attention.sh"
          }
        ]
      }
    ]
  }
}
```

### Option 3: Use Relative Path

If you want to use a relative path (useful if you move the project):

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "./claude-attention.sh"
          }
        ]
      }
    ]
  }
}
```

## Testing the Notification

To test if the notification works correctly:

1. Make sure the script is executable:
   ```bash
   chmod +x claude-attention.sh
   ```

2. Test the script manually:
   ```bash
   ./claude-attention.sh
   ```

3. The notification should:
   - Open a browser window with the animated notification
   - Show a desktop notification (if supported)
   - Create a log entry in `claude-attention.log`

## How It Works

1. **Hook Trigger**: When Claude needs attention, the hook system executes the configured command
2. **Script Execution**: The `claude-attention.sh` script runs and:
   - Detects the operating system
   - Opens the HTML file in the default browser
   - Sends a desktop notification (if available)
   - Logs the notification event
3. **User Interaction**: The animated page displays with options to close or auto-closes after 30 seconds

## Customization

### Modifying the Animation

Edit `claude-attention.html` to customize:
- Colors in the CSS variables
- Animation timing and effects
- Message text
- Auto-close timing (currently 30 seconds)

### Modifying the Script

Edit `claude-attention.sh` to:
- Change the log file location
- Modify desktop notification behavior
- Add additional actions when notification triggers

## Troubleshooting

### Script doesn't execute
- Ensure the script has executable permissions: `chmod +x claude-attention.sh`
- Check the absolute path in settings.json is correct

### Browser doesn't open
- Verify your system has a default browser configured
- Check browser permissions for opening local files

### No desktop notification
- This is normal on some systems - the HTML notification should still work
- Desktop notifications require specific system permissions

## Cross-Platform Notes

- **macOS**: Uses `open` command and `osascript` for notifications
- **Linux**: Uses `xdg-open` and `notify-send` for notifications
- **Windows**: Uses `start` command and PowerShell for notifications

The script automatically detects your platform and uses the appropriate commands.