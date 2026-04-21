# IMMEDIATE ACTION CARD
**Date**: April 21, 2026  
**Status**: Monitoring running - waiting for SSD boot  
**Next**: Boot external SSD from BIOS

---

## RIGHT NOW - BOOT THE SSD ✅

### Quick Steps:
1. **Restart computer** (click Start → Power → Restart)
2. **Press F12** during boot (HP boot menu)
3. **Select**: UEFI: [JMicron USB SSD]
4. **Wait** for EndeavourOS to load (2-3 min)

### What Happens:
- ✅ SSD will boot
- ✅ Desktop appears (GNOME)
- ✅ Monitoring script detects SSH opens
- ✅ Terminal will show: `!!! BOOT DETECTED !!!`

---

## AFTER BOOT - APPLY NOMODESET (5 minutes)

Open terminal in EndeavourOS and run:

```bash
# Edit GRUB config
sudo nano /etc/default/grub

# Find: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
# Change to: GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"

# Save: Ctrl+O, Enter, Ctrl+X

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot
sudo reboot
```

---

## AFTER REBOOT - PHASE A RUNS (20 minutes)

After system reboots with nomodeset applied, choose ONE option:

### Option 1: Auto-Execute (RECOMMENDED - Most Hands-Off)
```bash
sudo cp ~/aeon-build/linux_scripts/aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-phase-a.service
systemctl --user start aeon-phase-a.service

# Watch:
journalctl --user -f -u aeon-phase-a.service
```
**Duration**: ~20 minutes (fully automated)

### Option 2: Manual Run
```bash
cd ~/aeon-build
./01_phase_a_accessibility.sh
```
**Duration**: ~20 minutes (visible output)

### Option 3: Full Build (All Phases A-K)
```bash
sudo cp ~/aeon-build/linux_scripts/aeon-master-build.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-master-build.service
systemctl --user start aeon-master-build.service
```
**Duration**: ~5.5 hours (entire system built)

---

## TIMELINE

```
RIGHT NOW          → Boot SSD from BIOS
Within 5 min       → SSD boots, monitoring detects it
Then (5 min)       → Apply nomodeset to GRUB
Then (reboot 3min) → System reboots with nomodeset
Then (20 min)      → Phase A executes (fonts, GNOME tweaks)
Then (45 min)      → Phase B (dashboard) if you want to continue
Then (4+ hours)    → Phases C-K (full system build)
```

---

## KEY REMINDERS

✅ **nomodeset is CRITICAL** - prevents NVIDIA driver conflicts  
✅ **Apply nomodeset in GRUB** - not at VM level  
✅ **Boot directly** - no VirtualBox (too many conflicts)  
✅ **SSH will work** - can access from Windows if needed  
✅ **All scripts are ready** - nothing else needed from Windows side  

---

## MONITORING STATUS

**Active Terminal**: fd785b51-abbe-46a9-af3c-f5adb7756bf9  
**Last Check**: Review #1 at 09:25:51 (NOT BOOTED)  
**Next Check**: 09:28:51 (3-minute interval)  
**Will Alert**: When SSH opens (boot detected)  

---

**ACTION**: Boot the SSD now. Monitoring runs in background. You'll see alert when ready for Phase A.

