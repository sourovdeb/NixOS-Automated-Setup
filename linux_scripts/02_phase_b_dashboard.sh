#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/aeon-build/logs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/02_phase_b_dashboard.log") 2>&1

echo "[AEON] Phase B start: $(date)"

sudo pacman -S --noconfirm --needed \
  python-gobject gtk4 libadwaita

mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart" "$HOME/scripts"

cat > "$HOME/.local/bin/aeon-dashboard" << 'PYEOF'
#!/usr/bin/env python3
import gi
import os
import subprocess
from datetime import datetime

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

HOME = os.path.expanduser("~")
PRIORITIES = os.path.join(HOME, "Writing", "today", "priorities.md")

ACTIONS = [
    ("Write", ["flatpak", "run", "md.obsidian.Obsidian"]),
    ("Podcast", ["audacity"]),
    ("Publish", ["python", os.path.join(HOME, "scripts", "publish.py")]),
    ("Email", ["thunderbird"]),
    ("Search", ["xdg-open", "http://localhost:8888"]),
    ("Calendar", ["gnome-calendar"]),
    ("Backup", ["python", os.path.join(HOME, "scripts", "backup.py")]),
    ("Draw", ["krita"]),
    ("AI Chat", ["xdg-open", "http://localhost:3000"]),
    ("Help", ["zenity", "--info", "--text", "AEON Help: Use the buttons to start tasks."])
]

class Dashboard(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title("AEON Dashboard")
        self.set_default_size(1200, 700)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=20, margin_bottom=20, margin_start=20, margin_end=20)
        self.set_child(vbox)

        greeting = Gtk.Label(label=self._greeting_text(), xalign=0)
        greeting.set_css_classes(["title-1"])
        vbox.append(greeting)

        priorities = Gtk.Label(label=self._read_priorities(), xalign=0)
        priorities.set_wrap(True)
        vbox.append(priorities)

        grid = Gtk.Grid(column_spacing=12, row_spacing=12)
        vbox.append(grid)

        for i, (label, cmd) in enumerate(ACTIONS):
            btn = Gtk.Button(label=label)
            btn.connect("clicked", self._launch, cmd)
            grid.attach(btn, i % 5, i // 5, 1, 1)

    def _greeting_text(self):
        now = datetime.now()
        hour = now.hour
        if hour < 12:
            part = "Morning"
        elif hour < 18:
            part = "Afternoon"
        else:
            part = "Evening"
        return f"Good {part}, Sourou — {now.strftime('%A %b %d')}"

    def _read_priorities(self):
        if not os.path.exists(PRIORITIES):
            return "No priorities set. Create ~/Writing/today/priorities.md"
        with open(PRIORITIES, "r", encoding="utf-8") as f:
            return f.read().strip() or "No priorities set."

    def _launch(self, _btn, cmd):
        try:
            subprocess.Popen(cmd)
        except Exception:
            pass

class App(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.aeon.dashboard")

    def do_activate(self):
        win = Dashboard(self)
        win.present()

if __name__ == "__main__":
    app = App()
    app.run()
PYEOF

chmod +x "$HOME/.local/bin/aeon-dashboard"

cat > "$HOME/.config/autostart/aeon-dashboard.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=AEON Dashboard
Exec=/home/sourou/.local/bin/aeon-dashboard
X-GNOME-Autostart-enabled=true
EOF

sudo timeshift --create --comments "post-phase-B"

echo "[AEON] Phase B done: $(date)"