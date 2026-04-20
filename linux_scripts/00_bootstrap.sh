#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/00_bootstrap.log") 2>&1

echo "[AEON] Bootstrap start: $(date)"

# Base tools
sudo pacman -S --noconfirm --needed \
  base-devel git curl wget \
  python python-pip \
  flatpak timeshift

# Prepare working directories
mkdir -p "$HOME/aeon-build" "$HOME/scripts" "$HOME/aeon-build/offline-automations"

# Ensure yay exists
if ! command -v yay >/dev/null 2>&1; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

echo "[AEON] Bootstrap done: $(date)"