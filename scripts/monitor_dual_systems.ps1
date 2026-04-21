#!/usr/bin/env pwsh
# 3-MINUTE REVIEW MONITORING
# Monitors both VM SSH (port 2222) and SSD SSH (port 22)
# Reviews every 3 minutes as requested

Write-Host "======================================"
Write-Host "3-MINUTE REVIEW MONITORING STARTED"
Write-Host "VM SSH Port: 2222"
Write-Host "SSD SSH Port: 22"
Write-Host "Interval: 180 seconds (3 minutes)"
Write-Host "======================================"
Write-Host ""

$reviewCount = 1
$startTime = Get-Date

while ($true) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1)
    
    Write-Host "[$timestamp] Review #$reviewCount (elapsed: ${elapsed} min)"
    Write-Host ""
    
    # Test VM SSH (port 2222)
    Write-Host "[*] Testing VM SSH (port 2222):"
    try {
        $vmSocket = New-Object System.Net.Sockets.TcpClient
        $vmAsync = $vmSocket.BeginConnect("127.0.0.1", 2222, $null, $null)
        $vmWait = $vmAsync.AsyncWaitHandle.WaitOne(2000)
        if ($vmWait -and $vmSocket.Connected) {
            Write-Host "  ✅ VM SSH: RESPONDING"
            $vmStatus = "✅ READY"
            $vmSocket.Close()
        } else {
            Write-Host "  ❌ VM SSH: Closed"
            $vmStatus = "❌ NOT READY"
        }
    } catch {
        Write-Host "  ❌ VM SSH: Error"
        $vmStatus = "❌ ERROR"
    }
    
    # Test SSD SSH (port 22)
    Write-Host "[*] Testing SSD SSH (port 22):"
    try {
        $ssdSocket = New-Object System.Net.Sockets.TcpClient
        $ssdAsync = $ssdSocket.BeginConnect("127.0.0.1", 22, $null, $null)
        $ssdWait = $ssdAsync.AsyncWaitHandle.WaitOne(2000)
        if ($ssdWait -and $ssdSocket.Connected) {
            Write-Host "  ✅ SSD SSH: RESPONDING"
            $ssdStatus = "✅ BOOTED"
            $ssdSocket.Close()
        } else {
            Write-Host "  ❌ SSD SSH: Closed"
            $ssdStatus = "❌ NOT BOOTED"
        }
    } catch {
        Write-Host "  ❌ SSD SSH: Error"
        $ssdStatus = "❌ ERROR"
    }
    
    # Check SSD mount status
    Write-Host "[*] Checking SSD mount:"
    $ssdMount = "C:\Users\souro\Desktop\Arch_Linus\MOUNTEDSSD"
    if (Test-Path $ssdMount) {
        Write-Host "  ✅ Mount path: EXISTS"
        try {
            Get-ChildItem $ssdMount -ErrorAction Stop | Out-Null
            Write-Host "  ✅ Mount access: OK"
        } catch {
            Write-Host "  ❌ Mount access: Denied (expected for Linux ext4)"
        }
        $mountStatus = "✅ MOUNTED"
    } else {
        Write-Host "  ❌ Mount path: NOT FOUND"
        $mountStatus = "❌ NOT MOUNTED"
    }
    
    Write-Host ""
    Write-Host "[!] CURRENT STATUS:"
    Write-Host "  VM (port 2222):  $vmStatus"
    Write-Host "  SSD (port 22):   $ssdStatus"
    Write-Host "  SSD Mount:       $mountStatus"
    Write-Host ""
    
    # Alert if VM is ready
    if ($vmStatus -eq "✅ READY") {
        Write-Host "🎉 VM SSH IS READY!"
        Write-Host "   Connect with: ssh -p 2222 sourou@127.0.0.1"
        Write-Host "   Deploy scripts: scp -P 2222 -r linux_scripts sourou@127.0.0.1:~/aeon-build/"
        Write-Host ""
    }
    
    # Alert if SSD boots
    if ($ssdStatus -eq "✅ BOOTED") {
        Write-Host "🎉 SSD SYSTEM IS BOOTED!"
        Write-Host "   Connect with: ssh sourou@127.0.0.1"
        Write-Host "   Apply nomodeset, then run Phase A"
        Write-Host ""
    }
    
    # Show recommended actions
    Write-Host "[?] RECOMMENDED ACTIONS:"
    if ($vmStatus -ne "✅ READY" -and $ssdStatus -ne "✅ BOOTED") {
        Write-Host "  - Install EndeavourOS in VM and enable SSH"
        Write-Host "  - OR boot SSD from BIOS (F12 → UEFI: [JMicron USB SSD])"
    } elseif ($vmStatus -eq "✅ READY" -and $ssdStatus -ne "✅ BOOTED") {
        Write-Host "  - Deploy Aeon build to VM: scp -P 2222 -r linux_scripts sourou@127.0.0.1:~/aeon-build/"
        Write-Host "  - Run Phase A in VM: ssh -p 2222 sourou@127.0.0.1"
    } elseif ($vmStatus -ne "✅ READY" -and $ssdStatus -eq "✅ BOOTED") {
        Write-Host "  - Apply nomodeset to SSD: ssh sourou@127.0.0.1"
        Write-Host "  - Run Phase A on SSD"
    } else {
        Write-Host "  - Both systems ready! Choose VM or SSD for Phase A"
        Write-Host "  - VM: ssh -p 2222 sourou@127.0.0.1"
        Write-Host "  - SSD: ssh sourou@127.0.0.1"
    }
    
    Write-Host ""
    $nextTime = (Get-Date).AddMinutes(3).ToString("HH:mm:ss")
    Write-Host "Next review: $nextTime (in 3 min)"
    Write-Host "Press Ctrl+C to stop monitoring"
    Write-Host "========================================"
    Write-Host ""
    
    $reviewCount++
    Start-Sleep -Seconds 180  # 3 minutes
}