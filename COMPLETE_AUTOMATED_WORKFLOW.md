# COMPLETE AUTOMATED WORKFLOW
**The entire build process from this moment until Phase A completes**

---

## ONE COMMAND TO RUN EVERYTHING

```powershell
C:\Users\souro\Desktop\Arch_Linus\scripts\master_orchestrator.ps1
```

**What this does:**
1. Starts continuous monitoring (3-minute reviews)
2. Waits for SSD to boot
3. Auto-triggers Phase A deployment when boot detected
4. Guides through nomodeset + Phase A execution

**Duration:**
- Monitoring: Until you boot (~0-30 min depending on when you start)
- nomodeset application: 5 minutes
- Phase A execution: 20 minutes
- **Total: ~30-55 minutes to fully configured system**

---

## STEP-BY-STEP WORKFLOW

### Step 1: Boot the SSD (User Action - 5 min)
```
1. Restart Windows
2. Press F12 during boot
3. Select: UEFI: [JMicron USB SSD]
4. Wait for EndeavourOS GNOME desktop
```

### Step 2: Master Orchestrator Detects Boot (Automatic)
```
Terminal shows:
  [09:28:51] Review #2 - ❌ NOT BOOTED
  [09:31:51] Review #3 - ❌ NOT BOOTED
  [09:34:51] Review #4 - ✅ BOOTED!
  !!! BOOT DETECTED !!!
  
Then auto-triggers Phase A deployment...
```

### Step 3: Apply nomodeset (User Action - 5 min)
```bash
# Terminal prompts will show this procedure:
sudo nano /etc/default/grub

# Find: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
# Change to: GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"
# Save: Ctrl+O, Enter, Ctrl+X

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

### Step 4: Phase A Executes (Automatic - 20 min)
```bash
# After system reboots with nomodeset applied:
cd ~/aeon-build

# Enable auto-execution service (recommended):
sudo cp aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-phase-a.service
systemctl --user start aeon-phase-a.service

# Monitor progress:
journalctl --user -f -u aeon-phase-a.service
```

**What Phase A installs:**
- Accessibility fonts (OpenDyslexic, Atkinson, Lexend)
- GNOME tweaks (large cursor, text scaling, dark theme)
- Extensions (Just Perfection, Pano, Caffeine, Vitals)
- Timeshift snapshot for rollback

### Step 5: Phase A Complete
```
System is now configured for accessibility.
Ready for Phase B (Dashboard) if desired.
```

---

## HOW TO START

### NOW - Open terminal and run:
```powershell
cd "C:\Users\souro\Desktop\Arch_Linus"
.\scripts\master_orchestrator.ps1
```

This starts the entire workflow:
- Monitoring begins immediately
- Waits for you to boot SSD
- Guides through Phase A automatically
- Continues until system is ready

### Alternative: Run monitoring only (if you prefer manual control)
```powershell
.\scripts\monitor_ssd_status.ps1
```

---

## TIMELINE

```
RIGHT NOW               → Start master_orchestrator.ps1 (on Windows)
Within 5 min           → Boot SSD from BIOS
2-3 min boot time      → SSD loads GNOME desktop
                       → Monitoring detects boot
                       → Terminal alerts: !!! BOOT DETECTED !!!
5 min                  → Apply nomodeset in GRUB
3 min                  → System reboots
                       → System boots with nomodeset applied
5 min                  → Configure Phase A auto-execution
20 min                 → Phase A runs (fonts, tweaks, extensions)
                       → System configured for accessibility
                       → Timeshift snapshot created
                       → Ready for Phase B (optional)

TOTAL: ~50-60 minutes from now until Phase A complete
```

---

## FILE ORGANIZATION

**Windows side** (C:\Users\souro\Desktop\Arch_Linus\):
- scripts/master_orchestrator.ps1 ← **RUN THIS**
- scripts/monitor_ssd_status.ps1
- scripts/auto_deploy_trigger.ps1
- scripts/deploy_phase_a.ps1
- linux_scripts/01_phase_a_accessibility.sh
- linux_scripts/aeon-phase-a.service
- ... (all documentation + scripts)

**SSD side** (EndeavourOS):
- ~/aeon-build/01_phase_a_accessibility.sh (and 12 more)
- ~/aeon-build/aeon-phase-a.service
- ~/aeon-build/logs/ (for all output)

---

## SUCCESS CRITERIA

✅ Phase A succeeds when:
1. Fonts are installed (checked: `fc-list | grep -i opendyslexic`)
2. GNOME tweaks applied (cursor size 48px, text scaling 1.5x)
3. Extensions installed (Just Perfection, Pano, Caffeine, Vitals)
4. Timeshift snapshot created (checked: `sudo timeshift --list`)
5. No errors in logs (checked: `cat ~/aeon-build/logs/01_phase_a_accessibility.log`)

---

## TROUBLESHOOTING

**SSH doesn't work after boot:**
- Verify EndeavourOS is fully loaded (GNOME desktop visible)
- Check SSH is running: `sudo systemctl status ssh`
- Enable if needed: `sudo systemctl enable --now ssh`

**nomodeset not applied:**
- Verify GRUB edit: `grep nomodeset /etc/default/grub`
- Rebuild GRUB: `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- Reboot and check: `cat /proc/cmdline | grep nomodeset`

**Phase A script fails:**
- Check logs: `cat ~/aeon-build/logs/01_phase_a_accessibility.log`
- Verify dependencies: `sudo pacman -S yay base-devel`
- Re-run script: `./01_phase_a_accessibility.sh`

---

## NEXT PHASES (Optional)

After Phase A completes, you can continue with:

**Phase B** (Dashboard) - 45 min
```bash
./02_phase_b_dashboard.sh
# Creates custom GTK4 dashboard with 10 action buttons
```

**Or run all phases** (Phases A-K) - 5.5 hours total
```bash
sudo cp aeon-master-build.service /etc/systemd/user/
systemctl --user enable --now aeon-master-build.service
# Entire system builds automatically
```

---

## BOTTOM LINE

1. **Run this now**:
   ```powershell
   .\scripts\master_orchestrator.ps1
   ```

2. **Boot SSD when prompted** (5 minutes)

3. **System handles rest** (apply nomodeset + Phase A)

4. **Done**: Full accessibility-configured EndeavourOS (~50 min total)

---

**That's it. One command starts everything. Go.**

