# AEON Writer OS — Anticipated Issues & Notes
> Compiled from Arch Wiki research + live hardware verification

---

## 🔴 CRITICAL — Must Fix Before Install

### 1. ~~Fast Startup is ENABLED~~ → RESOLVED
- **Status:** `HiberbootEnabled = 0` (confirmed 2026-04-20)
- **Fix applied:** Elevated batch script → `reg add ... /v HiberbootEnabled /d 0 /f`
- ~~Risk: Corrupts shared NTFS partitions, prevents Linux from mounting Windows drives~~

### 2. Secure Boot → RESOLVED
- **Status:** `UEFISecureBootEnabled = 0` (confirmed)
- **Result:** Unsigned EndeavourOS bootloaders can boot normally

### 3. External SSD Connected → READY
- **Status:** `Disk 1 = JMicron Tech, 465.8 GB, GPT, Online`
- **Windows view:** 0.5 GB System + 465.3 GB Unknown partition
- **Meaning:** Normal for a non-Windows or unassigned target disk. The EndeavourOS installer can still use it safely as the install destination.
- **Internal SSD:** 203.9 GB free on C: — preserved for Windows

### 4. HP UEFI Boot Path Hardcoded
- **Risk:** HP firmware hard-codes boot path to `\EFI\Microsoft\Boot\bootmgfw.efi`
- **Impact:** systemd-boot may not appear in UEFI boot menu after install
- **Fix Options:**
  1. Use HP UEFI "Customized Boot" path setting (if available in BIOS)
  2. Copy systemd-boot EFI to `\EFI\BOOT\BOOTx64.EFI` on the external SSD
  3. Use `efibootmgr` to create a proper UEFI boot entry
- **Test:** During Phase 2, verify boot entry persists after reboot

---

## 🟡 WARNING — Known Issues to Monitor

### 5. Alder Lake-P Freeze After Suspend
- **Issue:** Freeze after wake from suspend (freedesktop bugs #5531, #6401)
- **Cause:** Duplicate eDP entries in Video BIOS Table (VBT) from HP
- **Symptoms:** Screen stays black or system hangs after resume
- **Workaround:** Modified VBT loaded via initramfs, or kernel parameter `i915.enable_dc=0`
- **Monitor during:** Phase 5 (power management setup)

### 6. NVIDIA GSP Firmware Issues on Ampere Laptops
- **Issue:** RTX 3050 (GA107/Ampere) may have GSP firmware bugs causing hangs
- **Symptoms:** Random GPU hangs, failed suspend/resume
- **Workaround:** `NVreg_EnableGpuFirmware=0` in modprobe.d
- **Monitor during:** Phase 3 (NVIDIA driver setup)

### 7. MediaTek MT7921 High Latency
- **Issue:** Known ASPM-related high latency problem with mt7921/mt7922 chipsets
- **Fix:** `/etc/modprobe.d/wifi.conf` → `options mt7921e disable_aspm=1`
- **Install note:** Need `linux-firmware-mediatek` package
- **Monitor during:** Phase 2 (first boot, need WiFi for packages)

### 8. Screen Flickering (Intel PSR)
- **Issue:** Panel Self Refresh can cause flickering on some Alder Lake laptops
- **Fix:** Kernel parameter `i915.enable_psr=0`
- **Monitor during:** Phase 3 (display configuration)

### 9. NVIDIA Optimus Hybrid Graphics Complexity
- **Issue:** Intel UHD + RTX 3050 requires careful Optimus configuration
- **Recommended method:** PRIME render offload (official NVIDIA method)
- **Key packages:** `nvidia-open` or `nvidia-580xx-dkms`, `nvidia-utils`, `nvidia-prime`
- **GNOME on Xorg note:** Need `xrandr --setprovideroutputsource` with GDM autostart
- **DRM KMS:** Enabled by default since nvidia-utils 560.35 — should work OOTB
- **Monitor during:** Phase 3

---

## 🟢 CONFIRMED WORKING — No Issues Expected

### 10. Intel UHD Graphics Driver
- modesetting driver is default and correct for Alder Lake (Gen 12)
- GuC/HuC firmware submission enabled by default (`enable_guc=3`)
- DO NOT install `xf86-video-intel` (broken for Gen 11+)

### 11. Wacom BT IntuosPro M
- Already paired via Bluetooth on Windows
- Linux: `xf86-input-wacom` + `libwacom` packages available
- EndeavourOS with GNOME should detect via Bluetooth
- Re-pair needed on Linux (separate BT stack)

### 12. ELAN Touchpad
- Supported via `libinput` (included in GNOME/Xorg by default)
- No special drivers needed

### 13. Realtek Ethernet
- Kernel driver `r8169` handles most Realtek GbE adapters
- Should work out of the box

### 14. Audio (Realtek HD)
- PipeWire is planned (EndeavourOS default)
- `sof-firmware` may be needed for Intel SST (digital mic)

---

## � Files Over 500 MB — Efficiency Evaluation

| File | Size | Indispensable? | Verdict |
|------|------|---------------|---------|
| `EndeavourOS_Titan-2026.03.06.iso` | 3,528 MB | **YES** — this IS the OS. Cannot install without it. SHA512 verified. | **KEEP** — delete after the first successful USB boot |
| `gparted-live-1.8.1-3-amd64.iso` | 619 MB | **CONDITIONAL** — only needed if partition rescue required. EndeavourOS installer has its own partitioner (calamares). | **KEEP for safety** — delete after Phase 2 succeeds. If disk space tight, skip it (Calamares handles standard partitioning) |

**Recommendation:** After the Rufus boot USB is confirmed working, the original ISO files in `downloads/` can be deleted to reclaim ~4.1 GB.

---

## �📋 Phase 0 Checklist Summary

| # | Task | Can Do From Windows? | Status |
|---|------|---------------------|--------|
| 1 | Disable Fast Startup | ✅ Yes (PowerShell) | ✅ DONE |
| 2 | Install Rufus | ✅ Yes (winget) | ✅ DONE (v4.13) |
| 3 | Download EndeavourOS ISO | ✅ Yes (BITS) | ✅ DONE (SHA512 verified) |
| 4 | Download Ventoy | ✅ Yes (BITS) | ✅ DONE (extracted) |
| 5 | Download GParted Live ISO | ✅ Yes (BITS) | ✅ DONE (619 MB) |
| 6 | Create bootable USB | ✅ Yes (Rufus) | ✅ DONE |
| 7 | Disable Secure Boot | ✅ Verified from Windows | ✅ DONE |
| 8 | Check UEFI boot mode | ✅ Verified from Windows | ✅ DONE |
| 9 | External SSD connected | ✅ Yes | ✅ DONE |
| 10 | VS Code extensions | ✅ Yes (code CLI) | ✅ DONE (20 ext) |
| 11 | System dependency audit | ✅ Yes (winget/CLI) | ✅ DONE |
