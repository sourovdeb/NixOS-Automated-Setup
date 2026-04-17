Write-Host "NixOS ISO Checker" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

# Check for ISO files in common locations
$searchPaths = @(
    "$env:USERPROFILE\Desktop\NixOS_Installer",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "C:\"
)

$foundIsos = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $isos = Get-ChildItem -Path $path -Filter "*.iso" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName, Length, LastWriteTime
        if ($isos) {
            $foundIsos += $isos
        }
    }
}

if ($foundIsos.Count -gt 0) {
    Write-Host "`n✅ Found NixOS ISO files:" -ForegroundColor Green
    $foundIsos | ForEach-Object {
        Write-Host "  - $($_.FullName)" -ForegroundColor White
        Write-Host "    Size: $([math]::Round($_.Length/1GB, 2)) GB, Modified: $($_.LastWriteTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "`n❌ No NixOS ISO files found." -ForegroundColor Red
    Write-Host "`nTo download NixOS ISO:" -ForegroundColor Yellow
    Write-Host "1. Run the download script:" -ForegroundColor White
    Write-Host "   .\run_download.bat" -ForegroundColor Cyan
    Write-Host "`n2. Or download manually:" -ForegroundColor White
    Write-Host "   Visit: https://nixos.org/download.html" -ForegroundColor Cyan
    Write-Host "   Download the 'Graphical installer' ISO" -ForegroundColor Cyan
    Write-Host "   Save to: $env:USERPROFILE\Desktop\NixOS_Installer\" -ForegroundColor Cyan
}

# Check if download directory exists
$nixosDir = "$env:USERPROFILE\Desktop\NixOS_Installer"
if (Test-Path $nixosDir) {
    Write-Host "`n📁 NixOS_Installer directory exists:" -ForegroundColor Cyan
    Get-ChildItem -Path $nixosDir | ForEach-Object {
        Write-Host "  - $($_.Name) ($($_.GetType().Name))" -ForegroundColor Gray
    }
} else {
    Write-Host "`n📁 NixOS_Installer directory does not exist." -ForegroundColor Yellow
    Write-Host "   It will be created when you run the download script." -ForegroundColor Gray
}

Write-Host "`nNext steps:" -ForegroundColor Green
Write-Host "1. If no ISO found, run: .\run_download.bat" -ForegroundColor Yellow
Write-Host "2. Use Rufus with the ISO to create bootable USB" -ForegroundColor Yellow
Write-Host "3. Boot from USB and run automate_nixos_setup.sh" -ForegroundColor Yellow