# NEXT STEPS — Corrected Workflow
**Date**: April 21, 2026 | **Status**: Phase 0 Complete, Ready for Phase 1

---

## What Was Wrong (April 21, Morning)

I was attempting to:
1. Reconfigure VirtualBox VM with kernel parameters (`nomodset`, fallback graphics)
2. SSH into a non-booting Linux environment 
3. Modify bootloaders on an **empty VDI disk** (0.00 GB)
4. Force hardware workarounds at the VM level

**Why this was wrong:**
- ❌ The VDI disk is EMPTY — no Linux OS exists to configure
- ❌ Instructions explicitly say to boot EXTERNAL SSD directly, not use VirtualBox
- ❌ Creating unnecessary Windows-Linux driver conflicts
- ❌ Violates the principle: "avoid potential driver conflict between Windows and Linux"
- ❌ Working against the pre-build assumptions: "Your job begins after the user logs into the fresh EndeavourOS desktop"

**Result**: Complete workflow reset. VirtualBox abandoned for this project.

---

## Correct Workflow

### Current State (✅ Phase 0 Complete)
- ✅ Fast Startup disabled: `HiberbootEnabled = 0`
- ✅ Secure Boot disabled: `UEFISecureBootEnabled = 0`  
- ✅ EndeavourOS USB created: Bootable USB with Rufus
- ✅ External SSD connected: Disk 1, 465.8 GB, GPT, ready for installation
- ✅ Windows environment prepared: No conflicts with Linux
- ✅ Build scripts staged: All 13 phase scripts ready in `linux_scripts/`
- ✅ Documentation complete: BUILD_PLAN.md, ANTICIPATED_ISSUES.md, etc.

### Next: Phase 1 (EndeavourOS Installation on External SSD)

**This step happens on the ACTUAL HARDWARE, not in VirtualBox.**

#### Step 1: Prepare for Boot
```
1. Insert the bootable EndeavourOS USB (already created with Rufus)
2. Ensure external SSD is connected via USB
3. Take a final backup of Windows (optional but safe)
```

#### Step 2: Boot from USB
```
1. Restart Windows
2. Press F12 (or ESC, DEL, depending on HP BIOS) to enter boot menu
3. Select: "UEFI: [USB device name]" or similar
4. Let it boot into EndeavourOS live environment
5. You should see the GNOME desktop live environment (no login needed)
```

#### Step 3: Install EndeavourOS to External SSD
```
1. Click "Install EndeavourOS" icon on desktop
2. Calamares installer will open
3. Follow wizard:
   - Language: English
   - Location: Your timezone
   - Keyboard: Your layout
   - Disk partitioning:
     * Select: Disk 1 (external SSD, ~465 GB)
     * Scheme: EFI (systemd-boot)
     * Format: ext4 for /
   - Desktop: GNOME
   - Bootloader: systemd-boot (default)
   - Network: Yes, use WiFi if possible
   - Services: Auto-login for sourou user
   - Summary: Review and confirm
4. Click "Install" → wait ~15-20 minutes
5. Reboot when prompted
6. Remove USB during restart
```

#### Step 4: First Boot into Fresh EndeavourOS
```
1. System boots into the external SSD
2. GNOME login screen appears (or auto-login to sourou)
3. First boot may take a few minutes (finalizing setup)
4. Timeshift will offer to create a snapshot → Accept
5. You are now in the FRESH EndeavourOS environment
6. This is where the AEON Writer OS build truly begins
```

---

## Hardware Issues — Handle AFTER Linux is Installed

Do **NOT** try to force compatibility at the Windows/VM level. Instead, configure properly on the ACTUAL LINUX SYSTEM using kernel parameters and modprobe files.

### Alder Lake Suspend Freeze (Phase H)
```bash
# File: /etc/kernel/cmdline or /etc/default/grub
# Add kernel parameter: i915.enable_dc=0
```

### NVIDIA GSP Firmware Issues (Phase C)
```bash
# File: /etc/modprobe.d/nvidia.conf
options nvidia NVreg_EnableGpuFirmware=0
```

### MediaTek WiFi High Latency (Phase B)
```bash
# File: /etc/modprobe.d/wifi.conf
options mt7921e disable_aspm=1
```

### Intel i915 Screen Flickering (Phase C)
```bash
# File: /etc/kernel/cmdline or GRUB
# Add kernel parameter: i915.enable_psr=0
```

### HP UEFI Boot Path (Phase 1, after install)
```bash
# If systemd-boot doesn't appear in UEFI menu, use:
sudo efibootmgr -c -d /dev/sda -p 1 -L "EndeavourOS" -l '\EFI\systemd\systemd-bootx64.efi'
```

**All these are documented in ANTICIPATED_ISSUES.md for proper phase implementation.**

---

## After Fresh Linux Installation: Phases A-K

Once you're logged into the fresh EndeavourOS desktop:

```bash
# 1. Transfer scripts from Windows to Linux
#    (Use USB, SCP, or network share)
mkdir -p ~/aeon-build
cp -r /path/to/linux_scripts/* ~/aeon-build/

# 2. Execute Phase A (Accessibility) - 20 minutes
cd ~/aeon-build
chmod +x 01_phase_a_accessibility.sh
./01_phase_a_accessibility.sh
sudo timeshift --create --comments "post-phase-A"

# 3. Execute Phase B (Dashboard) - 45 minutes
./02_phase_b_dashboard.sh
sudo timeshift --create --comments "post-phase-B"

# ... (Phases C-K follow same pattern)

# Total: ~5.5 hours for all phases A-K
```

---

## VirtualBox: Abandoned for This Project

### Why VirtualBox didn't work:
1. ArchOS.vdi is empty (0.00 GB) — not a bootable disk image
2. Using VirtualBox prevents direct hardware access
3. HP UEFI hardcoded to Microsoft bootloader — VirtualBox doesn't help here
4. Creating unnecessary complexity and Windows-Linux conflicts

### Better approach (what we're doing now):
- Boot external SSD directly on physical hardware
- Direct hardware compatibility = no virtualization overhead
- Proper UEFI boot entry on physical machine
- All hardware can be configured natively after install

---

## File Inventory (Safe to Use)

### 🟢 Ready Now (Phase 1):
- `downloads/EndeavourOS_Titan-2026.03.06.iso` ✅ Verified hash, on bootable USB
- `downloads/gparted-live.iso` ✅ Emergency rescue tool (if needed)
- Hardware specs documented in `HARDWARE_COMPATIBILITY.md` ✅

### 🟡 Ready After Linux Installs (Phases A-K):
- `linux_scripts/01_phase_a_accessibility.sh` → Phase A
- `linux_scripts/02_phase_b_dashboard.sh` → Phase B
- ... (13 total phase scripts)
- `BUILD_PLAN.md` → Reference during execution
- `ANTICIPATED_ISSUES.md` → Debugging guide

### 🔴 Can Be Deleted (No Longer Needed):
- VirtualBox configuration files (in `virtualbox/` folder)
- ArchOS.vdi (empty, not used)
- ArchSSD.vmdk (physical disk mapping, caused conflicts)
- Any VM snapshot files

---

## Safety Checklist Before Restarting

✅ **Before you restart into EndeavourOS USB:**

- [ ] External SSD is connected via USB
- [ ] Bootable EndeavourOS USB is ready (verify in File Explorer)
- [ ] You have read ANTICIPATED_ISSUES.md
- [ ] You understand the 4 hardware workarounds (suspend, GSP, WiFi, screen)
- [ ] You know to press F12 (or your HP boot key) during startup
- [ ] You have a backup of Windows (optional but recommended)

✅ **During installation:**
- [ ] Select external SSD (Disk 1), NOT internal drive
- [ ] Choose GNOME on Xorg (not Wayland)
- [ ] Choose systemd-boot (default)
- [ ] Enable auto-login for sourou user
- [ ] Enable WiFi for downloading packages

✅ **After first Linux boot:**
- [ ] Create Timeshift snapshot immediately
- [ ] Copy linux_scripts/ to ~/aeon-build/
- [ ] Run Phase A script: `./01_phase_a_accessibility.sh`

---

## Summary

| Phase | Status | Timeline |
|-------|--------|----------|
| **Phase 0** (Windows Prep) | ✅ COMPLETE | Done |
| **Phase 1** (Linux Install) | ⏳ NEXT | ~20 min to install |
| **Phases A-K** (Configuration) | 🔧 Ready to execute | ~5h 30min total |
| **TOTAL BUILD TIME** | - | ~6 hours |

**You are now ready to boot from USB and install EndeavourOS directly to the external SSD.**

No VirtualBox. No VM emulation. Direct hardware. Proper Linux.

