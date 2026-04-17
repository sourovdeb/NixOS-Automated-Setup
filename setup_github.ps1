#!/usr/bin/env pwsh
<#
.SYNOPSIS
Setup GitHub repository for NixOS Automated Setup project.

.DESCRIPTION
This script helps create a new GitHub repository and upload all project files.
It requires GitHub CLI (gh) to be installed and authenticated.

.PARAMETER RepoName
Name of the GitHub repository (default: NixOS-Automated-Setup)

.PARAMETER Description
Repository description (default: Automated NixOS setup for writers with ADHD/autism-friendly tools)

.EXAMPLE
.\setup_github.ps1
.\setup_github.ps1 -RepoName "My-NixOS-Setup" -Description "My custom NixOS setup"
#>

param(
    [string]$RepoName = "NixOS-Automated-Setup",
    [string]$Description = "Automated NixOS setup for writers with ADHD/autism-friendly tools"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if gh CLI is installed
try {
    $ghVersion = gh --version
    Write-Host "✓ GitHub CLI (gh) is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ GitHub CLI (gh) is not installed" -ForegroundColor Red
    Write-Host "Please install GitHub CLI from: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host "Or manually create repository at: https://github.com/new" -ForegroundColor Yellow
    exit 1
}

# Check if user is authenticated
try {
    $authStatus = gh auth status 2>&1
    if ($authStatus -match "Logged in to github.com") {
        Write-Host "✓ Authenticated with GitHub" -ForegroundColor Green
    } else {
        Write-Host "✗ Not authenticated with GitHub" -ForegroundColor Red
        Write-Host "Please run: gh auth login" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ GitHub authentication check failed" -ForegroundColor Red
    Write-Host "Please run: gh auth login" -ForegroundColor Yellow
    exit 1
}

# Create repository
Write-Host "`nCreating repository: $RepoName" -ForegroundColor Cyan
try {
    gh repo create $RepoName --description $Description --public
    Write-Host "✓ Repository created successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to create repository" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Please create manually at: https://github.com/new" -ForegroundColor Yellow
    exit 1
}

# Initialize local git repository if not already
if (-not (Test-Path .git)) {
    Write-Host "`nInitializing local git repository..." -ForegroundColor Cyan
    git init
    git add .
    
    # Create .gitignore
    $gitignoreContent = @"
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# System
.DS_Store
Thumbs.db

# NixOS
result/
.direnv/
"@
    
    Set-Content -Path .gitignore -Value $gitignoreContent
    git add .gitignore
    
    git commit -m "Initial commit: NixOS Automated Setup for Writers"
    Write-Host "✓ Local repository initialized" -ForegroundColor Green
}

# Add remote and push
Write-Host "`nSetting up remote and pushing code..." -ForegroundColor Cyan
try {
    git remote add origin "https://github.com/sourovdeb/$RepoName.git"
    git branch -M main
    git push -u origin main
    Write-Host "✓ Code pushed to GitHub successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to push to GitHub" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Please check your remote URL and permissions" -ForegroundColor Yellow
}

# Display repository information
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Repository Information" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Name: $RepoName" -ForegroundColor White
Write-Host "URL: https://github.com/sourovdeb/$RepoName" -ForegroundColor White
Write-Host "Description: $Description" -ForegroundColor White

Write-Host "`nFiles included in repository:" -ForegroundColor Cyan
Get-ChildItem -File | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host "`nNext steps:" -ForegroundColor Green
Write-Host "1. Test the download script: python download_nixos_playwright.py" -ForegroundColor Yellow
Write-Host "2. Use Rufus to create bootable USB from downloaded ISO" -ForegroundColor Yellow
Write-Host "3. Boot from USB and run automate_nixos_setup.sh" -ForegroundColor Yellow
Write-Host "4. Post to WordPress: cd ../browser_bot && python browser_bot.py --mode blog" -ForegroundColor Yellow

Write-Host "`n✅ GitHub setup complete!" -ForegroundColor Green