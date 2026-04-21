#!/usr/bin/env pwsh
# FRESH VM SETUP SCRIPT
# Automatically creates and configures EndeavourOS VM with SSH

param(
    [string]$VMName = "EndeavourOS-Fresh",
    [int]$Memory = 4096,
    [int]$DiskSize = 50000,
    [string]$ISOPath = "C:\Users\souro\Desktop\Arch_Linus\endeavouros-cassini-nova-22_12-x86_64.iso"
)

$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

Write-Host "======================================"
Write-Host "FRESH VM SETUP AUTOMATION"
Write-Host "======================================"
Write-Host ""

# Step 1: Stop all existing VMs
Write-Host "[1] Stopping existing VMs..."
Get-Process VirtualBoxVM -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  Stopping VM process $($_.Id)..."
    Stop-Process -Id $_.Id -Force
}

# Remove existing VM if it exists
Write-Host "[2] Removing existing VM '$VMName' (if exists)..."
try {
    & $VBoxPath unregistervm $VMName --delete 2>$null
    Write-Host "  ✅ Existing VM removed"
} catch {
    Write-Host "  ℹ️ No existing VM to remove"
}

# Step 3: Check ISO
Write-Host "[3] Checking ISO file..."
if (-not (Test-Path $ISOPath)) {
    Write-Host "  ❌ ISO not found: $ISOPath"
    Write-Host "  Please download EndeavourOS ISO to that location"
    exit 1
}
Write-Host "  ✅ ISO found: $ISOPath"

# Step 4: Create VM
Write-Host "[4] Creating VM '$VMName'..."
& $VBoxPath createvm --name $VMName --ostype "ArchLinux_64" --register
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Failed to create VM"
    exit 1
}
Write-Host "  ✅ VM created"

# Step 5: Configure VM
Write-Host "[5] Configuring VM settings..."
& $VBoxPath modifyvm $VMName --memory $Memory --cpus 2
& $VBoxPath modifyvm $VMName --vram 128 --graphicscontroller vmsvga
& $VBoxPath modifyvm $VMName --nic1 nat --nictype1 82540EM
& $VBoxPath modifyvm $VMName --natpf1 "ssh,tcp,,2222,,22"
& $VBoxPath modifyvm $VMName --natpf1 "http,tcp,,8080,,80"
Write-Host "  ✅ VM configured (4GB RAM, SSH port 2222)"

# Step 6: Create disk
Write-Host "[6] Creating virtual disk (${DiskSize}MB)..."
$DiskPath = "$HOME\VirtualBox VMs\$VMName\$VMName.vdi"
& $VBoxPath createhd --filename $DiskPath --size $DiskSize
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Failed to create disk"
    exit 1
}
Write-Host "  ✅ Virtual disk created: $DiskPath"

# Step 7: Add storage controller and attach disk/ISO
Write-Host "[7] Configuring storage..."
& $VBoxPath storagectl $VMName --name "SATA Controller" --add sata
& $VBoxPath storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $DiskPath
& $VBoxPath storageattach $VMName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $ISOPath
Write-Host "  ✅ Storage configured"

# Step 8: Start VM
Write-Host "[8] Starting VM..."
& $VBoxPath startvm $VMName --type gui
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Failed to start VM"
    exit 1
}
Write-Host "  ✅ VM started"

Write-Host ""
Write-Host "======================================"
Write-Host "VM SETUP COMPLETE"
Write-Host "======================================"
Write-Host ""
Write-Host "VM Name: $VMName"
Write-Host "Memory: ${Memory}MB"
Write-Host "Disk: ${DiskSize}MB"
Write-Host "SSH Port: 2222 (Windows) → 22 (VM)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Install EndeavourOS in the VM window"
Write-Host "2. Enable SSH service in VM: sudo systemctl enable --now ssh"
Write-Host "3. Test connection: ssh -p 2222 sourou@127.0.0.1"
Write-Host ""
Write-Host "Starting SSH monitoring..."
Write-Host ""

# Step 9: Start SSH monitoring
$timeout = 300  # 5 minutes for installation
$elapsed = 0
$interval = 10  # Check every 10 seconds during installation

Write-Host "Waiting for SSH service (checking every 10 seconds)..."
while ($elapsed -lt $timeout) {
    try {
        $test = Test-NetConnection -ComputerName 127.0.0.1 -Port 2222 -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Host ""
            Write-Host "🎉 SSH CONNECTION AVAILABLE!"
            Write-Host ""
            Write-Host "Connect with: ssh -p 2222 sourou@127.0.0.1"
            Write-Host ""
            break
        } else {
            Write-Host "  ⏳ SSH not ready yet... ($elapsed/$timeout seconds)"
        }
    } catch {
        Write-Host "  ⏳ SSH not ready yet... ($elapsed/$timeout seconds)"
    }
    
    Start-Sleep -Seconds $interval
    $elapsed += $interval
}

if ($elapsed -ge $timeout) {
    Write-Host ""
    Write-Host "ℹ️ SSH monitoring timeout. Installation may still be in progress."
    Write-Host "   Continue with manual installation, then test SSH manually."
}

Write-Host ""
Write-Host "======================================"
Write-Host "READY FOR 3-MINUTE REVIEWS"
Write-Host "======================================"