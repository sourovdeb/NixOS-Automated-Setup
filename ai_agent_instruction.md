# AEON WRITER OS — Agent Build Instructions

**For:** Claude Code / AI Assistant  
**Target Machine:** Intel Alder Lake + Nvidia RTX 3050 Laptop  
**Installation Medium:** External SSD (portable, dual-boot optional)  
**Build Environment:** EndeavourOS (Arch-based) with GNOME on Xorg  
**User Profile:** Sourou — writer, podcaster, neurodivergent with executive function needs  

---

## 🧭 Context & Philosophy

You are building a **personalized, accessible Linux environment** optimized for:
- Heavy daily writing (100+ pages)
- Podcast production & publishing
- Multi-platform content distribution (WordPress, Ghost, Hugo)
- Wacom tablet input (drawing, PDF annotation)
- Offline-first AI assistance (Ollama + Claude API fallback)

**Design Principles (from *Atomic Habits*):**
- Make it **obvious** — everything one click away
- Make it **easy** — zero cognitive friction
- Make it **attractive** — consistent, calm UI
- Make it **satisfying** — visible progress and gentle nudges

**Critical Constraint:** The OS must **disappear**. The work must become visible.

---

## 🧰 Pre‑Build Assumptions

Before executing the build phases, assume the following has been completed by the user (do **not** re-run these steps):

1. **Hardware ready:** External SSD connected, Ventoy USB created with EndeavourOS ISO.
2. **Windows prepared:** Fast Startup disabled, Secure Boot temporarily off, internal drive shrunk if needed.
3. **EndeavourOS installed** on the external SSD with:
   - Desktop: **GNOME on Xorg**
   - Bootloader: **systemd‑boot**
   - Nvidia proprietary driver selected
   - User: `sourou`, auto‑login enabled
   - Timeshift snapshot taken immediately after first boot

4. **Working directory on the target system:**
   - Path: `/home/sourou/aeon-build/`
   - Contains this instruction file and will be used for all scripts/configs.

**Your job begins after the user logs into the fresh EndeavourOS desktop.**

---

## 🔨 Build Phases (Execute in Order)

Each phase ends with:
- A Timeshift snapshot named `post-phase-X`
- A brief status report
- **Proceed only after user confirmation** unless instructed otherwise.

### Phase A — Accessibility Foundation

**Goal:** Set up fonts, GNOME tweaks, and extensions for readability and reduced cognitive load.

```bash
# 1. Install accessibility fonts
yay -S --noconfirm ttf-opendyslexic-git ttf-atkinson-hyperlegible ttf-lexend

# 2. GNOME settings via gsettings
gsettings set org.gnome.desktop.interface cursor-size 48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface show-battery-percentage true

# 3. Install GNOME Extensions (via Extension Manager flatpak)
flatpak install -y flathub com.mattjakeman.ExtensionManager
# Then use Extension Manager CLI to install:
# - Just Perfection (ID: 3843)
# - Pano (ID: 5278)
# - Caffeine (ID: 517)
# - Vitals (ID: 518)
# (CLI method: gnome-extensions install <id> but IDs must be numeric)
# Alternative: Provide manual instructions for user to click install.
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-A"`

---

### Phase B — The Board Screen (Custom Dashboard)

**Goal:** Replace empty desktop with always‑visible GTK4 Python dashboard.

1. Create the app at `~/.local/bin/aeon-dashboard` (Python 3, PyGObject).
2. Features:
   - Greeting + time of day
   - Today’s 3 priorities from `~/Writing/today/priorities.md`
   - Next calendar event (parse `~/.local/share/evolution/calendar/system/calendar.ics`)
   - 10 large buttons with actions:
     - Write → `obsidian`
     - Podcast → `audacity`
     - Publish → `python ~/scripts/publish.py`
     - Email → `thunderbird`
     - Search → `xdg-open http://localhost:8888` (SearXNG)
     - Calendar → `gnome-calendar`
     - Backup → `python ~/scripts/backup.py`
     - Draw → `krita`
     - AI Chat → `xdg-open http://localhost:3000` (Open‑WebUI)
     - Help → display simple FAQ dialog
   - Bottom status bar (system health from Vitals extension)

3. Autostart: Create `~/.config/autostart/aeon-dashboard.desktop`.

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-B"`

---

### Phase C — Writing Environment

**Goal:** Set up Obsidian vault, folder structure, and Git auto‑versioning.

```bash
# Install packages
sudo pacman -S --noconfirm pandoc typst hugo zathura xournalpp
flatpak install -y flathub md.obsidian.Obsidian
yay -S --noconfirm ghostwriter

# Create folder structure
mkdir -p ~/Writing/{today,current-project,week,archive/{$(date +%Y),$(date +%Y/%m)},podcasts/{raw,edited},drafts,published}
touch ~/Writing/today/priorities.md

# Initialize Obsidian vault
# (user must manually open Obsidian and set vault folder to ~/Writing)
# Configure community plugins: Auto-save, Git, Pomodoro, Word Count, Dataview, Templater

# Git auto-commit cron
(crontab -l 2>/dev/null; echo "*/5 * * * * cd ~/Writing && git add . && git commit -m 'auto-save'") | crontab -
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-C"`

---

### Phase D — Podcast & Transcription Pipeline

**Goal:** One‑click recording, automatic transcription, and publishing prep.

```bash
# Install audio tools
sudo pacman -S --noconfirm audacity ffmpeg lame sox easyeffects
# Whisper (CPU optimised)
yay -S --noconfirm whisper.cpp
pip install --user openai-whisper

# Create ~/scripts/transcribe-watcher.py (watch raw folder, transcribe with whisper.cpp, output .md)
# Create ~/scripts/podcast-publish.py (FFmpeg normalize, generate RSS, upload to host)

# Systemd user service for watcher
mkdir -p ~/.config/systemd/user
# Write service file to ~/.config/systemd/user/aeon-transcribe.service
systemctl --user enable --now aeon-transcribe.service
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-D"`

---

### Phase E — Publishing Automation

**Goal:** Publish markdown posts to WordPress, Ghost, and Hugo with one click.

```bash
yay -S --noconfirm wp-cli
pip install --user python-wordpress-xmlrpc requests playwright
playwright install chromium

# Create ~/scripts/publish.py with GUI (Zenity) for file/platform selection
# Support front‑matter for tags/categories/featured image
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-E"`

---

### Phase F — AI Layer (3‑Tier Offline‑First)

**Goal:** Local LLM for most tasks, API fallback, and caching.

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:3b
ollama pull nomic-embed-text
ollama pull qwen2.5-coder:3b

# Install Open‑WebUI (Docker method)
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Create ~/services/open-webui/docker-compose.yml (port 3000)

# Create ~/scripts/ai-router.py:
# - Tier 1: Ollama (local)
# - Tier 2: Claude API (fallback)
# - Cache prompts & responses in ~/.cache/aeon/ai/
# - Export reusable functions to ~/scripts/offline-automations/

# Create systemd user service for Open‑WebUI
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-F"`

---

### Phase G — Notification System

**Goal:** Gentle, tiered nudges for productivity and health.

```bash
sudo pacman -S --noconfirm dunst libnotify
# Create ~/scripts/notification-engine.py
# Use systemd timers (not cron) for triggers
mkdir -p ~/.config/systemd/user
# Write timer/service units for:
# - hourly encouragement
# - hyperfocus break (90 min idle)
# - medication reminders
# - backup success
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-G"`

---

### Phase H — Safety & Diagnostics

**Goal:** Plain‑language error reporting and easy recovery.

```bash
sudo pacman -S --noconfirm cockpit
sudo systemctl enable --now cockpit.socket

# Create ~/scripts/log-translator.py (monitor journal, translate errors)
# Create weekly Timeshift systemd timer
# Add disk space monitor (<10% triggers cleanup)
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-H"`

---

### Phase I — Self‑Hosted Services (Optional)

**Goal:** Private cloud and search engine (if user wants full independence).

```bash
# Create ~/services/docker-compose.yml with:
# - Nextcloud (port 8080)
# - SearXNG (port 8888)
# - Ghost (port 2368)
# - Vikunja (port 3456)
# - Castopod (port 8000)

docker-compose -f ~/services/docker-compose.yml up -d
# Add systemd unit for auto‑start
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-I"`

---

### Phase J — Atomic Habits Integration

**Goal:** Gamify writing streaks and environment design.

```bash
# Create ~/scripts/habits.py:
# - Morning routine launcher (3 priorities)
# - Habit stacking triggers (e.g., after login → open Obsidian)
# - Website blocking during focus hours (/etc/hosts manipulation)
# - Streak counter in dashboard
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-J"`

---

### Phase K — Shareability Packaging

**Goal:** Make the entire setup reproducible as an ISO for non‑profits.

```bash
mkdir -p ~/aeon-installer/{config-templates,docs}
# Write install.sh (one‑command setup)
# Write uninstall.sh (clean removal)
# Create archiso profile to build custom live ISO
# Generate README.md with user guide and license (GPL‑3)
```

**Timeshift snapshot:** `sudo timeshift --create --comments "post-phase-K"`

---

## ✅ Final Verification

Run `~/scripts/verify-aeon.py` to check:
- All services active
- Directory structure correct
- Desktop shortcuts functional
- Wacom tablet detected (`xsetwacom --list`)
- Audio I/O working (`pactl info`)
- Network connectivity
- AI tiers responsive (Ollama, Claude API)

---

## 📋 Important Notes for the Agent

- **Ask for credentials only when absolutely necessary** (e.g., WordPress application password, Ghost API key). Never store them in plain text logs.
- **Default to safe, non‑destructive actions.** Never format drives or modify partitions.
- **Use Timeshift snapshots as safety net.** If something fails, suggest rollback.
- **All scripts must be executable and placed in `~/scripts/`** (or `~/.local/bin/` for binaries).
- **User is `sourou`, home is `/home/sourou`.** All paths are relative to this.
- **Prefer systemd user services over cron** for reliability.
- **Whenever an AI‑generated solution is used, cache it as a standalone Python script** in `~/scripts/offline-automations/`.

---

## 🚦 Proceed Phase by Phase

The user will guide you through each phase. After completing a phase, report:

- What was installed/configured
- Any issues encountered
- The Timeshift snapshot name created
- Await confirmation before moving to the next phase.

**Start with Phase A when ready.**

---

# 📘 AEON WRITER OS — The Complete Blueprint
## *An IKEA-Style Manual for Building a Personalized Linux for Humans*

---

# PART 1: WHY WE'RE BUILDING THIS

## 1.1 Lessons From The NixOS Project

**What We Learned (The Hard Way):**

| Lesson | What We Experienced | What To Avoid |
|--------|---------------------|---------------|
| **Declarative ≠ Simple** | 500+ lines of config for basic features | Any system requiring syntax mastery before use |
| **One typo = dead system** | Missing `"` cost us 30 minutes | Systems where tiny errors cascade |
| **Obscure error messages** | "syntax error, expecting '.' or '='" | Cryptic feedback loops |
| **Unintuitive flow** | Rebuild → reboot → test → repeat | Long iteration cycles |
| **No forgiving UX** | Black screen = panic | Systems that "fail silently into darkness" |
| **Documentation overload** | ArchWiki > NixOS Wiki because consistent | Fragmented, version-specific docs |

**The Core Insight**: We spent 4 hours fighting the OS instead of using it. **The OS must disappear. The work must become visible.**

## 1.2 Who Is This For?

**Primary Audience** (ordered by priority):
1. **Heavy writers** (100+ pages/day) with executive function challenges
2. **Adults with Alzheimer's** in early-to-mid stages who still create
3. **Autism + ADHD individuals** needing predictable environments
4. **Caregivers** maintaining systems for loved ones
5. **Non-profits** serving cognitive disabilities
6. **Anyone** who wants technology to get out of their way

**Design Philosophy**: *Atomic Habits* by James Clear — Make it Obvious. Make it Easy. Make it Attractive. Make it Satisfying.

---

# PART 2: HARDWARE SHOPPING LIST (What You Need)

## 2.1 You Already Have ✅
- Windows 11 laptop (the build machine)
- VS Code installed
- RTX 3050 + Intel laptop (target machine — we'll keep this, with dual-boot)

## 2.2 What To Buy 🛒

| Item | Purpose | Budget | Recommended |
|------|---------|--------|-------------|
| **USB 3.0 drive, 16GB+** | Arch bootable installer | $10 | SanDisk Ultra |
| **External SSD, 500GB+** | Portable Aeon OS | $50-80 | Samsung T7 or Crucial X6 |
| **Second USB drive, 8GB+** | Ventoy for testing ISOs | $8 | Any brand |
| **Wacom tablet** | Writing/signing/drawing | $80-300 | Wacom Intuos S or Intuos Pro |
| **Good microphone** | Podcast/voice transcription | $50-150 | Blue Yeti Nano or Samson Q2U |
| **Backup external HDD** | Weekly backups | $50 | Any 1TB+ USB drive |

**Total minimum**: ~$150 additional hardware

## 2.3 Optional But Valuable
- **Raspberry Pi 4** ($55) — Self-host Nextcloud, Ghost blog, SearXNG
- **Stream Deck** ($80) — Physical buttons for "Publish", "Record", "Save"
- **E-ink monitor** ($500) — Eye-friendly for heavy writers
- **Foot pedals** ($60) — Hands-free controls during transcription

---

# PART 3: THE ARCHITECTURE (What We're Building)

## 3.1 The "Board Screen" Philosophy

**Reject**: Empty desktop (Windows/Mac/classic Linux)  
**Adopt**: Always-visible dashboard where everything is one click away

```
┌─────────────────────────────────────────────────────────┐
│  AEON WRITER — Good morning, Sourou ☀️                  │
├─────────────────────────────────────────────────────────┤
│  TODAY'S MISSION (from atomic habits)                   │
│  ○ Write 100 pages of "Chapter 7"        [▶ OPEN]      │
│  ○ Record Episode 42 podcast             [🎙 START]     │
│  ○ Publish yesterday's draft             [📤 PUSH]      │
├─────────────────────────────────────────────────────────┤
│  ⏰ NEXT: Medication at 2:00 PM (in 47 min)            │
│  🧠 AI assistant ready (local + Claude API)             │
├─────────────────────────────────────────────────────────┤
│  📝 WRITE  🎙 PODCAST  📤 PUBLISH  📧 EMAIL  🔍 SEARCH  │
│  📅 CALENDAR  💾 BACKUP  🎨 DRAW  🤖 AI  ⚙️ HELP        │
├─────────────────────────────────────────────────────────┤
│  ✅ System: all good | 🔋 76% | ☁️ synced 2 min ago     │
└─────────────────────────────────────────────────────────┘
```

**Key principles:**
- **No hidden menus** — every tool visible
- **Large buttons** (48x48px minimum) for motor/vision issues  
- **Color coding** consistent across all screens
- **Progress visible always** — dopamine for ADHD brains
- **One screen = one decision** (reduce cognitive load)

## 3.2 The Notification System (Facebook, But For Good)

Social media exploits dopamine. We'll use the same mechanism for **productivity, health, and organization**.

**Notification Tiers:**

```
TIER 1 - GENTLE (no sound, fade in/out)
├─ "You've written 23 pages today 💫"
├─ "Focus streak: 47 minutes ✨"
└─ "Water reminder 💧"

TIER 2 - NOTICEABLE (soft chime)
├─ "⏰ Pomodoro break in 5 min"
├─ "💊 Medication in 10 min"
└─ "📝 Auto-save successful"

TIER 3 - IMPORTANT (banner + sound)
├─ "🎙 Podcast auto-published!"
├─ "✅ Daily goal reached"
└─ "📞 Family calling"

TIER 4 - CRITICAL (full screen)
├─ "⚠️ System needs attention"
├─ "🆘 Caregiver alert"
└─ "💊 Missed medication (2nd reminder)"
```

**Smart triggers** (Python-powered):
- **Time blindness**: Every hour → "You've been writing for 2 hours, you're doing great"
- **Hyperfocus detection**: No interaction 90 min → "Breathe. Look away. Drink water."
- **Achievement unlocks**: First 50 pages → confetti animation
- **Context-aware**: Reminder shows relevant action button

---

# PART 4: THE SOFTWARE STACK (Tools Chosen & Why)

## 4.1 Base OS Decision Tree

```
Do you want rolling-release + bleeding edge? 
├── YES → Arch Linux (manual) or EndeavourOS (guided)
└── NO → Debian stable or Fedora

Need extreme stability for caregiver?
├── YES → Fedora Kinoite (immutable)
└── NO → EndeavourOS

Budget: zero config pain?
└── CachyOS or EndeavourOS (Arch-based, pre-configured)
```

**OUR CHOICE**: **EndeavourOS** (Arch-based, installer does 90% of work)

**Fallback ranked**:
1. CachyOS (performance-tuned Arch)
2. Manjaro (stable Arch branch, but controversial)
3. Fedora Kinoite (if immutability preferred)

## 4.2 Desktop Environment

**Chosen: GNOME on Xorg**

| Why | Alternative rejected |
|-----|---------------------|
| Best accessibility (built-in screen reader, zoom) | KDE (too many options = cognitive overload) |
| GTK4 native support for our custom UI | XFCE (looks dated, less accessible) |
| Xorg = stable with Nvidia | Wayland (Nvidia still flaky) |
| Wacom Pro tablets work natively via libinput | Hyprland/Sway (too technical) |

## 4.3 The Writing Layer

| Tool | Purpose | Why This One |
|------|---------|--------------|
| **Obsidian** | Main writing app | Markdown, plugins, vault-based, local-first |
| **Typst** | Long-form documents | Modern LaTeX replacement, fast |
| **Ghostwriter** | Distraction-free mode | Zen writing, GTK native |
| **LibreOffice** | Compatibility fallback | When others send .docx |
| **OpenDyslexic + Atkinson Hyperlegible** | Fonts | Research-backed for cognitive disabilities |

## 4.4 Publishing & Content Platforms

**Research-validated options** (from our searches):

| Platform | Best For | Local | Verdict |
|----------|----------|-------|---------|
| **WordPress** | Max compatibility, 40% of web | Self-hostable | ✅ Primary |
| **Ghost** | Clean writer UX, modern | Self-hostable | ✅ Secondary |
| **Hugo** | Static sites, fast | Yes | ✅ Archive |
| **Grav** | File-based, no database | Yes | ⚠️ Niche |
| **Typemill** | Documentation | Yes | ⚠️ Niche |

**Our integration**: Python script that publishes to **all three** (WordPress + Ghost + Hugo) from a single markdown file.

## 4.5 Email Client

**Chosen: Thunderbird** (or Betterbird fork)

**Why**: Native desktop, encrypted, works with any provider, extensible.

**Alternatives researched**:
- **Evolution** (GNOME native, calendar integration)
- **Geary** (simple, clean)
- **Claws Mail** (power users)
- **Roundcube** (web-based, self-hosted)

## 4.6 Search Engine

**Chosen: SearXNG** (self-hosted meta-search)

**Why**: 
- Privacy-first
- Aggregates Google/Bing/DuckDuckGo without tracking
- Runs on your machine or Raspberry Pi
- No ads, no profiling

## 4.7 Cloud / Sync

**Chosen: Nextcloud** (self-hosted)

| Feature | Benefit |
|---------|---------|
| Files | Dropbox replacement |
| Calendar | CalDAV synced |
| Contacts | CardDAV synced |
| Notes | Obsidian sync alternative |
| Mail | Email aggregator (optional) |
| Deck | Trello replacement |

## 4.8 Podcast Stack

| Tool | Purpose |
|------|---------|
| **Audacity** | Recording, editing |
| **FFmpeg** | Automated processing |
| **Auphonic API** | AI audio cleanup |
| **Castopod** | Self-hosted podcast hosting (alternative to Spotify for Podcasters) |

## 4.9 Wacom Tablet Setup

**Packages needed** (from ArchWiki research):
```bash
sudo pacman -S xf86-input-wacom libwacom
# For non-Wacom: digimend-kernel-drivers-dkms (AUR)
# GUI config: yay -S wacom-utility (AUR)
```

**Apps that work perfectly:**
- Krita (painting)
- Xournal++ (PDF annotation + writing by hand)
- Inkscape (vector)
- GIMP (photo editing)
- Drawing (simple sketches)

## 4.10 AI Integration (The Core)

**Three-tier AI system**:

```
TIER 1 — LOCAL FIRST (always available, no internet)
├─ Ollama with llama3.2:3b (fast, small)
├─ Whisper (transcription)
├─ Piper (text-to-speech, offline)
└─ Purpose: 80% of daily tasks

TIER 2 — API WHEN BETTER
├─ ai API (complex writing help)
├─ GPT-4 API (fallback)
├─ DeepSeek API (cheap, good for code)
└─ Purpose: Complex tasks, when local isn't enough

TIER 3 — PYTHON AUTOMATION (your safety net)
├─ All AI interactions saved as Python functions
├─ Cached prompts + responses
├─ Reusable as offline scripts
└─ Purpose: When AI is unavailable, system still works
```

**This is critical**: Every time AI is used, the solution is converted into a Python script and saved. Over time, **80% of tasks won't need AI at all**.

---

# PART 5: THE INSTALLATION MANUAL (IKEA STYLE)

## 📦 PRE-FLIGHT CHECKLIST

Print this or keep on Windows laptop:

```
□ Back up important files from target laptop to external HDD
□ Charge laptop to 100% + plug in power
□ Stable internet connection
□ 2-3 hours of uninterrupted time
□ All hardware from shopping list ready
□ Phone available (for tethering if WiFi fails)
□ Windows laptop accessible (for guidance)
```

---

## 🔧 PHASE 0: Prepare Windows Laptop (15 min)

### Step 0.1 — Install Build Tools
Open PowerShell as Administrator:
```powershell
winget install Rufus.Rufus
winget install OBSProject.OBSStudio
winget install Microsoft.VisualStudioCode
```

### Step 0.2 — Download ISOs
Save to `C:\Aeon\ISOs\`:
1. EndeavourOS: https://endeavouros.com/download/
2. Ventoy: https://www.ventoy.net/ (for multi-boot USB)
3. GParted Live: https://gparted.org/ (partition rescue if needed)

### Step 0.3 — Create Ventoy USB
```
1. Insert 16GB USB
2. Run Ventoy2Disk.exe
3. Select USB → Install
4. Copy all 3 ISOs to the USB drive
```

You now have a **swiss-army-knife USB** that can boot any ISO.

---

## 🔧 PHASE 1: Dual-Boot Planning (10 min)

### Decision: Where Does Aeon Live?

**Option A — Safest: External SSD only**
- Zero risk to Windows
- Portable (plug into any machine)
- Slight speed reduction
- **RECOMMENDED FOR YOU**

**Option B — Dual boot internal**
- Faster
- Risk of breaking Windows
- Requires 60GB internal space

**Option C — Both!**
- Test on external SSD first
- Migrate to internal once comfortable

### Step 1.1 — Shrink Windows (only if Option B/C)

On Windows:
```
1. Win+X → Disk Management
2. Right-click C: → Shrink Volume
3. Enter 60000 (60GB)
4. Click Shrink
5. Leave the unallocated space alone
```

### Step 1.2 — Disable Fast Startup
```
Control Panel → Power Options → Choose what power buttons do
→ Change settings currently unavailable
→ Uncheck "Turn on fast startup"
```

### Step 1.3 — Disable Secure Boot (temporarily)
```
Restart → Hold F2/F10/Del (varies by laptop)
→ Security → Secure Boot → Disabled
→ Save & Exit
```

---

## 🔧 PHASE 2: Install EndeavourOS on External SSD (30 min)

### Step 2.1 — Boot From Ventoy USB
```
1. Plug in Ventoy USB + External SSD
2. Restart laptop
3. Spam F12 (or Esc/F8/F10) at boot logo
4. Select USB from boot menu
5. Choose EndeavourOS ISO from Ventoy menu
6. Select "Boot in normal mode"
```

### Step 2.2 — Launch Installer
```
Wait for desktop to load
Click "Start the Installer" on welcome screen
Choose: Online install (more current packages)
```

### Step 2.3 — Installer Choices (CRITICAL)

| Setting | Choose | Why |
|---------|--------|-----|
| Language | English | Skip locale issues |
| Location | Your timezone | |
| Keyboard | Your layout (AZERTY?) | |
| Desktop | **GNOME** | Best accessibility |
| Packages | Keep defaults + Firefox | |
| Bootloader | **systemd-boot** | Simpler than GRUB |
| Partitioning | **Manual** (important!) | Target external SSD |

### Step 2.4 — Partition The External SSD

**On the external SSD (NOT internal!):**
```
- 500MB   FAT32    /boot/efi    (boot flag)
- 40GB    ext4     /            (root)
- Rest    ext4     /home        (your data)
```

**Triple-check you selected the external SSD** (usually `/dev/sdb` or `/dev/sdc`).

### Step 2.5 — User Setup
```
Name: Sourou
Username: sourou
Hostname: aeon-writer
Password: [SIMPLE — change later]
Auto-login: ✅ YES
Root password: SAME as user (simpler)
```

### Step 2.6 — Graphics Driver
```
Select: Nvidia Proprietary
```

### Step 2.7 — Install & Wait (15-20 min)
Go make tea. Don't touch it.

### Step 2.8 — First Boot
```
Remove USB when prompted
Restart
Hold F12 → select external SSD
Welcome screen appears!
```

---

## 🔧 PHASE 3: Foundation Hardening (20 min)

### Step 3.1 — Open Terminal
Super key (Windows key) → type "Terminal" → Enter

### Step 3.2 — Update System
```bash
sudo pacman -Syu --noconfirm
```

### Step 3.3 — Safety Net First (CRITICAL)
```bash
# Install Timeshift (system rollback)
sudo pacman -S --noconfirm timeshift timeshift-autosnap

# Create first snapshot
sudo timeshift --create --comments "Fresh install"

# Auto-snapshot before updates
sudo systemctl enable --now cronie
```

### Step 3.4 — Install Core Tools
```bash
sudo pacman -S --noconfirm \
  base-devel git curl wget \
  nodejs npm python python-pip \
  firefox code neovim \
  htop btop tree ripgrep fzf \
  flatpak
```

### Step 3.5 — AUR Helper
```bash
# yay should already be installed, verify:
yay --version

# If not:
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Step 3.6 — Wacom Setup
```bash
sudo pacman -S --noconfirm xf86-input-wacom libwacom
yay -S --noconfirm digimend-kernel-drivers-dkms

# Test: plug in tablet, run:
xsetwacom --list devices
```

---

## 🔧 PHASE 4: Install Claude Code (10 min)

### Step 4.1 — Install Node (already done above, verify)
```bash
node --version    # should be v20+
npm --version
```

### Step 4.2 — Install Claude Code
```bash
npm install -g @anthropic-ai/claude-code or 
```

### Step 4.3 — Authenticate
```bash
claude login
# Follow browser prompts
# Use Anthropic Pro or API key
```

### Step 4.4 — Test
```bash
cd ~
mkdir aeon-build && cd aeon-build
claude
# Type: "hello, confirm you can write files here"
```

---

## 🔧 PHASE 5: Hand The Build To Claude Code (60-90 min)

This is where magic happens. Paste the **Master Build Prompt** (below) into Claude Code. It will take 60-90 minutes to set everything up.

### 🤖 THE MASTER BUILD PROMPT

Copy this exactly into Claude Code:

```
You are building "Aeon Writer OS" — a personalized Linux for a user with 
ADHD, Autism, and Alzheimer's awareness needs. The user writes 100 pages/day, 
produces podcasts, publishes to WordPress/Ghost/Hugo, and uses a Wacom tablet.

HARDWARE: Intel Alder Lake + Nvidia RTX 3050, external SSD as OS.
OS: EndeavourOS (Arch-based) with GNOME on Xorg.

DESIGN PHILOSOPHY: "Atomic Habits" by James Clear — Make it obvious, easy, 
attractive, and satisfying. The OS must disappear, the work must become visible.

Build everything in phases. After each phase, take a Timeshift snapshot, 
show status, and proceed. Ask only when you need credentials.

═══════════════════════════════════════════════════════════════════
PHASE A — ACCESSIBILITY FOUNDATION
═══════════════════════════════════════════════════════════════════
1. Install & configure fonts:
   - OpenDyslexic (AUR: ttf-opendyslexic-git)
   - Atkinson Hyperlegible (AUR)
   - Lexend (AUR: ttf-lexend)

2. GNOME tweaks via gsettings:
   - cursor-size: 48
   - text-scaling-factor: 1.5
   - enable-animations: false (reduce cognitive load)
   - high-contrast theme available but default off
   - clock-show-seconds: true
   - show-battery-percentage: true

3. Install GNOME Extensions (via gnome-browser-connector):
   - Just Perfection (hide distractions)
   - Pano (clipboard history for memory support)
   - Caffeine (prevent sleep during writing)
   - Vitals (system health visible)

═══════════════════════════════════════════════════════════════════
PHASE B — THE BOARD SCREEN (Custom UI)
═══════════════════════════════════════════════════════════════════
Build a GTK4 Python app called "aeon-dashboard" that:

1. Launches automatically at login (replaces empty desktop)
2. Shows these ALWAYS-VISIBLE sections:
   - Greeting with time of day
   - Today's 3 priority tasks (from ~/Writing/today/priorities.md)
   - Next scheduled event (from calendar)
   - 10 big buttons (Write, Podcast, Publish, Email, Search, 
     Calendar, Backup, Draw, AI Chat, Help)
   - System status bar (bottom)

3. Button actions:
   - Write → opens Obsidian in /today/
   - Podcast → opens Audacity + record template
   - Publish → runs ~/scripts/publish.py
   - Email → opens Thunderbird
   - Search → opens SearXNG in browser
   - Calendar → opens GNOME Calendar
   - Backup → runs ~/scripts/backup.py
   - Draw → opens Krita
   - AI Chat → opens Ollama WebUI
   - Help → shows simple FAQ

4. Store app at ~/.local/bin/aeon-dashboard
5. Create .desktop file to autostart
6. Use only pre-installed Python + PyGObject (no pip needed)

═══════════════════════════════════════════════════════════════════
PHASE C — WRITING ENVIRONMENT
═══════════════════════════════════════════════════════════════════
1. Install:
   - obsidian (flatpak)
   - ghostwriter (distraction-free)
   - typst, pandoc, hugo
   - zathura (PDF reader)
   - xournalpp (PDF + handwriting)

2. Create folder structure in ~/Writing/:
   /today/priorities.md        (auto-generated daily)
   /today/scratchpad.md
   /current-project/
   /week/
   /archive/YYYY/MM/
   /podcasts/raw/
   /podcasts/edited/
   /drafts/
   /published/

3. Configure Obsidian vault at ~/Writing/:
   - Default font: Atkinson Hyperlegible 16pt
   - Theme: Minimal (install community theme)
   - Plugins: Auto-save (30s), Git backup, Pomodoro, 
     Word count, Dataview, Templater
   - Keyboard shortcut: Ctrl+N opens today's note

4. Setup Git auto-commit:
   cd ~/Writing && git init
   Create cron job: every 5 minutes, git add . && git commit
   Hook to GitHub if user provides credentials

═══════════════════════════════════════════════════════════════════
PHASE D — TRANSCRIPTION & PODCAST PIPELINE
═══════════════════════════════════════════════════════════════════
1. Install:
   - audacity, ffmpeg, lame, sox
   - easyeffects (real-time audio filters)
   - pipewire (already running)
   - openai-whisper (via pip, user install)
   - whisper.cpp (AUR, for faster CPU)

2. Create ~/scripts/transcribe-watcher.py:
   - Watches ~/Writing/podcasts/raw/ for new .wav/.mp3
   - Auto-transcribes with Whisper
   - Saves .md transcript in ~/Writing/today/
   - Notifies user via notify-send

3. Create ~/scripts/podcast-publish.py:
   - Cleans audio via FFmpeg (normalize, noise reduce)
   - Generates RSS feed entry
   - Uploads to chosen host (ask user: Castopod, Podbean, or local)
   - Creates markdown show notes

4. Systemd user service for watcher (auto-start at login)

═══════════════════════════════════════════════════════════════════
PHASE E — PUBLISHING AUTOMATION
═══════════════════════════════════════════════════════════════════
1. Install:
   - wp-cli (yay)
   - python-wordpress-xmlrpc, python-requests (via pip)
   - playwright (fallback for complex UIs)

2. Ask user for:
   - WordPress URL + username + application password
   - (Optional) Ghost admin API key
   - (Optional) Hugo site Git repo URL

3. Create ~/scripts/publish.py:
   - Opens dialog: which file? which platform(s)?
   - Converts markdown → HTML via pandoc
   - Uploads to selected platforms in parallel
   - Uploads featured images automatically
   - Tags based on front matter
   - Shows progress + success notification

4. Desktop shortcut: "Publish" on dashboard

═══════════════════════════════════════════════════════════════════
PHASE F — AI LAYER (3-TIER)
═══════════════════════════════════════════════════════════════════
1. Install Ollama + pull models:
   - llama3.2:3b (fast chat)
   - nomic-embed-text (for semantic search)
   - qwen2.5-coder:3b (code help)

2. Install Open-WebUI (Docker or pip):
   Port 3000, accessible via dashboard

3. Create ~/scripts/ai-router.py:
   - Tier 1: Try Ollama first (local)
   - Tier 2: If task complex, use Claude API
   - Tier 3: Cache every successful prompt+response
   - Log cached solutions as reusable Python functions in 
     ~/scripts/ai-cache/

4. Create ~/scripts/offline-automations/ folder:
   - Every AI-generated solution saved as .py
   - Named by task: "summarize-article.py", "outline-essay.py"
   - So when AI isn't available, scripts still work

═══════════════════════════════════════════════════════════════════
PHASE G — NOTIFICATION SYSTEM (The Attention Engine)
═══════════════════════════════════════════════════════════════════
Build ~/scripts/notification-engine.py:

1. 4 tiers (gentle, noticeable, important, critical)
2. Use libnotify + dunst for delivery
3. Triggers:
   - Every hour during writing: encouragement message
   - Hyperfocus > 90min: "Breathe, look away"
   - Achievement milestones: "You wrote 50 pages today! 🎉"
   - Medication reminders (user-configurable)
   - Pomodoro cycles
   - Backup successes
   
4. Schedule via systemd timers (not cron — more reliable)
5. User config at ~/.config/aeon/notifications.yml

═══════════════════════════════════════════════════════════════════
PHASE H — SAFETY & DIAGNOSTICS
═══════════════════════════════════════════════════════════════════
1. Systemd service monitoring:
   - Nvidia driver health → auto-fallback alert
   - Disk space < 10% → notify + auto-cleanup old logs
   - Failed services → plain English notification
   - Memory pressure → suggest restart

2. Plain language translator for logs:
   Create ~/scripts/log-translator.py
   Monitors journalctl, translates errors to user-friendly text
   Example: "Display driver restarted — you're safe"

3. Weekly Timeshift snapshot via systemd timer

4. Cockpit dashboard (web UI at :9090):
   - System health visible
   - One-click rollback button
   - Remote access for caregiver/family

═══════════════════════════════════════════════════════════════════
PHASE I — SELF-HOSTED SERVICES (Optional but recommended)
═══════════════════════════════════════════════════════════════════
Via Docker Compose at ~/services/:

1. Nextcloud (files, calendar, contacts sync)
2. SearXNG (private search engine)
3. Ghost (blog, if user wants WordPress alternative)
4. Vikunja (tasks / todo)
5. Castopod (podcast hosting)

Configure systemd unit for auto-start

═══════════════════════════════════════════════════════════════════
PHASE J — ATOMIC HABITS INTEGRATION
═══════════════════════════════════════════════════════════════════
Build ~/scripts/habits.py:

1. Morning routine launcher:
   - Shows 3 priorities visibly on dashboard
   - Large "START" button for first task
   - Gamified streak counter

2. Habit stacking:
   - "After coffee → open Obsidian automatically"
   - "After writing 50 pages → play celebration sound"
   
3. Environment design:
   - Auto-block social sites during writing hours
   - Browser opens to task page, not new tab
   - Phone DND via KDE Connect

4. Identity affirmations:
   - Daily prompt: "You are a writer. You wrote X pages yesterday."

═══════════════════════════════════════════════════════════════════
PHASE K — SHAREABILITY (For Non-Profits)
═══════════════════════════════════════════════════════════════════
Package everything as installable:

1. Create ~/aeon-installer/ with:
   - install.sh (one-command setup)
   - config-templates/ (personalization)
   - docs/ (non-tech user guide)
   - uninstall.sh (clean removal)

2. Custom ISO builder script:
   - archiso-based
   - Embeds all configs + scripts
   - Produces bootable "Aeon Writer Live USB"

3. Write README.md:
   - Who this is for
   - Installation in 3 steps
   - Contact for help
   - License: GPL-3 (force sharing)

═══════════════════════════════════════════════════════════════════
POST-BUILD VERIFICATION
═══════════════════════════════════════════════════════════════════
Run ~/scripts/verify-aeon.py to test:
- All services running
- All folders exist
- All shortcuts work
- Wacom tablet detected
- Audio I/O functional
- Network connected
- AI tiers all responding

Report results clearly.
```

---

# PART 6: THE DAILY WORKFLOW (Post-Build)

## 6.1 Morning (30 seconds)

```
1. Open laptop → auto-login
2. Dashboard appears automatically
3. See today's 3 priorities
4. Click first task → environment opens
```

## 6.2 Writing (hours)

```
- Obsidian opens to today's note
- Pomodoro timer in corner
- Auto-save every 30s (silent)
- Word count visible
- Gentle notifications every hour
```

## 6.3 Recording Podcast (5 minutes setup)

```
- Click 🎙 PODCAST button
- Audacity opens pre-configured
- Record, stop, save
- Drop into /podcasts/raw/
- Automation takes over
```

## 6.4 Publishing (one click)

```
- Click 📤 PUBLISH button
- Dialog: "Which post? Which platform?"
- Python script handles everything
- Success notification appears
```

## 6.5 Evening (automatic)

```
- Backup runs silently
- Daily summary generated by AI
- Snapshot taken
- "Great work today ✅" notification
```

---

# PART 7: BOTTLENECKS & SOLUTIONS

| Potential Issue | Why It Happens | Solution |
|-----------------|----------------|----------|
| **Nvidia breaks after update** | Rolling release quirk | Auto-snapshot before update; rollback one command |
| **Wacom stops working** | USB disconnected | Xsetwacom auto-reapplies config on replug |
| **AI API costs climb** | Heavy Claude use | Ollama-first policy; cache everything |
| **Caregiver confused** | Tech jargon | Plain-language log translator |
| **Disk fills up** | Podcasts + logs | Weekly auto-cleanup script |
| **External SSD unplugged** | Accident | Immediate notification + read-only mode |
| **Forget password** | Alzheimer's | Fingerprint reader config + caregiver recovery |
| **Lost internet** | ISP issues | All critical features work offline (that's why Tier 1 is local AI) |

---

# PART 8: THE GIFT — SHARING WITH NON-PROFITS

## 8.1 The Vision

Once Aeon Writer OS is stable, package it as:

```
aeon-writer-live.iso (4GB bootable USB)
├── Auto-installs everything
├── Asks 3 questions (name, language, timezone)
├── Done in 20 minutes
└── Ready for someone with Alzheimer's, ADHD, Autism, or just
    anyone who wants simplicity
```

## 8.2 Target Organizations

- Alzheimer's Association local chapters
- Autism Speaks (critiqued but has reach)
- ADDA (ADHD association)
- Local cognitive disability charities
- Writers associations

## 8.3 License

**GPL-3**: Forces anyone who modifies to share back. The dream stays free.

---

# PART 9: WHAT YOU DO RIGHT NOW

## Immediate Next Steps:

```
□ Today:     Order external SSD + USB drives (Amazon next-day)
□ Tomorrow:  Print this blueprint
□ Day 3:     Buy Wacom tablet + microphone
□ Day 4:     Follow Phase 0-4 on Windows
□ Day 5-6:   Let Claude Code build (Phase 5) 
□ Day 7:     Test daily workflow
□ Week 2:    Refine based on actual usage
□ Month 2:   Package as shareable ISO
□ Month 3:   Share with first non-profit
```

---

# 🎯 FINAL NOTES

**What we learned from NixOS hell**:
- Tools that fight you are worse than no tools
- Simple > clever, always
- Iterate fast, fail cheap

**What Arch Linux Wiki taught us**:
- Good documentation beats good software
- Community-maintained > corporation-owned
- Transparency > magic

**What James Clear teaches us**:
- Environment shapes behavior
- Small systems compound
- Identity > goals

**What you are building**:

Not just an OS. A **gift**. A tool that disappears so humans can create. A rebellion against complexity. A love letter to the neurodivergent, the aging, the caregivers, and everyone who ever felt like technology was designed for someone else.

**Your role after build**: Just write. The system maintains itself.  
**Your eventual role**: Share this with someone who needs it.

---

**Estimated total build time**: 2-3 hours active + overnight downloads  
**Estimated weekly maintenance**: 5 minutes  
**Impact**: Immeasurable

Build it. Share it. Change things. 🚀