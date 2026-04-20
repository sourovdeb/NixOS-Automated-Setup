# AEON Writer OS - Execution Guide

## Current Status
✅ VM "arch" is running headless on localhost:2222
✅ All build scripts created and ready
✅ Hardware compatibility documented

## Option 1: Test in VM First (RECOMMENDED)
```powershell
# 1. VM is already running (we just started it)

# 2. Connect via SSH from Windows Terminal or PowerShell:
ssh user@localhost -p 2222
# Password: (enter your password)

# 3. Copy the build script to VM:
scp -P 2222 AEON_BUILD_SCRIPT.sh user@localhost:~/

# 4. Inside VM, run the build:
chmod +x ~/AEON_BUILD_SCRIPT.sh
sudo ~/AEON_BUILD_SCRIPT.sh

# 5. Monitor progress - takes ~30-45 minutes
```

## Option 2: Install on External SSD
```bash
# 1. Boot from EndeavourOS USB (created earlier)
# 2. Connect to WiFi
# 3. Install base EndeavourOS to external SSD
# 4. After first boot, copy and run:
curl -O https://raw.githubusercontent.com/[your-repo]/AEON_BUILD_SCRIPT.sh
chmod +x AEON_BUILD_SCRIPT.sh
sudo ./AEON_BUILD_SCRIPT.sh
```

## What the Script Does (6 Phases)

### Phase 0: Hardware Detection ✅
- Detects Intel GPU (uses as primary)
- Fixes MediaTek WiFi latency
- Skips NVIDIA (as requested)

### Phase 1: Accessibility ✅
- Installs GNOME on Xorg (NOT Wayland)
- OpenDyslexic fonts
- Large cursor
- Screen reader

### Phase 2: Writing Tools ✅
- Obsidian (Flatpak)
- LibreOffice, Ghostwriter
- Creates ~/Writing structure
- Git auto-commit every 5 min

### Phase 3: Wacom Support ✅
- Full tablet drivers
- Krita, GIMP, Inkscape
- Xournal++ for handwriting

### Phase 4: Podcast Tools ✅
- Audacity
- Whisper transcription (CPU version)
- FFmpeg processing

### Phase 5: Publishing ✅
- Hugo static site generator
- Python automation scripts
- Markdown → multi-platform

### Phase 6: Optimization ✅
- SSD trim
- Reduced swappiness
- Performance monitoring

## What's NOT Included (per your request)
❌ NVIDIA drivers (can add later)
❌ Ollama/AI (last priority, can add later)
❌ Docker (not needed yet)
❌ Heavy downloads

## Resource Usage
- **Disk**: ~15 GB total
- **RAM**: 4 GB minimum, 8 GB recommended
- **Network**: ~2 GB download during install
- **Time**: 30-45 minutes

## Testing Checklist After Build
```bash
# In the VM or real system:

# 1. Check graphics (should show Intel)
lspci | grep VGA

# 2. Test writing environment
flatpak run md.obsidian.Obsidian

# 3. Check Git auto-save
cd ~/Writing && git log --oneline

# 4. Test accessibility
gsettings get org.gnome.desktop.interface cursor-size
# Should return 48

# 5. Audio test
speaker-test -c 2
```

## Troubleshooting

### SSH Connection Refused
```powershell
# Restart VM networking
VBoxManage controlvm arch reset
```

### VM Too Slow
```powershell
# Increase RAM/CPU
VBoxManage modifyvm arch --memory 12288 --cpus 6
```

### Build Script Fails
- Check internet connection
- Run phases individually
- Check /var/log/aeon-build.log

## Stop VM When Done
```powershell
VBoxManage controlvm arch poweroff
```

## Next Steps
1. Test everything in VM first
2. Take snapshots at each phase
3. Document any issues
4. When ready, deploy to real SSD

---
**Token-Efficient Summary**: 
- VM running on localhost:2222
- Run AEON_BUILD_SCRIPT.sh inside VM
- Hardware-first, AI-last approach
- Intel graphics only
- Total time: 30-45 minutes