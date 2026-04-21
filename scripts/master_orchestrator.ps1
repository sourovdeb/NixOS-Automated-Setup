#!/usr/bin/env pwsh
# MASTER ORCHESTRATOR
# Runs monitoring + auto-deploys Phase A when SSD boots
# This is the single entry point for the entire workflow

Write-Host "======================================"
Write-Host "AEON OS - MASTER ORCHESTRATOR"
Write-Host "======================================"
Write-Host ""
Write-Host "Starting automated monitoring and deployment..."
Write-Host ""

$monitorScript = "C:\Users\souro\Desktop\Arch_Linus\scripts\monitor_ssd_status.ps1"
$deployScript = "C:\Users\souro\Desktop\Arch_Linus\scripts\auto_deploy_trigger.ps1"

if (-not (Test-Path $monitorScript)) {
    Write-Host "[✗] Monitor script not found: $monitorScript"
    exit 1
}

if (-not (Test-Path $deployScript)) {
    Write-Host "[✗] Deploy script not found: $deployScript"
    exit 1
}

Write-Host "[✓] Scripts found"
Write-Host "[*] Starting continuous monitoring..."
Write-Host ""
Write-Host "Monitoring will:"
Write-Host "  1. Check SSH Port 22 every 3 minutes"
Write-Host "  2. Alert when SSD boots"
Write-Host "  3. Automatically trigger Phase A deployment"
Write-Host ""
Write-Host "To stop monitoring, close this terminal or press Ctrl+C"
Write-Host ""
Write-Host "======================================"
Write-Host ""

# Run monitoring (this will run until boot is detected or user stops it)
& $monitorScript

Write-Host ""
Write-Host "[!] Boot detected or monitoring stopped"
Write-Host ""
Write-Host "[*] Running auto-deployment trigger..."
Write-Host ""

# Boot was detected, trigger deployment
& $deployScript -Phase "A"

Write-Host ""
Write-Host "======================================"
Write-Host "MASTER ORCHESTRATOR COMPLETE"
Write-Host "======================================"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. SSH into EndeavourOS system"
Write-Host "  2. Apply nomodeset to GRUB (if needed)"
Write-Host "  3. Reboot"
Write-Host "  4. Enable Phase A auto-execution service"
Write-Host "  5. Phase A will run automatically"
Write-Host ""
