# prepare_install.ps1
# Run this on Windows BEFORE booting the NixOS USB.
# Copies all setup scripts to F:\nixos_setup\ so they are readable
# from the NixOS live environment (NixOS can mount exFAT drives).

$SsdDrive   = "F:\"
$SetupDir   = "F:\nixos_setup"
$ScriptDir  = $PSScriptRoot
$IsoFile    = "$env:USERPROFILE\Desktop\NixOS_Installer\nixos-graphical-installer.iso"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " NixOS Install Prep - copying scripts to F:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

if (-not (Test-Path $SsdDrive)) {
    Write-Host "ERROR: SSD F: not found. Plug in the SSD and try again." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $IsoFile)) {
    Write-Host "WARNING: NixOS ISO not downloaded yet." -ForegroundColor Yellow
    Write-Host "  Run run_download.bat first, then come back here." -ForegroundColor Yellow
    Write-Host "  (Skipping ISO check - scripts will still be copied.)" -ForegroundColor Gray
} else {
    $sizeGB = [math]::Round((Get-Item $IsoFile).Length / 1GB, 2)
    Write-Host "ISO     : $IsoFile ($sizeGB GB)  OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "Copying setup scripts to $SetupDir ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $SetupDir -Force | Out-Null

$files = @(
    "automate_nixos_setup.sh",
    "partition_ssd.sh",
    "configuration.nix",
    "research.py",
    "post_to_wp.py"
)

foreach ($f in $files) {
    $src = Join-Path $ScriptDir $f
    if (Test-Path $src) {
        Copy-Item $src $SetupDir -Force
        Write-Host "  Copied: $f" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $f  (not copied)" -ForegroundColor Yellow
    }
}

$startHere = @"
============================================================
 NixOS Setup - START HERE
 (Read this from the NixOS live USB environment)
============================================================

Your scripts are in this folder on the Windows SSD.
To access them from the live environment:

  1. Find this drive:
       lsblk -f
     Look for the exFAT partition labelled LUBUNTU (your F: drive, ~465GB).

  2. Mount it (replace /dev/sdXY with that partition):
       mkdir -p /mnt/ssd
       mount /dev/sdXY /mnt/ssd

  3. Copy the scripts to /tmp:
       cp /mnt/ssd/nixos_setup/*.sh /tmp/
       cp /mnt/ssd/nixos_setup/configuration.nix /tmp/
       cp /mnt/ssd/nixos_setup/*.py /tmp/
       chmod +x /tmp/*.sh

  4. Run the installer:
       cd /tmp
       sudo bash automate_nixos_setup.sh

  OR - if you have internet in the live environment:
       curl -O https://raw.githubusercontent.com/sourovdeb/NixOS-Automated-Setup/main/automate_nixos_setup.sh
       chmod +x automate_nixos_setup.sh
       sudo bash automate_nixos_setup.sh

============================================================
 Rufus settings used to flash the USB:
   Partition scheme : GPT
   Target system    : UEFI (non CSM)
   Write mode       : DD Image
============================================================
"@

Set-Content -Path "$SetupDir\START_HERE.txt" -Value $startHere -Encoding UTF8
Write-Host "  Created: START_HERE.txt" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Prep complete! Files on F:\nixos_setup\" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Run flash_usb_rufus.ps1 to flash the ISO to USB E:" -ForegroundColor Yellow
Write-Host "  2. Reboot - press F12 - select USB" -ForegroundColor Yellow
Write-Host "  3. In NixOS live: follow START_HERE.txt on this drive" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: The installer will ERASE everything on your target SSD." -ForegroundColor Red
Write-Host "           Double-check the device name with  lsblk -f  before confirming." -ForegroundColor Red
