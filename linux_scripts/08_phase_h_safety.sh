#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/08_phase_h_safety.log") 2>&1

echo "[AEON] Phase H start: $(date)"

sudo pacman -S --noconfirm --needed cockpit
sudo systemctl enable --now cockpit.socket

mkdir -p "$HOME/scripts"
cat > "$HOME/scripts/log-translator.py" << 'PYEOF'
#!/usr/bin/env python3
import subprocess

# Minimal placeholder: tail journal and print raw lines.
# Extend later with friendly translations.

if __name__ == "__main__":
    subprocess.run(["journalctl", "-p", "err", "-n", "50"])
PYEOF

chmod +x "$HOME/scripts/log-translator.py"

sudo timeshift --create --comments "post-phase-H"

echo "[AEON] Phase H done: $(date)"