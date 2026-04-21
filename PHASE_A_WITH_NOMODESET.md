# PHASE A EXECUTION - WITH NOMODESET (FINAL)
**Approach**: Direct SSD boot + SSH from Windows (OPTION C - Hybrid)  
**Timeline**: ~30 min (nomodeset) + 20 min (Phase A) = 50 min total

---

## STEP 1: Boot External SSD and Apply nomodeset (10 minutes)

### 1a. Boot from External SSD
```
1. From Windows desktop, restart computer
2. As it boots, press F12 (or ESC/DEL depending on HP model)
3. Select boot menu option
4. Choose: "UEFI: [JMicron - USB SSD]" (or similar external device)
5. Boot into EndeavourOS GNOME desktop
```

### 1b. Apply nomodeset Kernel Parameter
```bash
# Open terminal (Ctrl+Alt+T or Activities → Terminal)

# Edit GRUB configuration
sudo nano /etc/default/grub

# FIND THIS LINE:
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"

# CHANGE IT TO:
GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"

# SAVE: Press Ctrl+O (Enter to confirm) then Ctrl+X

# Rebuild GRUB with new parameter
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot to apply nomodeset
sudo reboot
```

**Why nomodeset?** Disables kernel mode setting, prevents NVIDIA conflicts in virtualized environments. This is critical for avoiding driver hangs during Phase A.

### 1c. Verify nomodeset Applied (After Reboot)
```bash
# Boot back into EndeavourOS (will happen automatically)

# Check kernel boot parameters:
cat /proc/cmdline | grep nomodeset

# Should show: ... nomodeset ...
# If yes → SUCCESS ✅
```

---

## STEP 2: Set Up SSH from Windows to SSD (5 minutes)

### 2a. Get SSD's IP Address
```bash
# On EndeavourOS (still booted from SSD), open terminal:

# Find your local IP:
ip addr show | grep "inet "

# Look for something like: 192.168.x.x or 10.x.x.x
# Note this IP address (e.g., 192.168.1.100)
```

### 2b. Verify SSH Server is Running
```bash
# On EndeavourOS, check if SSH is active:
sudo systemctl status ssh

# If not running, start it:
sudo systemctl start ssh
sudo systemctl enable ssh  # Auto-start on reboot
```

### 2c. Connect from Windows
```powershell
# On Windows (PowerShell or Terminal):

# SSH into the SSD:
ssh sourou@192.168.1.100
# (Replace 192.168.1.100 with the IP you found above)

# First time, it will ask:
# "Are you sure you want to continue connecting? (yes/no)"
# Type: yes

# Password: (enter sourou user password)

# You should now be in EndeavourOS terminal via SSH
```

---

## STEP 3: Copy Phase Scripts to SSD (5 minutes)

### 3a. From Windows, Copy linux_scripts Folder
```powershell
# From Windows PowerShell:

# SCP (Secure Copy) to transfer scripts:
scp -r "C:\Users\souro\Desktop\Arch_Linus\linux_scripts\*" sourou@192.168.1.100:~/aeon-build/

# If SCP doesn't work, use SFTP:
# 1. Download WinSCP (Windows SFTP client)
# 2. Connect: Host=192.168.1.100, User=sourou, SSH protocol
# 3. Drag linux_scripts folder to ~/aeon-build/
```

### 3b. Or: Manually Create Working Directory
```bash
# On EndeavourOS (via SSH terminal):

# Create build directory:
mkdir -p ~/aeon-build/logs

# List to verify:
ls -la ~/

# You should see: aeon-build directory
```

---

## STEP 4: Execute Phase A (20 minutes)

### OPTION A: Auto-Execute (Recommended - Hands-Off)

This option runs Phase A automatically after boot without user interaction.

```bash
# After reboot with nomodeset applied, while in EndeavourOS:

# Install auto-execution service (one-time setup):
sudo cp ~/aeon-build/linux_scripts/aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable aeon-phase-a.service

# Phase A will run automatically on next reboot
# Monitor progress:
journalctl --user -f -u aeon-phase-a.service
```

**Why auto-execution?**
- ✅ Hands-free: Set up once, Phase A runs automatically
- ✅ Reliable: systemd service ensures proper startup order
- ✅ Logged: All output saved to `~/aeon-build/logs/phase_a_auto_execute.log`
- ✅ Recoverable: Completion marker created for verification

See: **INSTALL_AUTO_EXECUTION_SERVICE.md** for full details

---

### OPTION B: Manual Execution (Interactive)

```bash
# Via SSH or local terminal on EndeavourOS:

# Navigate to build directory:
cd ~/aeon-build

# Make script executable:
chmod +x 01_phase_a_accessibility.sh

# Run Phase A script:
./01_phase_a_accessibility.sh

# What it does (~15-20 minutes):
# ✅ Installs accessibility packages (screen reader, fonts)
# ✅ Installs dyslexic-friendly fonts
# ✅ Configures GNOME settings (large cursor, text scaling)
# ✅ Installs Extension Manager
# ✅ Creates Timeshift snapshot "post-phase-A"

# Watch the output for progress
```

**Why manual execution?**
- ✅ Full control: Run exactly when you want
- ✅ Visible output: See each step in real-time
- ✅ Pauseable: Stop and resume as needed
- ✅ Debuggable: Easier to troubleshoot if issues arise

### 4c. Verify Phase A Success

**If using auto-execution:**
```bash
# Check service status:
systemctl --user status aeon-phase-a.service

# View logs:
cat ~/aeon-build/logs/phase_a_auto_execute.log

# Verify completion marker:
ls -la ~/aeon-build/logs/phase_a_complete.marker
```

**If using manual execution:**
```bash
# Check Phase A logs:
cat ~/aeon-build/logs/01_phase_a_accessibility.log

# Verify Timeshift snapshot:
sudo timeshift --list | grep "post-phase-A"

# Both should show success
```

---

## STEP 5: Install GNOME Extensions Manually (5 minutes)

Phase A script installs Extension Manager, but extensions must be installed manually:

```bash
# On SSD desktop (switch to GUI if in SSH terminal):
# 1. Click Activities → Extension Manager
# 2. Search and install:
#    - Just Perfection (3843)
#    - Pano (5278)
#    - Caffeine (517)
#    - Vitals (518)
# 3. Enable each after installation (toggle switch)
```

---

## PHASE A COMPLETE ✅

Once Phase A succeeds:
- ✅ Fonts installed
- ✅ GNOME tweaked for accessibility
- ✅ Extensions installed
- ✅ Timeshift snapshot created
- ✅ Ready for Phase B

---

## NEXT: Phase B (Dashboard)

```bash
# Via SSH (same terminal):

# Run Phase B script:
cd ~/aeon-build
./02_phase_b_dashboard.sh

# This creates a custom GTK4 dashboard with 10 action buttons
# Duration: ~45 minutes
```

---

## TROUBLESHOOTING

**SSH won't connect:**
- Verify IP: `ip addr show` on SSD
- Verify SSH is running: `sudo systemctl status ssh`
- Check Windows firewall isn't blocking port 22
- Try: `ssh -v sourou@[ip]` for verbose error messages

**Phase A script fails:**
- Check logs: `cat ~/aeon-build/logs/01_phase_a_accessibility.log`
- If `yay` not found: Use `pacman` instead for AUR packages
- If fonts don't appear: Run `fc-cache -fv`
- If Timeshift fails: Run `sudo timeshift --check` first

**nomodeset didn't apply:**
- Verify: `cat /proc/cmdline | grep nomodeset`
- If missing, redo steps 1b-1c
- Rebuild GRUB again: `sudo grub-mkconfig -o /boot/grub/grub.cfg`

---

## TIMELINE SUMMARY

| Step | Task | Duration |
|------|------|----------|
| 1 | Boot SSD + apply nomodeset | 10 min |
| 2 | Set up SSH | 5 min |
| 3 | Copy scripts | 5 min |
| 4 | Run Phase A | 20 min |
| 5 | Install GNOME extensions | 5 min |
| **Phase A Total** | | **45 min** |

**After Phase A**: ~5 hours remaining (Phases B-K)

---

## KEY REMINDERS

✅ **nomodeset MUST be in GRUB** (not VM level)  
✅ **SSH allows remote access** from Windows while keeping SSD as primary  
✅ **Phase scripts are CLI-based** (no GUI needed via SSH)  
✅ **Timeshift snapshots** after each phase (automatic rollback points)  
✅ **Follow phases in order** (A → B → C → ... → K)  

---

**Ready to proceed?** Follow steps 1-5 above. Once Phase A completes, Phase B is next.

