#!/usr/bin/env pwsh
# CONTINUOUS 3-MINUTE REVIEW MONITORING SCRIPT
# Monitors SSD status and reports every 3 minutes until boot detected

param(
    [int]$ReviewIntervalSeconds = 180,  # 3 minutes
    [int]$MaxReviews = 0  # 0 = infinite
)

$reviewCount = 0
$bootDetected = $false

Write-Host "======================================"
Write-Host "CONTINUOUS 3-MINUTE MONITORING STARTED"
Write-Host "Interval: $ReviewIntervalSeconds seconds (3 minutes)"
Write-Host "======================================"
Write-Host ""

while ($true) {
    $reviewCount++
    
    if ($MaxReviews -gt 0 -and $reviewCount -gt $MaxReviews) {
        Write-Host ""
        Write-Host "[*] Max reviews ($MaxReviews) reached. Stopping."
        break
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    # Check 1: SSH Port 22
    $sshOpen = $false
    try {
        $socket = New-Object System.Net.Sockets.TcpClient
        $socket.ConnectAsync("127.0.0.1", 22) | Wait-Job -Timeout 1 >$null 2>&1
        if ($socket.Connected) {
            $sshOpen = $true
            $socket.Close()
        }
    } catch {
        $sshOpen = $false
    }
    
    # Check 2: Mount path exists
    $mountExists = Test-Path "C:\Users\souro\Desktop\Arch_Linus\MOUNTEDSSD" -ErrorAction SilentlyContinue
    
    # Check 3: Try to list mount contents (indicates if accessible)
    $mountAccessible = $false
    try {
        $items = @(Get-ChildItem "C:\Users\souro\Desktop\Arch_Linus\MOUNTEDSSD" -ErrorAction SilentlyContinue)
        $mountAccessible = ($items.Count -gt 0)
    } catch {
        $mountAccessible = $false
    }
    
    # Determine boot status
    if ($sshOpen) {
        $bootStatus = "✅ BOOTED"
        $bootDetected = $true
    } else {
        $bootStatus = "❌ NOT BOOTED"
    }
    
    # Display review
    Write-Host "[$timestamp] Review #$reviewCount - $bootStatus"
    Write-Host "  SSH Port 22: $(if ($sshOpen) { '✅ OPEN' } else { '❌ Closed' })"
    Write-Host "  Mount path: $(if ($mountExists) { '✅ Exists' } else { '❌ Missing' })"
    Write-Host "  Mount access: $(if ($mountAccessible) { '✅ Accessible' } else { '❌ Denied' })"
    
    # If booted, alert and stop
    if ($bootDetected) {
        Write-Host ""
        Write-Host "!!! BOOT DETECTED !!!"
        Write-Host "EndeavourOS is now running and SSH is available."
        Write-Host "Ready to deploy Phase A scripts."
        Write-Host ""
        break
    }
    
    # Schedule next review
    if ($MaxReviews -eq 0 -or $reviewCount -lt $MaxReviews) {
        $nextTime = (Get-Date).AddSeconds($ReviewIntervalSeconds)
        Write-Host "  Next review: $(Get-Date $nextTime -Format 'HH:mm:ss') (in 3 min)"
        Write-Host ""
        
        # Wait for next review
        Start-Sleep -Seconds $ReviewIntervalSeconds
    }
}

Write-Host "Monitoring completed at $(Get-Date -Format 'HH:mm:ss')"
