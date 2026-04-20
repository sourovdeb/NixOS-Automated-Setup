#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/01_phase_a_accessibility.log") 2>&1

echo "[AEON] Phase A start: $(date)"

sudo pacman -S --noconfirm --needed \
  orca at-spi2-core at-spi2-atk \
  gnome-tweaks gsettings-desktop-schemas

# Fonts (AUR)
yay -S --noconfirm --needed \
  ttf-opendyslexic-git ttf-atkinson-hyperlegible ttf-lexend

# GNOME settings
gsettings set org.gnome.desktop.interface cursor-size 48

gsettings set org.gnome.desktop.interface text-scaling-factor 1.5

gsettings set org.gnome.desktop.interface enable-animations false

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

gsettings set org.gnome.desktop.interface clock-show-seconds true

gsettings set org.gnome.desktop.interface show-battery-percentage true

# Extension Manager (Flatpak)
flatpak install -y flathub com.mattjakeman.ExtensionManager

echo "[AEON] Install GNOME extensions via Extension Manager:"
echo "- Just Perfection (3843)"
echo "- Pano (5278)"
echo "- Caffeine (517)"
echo "- Vitals (518)"

sudo timeshift --create --comments "post-phase-A"

echo "[AEON] Phase A done: $(date)"