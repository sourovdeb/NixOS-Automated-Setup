#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/07_phase_g_notifications.log") 2>&1

echo "[AEON] Phase G start: $(date)"

sudo pacman -S --noconfirm --needed dunst libnotify

mkdir -p "$HOME/scripts" "$HOME/.config/systemd/user"

cat > "$HOME/scripts/notification-engine.py" << 'PYEOF'
#!/usr/bin/env python3
import subprocess
import time

MESSAGES = [
    "You are doing great. Keep going.",
    "One small step is still progress.",
    "Take a breath and keep writing."
]

if __name__ == "__main__":
    idx = int(time.time()) % len(MESSAGES)
    subprocess.run(["notify-send", "AEON", MESSAGES[idx]])
PYEOF

chmod +x "$HOME/scripts/notification-engine.py"

cat > "$HOME/.config/systemd/user/aeon-hourly.timer" << 'EOF'
[Unit]
Description=AEON Hourly Encouragement

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat > "$HOME/.config/systemd/user/aeon-hourly.service" << 'EOF'
[Unit]
Description=AEON Hourly Encouragement

[Service]
Type=oneshot
ExecStart=%h/scripts/notification-engine.py
EOF

systemctl --user enable --now aeon-hourly.timer

sudo timeshift --create --comments "post-phase-G"

echo "[AEON] Phase G done: $(date)"