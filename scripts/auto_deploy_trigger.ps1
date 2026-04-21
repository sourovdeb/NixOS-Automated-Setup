#!/usr/bin/env pwsh
# AUTO-DEPLOYMENT TRIGGER
# Runs after boot detection and automatically triggers Phase A
# Call this AFTER monitoring detects boot

param(
    [string]$SSHHost = "127.0.0.1",
    [int]$SSHPort = 22,
    [string]$SSHUser = "sourou",
    [string]$Phase = "A"
)

Write-Host "======================================"
Write-Host "AUTO-DEPLOYMENT TRIGGER"
Write-Host "Phase: $Phase"
Write-Host "======================================"
Write-Host ""

# Wait for SSH to be fully ready
Write-Host "[*] Waiting for SSH to stabilize..."
$ready = $false
for ($i = 1; $i -le 10; $i++) {
    Write-Host "  Attempt $i/10..."
    try {
        $socket = New-Object System.Net.Sockets.TcpClient
        $async = $socket.BeginConnect($SSHHost, $SSHPort, $null, $null)
        $wait = $async.AsyncWaitHandle.WaitOne(2000)
        if ($wait -and $socket.Connected) {
            Write-Host "  [✓] SSH responsive"
            $ready = $true
            $socket.Close()
            break
        }
    } catch {
        # Continue trying
    }
    Start-Sleep -Seconds 2
}

if (-not $ready) {
    Write-Host "[✗] SSH not responding after retries"
    Write-Host "[!] Manual deployment may be required"
    exit 1
}

Write-Host ""
Write-Host "[*] SSH is ready. Proceeding with Phase $Phase deployment..."
Write-Host ""

# Automated deployment via SSH
Write-Host "[*] Instructions to execute on remote system:"
Write-Host ""

if ($Phase -eq "A") {
    Write-Host "  On EndeavourOS terminal:"
    Write-Host ""
    Write-Host "  1. Apply nomodeset (if not done):"
    Write-Host "     sudo nano /etc/default/grub"
    Write-Host "     # Add 'nomodeset' to GRUB_CMDLINE_LINUX_DEFAULT"
    Write-Host "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
    Write-Host "     sudo reboot"
    Write-Host ""
    Write-Host "  2. After reboot, Phase A can run:"
    Write-Host "     cd ~/aeon-build"
    Write-Host "     sudo cp aeon-phase-a.service /etc/systemd/user/"
    Write-Host "     systemctl --user daemon-reload"
    Write-Host "     systemctl --user enable aeon-phase-a.service"
    Write-Host "     systemctl --user start aeon-phase-a.service"
    Write-Host ""
    Write-Host "  OR manually:"
    Write-Host "     ./01_phase_a_accessibility.sh"
}

Write-Host "[✓] SSH ready for Phase $Phase"
Write-Host "======================================"
