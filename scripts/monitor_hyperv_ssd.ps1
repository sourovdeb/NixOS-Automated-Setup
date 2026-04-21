#!/usr/bin/env pwsh
# HYPER-V + SSD 3-MINUTE MONITORING
# Monitors Hyper-V VM and physical SSD boot options

Write-Host "======================================"
Write-Host "3-MINUTE REVIEW MONITORING - HYPER-V"
Write-Host "Hyper-V VM: EndeavourOS-SSD-Direct"
Write-Host "Physical SSD: Direct BIOS boot option"
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
    
    # Check Hyper-V VM status
    Write-Host "[*] Testing Hyper-V VM..."
    try {
        $vm = Get-VM -Name "EndeavourOS-SSD-Direct" -ErrorAction SilentlyContinue
        if ($vm) {
            $vmState = $vm.State
            Write-Host "  VM State: $vmState"
            
            if ($vmState -eq "Running") {
                # Try to get VM IP
                $vmIP = $null
                try {
                    $adapter = Get-VMNetworkAdapter -VMName "EndeavourOS-SSD-Direct" -ErrorAction SilentlyContinue
                    if ($adapter) {
                        $vmIP = ($adapter | Get-VMNetworkAdapterIP -ErrorAction SilentlyContinue).IPAddresses | Where-Object { $_ -like "192.168.*" -or $_ -like "172.*" -or $_ -like "10.*" } | Select-Object -First 1
                    }
                } catch {
                    # IP detection failed, continue without it
                }
                
                if ($vmIP) {
                    Write-Host "  VM IP: $vmIP"
                    
                    # Test SSH to VM
                    try {
                        $vmSocket = New-Object System.Net.Sockets.TcpClient
                        $vmAsync = $vmSocket.BeginConnect($vmIP, 22, $null, $null)
                        $vmWait = $vmAsync.AsyncWaitHandle.WaitOne(3000)
                        if ($vmWait -and $vmSocket.Connected) {
                            Write-Host "  ✅ Hyper-V SSH: RESPONDING"
                            $hypervStatus = "✅ READY"
                            $vmSocket.Close()
                        } else {
                            Write-Host "  ❌ Hyper-V SSH: Closed"
                            $hypervStatus = "❌ NO SSH"
                        }
                    } catch {
                        Write-Host "  ❌ Hyper-V SSH: Error"
                        $hypervStatus = "❌ ERROR"
                    }
                } else {
                    Write-Host "  ⏳ VM IP: Not detected yet"
                    $hypervStatus = "⏳ BOOTING"
                }
            } else {
                Write-Host "  ❌ VM not running"
                $hypervStatus = "❌ STOPPED"
            }
        } else {
            Write-Host "  ❌ VM not found"
            $hypervStatus = "❌ NOT CREATED"
        }
    } catch {
        Write-Host "  ❌ Hyper-V error: $($_.Exception.Message)"
        $hypervStatus = "❌ ERROR"
    }
    
    # Test physical SSD SSH (direct boot option)
    Write-Host "[*] Testing physical SSD SSH (port 22):"
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
            $mountStatus = "✅ ACCESSIBLE"
        } catch {
            Write-Host "  ❌ Mount access: Denied (expected for Linux ext4)"
            $mountStatus = "✅ MOUNTED"
        }
    } else {
        Write-Host "  ❌ Mount path: NOT FOUND"
        $mountStatus = "❌ NOT MOUNTED"
    }
    
    # Check physical SSD disk status
    Write-Host "[*] Checking SSD disk status:"
    try {
        $ssdDisk = Get-Disk -Number 1 -ErrorAction SilentlyContinue
        if ($ssdDisk) {
            $diskOffline = $ssdDisk.IsOffline
            if ($diskOffline) {
                Write-Host "  ⚠️  SSD Disk: OFFLINE (used by Hyper-V VM)"
                $diskStatus = "⚠️  VM PASSTHROUGH"
            } else {
                Write-Host "  ✅ SSD Disk: ONLINE (available for direct boot)"
                $diskStatus = "✅ AVAILABLE"
            }
        } else {
            Write-Host "  ❌ SSD Disk: NOT FOUND"
            $diskStatus = "❌ NOT FOUND"
        }
    } catch {
        Write-Host "  ❌ SSD Disk: ERROR"
        $diskStatus = "❌ ERROR"
    }
    
    Write-Host ""
    Write-Host "[!] CURRENT STATUS:"
    Write-Host "  Hyper-V VM:     $hypervStatus"
    Write-Host "  Physical SSD:   $ssdStatus"
    Write-Host "  SSD Mount:      $mountStatus"
    Write-Host "  SSD Disk:       $diskStatus"
    Write-Host ""
    
    # Alert if Hyper-V VM is ready
    if ($hypervStatus -eq "✅ READY") {
        Write-Host "🎉 HYPER-V VM SSH IS READY!"
        Write-Host "   Connect with: ssh sourou@$vmIP"
        Write-Host "   Deploy scripts via GitHub or network share"
        Write-Host ""
    }
    
    # Alert if physical SSD boots
    if ($ssdStatus -eq "✅ BOOTED") {
        Write-Host "🎉 PHYSICAL SSD SYSTEM IS BOOTED!"
        Write-Host "   Connect with: ssh sourou@127.0.0.1"
        Write-Host "   Apply nomodeset, then run Phase A"
        Write-Host ""
    }
    
    # Show recommended actions
    Write-Host "[?] RECOMMENDED ACTIONS:"
    if ($hypervStatus -eq "❌ NOT CREATED") {
        Write-Host "  - Create Hyper-V VM: Run scripts\create_hyperv_ssd_vm.ps1 as Administrator"
    } elseif ($hypervStatus -eq "❌ STOPPED") {
        Write-Host "  - Start Hyper-V VM: Start-VM -Name 'EndeavourOS-SSD-Direct'"
    } elseif ($hypervStatus -eq "⏳ BOOTING") {
        Write-Host "  - Wait for VM to fully boot and get IP address"
    } elseif ($hypervStatus -eq "✅ READY") {
        Write-Host "  - Deploy Aeon build: ssh sourou@$vmIP"
        Write-Host "  - Run Phase A: cd ~/aeon-build && ./linux_scripts/01_phase_a_accessibility.sh"
    } elseif ($ssdStatus -eq "✅ BOOTED") {
        Write-Host "  - Apply nomodeset: ssh sourou@127.0.0.1"
        Write-Host "  - Run Phase A on physical SSD"
    } else {
        Write-Host "  - Create Hyper-V VM with SSD passthrough"
        Write-Host "  - OR boot SSD from BIOS (F12 → UEFI: [JMicron USB SSD])"
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