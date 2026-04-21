# VM CONNECTION AND DEPLOYMENT GUIDE
**VM SSH is READY - Deploy scripts now**

---

## METHOD 1: SSH from Windows (Recommended)

### Install OpenSSH (if not available):
```powershell
# Enable OpenSSH client (Windows 10+):
Add-WindowsCapability -Online -Name OpenSSH.Client*
```

### Connect and Deploy:
```bash
# Connect to VM:
ssh -p 2222 sourou@127.0.0.1

# Inside VM, run deployment script:
curl -sSL https://raw.githubusercontent.com/sourovdeb/NixOS-Automated-Setup/aeon-writer-os/VM_DEPLOY_FROM_GITHUB.sh | bash
```

---

## METHOD 2: VirtualBox GUI (Alternative)

### Using VirtualBox Console:
1. **Open VirtualBox Manager**
2. **Select "EndeavourOS-Fresh"**  
3. **Click "Show"** (opens VM window)
4. **Login to GNOME desktop** 
5. **Open terminal** (Ctrl+Alt+T)
6. **Run deployment**:
   ```bash
   curl -sSL https://raw.githubusercontent.com/sourovdeb/NixOS-Automated-Setup/aeon-writer-os/VM_DEPLOY_FROM_GITHUB.sh | bash
   ```

---

## METHOD 3: Manual File Transfer

### Copy files via shared folder:
1. **VirtualBox → Settings → Shared Folders**
2. **Add:** `C:\Users\souro\Desktop\Arch_Linus\linux_scripts` 
3. **Mount in VM:**
   ```bash
   sudo mkdir /mnt/scripts
   sudo mount -t vboxsf linux_scripts /mnt/scripts
   cp -r /mnt/scripts ~/aeon-build/
   ```

---

## AFTER DEPLOYMENT - PHASE A EXECUTION

### Option 1: Apply nomodeset first (Recommended):
```bash
sudo nano /etc/default/grub
# Find: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"  
# Change to: GRUB_CMDLINE_LINUX_DEFAULT="nomodeset loglevel=3 quiet"
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot

# After reboot:
cd ~/aeon-build
./linux_scripts/01_phase_a_accessibility.sh
```

### Option 2: Direct Phase A (if no nvidia issues):
```bash
cd ~/aeon-build
./linux_scripts/01_phase_a_accessibility.sh
```

### Option 3: Auto-service execution:
```bash
cd ~/aeon-build
sudo cp linux_scripts/aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now aeon-phase-a.service

# Monitor progress:
journalctl --user -f -u aeon-phase-a.service
```

---

## CURRENT STATUS

✅ **VM SSH Ready**: Port 2222 responding  
✅ **Deployment script ready**: VM_DEPLOY_FROM_GITHUB.sh  
✅ **All Phase A-K scripts available via GitHub**  
✅ **NVIDIA conflict solutions documented**

**Choose your deployment method and start Phase A!**