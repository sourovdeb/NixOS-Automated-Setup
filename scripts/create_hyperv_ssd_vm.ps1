#!/usr/bin/env pwsh
# HYPER-V SSD PASSTHROUGH SETUP
# Creates Hyper-V VM that boots directly from external SSD

param(
    [string]$VMName = "EndeavourOS-SSD-Direct",
    [int]$DiskNumber = 1,  # JMicron external SSD
    [int]$Memory = 4096    # 4GB RAM
)

Write-Host "======================================"
Write-Host "HYPER-V SSD PASSTHROUGH SETUP"
Write-Host "======================================"
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ ERROR: This script must be run as Administrator"
    Write-Host "   Right-click PowerShell → 'Run as Administrator'"
    exit 1
}

# Step 1: Check SSD status
Write-Host "[1] Checking external SSD (Disk $DiskNumber)..."
$ssdDisk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue
if (-not $ssdDisk) {
    Write-Host "❌ ERROR: Disk $DiskNumber not found"
    Write-Host "Available disks:"
    Get-Disk | Format-Table Number, FriendlyName, Size
    exit 1
}

Write-Host "   ✅ Found: $($ssdDisk.FriendlyName)"
Write-Host "   ✅ Size: $([math]::Round($ssdDisk.Size / 1GB, 1)) GB"
Write-Host "   ✅ Status: $($ssdDisk.OperationalStatus)"

# Step 2: Check Hyper-V availability
Write-Host "[2] Checking Hyper-V status..."
$hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hyperVFeature.State -ne "Enabled") {
    Write-Host "❌ Hyper-V not enabled. Enabling now..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All
    Write-Host "⚠️  REBOOT REQUIRED after Hyper-V installation"
    Write-Host "   After reboot, run this script again"
    exit 0
} else {
    Write-Host "   ✅ Hyper-V is enabled"
}

# Step 3: Stop VM if exists
Write-Host "[3] Checking existing VM..."
$existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if ($existingVM) {
    Write-Host "   Stopping existing VM: $VMName"
    Stop-VM -Name $VMName -Force -TurnOff -ErrorAction SilentlyContinue
    Remove-VM -Name $VMName -Force
    Write-Host "   ✅ Removed existing VM"
}

# Step 4: Create VM with SSD passthrough
Write-Host "[4] Creating Hyper-V VM with SSD passthrough..."

# Create VM
New-VM -Name $VMName -Generation 2 -MemoryStartupBytes ($Memory * 1MB) -SwitchName "Default Switch"
Write-Host "   ✅ VM created: $VMName"

# Configure VM settings
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 1GB -MaximumBytes 8GB
Set-VMProcessor -VMName $VMName -Count 2
Write-Host "   ✅ VM configured (Dynamic RAM: 1-8GB, 2 CPUs)"

# Disable Secure Boot (required for Linux)
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
Write-Host "   ✅ Secure Boot disabled"

# Step 5: Add physical disk passthrough
Write-Host "[5] Setting up SSD passthrough..."

# Take disk offline (required for passthrough)
Set-Disk -Number $DiskNumber -IsOffline $true
Write-Host "   ⚠️  Disk $DiskNumber taken offline for VM use"

# Add physical disk to VM
Add-VMHardDiskDrive -VMName $VMName -DiskNumber $DiskNumber
Write-Host "   ✅ Physical SSD attached to VM"

# Set boot order (SSD first)
$bootOrder = Get-VMFirmware -VMName $VMName
$ssdDrive = $bootOrder.BootOrder | Where-Object { $_.Device -like "*Hard*" }
Set-VMFirmware -VMName $VMName -FirstBootDevice $ssdDrive
Write-Host "   ✅ Boot order set to SSD first"

# Step 6: Start VM
Write-Host "[6] Starting VM..."
Start-VM -Name $VMName
Write-Host "   ✅ VM started: $VMName"

Write-Host ""
Write-Host "======================================"
Write-Host "HYPER-V SETUP COMPLETE"
Write-Host "======================================"
Write-Host ""
Write-Host "VM Details:"
Write-Host "  Name: $VMName"
Write-Host "  Memory: Dynamic 1-8GB"
Write-Host "  CPUs: 2"
Write-Host "  Boot Device: Physical SSD (Disk $DiskNumber)"
Write-Host "  Network: Default Switch (NAT)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. VM should boot directly into EndeavourOS from SSD"
Write-Host "2. Check VM console: vmconnect localhost '$VMName'"
Write-Host "3. Get VM IP: Get-VMNetworkAdapter -VMName '$VMName'"
Write-Host "4. SSH to VM: ssh sourou@<VM_IP>"
Write-Host ""
Write-Host "To return SSD to Windows:"
Write-Host "  Stop-VM -Name '$VMName' -Force"
Write-Host "  Set-Disk -Number $DiskNumber -IsOffline `$false"
Write-Host ""

# Show VM status
Get-VM -Name $VMName | Format-Table Name, State, CPUUsage, MemoryAssigned, Uptime