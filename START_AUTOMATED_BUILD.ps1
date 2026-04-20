# AEON Automated Build Launcher
# This starts the build and you can leave for 90 minutes

$VBM = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  AEON AUTOMATED BUILD LAUNCHER" -ForegroundColor Cyan  
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Check VM is running
$vmState = & $VBM showvminfo arch --machinereadable | Select-String "VMState=" 
if ($vmState -notmatch "running") {
    Write-Host "Starting VM first..." -ForegroundColor Yellow
    & $VBM startvm arch --type headless
    Start-Sleep -Seconds 10
}

Write-Host "✓ VM is running" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "1. Open VirtualBox Manager (the GUI)" -ForegroundColor White
Write-Host "2. Right-click on 'arch' → Show" -ForegroundColor White
Write-Host "3. Login with your username and password" -ForegroundColor White
Write-Host "4. Copy everything between the markers below" -ForegroundColor White
Write-Host "5. Paste into the VM console" -ForegroundColor White
Write-Host "6. The build will start automatically" -ForegroundColor White
Write-Host "7. YOU CAN THEN LEAVE for 90 minutes!" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "COPY EVERYTHING BELOW THIS LINE:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Read the build script
$scriptContent = Get-Content "AEON_BUILD_SCRIPT.sh" -Raw

# Create the VM commands
@"
# First, create the build script
cat > ~/aeon-build.sh << 'EOFSCRIPT'
$scriptContent
EOFSCRIPT

# Make it executable
chmod +x ~/aeon-build.sh

# Start the build in background with logging
echo "Starting AEON build..."
nohup sudo bash ~/aeon-build.sh > ~/build.log 2>&1 &
BUILD_PID=`$!

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ BUILD STARTED SUCCESSFULLY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Process ID: `$BUILD_PID"
echo "Log file: ~/build.log"
echo ""
echo "You can now CLOSE this window and LEAVE!"
echo "Come back in 90 minutes."
echo ""
echo "To check progress when you return:"
echo "  tail -n 50 ~/build.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"@ | Out-Host

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "COPY EVERYTHING ABOVE THIS LINE" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "After pasting and seeing 'BUILD STARTED':" -ForegroundColor Green
Write-Host "  → You can leave for 90 minutes" -ForegroundColor Green
Write-Host "  → No interaction needed" -ForegroundColor Green
Write-Host "  → Everything runs automatically" -ForegroundColor Green
Write-Host ""
Write-Host "See you in 90 minutes! 👋" -ForegroundColor Cyan