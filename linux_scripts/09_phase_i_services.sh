#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/09_phase_i_services.log") 2>&1

echo "[AEON] Phase I start: $(date)"

mkdir -p "$HOME/services"
cat > "$HOME/services/docker-compose.yml" << 'EOF'
services:
  nextcloud:
    image: nextcloud
    ports:
      - "8080:80"
    restart: unless-stopped
  searxng:
    image: searxng/searxng
    ports:
      - "8888:8080"
    restart: unless-stopped
  ghost:
    image: ghost:5
    ports:
      - "2368:2368"
    restart: unless-stopped
  vikunja:
    image: vikunja/vikunja
    ports:
      - "3456:3456"
    restart: unless-stopped
  castopod:
    image: castopod/castopod:latest
    ports:
      - "8000:8000"
    restart: unless-stopped
EOF

echo "[AEON] Phase I ready. Run: docker-compose -f ~/services/docker-compose.yml up -d"

sudo timeshift --create --comments "post-phase-I"

echo "[AEON] Phase I done: $(date)"