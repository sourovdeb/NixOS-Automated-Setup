# AEON WRITER OS — BUILD PLAN
## Personalized Linux for Creative Writers with Accessibility Needs

**Project Owner:** Sourou  
**Target Date:** April 2026  
**Build Duration:** 2-3 hours (active) + overnight (automated)  
**Maintenance:** ~5 minutes weekly  

---

## 📋 EXECUTIVE SUMMARY

Building a **personalized, accessible Linux environment** (EndeavourOS/Arch-based) optimized for:
- Heavy daily writing (100+ pages)
- Podcast production & publishing
- Multi-platform content distribution (WordPress, Ghost, Hugo)
- Wacom tablet input (drawing, PDF annotation)
- Offline-first AI assistance (Ollama + Claude API fallback)

**Design Philosophy:** Make it obvious, easy, attractive, and satisfying. **The OS must disappear. The work must become visible.**

---

## 🎯 KEY OBJECTIVES

| Objective | Success Criteria |
|-----------|-----------------|
| **Write without distraction** | Dashboard → Obsidian in 1 click |
| **Record & publish podcasts** | Audio → Published in <5 minutes |
| **Multi-platform publishing** | One markdown file → WordPress/Ghost/Hugo simultaneously |
| **Accessibility first** | Large fonts, no flashing, voice assistance available |
| **Offline capability** | Core features work without internet (Ollama AI) |
| **Safety net** | Timeshift snapshots for instant rollback |
| **Caregiver-friendly** | Plain English error messages, simple controls |

---

## 🛒 HARDWARE REQUIREMENTS

### Already Have ✅
- Windows 11 laptop (build machine)
- Intel Alder Lake + Nvidia RTX 3050 (target machine)
- Stable internet connection

### Must Buy 🛍️
| Item | Cost | Purpose |
|------|------|---------|
| External SSD (500GB+) | $50-80 | Primary Aeon OS drive |
| USB 3.0 drive (16GB+) | $10 | Arch bootable installer |
| Second USB (8GB+) | $8 | Ventoy multi-boot USB |
| Wacom tablet (optional) | $80-300 | PDF annotation & drawing |
| Backup external HDD | $50 | Weekly backups |

**Total: ~$150 minimum**

---

## 🗂️ SOFTWARE STACK

### Base OS
- **Distribution:** EndeavourOS (Arch-based)
- **Desktop:** GNOME on Xorg
- **Bootloader:** systemd-boot
- **Key advantage:** Guided installer + rolling release + accessibility built-in

### Writing & Content
| Layer | Tool | Why |
|-------|------|-----|
| **Writing** | Obsidian | Markdown vault, plugins, local-first |
| **Distraction-free** | Ghostwriter | Zen mode, GTK native |
| **Long-form** | Typst | Modern LaTeX replacement |
| **PDF/Annotation** | Xournal++ | Handwriting + PDF editing |
| **Publishing** | Custom Python script | Auto-upload to WordPress/Ghost/Hugo |

### Media
- **Recording:** Audacity
- **Transcription:** Whisper.cpp + openai-whisper
- **Audio editing:** FFmpeg, easyeffects
- **Drawing:** Krita

### AI & Automation
- **Local AI (Tier 1):** Ollama + llama3.2:3b
- **Cloud fallback (Tier 2):** Claude API
- **UI:** Open-WebUI (port 3000)
- **Cache:** Python offline automation scripts

### Cloud & Sync
- **Files:** Nextcloud (self-hosted)
- **Search:** SearXNG (private meta-search)
- **Email:** Thunderbird
- **Calendar:** GNOME Calendar + CalDAV

### Accessibility
- **Fonts:** OpenDyslexic, Atkinson Hyperlegible, Lexend
- **Settings:** Large cursors (48px), text scaling 1.5x, no animations
- **Extensions:** Just Perfection, Pano, Caffeine, Vitals

---

## 🔨 BUILD PHASES (11 Sequential Phases)

### **PHASE 0** — Windows Preparation (15 min)
**Outcome:** Build tools ready, ISOs downloaded, bootable USBs created

- [ ] Install Rufus, OBS Studio, VS Code via winget
- [ ] Download EndeavourOS, Ventoy, GParted ISOs
- [ ] Create Ventoy USB with all 3 ISOs
- [ ] Disable Windows Fast Startup
- [ ] Disable Secure Boot (temporarily)
- [ ] Shrink Windows drive (if dual-boot intended)

---

### **PHASE 1** — Boot EndeavourOS & Install (30 min)
**Outcome:** Fresh EndeavourOS running on external SSD with Nvidia drivers

- [ ] Boot from Ventoy USB
- [ ] Select EndeavourOS ISO
- [ ] Run installer → choose:
  - Desktop: GNOME
  - Bootloader: systemd-boot
  - Graphics: Nvidia proprietary
  - Partition: Manual (external SSD only!)
  - User: sourou (auto-login enabled)
- [ ] Create initial Timeshift snapshot: `post-phase-0`
- [ ] Reboot into new OS

---

### **PHASE A** — Accessibility Foundation (20 min)
**Outcome:** Large text, readable fonts, reduced cognitive load

**Commands:**
```bash
# Install fonts
yay -S --noconfirm ttf-opendyslexic-git ttf-atkinson-hyperlegible ttf-lexend

# GNOME tweaks
gsettings set org.gnome.desktop.interface cursor-size 48
gsettings set org.gnome.desktop.interface text-scaling-factor 1.5
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Install Extension Manager
flatpak install -y flathub com.mattjakeman.ExtensionManager
```

**Extensions to install (via Extension Manager GUI):**
- Just Perfection (hide distractions)
- Pano (clipboard history)
- Caffeine (prevent sleep)
- Vitals (system health)

**Timeshift:** `sudo timeshift --create --comments "post-phase-A"`

---

### **PHASE B** — The Board Screen (Custom Dashboard) (45 min)
**Outcome:** Always-visible dashboard with 10 big action buttons

**Create:** `~/.local/bin/aeon-dashboard` (Python GTK4 app)

**Features:**
- Greeting + time of day
- Today's 3 priorities (from `~/Writing/today/priorities.md`)
- Next calendar event
- 10 large buttons:
  - 📝 Write → Obsidian
  - 🎙 Podcast → Audacity
  - 📤 Publish → publish.py
  - 📧 Email → Thunderbird
  - 🔍 Search → SearXNG localhost:8888
  - 📅 Calendar → GNOME Calendar
  - 💾 Backup → backup.py
  - 🎨 Draw → Krita
  - 🤖 AI Chat → localhost:3000
  - ⚙️ Help → FAQ dialog
- Status bar (system health)

**Autostart:** Create `~/.config/autostart/aeon-dashboard.desktop`

**Timeshift:** `sudo timeshift --create --comments "post-phase-B"`

---

### **PHASE C** — Writing Environment (20 min)
**Outcome:** Obsidian vault with folder structure and auto-git-backup

**Install packages:**
```bash
sudo pacman -S --noconfirm pandoc typst hugo zathura xournalpp ghostwriter
flatpak install -y flathub md.obsidian.Obsidian
```

**Create folder structure:**
```
~/Writing/
├── today/
│   ├── priorities.md (auto-generated daily)
│   └── scratchpad.md
├── current-project/
├── week/
├── archive/YYYY/MM/
├── podcasts/raw/
├── podcasts/edited/
├── drafts/
└── published/
```

**Obsidian setup:**
- Vault: ~/Writing
- Font: Atkinson Hyperlegible 16pt
- Theme: Minimal (community)
- Plugins: Auto-save, Git, Pomodoro, Word Count, Dataview, Templater

**Git auto-backup:**
```bash
cd ~/Writing && git init
# Cron: */5 * * * * cd ~/Writing && git add . && git commit -m 'auto-save'
```

**Timeshift:** `sudo timeshift --create --comments "post-phase-C"`

---

### **PHASE D** — Podcast Pipeline (30 min)
**Outcome:** Auto-transcription watcher + publish script

**Install:**
```bash
sudo pacman -S --noconfirm audacity ffmpeg lame sox easyeffects
yay -S --noconfirm whisper.cpp
pip install --user openai-whisper
```

**Create scripts:**
- `~/scripts/transcribe-watcher.py` — watches /podcasts/raw/, auto-transcribes
- `~/scripts/podcast-publish.py` — normalizes audio, generates RSS, uploads

**Systemd user service:** `~/.config/systemd/user/aeon-transcribe.service`

**Activate:**
```bash
systemctl --user enable --now aeon-transcribe.service
```

**Timeshift:** `sudo timeshift --create --comments "post-phase-D"`

---

### **PHASE E** — Publishing Automation (30 min)
**Outcome:** One-click publish to WordPress, Ghost, Hugo

**Install:**
```bash
yay -S --noconfirm wp-cli
pip install --user python-wordpress-xmlrpc requests playwright
playwright install chromium
```

**Ask user for credentials:**
- WordPress URL + username + application password
- (Optional) Ghost API key
- (Optional) Hugo Git repo URL

**Create:** `~/scripts/publish.py`
- File/platform selection dialog
- Markdown → HTML conversion (pandoc)
- Parallel upload to all platforms
- Featured image handling
- Tag/category mapping from front matter
- Success notification

**Timeshift:** `sudo timeshift --create --comments "post-phase-E"`

---

### **PHASE F** — AI Layer (3-Tier Offline-First) (45 min)
**Outcome:** Local Ollama AI + Claude API fallback + caching

**Install Ollama & models:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:3b
ollama pull nomic-embed-text
ollama pull qwen2.5-coder:3b
```

**Install Open-WebUI:**
```bash
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Create ~/services/open-webui/docker-compose.yml (port 3000)
```

**Create:** `~/scripts/ai-router.py`
- Tier 1: Try Ollama first (local, always available)
- Tier 2: Claude API if Ollama can't handle task
- Tier 3: Cache all successful prompts + responses
- Save reusable solutions as Python scripts in `~/scripts/offline-automations/`

**Systemd service:** Auto-start Open-WebUI

**Timeshift:** `sudo timeshift --create --comments "post-phase-F"`

---

### **PHASE G** — Notification System (30 min)
**Outcome:** Gentle, tiered nudges for productivity + health

**Install:**
```bash
sudo pacman -S --noconfirm dunst libnotify
```

**Create:** `~/scripts/notification-engine.py`

**Tiers:**
- **Tier 1 (Gentle):** No sound, fade-in/out
  - "You've written 23 pages today 💫"
  - "Focus streak: 47 minutes ✨"
- **Tier 2 (Noticeable):** Soft chime
  - "Pomodoro break in 5 min"
  - "Medication reminder"
- **Tier 3 (Important):** Banner + sound
  - "Daily goal reached"
  - "Podcast published!"
- **Tier 4 (Critical):** Full screen
  - System warnings
  - Caregiver alerts

**Systemd timers** (not cron):
- Hourly encouragement
- Hyperfocus break (90min idle)
- Medication reminders
- Backup confirmation

**Config:** `~/.config/aeon/notifications.yml`

**Timeshift:** `sudo timeshift --create --comments "post-phase-G"`

---

### **PHASE H** — Safety & Diagnostics (25 min)
**Outcome:** Plain-English error reporting + safe rollback

**Install:**
```bash
sudo pacman -S --noconfirm cockpit
sudo systemctl enable --now cockpit.socket
```

**Create:**
- `~/scripts/log-translator.py` — monitors journalctl, translates errors
- Weekly Timeshift systemd timer
- Disk space monitor (<10% → auto-cleanup)

**Cockpit dashboard:** Web UI at localhost:9090
- System health visible
- One-click rollback option
- Remote access for caregiver

**Timeshift:** `sudo timeshift --create --comments "post-phase-H"`

---

### **PHASE I** — Self-Hosted Services (Optional, 45 min)
**Outcome:** Private Nextcloud, SearXNG, Ghost, Vikunja, Castopod

**Create:** `~/services/docker-compose.yml` with:
- Nextcloud:3000 (files, calendar, contacts)
- SearXNG:8888 (private search)
- Ghost:2368 (blog alternative)
- Vikunja:3456 (tasks)
- Castopod:8000 (podcast hosting)

**Systemd unit:** Auto-start on boot

**Timeshift:** `sudo timeshift --create --comments "post-phase-I"`

---

### **PHASE J** — Atomic Habits Integration (30 min)
**Outcome:** Gamified writing streaks + environment design

**Create:** `~/scripts/habits.py`

**Features:**
- Morning routine launcher (3 priorities visible)
- Habit stacking triggers (after login → open Obsidian)
- Website blocking during focus hours (/etc/hosts manipulation)
- Streak counter visible on dashboard
- Identity affirmations ("You are a writer")

**Timeshift:** `sudo timeshift --create --comments "post-phase-J"`

---

### **PHASE K** — Shareability Packaging (45 min)
**Outcome:** Reproducible setup for non-profits

**Create:** `~/aeon-installer/` with:
- `install.sh` — one-command setup
- `uninstall.sh` — clean removal
- `config-templates/` — personalization options
- `docs/` — non-technical user guide
- `README.md` — who this is for, quick start, GPL-3 license

**Build custom ISO:**
- Use archiso to create bootable "Aeon Writer Live"
- Auto-install on first boot
- Ask only 3 questions: name, language, timezone
- Ready for non-profits serving neurodivergent communities

**Timeshift:** `sudo timeshift --create --comments "post-phase-K"`

---

### **VERIFICATION** — Post-Build Testing (15 min)

**Run:** `~/scripts/verify-aeon.py`

Checks:
- [ ] All systemd services active
- [ ] All directories exist with correct structure
- [ ] All desktop shortcuts functional
- [ ] Wacom tablet detected: `xsetwacom --list`
- [ ] Audio I/O working: `pactl info`
- [ ] Network connectivity
- [ ] AI tiers all responding (Ollama + Claude API)
- [ ] Git auto-backup working
- [ ] Timeshift snapshots created

---

## ⏱️ BUILD TIMELINE

| Phase | Duration | Cumulative |
|-------|----------|-----------|
| Phase 0 (Windows prep) | 15 min | 15 min |
| Phase 1 (Install OS) | 30 min | 45 min |
| Phase A (Accessibility) | 20 min | 1h 5m |
| Phase B (Dashboard) | 45 min | 1h 50m |
| Phase C (Writing) | 20 min | 2h 10m |
| Phase D (Podcast) | 30 min | 2h 40m |
| Phase E (Publishing) | 30 min | 3h 10m |
| Phase F (AI) | 45 min | 3h 55m |
| Phase G (Notifications) | 30 min | 4h 25m |
| Phase H (Safety) | 25 min | 4h 50m |
| Phase I (Services) | 45 min | 5h 35m |
| Phase J (Habits) | 30 min | 6h 5m |
| Phase K (Packaging) | 45 min | 6h 50m |
| Verification | 15 min | **7h 5m** |

**Actual time:** 2-3 hours (active) + overnight (automated downloads/builds)

---

## 🎯 DAILY WORKFLOW (Post-Build)

### Morning (30 seconds)
1. Open laptop → auto-login
2. Dashboard appears automatically
3. See today's 3 priorities
4. Click button → environment opens

### Writing (hours)
- Obsidian opens to today's note
- Pomodoro timer in corner
- Auto-save every 30s (silent)
- Word count visible
- Hourly encouragement notification
- Hyperfocus break reminders (90+ min idle)

### Podcast Recording (5 minutes setup)
- Click 🎙 PODCAST button
- Audacity opens pre-configured
- Record, stop, save to /podcasts/raw/
- Automation transcribes & publishes

### Publishing (one click)
- Click 📤 PUBLISH button
- Select file & platforms
- Python script uploads to WordPress/Ghost/Hugo
- Success notification

### Evening (automatic)
- Backup runs silently
- Daily summary generated
- Timeshift snapshot created
- "Great work today ✅" notification

---

## ⚠️ CRITICAL CONSTRAINTS & SOLUTIONS

| Risk | Why | Solution |
|------|-----|----------|
| **Nvidia driver breaks** | Rolling release | Pre-update snapshot → rollback one command |
| **Wacom stops working** | USB issue | Xsetwacom auto-reapply on replug |
| **AI API costs climb** | Heavy Claude use | Ollama-first + caching policy |
| **Caregiver confusion** | Tech jargon | Plain-language log translator |
| **Disk fills** | Podcast/logs | Weekly auto-cleanup script |
| **External SSD unplugged** | Accident | Notification + read-only mode |
| **Forgotten password** | Alzheimer's | Fingerprint reader setup |
| **Lost internet** | ISP down | All critical features work offline |

---

## 🎁 LONG-TERM VISION (Post-Build)

### Months 1-2
- Test daily workflow
- Refine based on real usage
- Fix edge cases
- Document learnings

### Months 2-3
- Package as custom ISO
- Create non-tech user guide
- Set up GPL-3 license
- Reach out to organizations

### Target Organizations
- Alzheimer's Association chapters
- ADDA (ADHD Association)
- Autism Speaks chapters
- Local cognitive disability charities
- Writers associations

**Impact:** Free, reproducible setup for neurodivergent creators worldwide

---

## 📚 KEY DESIGN PRINCIPLES

From *Atomic Habits* by James Clear:

1. **Make it obvious** — Everything one click away (Board Screen)
2. **Make it easy** — Zero cognitive friction (auto-save, auto-backup, auto-publish)
3. **Make it attractive** — Consistent, calm, dark UI with readable fonts
4. **Make it satisfying** — Visible progress (word counts, streaks, notifications)

**Core Philosophy:** *The OS must disappear. The work must become visible.*

---

## ✅ SUCCESS CRITERIA

By end of build, verify:
- [ ] Laptop boots to dashboard in <30 seconds
- [ ] Write 100 pages without distraction
- [ ] Record & publish podcast in <10 minutes
- [ ] Publish to 3 platforms simultaneously
- [ ] System works offline (Ollama AI available)
- [ ] One Timeshift snapshot per phase created
- [ ] All scripts tested & documented
- [ ] Non-technical user can understand error messages
- [ ] External SSD portable & bootable on other machines
- [ ] Caregiver can understand system & perform rollback

---

## 👤 USER PROFILE

**Name:** Sourou  
**Neurodiversity:** ADHD, Autism, Alzheimer's awareness  
**Primary Use:** Writing (100+ pages/day)  
**Secondary Uses:** Podcast production, Publishing, Drawing  
**Hardware:** Intel Alder Lake + Nvidia RTX 3050 (laptop)  
**Storage:** External SSD (portable, dual-boot optional)  
**Input Devices:** Keyboard, mouse, Wacom tablet  
**Internet:** Offline-first design preferred  

---

## 🚀 HOW TO PROCEED

1. **Review this plan** with user
2. **Order hardware** (if needed)
3. **Print Phase 0-4 instructions** for reference
4. **Follow phases sequentially**
5. **Take Timeshift snapshot after each phase**
6. **Proceed only after user confirmation**
7. **Document issues & solutions**
8. **Test daily workflow thoroughly**
9. **Package for sharing (Phase K)**
10. **Share with non-profits**

---

## 📞 SUPPORT CONTACTS

- **Arch Wiki:** https://wiki.archlinux.org (documentation)
- **EndeavourOS Community:** https://endeavouros.com (forum)
- **Ollama Docs:** https://ollama.com (AI setup)
- **GNOME Documentation:** https://help.gnome.org (accessibility)

---

**Document Created:** April 20, 2026  
**Last Updated:** April 20, 2026  
**Status:** ✅ Ready for Phase 0
