# AEON Writer OS - Hardware Compatibility Checklist

## ✅ SUPPORTED & TESTED

### Graphics
- **Intel UHD Graphics** (Alder Lake) - PRIMARY
  - Driver: `modesetting` (built-in)
  - No additional setup needed
  - Best stability and battery life

### WiFi
- **MediaTek MT7921** 
  - Fix applied automatically in build script
  - Manual fix if needed: `echo "options mt7921e disable_aspm=1" | sudo tee /etc/modprobe.d/wifi.conf`

### Input Devices
- **ELAN Touchpad** - Works out of box
- **Wacom Intuos Pro M** - Full support via `xf86-input-wacom`
- **Standard USB/Bluetooth mice** - No setup needed

### Audio
- **Realtek HD Audio** - PulseAudio handles automatically
- **Bluetooth audio** - Works after pairing

## ⚠️ OPTIONAL (Not Required)

### NVIDIA RTX 3050
- **NOT INSTALLED BY DEFAULT** (per user request)
- System runs on Intel graphics
- To add later if needed:
  ```bash
  sudo pacman -S nvidia-dkms nvidia-utils
  # Then configure PRIME offloading
  ```

## 🔧 BOOT FIXES

### HP UEFI Issue
HP laptops hardcode boot path. After installation:
```bash
# Copy systemd-boot to fallback location
sudo cp /boot/EFI/systemd/systemd-bootx64.efi /boot/EFI/BOOT/BOOTx64.EFI
```

## 📊 MINIMUM REQUIREMENTS

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4 GB | 8 GB+ |
| Storage | 20 GB | 50 GB+ |
| CPU | 2 cores | 4+ cores |
| Graphics | Any Intel/AMD | Intel UHD |

## 🚫 KNOWN ISSUES

1. **Wayland** - Disabled, use Xorg only
2. **Secure Boot** - Must be disabled
3. **Fast Startup** - Must be disabled in Windows
4. **Hibernation** - May not work with encrypted drives

## ✅ VERIFIED WORKING SOFTWARE

### Writing
- Obsidian (Flatpak)
- LibreOffice
- Ghostwriter
- Typora alternatives

### Media
- Audacity
- Krita
- GIMP
- Inkscape

### Browsers
- Firefox (default)
- Chromium (optional)

## 🔄 POST-INSTALL VERIFICATION

Run this after installation:
```bash
# Check graphics
lspci | grep -i vga

# Check WiFi
ip link show

# Check audio
pactl list sinks

# Check Wacom
xsetwacom --list devices

# Check boot mode
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
```