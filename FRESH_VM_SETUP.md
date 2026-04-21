# VIRTUALIZATION RESET & FRESH SETUP
**Complete VM setup from scratch with SSH configuration**

---

## STEP 1: STOP ALL VIRTUALIZATION

```powershell
# Stop all running VMs
Get-Process VirtualBoxVM -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process vmware* -ErrorAction SilentlyContinue | Stop-Process -Force

# Clean VirtualBox VMs (if exists)
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list runningvms
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list vms

Write-Host "✅ All VMs stopped"
```

---

## STEP 2: CHOOSE VIRTUALIZATION PLATFORM

### Option A: VirtualBox (Recommended)
```powershell
# VirtualBox is already installed at:
# C:\Program Files\Oracle\VirtualBox\

# Add to PATH for convenience
$env:PATH += ";C:\Program Files\Oracle\VirtualBox"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, "User")
```

### Option B: Hyper-V (If preferred)
```powershell
# Enable Hyper-V (requires admin + reboot)
# Run as Administrator:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Restart
```

---

## STEP 3: CREATE FRESH ENDEAVOUROS VM

### VirtualBox Method (Automated):
```powershell
# VM Configuration
$VM_NAME = "EndeavourOS-Fresh"
$VM_MEMORY = 4096  # 4GB RAM
$VM_DISK_SIZE = 50000  # 50GB
$ISO_PATH = "C:\Users\souro\Desktop\Arch_Linus\endeavouros-cassini-nova-22_12-x86_64.iso"

# Create VM
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name "$VM_NAME" --ostype "ArchLinux_64" --register
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$VM_NAME" --memory $VM_MEMORY --cpus 2
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$VM_NAME" --vram 128 --graphicscontroller vmsvga
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$VM_NAME" --nic1 nat --nictype1 82540EM
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "$VM_NAME" --natpf1 "ssh,tcp,,2222,,22"

# Create virtual disk
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi" --size $VM_DISK_SIZE

# Add storage
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl "$VM_NAME" --name "SATA Controller" --add sata
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi"
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

Write-Host "✅ VM Created: $VM_NAME"
Write-Host "   SSH Port: 2222 (host) → 22 (guest)"
Write-Host "   Memory: 4GB"
Write-Host "   Disk: 50GB"
```

---

## STEP 4: BOOT VM & INSTALL

```powershell
# Start VM
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "$VM_NAME"

Write-Host "VM starting..."
Write-Host ""
Write-Host "Next steps IN THE VM:"
Write-Host "1. Boot from ISO"
Write-Host "2. Install EndeavourOS (20 min)"
Write-Host "3. Enable SSH service"
Write-Host "4. Configure network"
Write-Host "5. Test SSH connection"
```

### EndeavourOS Installation Notes:
1. **Boot VM** → Select "Start EndeavourOS installer"
2. **Installation**:
   - Language: English
   - Keyboard: US
   - Partition: Use entire disk (50GB)
   - User: `sourou` / password of your choice
   - **IMPORTANT**: Enable "Log in automatically" OR remember password for SSH
3. **After installation**:
   ```bash
   sudo systemctl enable --now ssh
   sudo systemctl enable --now NetworkManager
   ip addr show  # Note the IP (should be 10.0.2.15)
   ```

---

## STEP 5: SSH CONFIGURATION & TEST

### In EndeavourOS VM:
```bash
# Enable SSH
sudo systemctl enable --now ssh
sudo ufw allow ssh

# Check SSH status
sudo systemctl status ssh
ip addr show

# Create SSH key for convenience (optional)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

### From Windows (test connection):
```powershell
# Test SSH (VirtualBox NAT: port 2222 → 22)
ssh -p 2222 sourou@127.0.0.1

# If successful:
Write-Host "✅ SSH connection working!"
Write-Host "VM IP (internal): 10.0.2.15"
Write-Host "SSH from Windows: ssh -p 2222 sourou@127.0.0.1"
```

---

## STEP 6: DEPLOY AEON BUILD TO VM

```powershell
# Transfer all scripts to VM
scp -P 2222 -r "C:\Users\souro\Desktop\Arch_Linus\linux_scripts" sourou@127.0.0.1:~/aeon-build

# OR create deployment script
$deployScript = @'
#!/bin/bash
mkdir -p ~/aeon-build
cd ~/aeon-build

# Clone from GitHub
git clone -b aeon-writer-os https://github.com/sourovdeb/NixOS-Automated-Setup.git .

# Make scripts executable
chmod +x linux_scripts/*.sh

echo "✅ Aeon build deployed to ~/aeon-build"
echo "Ready for Phase A execution"
'@

$deployScript | Out-File -FilePath "deploy_to_vm.sh" -Encoding UTF8
scp -P 2222 deploy_to_vm.sh sourou@127.0.0.1:~/
ssh -p 2222 sourou@127.0.0.1 "bash ~/deploy_to_vm.sh"
```

---

## STEP 7: PHASE A EXECUTION IN VM

### Automatic (Recommended):
```bash
# In VM via SSH
cd ~/aeon-build
sudo cp linux_scripts/aeon-phase-a.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now aeon-phase-a.service

# Monitor progress
journalctl --user -f -u aeon-phase-a.service
```

### Manual:
```bash
cd ~/aeon-build
./linux_scripts/01_phase_a_accessibility.sh
```

---

## STEP 8: 3-MINUTE REVIEW MONITORING

```powershell
# Monitor VM + SSD simultaneously
$monitorScript = @'
while ($true) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "========================================"
    Write-Host "3-MINUTE REVIEW - $timestamp"
    Write-Host "========================================"
    
    # Test VM SSH
    Write-Host "[*] Testing VM SSH (port 2222):"
    try {
        $vm_test = Test-NetConnection -ComputerName 127.0.0.1 -Port 2222 -WarningAction SilentlyContinue
        if ($vm_test.TcpTestSucceeded) {
            Write-Host "  ✅ VM SSH: RESPONDING"
        } else {
            Write-Host "  ❌ VM SSH: NOT RESPONDING"
        }
    } catch {
        Write-Host "  ❌ VM SSH: ERROR"
    }
    
    # Test SSD SSH  
    Write-Host "[*] Testing SSD SSH (port 22):"
    try {
        $ssd_test = Test-NetConnection -ComputerName 127.0.0.1 -Port 22 -WarningAction SilentlyContinue
        if ($ssd_test.TcpTestSucceeded) {
            Write-Host "  ✅ SSD SSH: RESPONDING"
        } else {
            Write-Host "  ❌ SSD SSH: NOT RESPONDING"
        }
    } catch {
        Write-Host "  ❌ SSD SSH: ERROR"
    }
    
    # Check SSD mount
    $ssd_mount = "C:\Users\souro\Desktop\Arch_Linus\MOUNTEDSSD"
    if (Test-Path $ssd_mount) {
        Write-Host "  ✅ SSD Mount: EXISTS"
    } else {
        Write-Host "  ❌ SSD Mount: NOT FOUND"
    }
    
    Write-Host ""
    Write-Host "Next review in 3 minutes..."
    Write-Host "========================================"
    Write-Host ""
    
    Start-Sleep -Seconds 180  # 3 minutes
}
'@

Write-Host "Starting 3-minute monitoring..."
Invoke-Expression $monitorScript
```

---

## QUICK COMMANDS

### Reset everything:
```powershell
Get-Process VirtualBoxVM -ErrorAction SilentlyContinue | Stop-Process -Force
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" unregistervm "EndeavourOS-Fresh" --delete
```

### Start fresh VM:
```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "EndeavourOS-Fresh"
```

### Connect to VM:
```powershell
ssh -p 2222 sourou@127.0.0.1
```

### Deploy to VM:
```powershell
scp -P 2222 -r linux_scripts sourou@127.0.0.1:~/aeon-build/
```

---

**Ready to start fresh VM setup and 3-minute monitoring.**
