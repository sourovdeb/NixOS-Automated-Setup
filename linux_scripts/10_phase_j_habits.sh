#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/10_phase_j_habits.log") 2>&1

echo "[AEON] Phase J start: $(date)"

sudo pacman -S --noconfirm --needed espanso ulauncher

yay -S --noconfirm --needed super-productivity-bin

mkdir -p "$HOME/scripts"
cat > "$HOME/scripts/habits.py" << 'PYEOF'
#!/usr/bin/env python3
import os
import subprocess

def main():
    print("AEON Habits: start your day with 3 priorities.")
    priorities = os.path.expanduser("~/Writing/today/priorities.md")
    if not os.path.exists(priorities):
        open(priorities, "w").write("- Priority 1\n- Priority 2\n- Priority 3\n")
    subprocess.run(["xdg-open", priorities])

if __name__ == "__main__":
    main()
PYEOF

chmod +x "$HOME/scripts/habits.py"

sudo timeshift --create --comments "post-phase-J"

echo "[AEON] Phase J done: $(date)"