#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/05_phase_e_publishing.log") 2>&1

echo "[AEON] Phase E start: $(date)"

yay -S --noconfirm --needed wp-cli
sudo pacman -S --noconfirm --needed zenity
python -m pip install --user python-wordpress-xmlrpc requests playwright
python -m playwright install chromium

mkdir -p "$HOME/scripts"
cat > "$HOME/scripts/publish.py" << 'PYEOF'
#!/usr/bin/env python3
import os
import sys
import subprocess

# Credentials must be provided via environment variables.
# WP_URL, WP_USER, WP_APP_PASS

def main():
    if len(sys.argv) < 2:
        print("Usage: publish.py <markdown-file>")
        sys.exit(1)

    md_file = sys.argv[1]
    if not os.path.exists(md_file):
        print(f"File not found: {md_file}")
        sys.exit(1)

    wp_url = os.environ.get("WP_URL")
    wp_user = os.environ.get("WP_USER")
    wp_pass = os.environ.get("WP_APP_PASS")

    if not all([wp_url, wp_user, wp_pass]):
        print("Missing WP credentials. Set WP_URL, WP_USER, WP_APP_PASS.")
        sys.exit(1)

    # Convert markdown to HTML
    html = subprocess.check_output(["pandoc", md_file, "-f", "markdown", "-t", "html"]).decode("utf-8")

    # Minimal WP post via wp-cli
    subprocess.run([
        "wp", "post", "create",
        f"--post_title={os.path.basename(md_file)}",
        "--post_status=publish",
        f"--post_content={html}",
        f"--url={wp_url}",
        f"--user={wp_user}",
        f"--path={os.path.expanduser('~')}",
    ], check=False)

if __name__ == "__main__":
    main()
PYEOF

chmod +x "$HOME/scripts/publish.py"

sudo timeshift --create --comments "post-phase-E"

echo "[AEON] Phase E done: $(date)"