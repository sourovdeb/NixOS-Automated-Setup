# PHASE A EXECUTION GUIDE (NOW ACTIVE)
**Status**: EndeavourOS installed on external SSD ✅ | **Next**: Execute Phase A

---

## CURRENT STATE

✅ You are now booted into EndeavourOS on the external SSD  
✅ Fresh Linux environment ready  
✅ Phase A script is prepared and ready to execute  
⏳ Next: Transfer scripts from Windows → Linux, then run Phase A

---

## STEP 1: Transfer linux_scripts Folder to Your Linux System

Choose ONE method below (easiest first):

### Method A: USB Drive (Easiest if you have USB)
```bash
# On Windows:
# 1. Insert USB drive
# 2. Copy folder: C:\Users\souro\Desktop\Arch_Linus\linux_scripts → USB
# 3. Eject USB

# On Linux:
# 1. Insert USB drive
# 2. Open Files → find USB drive
# 3. Copy linux_scripts folder to ~/aeon-build/
mkdir -p ~/aeon-build
cp -r /path/to/usb/linux_scripts ~/aeon-build/
```

### Method B: Network Share (If Windows + Linux on same WiFi)
```bash
# On Windows (enable file sharing):
# 1. Open Windows Explorer
# 2. Right-click C:\Users\souro\Desktop\Arch_Linus → Share with → Specific people
# 3. Get Windows IP: ipconfig (look for IPv4 Address)

# On Linux:
# 1. Open Files
# 2. Press Ctrl+L (location bar)
# 3. Type: smb://[windows-ip]/Arch_Linus
# 4. Copy linux_scripts to ~/aeon-build/
mkdir -p ~/aeon-build
```

### Method C: SCP (If you know Windows IP address)
```bash
# On Linux terminal:
# Get the Windows IP first:
# Windows: ipconfig → IPv4 Address

# Then copy scripts:
mkdir -p ~/aeon-build
scp -r sourou@[windows-ip]:"C:\Users\souro\Desktop\Arch_Linus\linux_scripts" ~/aeon-build/

# Or if easier, copy one script at a time:
scp sourou@[windows-ip]:"C:\Users\souro\Desktop\Arch_Linus\linux_scripts\01_phase_a_accessibility.sh" ~/aeon-build/
```

### Method D: Re-type Phase A Script (If no network/USB)
```bash
# Open this file on Windows:
# C:\Users\souro\Desktop\Arch_Linus\linux_scripts\01_phase_a_accessibility.sh

# Copy the entire script text, paste into Linux terminal:
# cat > ~/aeon-build/01_phase_a_accessibility.sh << 'EOF'
# [paste script here]
# EOF

# Then proceed to Step 2
```

---

## STEP 2: Set Up Working Directory

Once scripts are copied to Linux:

```bash
# On Linux terminal:
mkdir -p ~/aeon-build/logs

# Verify Phase A script exists:
ls -la ~/aeon-build/01_phase_a_accessibility.sh

# Make it executable:
chmod +x ~/aeon-build/01_phase_a_accessibility.sh
```

---

## STEP 3: Run Phase A (Accessibility — 20 minutes)

```bash
# Navigate to build directory:
cd ~/aeon-build

# Run Phase A script:
./01_phase_a_accessibility.sh

# What it does:
# ✅ Installs accessibility packages (screen reader, fonts)
# ✅ Installs dyslexic-friendly fonts (OpenDyslexic, Atkinson, Lexend)
# ✅ Configures GNOME settings:
#    - Cursor size: 48px (large, easy to track)
#    - Text scaling: 1.5x (50% larger text)
#    - Animations: disabled (reduce distraction)
#    - Theme: Adwaita dark (easier on eyes)
#    - Battery percentage: shown (always visible)
# ✅ Installs Extension Manager (Flatpak)
# ✅ Creates Timeshift snapshot named "post-phase-A"

# Timeline: ~15-20 minutes (mostly downloading + installing packages)
```

---

## STEP 4: Install GNOME Extensions Manually

After Phase A completes, install extensions via GNOME Extension Manager:

```bash
# Open Extension Manager:
# - Click Activities → Extension Manager (or type in search)
# - OR: flatpak run com.mattjakeman.ExtensionManager

# Search and install these 4 extensions:
# 1. Just Perfection (ID: 3843) — Hide unwanted UI elements
# 2. Pano (ID: 5278) — Clipboard manager
# 3. Caffeine (ID: 517) — Keep screen awake
# 4. Vitals (ID: 518) — System monitoring widget

# Each extension: Click "Install" button
# Enable each after installation (toggle switch)
```

---

## STEP 5: Verify Phase A Complete

```bash
# Check Timeshift snapshot was created:
sudo timeshift --list | grep "post-phase-A"

# Check logs:
cat ~/aeon-build/logs/01_phase_a_accessibility.log

# Verify fonts installed:
fc-list | grep -i "opendyslexic\|atkinson\|lexend"

# Check GNOME settings applied:
gsettings get org.gnome.desktop.interface cursor-size
gsettings get org.gnome.desktop.interface text-scaling-factor
```

---

## AFTER PHASE A IS COMPLETE

Once Phase A succeeds:

1. ✅ Take a screenshot of your GNOME desktop
2. ✅ Note any issues or missing extensions
3. ✅ Verify fonts are installed (check in Settings → Fonts)
4. ✅ Test cursor size and text scaling (should be noticeably larger)
5. ✅ Confirm Timeshift snapshot "post-phase-A" exists

Then you're ready for **Phase B (Dashboard)** — which creates a custom GTK4 dashboard with 10 action buttons.

---

## REFERENCE: All 13 Phases Ahead

| Phase | Script | Duration | Goal |
|-------|--------|----------|------|
| **A** | 01_phase_a_accessibility.sh | 20 min | Fonts, GNOME tweaks, extensions |
| **B** | 02_phase_b_dashboard.sh | 45 min | Custom GTK4 dashboard (10 buttons) |
| **C** | 03_phase_c_writing.sh | 20 min | Obsidian, folder structure, git auto-commit |
| **D** | 04_phase_d_podcast.sh | 30 min | Audacity, Whisper transcription |
| **E** | 05_phase_e_publishing.sh | 30 min | Hugo, multi-platform publishing |
| **F** | 06_phase_f_ai.sh | 45 min | Ollama, Open-WebUI (local AI) |
| **G** | 07_phase_g_notifications.sh | 30 min | Dunst, 4-tier notification system |
| **H** | 08_phase_h_safety.sh | 25 min | Cockpit, Timeshift automation |
| **I** | 09_phase_i_services.sh | 45 min | Docker services (Nextcloud, SearXNG, Ghost) |
| **J** | 10_phase_j_habits.sh | 30 min | Atomic habits tracking, streaks |
| **K** | 11_phase_k_packaging.sh | 45 min | Custom ISO packaging |
| **Verify** | 99_verify.sh | 5 min | Validation check |
| **TOTAL** | | ~5.5 hours | Full AEON OS configured |

---

## TROUBLESHOOTING Phase A

**Issue**: `yay: command not found`
```bash
# Solution: yay (AUR helper) not installed, use pacman instead:
sudo pacman -S --noconfirm --needed ttf-opendyslexic ttf-atkinson-hyperlegible ttf-lexend
# (Fonts may be in different AUR packages, adjust as needed)
```

**Issue**: Fonts don't appear in GNOME Settings
```bash
# Solution: Refresh font cache:
fc-cache -fv
# Then restart GNOME:
killall -9 gnome-shell
```

**Issue**: Extension Manager won't install extensions
```bash
# Solution: Use GNOME Extensions website instead:
# https://extensions.gnome.org/
# Search for extension name, click "Install"
```

**Issue**: Timeshift snapshot fails
```bash
# Solution: May need Timeshift configuration
sudo timeshift --check
# If not configured, first run:
sudo timeshift --create --description "Initial snapshot"
```

---

## NEXT IMMEDIATE ACTION

1. ✅ Copy linux_scripts folder to Linux (pick Method A-D above)
2. ✅ Run: `cd ~/aeon-build && ./01_phase_a_accessibility.sh`
3. ✅ Wait 15-20 minutes for Phase A to complete
4. ✅ Manually install GNOME extensions via Extension Manager
5. ✅ Verify Timeshift snapshot "post-phase-A" exists
6. 🔜 Then: Run Phase B (Dashboard) — 45 minutes

**Total remaining after Phase A**: ~5 hours 20 minutes (Phases B-K)

