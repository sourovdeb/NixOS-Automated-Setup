#!/bin/bash
# Pre-download packages for AEON build (Arch/EndeavourOS).
# Runs on the Linux target to cache downloads for faster install.
set -euo pipefail

CACHE_ROOT="$HOME/aeon-cache"
PACMAN_CACHE="$CACHE_ROOT/pacman"
PIP_CACHE="$CACHE_ROOT/pip"

mkdir -p "$PACMAN_CACHE" "$PIP_CACHE"

PACMAN_PKGS=(
  gnome gnome-extra xorg-server xorg-apps gdm
  orca espeak-ng speech-dispatcher
  pandoc typst hugo zathura xournalpp
  audacity ffmpeg lame sox easyeffects
  flatpak dunst libnotify cockpit
  docker docker-compose
  python python-pip python-virtualenv
)

AUR_PKGS=(
  ttf-opendyslexic-git ttf-atkinson-hyperlegible ttf-lexend
  ghostwriter whisper.cpp
)

FLATPAK_PKGS=(
  com.mattjakeman.ExtensionManager
  md.obsidian.Obsidian
)

PIP_PKGS=(
  python-wordpress-xmlrpc
  requests
  playwright
  openai-whisper
)

sudo pacman -Sw --noconfirm --needed --cachedir "$PACMAN_CACHE" "${PACMAN_PKGS[@]}"

if command -v yay >/dev/null 2>&1; then
  yay -Sw --noconfirm --needed "${AUR_PKGS[@]}"
else
  echo "yay not found. Install yay, then rerun to cache AUR packages."
fi

if command -v flatpak >/dev/null 2>&1; then
  for app in "${FLATPAK_PKGS[@]}"; do
    flatpak install -y --download-only flathub "$app" || true
  done
else
  echo "flatpak not found. Install flatpak, then rerun to cache flatpaks."
fi

python3 -m pip download --dest "$PIP_CACHE" "${PIP_PKGS[@]}"

echo "Prefetch complete. Cached files in: $CACHE_ROOT"