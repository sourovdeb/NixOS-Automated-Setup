#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/06_phase_f_ai.log") 2>&1

echo "[AEON] Phase F start: $(date)"

sudo pacman -S --noconfirm --needed docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:3b
ollama pull nomic-embed-text
ollama pull qwen2.5-coder:3b

mkdir -p "$HOME/services/open-webui"
cat > "$HOME/services/open-webui/docker-compose.yml" << 'EOF'
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    volumes:
      - ./data:/app/backend/data
    restart: unless-stopped
EOF

mkdir -p "$HOME/scripts"
cat > "$HOME/scripts/ai-router.py" << 'PYEOF'
#!/usr/bin/env python3
import os
import json
import hashlib
import time
import requests

CACHE_DIR = os.path.expanduser("~/.cache/aeon/ai")
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"

os.makedirs(CACHE_DIR, exist_ok=True)

def _cache_path(prompt):
    h = hashlib.sha256(prompt.encode("utf-8")).hexdigest()
    return os.path.join(CACHE_DIR, f"{h}.json")

def query_ollama(prompt, model="llama3.2:3b"):
    payload = {"model": model, "prompt": prompt, "stream": False}
    r = requests.post(OLLAMA_URL, json=payload, timeout=120)
    r.raise_for_status()
    return r.json().get("response", "")

def main():
    prompt = " ".join(os.sys.argv[1:]).strip()
    if not prompt:
        print("Usage: ai-router.py <prompt>")
        return 1

    cache = _cache_path(prompt)
    if os.path.exists(cache):
        print(open(cache, "r", encoding="utf-8").read())
        return 0

    try:
        response = query_ollama(prompt)
        with open(cache, "w", encoding="utf-8") as f:
            f.write(response)
        print(response)
        return 0
    except Exception:
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
PYEOF

chmod +x "$HOME/scripts/ai-router.py"

sudo timeshift --create --comments "post-phase-F"

echo "[AEON] Phase F done: $(date)"