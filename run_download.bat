@echo off
echo NixOS ISO Download Script
echo =========================

REM Check if Python is available
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not found in PATH.
    echo Please install Python 3.8+ or add it to PATH.
    pause
    exit /b 1
)

REM Check Python version
python --version

REM Check if Playwright is installed
echo.
echo Checking Playwright installation...
python -c "import playwright" 2>nul
if %errorlevel% neq 0 (
    echo Playwright is not installed.
    echo Installing Playwright...
    python -m pip install playwright
    echo Installing Firefox browser for Playwright...
    python -m playwright install firefox
)

REM Create download directory
echo.
echo Creating download directory...
mkdir "%USERPROFILE%\Desktop\NixOS_Installer" 2>nul

REM Run the download script
echo.
echo Running NixOS ISO download script...
echo This will open Firefox browser to download the ISO.
echo.
python download_nixos_playwright.py

REM Check if download was successful
if exist "%USERPROFILE%\Desktop\NixOS_Installer\nixos-graphical-installer.iso" (
    echo.
    echo SUCCESS: NixOS ISO downloaded!
    echo Location: %USERPROFILE%\Desktop\NixOS_Installer\nixos-graphical-installer.iso
) else (
    echo.
    echo WARNING: ISO download may have failed.
    echo Please check the Firefox window and manually download if needed.
    echo Download URL: https://nixos.org/download.html
)

echo.
echo Press any key to exit...
pause >nul