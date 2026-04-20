# Backup workspace to external SSD.
# Finds the first non-C: drive with enough free space.

$source = "C:\Users\souro\Desktop\Arch_Linus"
$drives = Get-CimInstance Win32_LogicalDisk | Where-Object {
    $_.DriveType -in 2,3 -and $_.DeviceID -ne "C:" -and $_.FreeSpace -gt 5GB
}

if (-not $drives) {
    Write-Host "No external drive found. Plug in the SSD and rerun." -ForegroundColor Yellow
    exit 1
}

$targetRoot = $drives[0].DeviceID + "\AEON_Backup"
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

Write-Host "Backing up to $targetRoot" -ForegroundColor Cyan
robocopy $source $targetRoot /MIR /XD ".git" ".vscode" "node_modules" "__pycache__" /R:1 /W:1

Write-Host "Backup complete." -ForegroundColor Green