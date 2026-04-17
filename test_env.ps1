Write-Host "Environment Test for NixOS Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Test 1: Check if Python is available
Write-Host "`n1. Checking Python installation..." -ForegroundColor Yellow
$pythonPaths = @(
    "python",
    "python3",
    "$env:USERPROFILE\AppData\Local\Programs\Python\Python311\python.exe",
    "C:\Python311\python.exe"
)

$pythonFound = $false
foreach ($python in $pythonPaths) {
    try {
        $result = & $python --version 2>&1
        if ($result -like "*Python*") {
            Write-Host "   ✅ Python found: $python" -ForegroundColor Green
            Write-Host "      Version: $result" -ForegroundColor Gray
            $pythonFound = $true
            $pythonExe = $python
            break
        }
    } catch {
        # Continue to next path
    }
}

if (-not $pythonFound) {
    Write-Host "   ❌ Python not found!" -ForegroundColor Red
    Write-Host "   Please install Python 3.8+ from: https://python.org/downloads" -ForegroundColor Yellow
    exit 1
}

# Test 2: Check pip
Write-Host "`n2. Checking pip installation..." -ForegroundColor Yellow
try {
    & $pythonExe -m pip --version 2>&1 | Out-Null
    Write-Host "   ✅ pip is available" -ForegroundColor Green
} catch {
    Write-Host "   ❌ pip not available" -ForegroundColor Red
    Write-Host "   Run: $pythonExe -m ensurepip --upgrade" -ForegroundColor Yellow
}

# Test 3: Check Playwright
Write-Host "`n3. Checking Playwright installation..." -ForegroundColor Yellow
try {
    & $pythonExe -c "import playwright; print('Playwright is installed')" 2>&1 | Out-Null
    Write-Host "   ✅ Playwright Python package is installed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Playwright not installed" -ForegroundColor Red
    Write-Host "   Installing Playwright..." -ForegroundColor Yellow
    & $pythonExe -m pip install playwright
    Write-Host "   Installing Firefox for Playwright..." -ForegroundColor Yellow
    & $pythonExe -m playwright install firefox
}

# Test 4: Check Firefox browser installation
Write-Host "`n4. Checking Firefox browser for Playwright..." -ForegroundColor Yellow
try {
    & $pythonExe -c "from playwright.sync_api import sync_playwright; p = sync_playwright().start(); browser = p.firefox.launch(headless=True); browser.close(); p.stop(); print('Firefox is working')" 2>&1 | Out-Null
    Write-Host "   ✅ Firefox browser is installed and working" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Firefox browser issue" -ForegroundColor Red
    Write-Host "   Reinstalling Firefox..." -ForegroundColor Yellow
    & $pythonExe -m playwright install firefox --force
}

# Test 5: Check download directory
Write-Host "`n5. Checking download directory..." -ForegroundColor Yellow
$downloadDir = "$env:USERPROFILE\Desktop\NixOS_Installer"
if (Test-Path $downloadDir) {
    Write-Host "   ✅ Download directory exists: $downloadDir" -ForegroundColor Green
} else {
    Write-Host "   📁 Creating download directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    Write-Host "   ✅ Download directory created: $downloadDir" -ForegroundColor Green
}

# Summary
Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "Environment Test Complete" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor Green
Write-Host "1. Run the download script:" -ForegroundColor Yellow
Write-Host "   .\run_download.bat" -ForegroundColor White
Write-Host "   OR" -ForegroundColor White
Write-Host "   $pythonExe download_nixos_playwright.py" -ForegroundColor White

Write-Host "`n2. Use Rufus with the downloaded ISO to create bootable USB" -ForegroundColor Yellow
Write-Host "`n3. Boot from USB and run automate_nixos_setup.sh" -ForegroundColor Yellow