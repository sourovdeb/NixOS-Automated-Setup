#!/usr/bin/env pwsh
# QUICK VM SETUP WITHOUT ISO
# Creates VM to use existing SSD or manual ISO load

param(
    [string]$VMName = "EndeavourOS-Fresh"
)

$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

Write-Host "======================================"
Write-Host "QUICK VM SETUP (NO ISO DOWNLOAD)"
Write-Host "======================================"
Write-Host ""

# Stop existing VMs and remove if exists
Get-Process VirtualBoxVM -ErrorAction SilentlyContinue | Stop-Process -Force
try {
    & $VBoxPath unregistervm $VMName --delete 2>$null
} catch {}

# Create VM
Write-Host "[*] Creating VM '$VMName'..."
& $VBoxPath createvm --name $VMName --ostype "ArchLinux_64" --register
& $VBoxPath modifyvm $VMName --memory 4096 --cpus 2
& $VBoxPath modifyvm $VMName --vram 128 --graphicscontroller vmsvga
& $VBoxPath modifyvm $VMName --nic1 nat --nictype1 82540EM
& $VBoxPath modifyvm $VMName --natpf1 "ssh,tcp,,2222,,22"

# Create disk
$DiskPath = "$HOME\VirtualBox VMs\$VMName\$VMName.vdi"
& $VBoxPath createhd --filename $DiskPath --size 50000

# Add storage
& $VBoxPath storagectl $VMName --name "SATA Controller" --add sata
& $VBoxPath storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $DiskPath

Write-Host "✅ VM created: $VMName"
Write-Host "   SSH Port: 2222 (host) → 22 (guest)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Attach ISO manually in VirtualBox GUI"
Write-Host "2. OR boot existing SSD in VM"
Write-Host "3. OR start VM without OS for PXE/network boot"
Write-Host ""

# Start VM
Write-Host "[*] Starting VM..."
& $VBoxPath startvm $VMName --type gui

Write-Host "✅ VM started - configure OS manually in VM window"