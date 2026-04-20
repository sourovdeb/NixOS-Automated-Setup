#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/04_phase_d_podcast.log") 2>&1

echo "[AEON] Phase D start: $(date)"

sudo pacman -S --noconfirm --needed \
  audacity ffmpeg lame sox easyeffects inotify-tools

yay -S --noconfirm --needed whisper.cpp piper-tts

python -m pip install --user openai-whisper watchdog

mkdir -p "$HOME/scripts"

cat > "$HOME/scripts/transcribe-watcher.py" << 'PYEOF'
#!/usr/bin/env python3
import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import subprocess

RAW_DIR = os.path.expanduser("~/Writing/podcasts/raw")
OUT_DIR = os.path.expanduser("~/Writing/podcasts/transcripts")
WHISPER_BIN = "whisper.cpp"

os.makedirs(OUT_DIR, exist_ok=True)

class Handler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return
        if not event.src_path.lower().endswith(('.wav', '.mp3', '.m4a')):
            return
        out_file = os.path.join(OUT_DIR, os.path.basename(event.src_path) + ".txt")
        cmd = [WHISPER_BIN, "-f", event.src_path, "-otxt", "-o", out_file]
        try:
            subprocess.run(cmd, check=True)
        except Exception:
            pass

if __name__ == "__main__":
    os.makedirs(RAW_DIR, exist_ok=True)
    observer = Observer()
    observer.schedule(Handler(), RAW_DIR, recursive=False)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
PYEOF

chmod +x "$HOME/scripts/transcribe-watcher.py"

mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/aeon-transcribe.service" << 'EOF'
[Unit]
Description=AEON Transcription Watcher

[Service]
ExecStart=%h/scripts/transcribe-watcher.py
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user enable --now aeon-transcribe.service

sudo timeshift --create --comments "post-phase-D"

echo "[AEON] Phase D done: $(date)"