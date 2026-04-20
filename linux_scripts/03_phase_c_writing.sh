#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/03_phase_c_writing.log") 2>&1

echo "[AEON] Phase C start: $(date)"

sudo pacman -S --noconfirm --needed \
  pandoc typst hugo zathura zathura-pdf-mupdf xournalpp \
  ghostwriter libreoffice-fresh

flatpak install -y flathub md.obsidian.Obsidian

mkdir -p "$HOME/Writing/today" \
  "$HOME/Writing/current-project" \
  "$HOME/Writing/week" \
  "$HOME/Writing/archive/$(date +%Y)/$(date +%m)" \
  "$HOME/Writing/podcasts/raw" \
  "$HOME/Writing/podcasts/edited" \
  "$HOME/Writing/drafts" \
  "$HOME/Writing/published"

touch "$HOME/Writing/today/priorities.md"

cd "$HOME/Writing"
if [ ! -d .git ]; then
  git init
  git config --global user.name "AEON Writer"
  git config --global user.email "writer@aeon.local"
fi

(crontab -l 2>/dev/null; echo "*/5 * * * * cd $HOME/Writing && git add . && git commit -m 'auto-save' --quiet") | crontab -

sudo timeshift --create --comments "post-phase-C"

echo "[AEON] Phase C done: $(date)"