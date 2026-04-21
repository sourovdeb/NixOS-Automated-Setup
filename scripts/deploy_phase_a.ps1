#!/usr/bin/env pwsh
# PHASE A DEPLOYMENT ORCHESTRATOR
# Runs after SSD boot is detected
# Deploys scripts and triggers Phase A execution

param(
    [string]$RemoteIP = "127.0.0.1",
    [int]$RemotePort = 22,
    [string]$RemoteUser = "sourou",
    [string]$DeployMethod = "ssh"  # ssh, sftp, or manual
)

Write-Host "======================================"
Write-Host "PHASE A DEPLOYMENT ORCHESTRATOR"
Write-Host "======================================"
Write-Host ""

# Function to test SSH connectivity
function Test-SSHConnection {
    param([string]$IP, [int]$Port)
    try {
        $socket = New-Object System.Net.Sockets.TcpClient
        $socket.ConnectAsync($IP, $Port) | Wait-Job -Timeout 2 >$null 2>&1
        $result = $socket.Connected
        $socket.Close()
        return $result
    } catch {
        return $false
    }
}

# Function to deploy via SSH
function Deploy-ViaSCP {
    param([string]$IP, [int]$Port, [string]$User)
    
    Write-Host "[*] Deploying scripts via SCP..."
    
    $sourceDir = "C:\Users\souro\Desktop\Arch_Linus\linux_scripts"
    $targetDir = "/home/$User/aeon-build"
    
    # SCP command - deploy all scripts
    $scpCmd = @(
        "scp",
        "-r",
        "-P", $Port.ToString(),
        "-o", "ConnectTimeout=5",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "$sourceDir/*",
        "$User@${IP}:$targetDir/"
    )
    
    Write-Host "  Command: scp -r $sourceDir/* $User@$IP`:$targetDir/"
    Write-Host "  Running SCP transfer..."
    
    try {
        & @scpCmd 2>&1 | Out-Null
        Write-Host "  [✓] Scripts deployed successfully"
        return $true
    } catch {
        Write-Host "  [!] SCP failed - trying alternate method"
        return $false
    }
}

# Main deployment workflow
Write-Host "[*] Checking SSH connectivity to $RemoteIP`:$RemotePort..."
if (Test-SSHConnection -IP $RemoteIP -Port $RemotePort) {
    Write-Host "[✓] SSH is available - deployment ready"
    Write-Host ""
    
    Write-Host "[*] Deployment Plan:"
    Write-Host "  1. Transfer scripts to remote system"
    Write-Host "  2. Execute Phase A on remote system"
    Write-Host "  3. Monitor progress"
    Write-Host ""
    
    # Attempt SCP deployment
    if (Deploy-ViaSCP -IP $RemoteIP -Port $RemotePort -User $RemoteUser) {
        Write-Host "[✓] Deployment phase complete"
        Write-Host ""
        Write-Host "[*] Next steps:"
        Write-Host "  1. SSH into the system: ssh $RemoteUser@$RemoteIP"
        Write-Host "  2. Navigate: cd ~/aeon-build"
        Write-Host "  3. Run Phase A: ./01_phase_a_accessibility.sh"
        Write-Host "  4. Or use systemd auto-execute:"
        Write-Host "     sudo cp aeon-phase-a.service /etc/systemd/user/"
        Write-Host "     systemctl --user enable --now aeon-phase-a.service"
    } else {
        Write-Host "[!] SCP deployment failed"
        Write-Host "[*] Manual deployment required:"
        Write-Host "  1. Boot SSD"
        Write-Host "  2. SSH: ssh $RemoteUser@$RemoteIP"
        Write-Host "  3. Clone repo: git clone https://github.com/sourovdeb/NixOS-Automated-Setup.git"
        Write-Host "  4. Copy scripts: cp NixOS-Automated-Setup/linux_scripts/* ~/aeon-build/"
        Write-Host "  5. Run: ~/aeon-build/01_phase_a_accessibility.sh"
    }
} else {
    Write-Host "[✗] SSH not available on $RemoteIP`:$RemotePort"
    Write-Host "[!] Possible reasons:"
    Write-Host "  - SSD not yet booted"
    Write-Host "  - SSH not running on remote system"
    Write-Host "  - Network not connected"
    Write-Host ""
    Write-Host "[*] Manual steps:"
    Write-Host "  1. Boot SSD from BIOS"
    Write-Host "  2. Wait for EndeavourOS desktop"
    Write-Host "  3. Open terminal"
    Write-Host "  4. Run Phase A: cd ~/aeon-build && ./01_phase_a_accessibility.sh"
}

Write-Host ""
Write-Host "======================================"
Write-Host "Deployment orchestrator complete"
Write-Host "======================================"
