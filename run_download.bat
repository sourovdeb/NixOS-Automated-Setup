@echo off
echo NixOS ISO Download Script
echo =========================

REM ── Find Python ──────────────────────────────────────────────────────────────
set PYTHON=

REM 1. Try python in PATH
where python >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON=python
    goto :python_found
)

REM 2. Try python3 in PATH
where python3 >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON=python3
    goto :python_found
)

REM 3. Known install location (Python 3.11)
if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" (
    set PYTHON=%LOCALAPPDATA%\Programs\Python\Python311\python.exe
    goto :python_found
)

REM 4. Common alternative locations
if exist "C:\Python311\python.exe" (
    set PYTHON=C:\Python311\python.exe
    goto :python_found
)
if exist "C:\Python310\python.exe" (
    set PYTHON=C:\Python310\python.exe
    goto :python_found
)
if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" (
    set PYTHON=%LOCALAPPDATA%\Programs\Python\Python310\python.exe
    goto :python_found
)

echo Python not found in any known location.
echo Please install Python 3.8+ from https://python.org/downloads
echo Make sure to check "Add Python to PATH" during installation.
pause
exit /b 1

:python_found
echo Python found: %PYTHON%
"%PYTHON%" --version

REM ── Check / install Playwright ───────────────────────────────────────────────
echo.
echo Checking Playwright installation...
"%PYTHON%" -c "import playwright" >nul 2>nul
if %errorlevel% neq 0 (
    echo Installing Playwright...
    "%PYTHON%" -m pip install playwright
    echo Installing Firefox for Playwright...
    "%PYTHON%" -m playwright install firefox
) else (
    echo Playwright is already installed.
)

REM ── Create download directory ─────────────────────────────────────────────────
echo.
echo Creating download directory...
mkdir "%USERPROFILE%\Desktop\NixOS_Installer" 2>nul

REM ── Run download script ───────────────────────────────────────────────────────
echo.
echo Running NixOS ISO download script...
echo This will open a Firefox window to download the ISO.
echo.
"%PYTHON%" "%~dp0download_nixos_playwright.py"

REM ── Result check ──────────────────────────────────────────────────────────────
if exist "%USERPROFILE%\Desktop\NixOS_Installer\nixos-graphical-installer.iso" (
    echo.
    echo SUCCESS: NixOS ISO downloaded!
    echo Location: %USERPROFILE%\Desktop\NixOS_Installer\nixos-graphical-installer.iso
) else (
    echo.
    echo WARNING: ISO not found at expected location.
    echo If Firefox opened, check your Downloads folder and move the .iso file to:
    echo   %USERPROFILE%\Desktop\NixOS_Installer\
    echo Or download manually from: https://nixos.org/download.html
)

echo.
pause
