# COMPLETE PHASE A EXECUTION GUIDE (HANDS-OFF)
**Status**: Ready to execute  
**Timeline**: ~32 minutes total (nomodeset + Phase A)  
**Effort**: ~5 minutes active, then hands-off

---

## QUICK START (5 Minute Setup)

### Step 1: Boot External SSD
1. From Windows, restart computer
2. Press **F12** during boot (HP boot menu)
3. Select: **UEFI: [JMicron - USB SSD]**
4. Boot into EndeavourOS GNOME desktop

### Step 2: Apply nomodeset (3 minutes)
```bash
# Open terminal (Ctrl+Alt+T)

# Edit GRUB:
sudo nano /etc/default/grub

# Find line: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
# Change to: GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"
# Save: Ctrl+O, Enter, Ctrl+X

# Rebuild and reboot:
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

### Step 3: Set Up Auto-Execution (2 minutes - After Reboot)
```bash
# After reboot, open terminal and run:

sudo cp ~/aeon-build/linux_scripts/aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-phase-a.service
systemctl --user start aeon-phase-a.service
```

### Step 4: Watch It Work
```bash
# In terminal, monitor Phase A execution:
journalctl --user -f -u aeon-phase-a.service

# You'll see:
# [*] Verifying nomodeset...
# [✓] nomodeset confirmed
# [*] Executing Phase A...
# ... (installation progress) ...
# [✓] Phase A completed successfully
```

**After completion, the system is ready for Phase B.**

---

## DETAILED WALKTHROUGH

### Phase 1: Boot and Apply nomodeset (5-10 minutes)

**Why nomodeset?**
- Disables kernel mode setting for GPU
- Prevents NVIDIA driver conflicts
- Critical for smooth Phase A execution
- Can be easily added/removed later

**Step-by-Step:**

1. **From Windows desktop:**
   ```
   Restart → Press F12 on boot → Select UEFI: [SSD] → Enter
   ```

2. **In EndeavourOS (after boot):**
   ```bash
   # Open terminal
   Ctrl+Alt+T
   
   # Edit GRUB configuration
   sudo nano /etc/default/grub
   ```

3. **In nano editor:**
   - Find line: `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"`
   - Change to: `GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"`
   - Save: `Ctrl+O` (Enter to confirm) `Ctrl+X`

4. **Rebuild GRUB and reboot:**
   ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   sudo reboot
   ```

5. **Verify (after reboot):**
   ```bash
   cat /proc/cmdline | grep nomodeset
   # Should output: ... nomodeset ...
   ```

---

### Phase 2: Set Up Auto-Execution Service (2-5 minutes)

**Why auto-execution?**
- Zero manual intervention needed
- systemd handles proper startup order
- Automatically waits for GNOME to load
- All output logged for debugging

**Step-by-Step:**

1. **After reboot with nomodeset confirmed, open terminal:**
   ```bash
   # Copy systemd service file to user config
   sudo cp ~/aeon-build/linux_scripts/aeon-phase-a.service /etc/systemd/user/
   ```

2. **Reload systemd:**
   ```bash
   systemctl --user daemon-reload
   ```

3. **Enable service (runs on every boot):**
   ```bash
   systemctl --user enable aeon-phase-a.service
   ```

4. **Start Phase A now:**
   ```bash
   systemctl --user start aeon-phase-a.service
   ```

---

### Phase 3: Monitor Execution (20 minutes - Hands-Off)

**In the terminal, watch Phase A run:**

```bash
# Real-time log view:
journalctl --user -f -u aeon-phase-a.service
```

**Expected output:**
```
[Service started...]
[*] Verifying nomodeset kernel parameter...
[✓] nomodeset confirmed in kernel parameters
[*] Waiting 5 seconds for system initialization...
[*] Making Phase A script executable...
[*] Executing Phase A: Accessibility Setup...
========================================
[*] Installing accessibility packages...
[*] Installing dyslexic-friendly fonts...
[*] Configuring GNOME settings...
[*] Installing Extension Manager...
[*] Creating Timeshift snapshot...
========================================
[✓] Phase A completed successfully
[*] Phase A success marker created
[*] Ready for Phase B execution
```

**Duration:** ~20 minutes (coffee break 😊)

---

### Phase 4: Verify Completion (2-3 minutes)

After the systemd service finishes:

```bash
# Check service status:
systemctl --user status aeon-phase-a.service
# Should show: Active: active (exited)

# View complete log:
cat ~/aeon-build/logs/phase_a_auto_execute.log

# Verify completion marker:
ls -la ~/aeon-build/logs/phase_a_complete.marker
# Should exist (marker file from successful completion)

# Verify Timeshift snapshot:
sudo timeshift --list
# Should show "post-phase-A" snapshot
```

**All verifications pass?** ✅ **Phase A Complete!**

---

## TROUBLESHOOTING

### Problem: "aeon-phase-a.service not found"
```bash
# Verify service file exists:
ls -la ~/aeon-build/linux_scripts/aeon-phase-a.service

# If missing, create it manually:
sudo nano /etc/systemd/user/aeon-phase-a.service
# Paste content from INSTALL_AUTO_EXECUTION_SERVICE.md

systemctl --user daemon-reload
```

### Problem: "nomodeset not in kernel parameters"
```bash
# Check current GRUB config:
grep CMDLINE_LINUX_DEFAULT /etc/default/grub

# If nomodeset missing:
sudo nano /etc/default/grub
# Add "nomodeset" to the parameter line
# Save and exit

# Rebuild GRUB:
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot to apply:
sudo reboot
```

### Problem: "Service won't start"
```bash
# Check for errors:
journalctl --user -xe

# Verify service file syntax:
systemd-analyze verify /etc/systemd/user/aeon-phase-a.service

# Check if script is executable:
ls -la ~/aeon-build/linux_scripts/00_auto_execute_phase_a.sh
chmod +x ~/aeon-build/linux_scripts/00_auto_execute_phase_a.sh
```

### Problem: "Phase A script fails during execution"
```bash
# View the detailed Phase A log:
cat ~/aeon-build/logs/01_phase_a_accessibility.log

# View system errors:
journalctl --user --all

# Try running script manually:
cd ~/aeon-build
./01_phase_a_accessibility.sh
```

---

## MANUAL EXECUTION ALTERNATIVE

If you prefer to run Phase A manually instead of auto-execution:

```bash
# Skip the systemd service setup above, instead:

cd ~/aeon-build
chmod +x 01_phase_a_accessibility.sh
./01_phase_a_accessibility.sh

# Watch output in real-time
# Takes ~20 minutes
```

---

## TIMELINE SUMMARY

| Step | Action | Duration |
|------|--------|----------|
| 1 | Boot SSD from BIOS | 2 min |
| 2 | Apply nomodeset to GRUB | 3 min |
| 3 | Rebuild GRUB and reboot | 3 min |
| 4 | Set up systemd service | 2 min |
| 5 | Phase A auto-execution | 20 min |
| 6 | Verify completion | 2 min |
| **TOTAL** | | **32 min** |

**Active time:** ~5-7 minutes  
**Hands-off time:** ~20 minutes  
**Verification time:** ~2 minutes

---

## WHAT PHASE A INSTALLS

✅ **Accessibility Packages**
- orca (screen reader)
- at-spi2 (accessibility framework)
- GNOME Tweaks

✅ **Dyslexia-Friendly Fonts**
- OpenDyslexic
- Atkinson Hyperlegible
- Lexend

✅ **GNOME Customizations**
- Cursor size: 48px (large)
- Text scaling: 1.5x
- Animations: disabled
- Dark theme enabled

✅ **GNOME Extensions**
- Extension Manager (installed)
- Just Perfection (custom UI)
- Pano (clipboard manager)
- Caffeine (screen lock prevention)
- Vitals (system monitor)

✅ **System Snapshot**
- Timeshift backup created at "post-phase-A"
- Can rollback to this point if needed

---

## NEXT: Phase B (Dashboard)

After Phase A completes successfully:

```bash
# Phase B installs GTK4 dashboard with 10 buttons
# Estimated time: ~45 minutes

cd ~/aeon-build
./02_phase_b_dashboard.sh
```

**Timeline to full AEON build completion:** ~5 additional hours (Phases B-K)

---

## KEY REMINDERS

✅ nomodeset MUST be in GRUB (not VM level)  
✅ Auto-execution service only runs after graphical session starts  
✅ All logs saved to ~/aeon-build/logs/  
✅ Timeshift snapshots allow safe rollback  
✅ Phases must run sequentially (A → B → C → ...)  
✅ Each phase is idempotent (safe to re-run)  

---

**You're ready to go. Follow steps 1-4 above.**

