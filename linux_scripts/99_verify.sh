#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/99_verify.log") 2>&1

echo "[AEON] Verify start: $(date)"

uname -a
cat /etc/os-release

# Graphics
lspci | grep -i vga || true

# WiFi
ip link show || true

# Audio
pactl info || true

# Wacom
xsetwacom --list devices || true

# Boot mode
if [ -d /sys/firmware/efi ]; then echo "UEFI"; else echo "BIOS"; fi

echo "[AEON] Verify done: $(date)"