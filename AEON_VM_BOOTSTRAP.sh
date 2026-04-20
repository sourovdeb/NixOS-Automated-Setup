#!/bin/bash
# AEON VM bootstrap: download scripts from host, prefetch packages, install VS Code + Copilot.
# Run this inside the Linux VM.
set -euo pipefail

HOST_IP="10.0.2.2"
HOST_PORT="8000"
WORK_DIR="$HOME/aeon-build"
LOG_FILE="$WORK_DIR/aeon-bootstrap.log"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[AEON] Bootstrap start: $(date)" | tee -a "$LOG_FILE"

# Ensure curl and tmux are available
if ! command -v curl >/dev/null 2>&1; then
  sudo pacman -S --noconfirm curl
fi
if ! command -v tmux >/dev/null 2>&1; then
  sudo pacman -S --noconfirm tmux
fi

# Download scripts from host
for f in AEON_PREFETCH.sh AEON_VSCODE_COPILOT.sh AEON_BUILD_SCRIPT.sh; do
  curl -fsSL "http://$HOST_IP:$HOST_PORT/$f" -o "$f"
  chmod +x "$f"
  echo "[AEON] Downloaded $f" | tee -a "$LOG_FILE"
done

# Run in tmux so it survives disconnects
SESSION="aeon-setup"
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" "bash -lc './AEON_PREFETCH.sh >> $LOG_FILE 2>&1; ./AEON_VSCODE_COPILOT.sh >> $LOG_FILE 2>&1; echo [AEON] Bootstrap complete: $(date) >> $LOG_FILE'"
  echo "[AEON] Started tmux session: $SESSION" | tee -a "$LOG_FILE"
else
  echo "[AEON] tmux session already running: $SESSION" | tee -a "$LOG_FILE"
fi

echo "[AEON] To monitor: tail -f $LOG_FILE" | tee -a "$LOG_FILE"
echo "[AEON] To attach: tmux attach -t $SESSION" | tee -a "$LOG_FILE"