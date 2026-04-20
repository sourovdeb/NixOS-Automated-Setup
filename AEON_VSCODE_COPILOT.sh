#!/bin/bash
# Install VS Code + Copilot on EndeavourOS/Arch.
set -euo pipefail

if ! command -v code >/dev/null 2>&1; then
  sudo pacman -S --noconfirm code
fi

code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat

cat << 'EOF'
VS Code and Copilot extensions installed.
Next step (interactive, one-time):
1) Launch VS Code: code
2) Sign in to GitHub when prompted.
3) Confirm Copilot is enabled (bottom status bar).
EOF