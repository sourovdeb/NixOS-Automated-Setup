# flash_usb_rufus.ps1
# Launches Rufus pre-loaded with the NixOS ISO and USB drive E:
# Run from the nix_os folder.  Rufus will open; click Start to begin flashing.

$RufusExe    = "C:\Users\souro\Desktop\rufus-4.13p.exe"
$IsoDir      = "$env:USERPROFILE\Desktop\NixOS_Installer"
$IsoFile     = "$IsoDir\nixos-graphical-installer.iso"
$UsbDrive    = "E:"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " NixOS USB Flasher (via Rufus)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# ── Check Rufus ───────────────────────────────────────────────────────────────
if (-not (Test-Path $RufusExe)) {
    Write-Host "ERROR: Rufus not found at $RufusExe" -ForegroundColor Red
    exit 1
}
Write-Host "Rufus  : $RufusExe" -ForegroundColor Green

# ── Check ISO ────────────────────────────────────────────────────────────────
if (-not (Test-Path $IsoFile)) {
    Write-Host ""
    Write-Host "ERROR: NixOS ISO not found at:" -ForegroundColor Red
    Write-Host "  $IsoFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Download it first by running:" -ForegroundColor Cyan
    Write-Host "  .\run_download.bat" -ForegroundColor White
    Write-Host ""
    Write-Host "Or download manually from https://nixos.org/download.html" -ForegroundColor Cyan
    Write-Host "and save it to: $IsoDir" -ForegroundColor Cyan
    exit 1
}

$isoSize = [math]::Round((Get-Item $IsoFile).Length / 1GB, 2)
Write-Host "ISO    : $IsoFile ($isoSize GB)" -ForegroundColor Green

# ── Check USB drive ───────────────────────────────────────────────────────────
if (-not (Test-Path $UsbDrive)) {
    Write-Host "ERROR: USB drive $UsbDrive not found. Plug in the USB and try again." -ForegroundColor Red
    exit 1
}
$usb = Get-PSDrive -Name ($UsbDrive -replace ':','') -ErrorAction SilentlyContinue
if ($usb) {
    $usbFree = [math]::Round($usb.Free / 1GB, 1)
    $usbUsed = [math]::Round($usb.Used / 1GB, 1)
    Write-Host "USB    : $UsbDrive  (Used: ${usbUsed} GB, Free: ${usbFree} GB)" -ForegroundColor Green
}

# ── Warning ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "WARNING: ALL data on USB $UsbDrive will be erased!" -ForegroundColor Yellow
Write-Host "  Current contents: Porteus Linux (will be replaced by NixOS)" -ForegroundColor Gray
Write-Host ""
$answer = Read-Host "Type 'yes' to open Rufus and continue"
if ($answer -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

# ── Launch Rufus ──────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Launching Rufus..." -ForegroundColor Cyan
Write-Host ""
Write-Host "In Rufus:" -ForegroundColor White
Write-Host "  1. Device    -> select $UsbDrive (your USB)" -ForegroundColor White
Write-Host "  2. Boot sel. -> should show the NixOS ISO (pre-loaded)" -ForegroundColor White
Write-Host "  3. Partition -> GPT" -ForegroundColor White
Write-Host "  4. Target    -> UEFI (non CSM)" -ForegroundColor White
Write-Host "  5. Click START -> choose 'Write in DD Image mode' when asked" -ForegroundColor White
Write-Host ""

# Pass /iso and /drive flags — Rufus 4.x accepts these to pre-populate the UI
Start-Process -FilePath $RufusExe -ArgumentList "/iso:`"$IsoFile`"" -Wait:$false

Write-Host "Rufus is open. Follow the steps above, then click START." -ForegroundColor Green
Write-Host ""
Write-Host "After flashing is complete:" -ForegroundColor Cyan
Write-Host "  1. Eject the USB safely" -ForegroundColor White
Write-Host "  2. Plug USB into target PC, boot from it (F12 or BIOS boot menu)" -ForegroundColor White
Write-Host "  3. In the NixOS live environment, run:" -ForegroundColor White
Write-Host "       bash automate_nixos_setup.sh" -ForegroundColor Yellow
Write-Host "     (copy the script to the USB or download from GitHub)" -ForegroundColor Gray
