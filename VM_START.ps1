# AEON Writer OS - VM Launcher Script
# Starts VirtualBox VM with optimal settings

$VBM = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VM_NAME = "arch"  # Using the simpler VM name

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  AEON Writer OS - VM Launcher   " -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Check VM exists
$vms = & $VBM list vms
if ($vms -notmatch $VM_NAME) {
    Write-Host "ERROR: VM '$VM_NAME' not found" -ForegroundColor Red
    Write-Host "Available VMs:" -ForegroundColor Yellow
    $vms
    exit 1
}

# Configure VM for optimal performance
Write-Host "`nConfiguring VM..." -ForegroundColor Yellow

& $VBM modifyvm "$VM_NAME" `
    --memory 8192 `
    --cpus 4 `
    --vram 128 `
    --graphicscontroller vmsvga `
    --audio none `
    --usb off `
    --accelerate3d off

# Ensure NAT networking with SSH
& $VBM modifyvm "$VM_NAME" --nic1 nat
& $VBM modifyvm "$VM_NAME" --natpf1 delete ssh 2>$null
& $VBM modifyvm "$VM_NAME" --natpf1 "ssh,tcp,,2222,,22"

Write-Host "VM configured successfully" -ForegroundColor Green

# Start VM
Write-Host "`nStarting VM in headless mode..." -ForegroundColor Yellow
& $VBM startvm "$VM_NAME" --type headless

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ VM Started Successfully!" -ForegroundColor Green
    Write-Host "`nConnection info:" -ForegroundColor Cyan
    Write-Host "  SSH: ssh user@localhost -p 2222" -ForegroundColor White
    Write-Host "  Default password: password" -ForegroundColor White
    Write-Host "`nTo stop VM: VBoxManage controlvm '$VM_NAME' poweroff" -ForegroundColor Gray
} else {
    Write-Host "Failed to start VM" -ForegroundColor Red
}