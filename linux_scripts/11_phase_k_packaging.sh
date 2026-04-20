#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/11_phase_k_packaging.log") 2>&1

echo "[AEON] Phase K start: $(date)"

sudo pacman -S --noconfirm --needed archiso

mkdir -p "$HOME/aeon-installer/config-templates" "$HOME/aeon-installer/docs"

cat > "$HOME/aeon-installer/install.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "AEON installer placeholder. Add non-interactive setup steps here."
EOF

cat > "$HOME/aeon-installer/uninstall.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "AEON uninstall placeholder. Add rollback steps here."
EOF

chmod +x "$HOME/aeon-installer/install.sh" "$HOME/aeon-installer/uninstall.sh"

sudo timeshift --create --comments "post-phase-K"

echo "[AEON] Phase K done: $(date)"