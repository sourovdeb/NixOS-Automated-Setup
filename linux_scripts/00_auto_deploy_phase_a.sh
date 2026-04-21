#!/usr/bin/env bash
# AUTO-DEPLOY PHASE A - Triggered when SSD boots
# This script runs after boot is detected and system is accessible via SSH

set -euo pipefail

LOGFILE="${HOME}/aeon-build/logs/phase_a_deployment.log"
mkdir -p "${HOME}/aeon-build/logs"

{
    echo "=========================================="
    echo "PHASE A AUTO-DEPLOYMENT STARTED"
    echo "Time: $(date)"
    echo "=========================================="
    echo ""
    
    # Step 1: Verify system is accessible
    echo "[*] Verifying EndeavourOS is fully booted..."
    sleep 5
    
    # Step 2: Check if scripts are present
    cd "${HOME}/aeon-build" || {
        echo "[✗] ERROR: ~/aeon-build/ not found"
        exit 1
    }
    
    if [ ! -f "01_phase_a_accessibility.sh" ]; then
        echo "[!] Phase A script not found at ~/aeon-build/"
        echo "[*] Attempting to download from GitHub..."
        git clone --depth 1 --branch aeon-writer-os https://github.com/sourovdeb/NixOS-Automated-Setup.git temp-repo
        cp temp-repo/linux_scripts/*.sh . 2>/dev/null || true
        rm -rf temp-repo
    fi
    
    # Step 3: Verify nomodeset is applied
    echo "[*] Checking nomodeset in kernel parameters..."
    if grep -q "nomodeset" /proc/cmdline; then
        echo "[✓] nomodeset confirmed - safe to proceed"
    else
        echo "[!] WARNING: nomodeset NOT found in /proc/cmdline"
        echo "[!] Kernel parameters: $(cat /proc/cmdline)"
        echo "[!] Phase A may have display issues without nomodeset"
    fi
    echo ""
    
    # Step 4: Execute Phase A
    echo "[*] Starting Phase A: Accessibility Setup..."
    echo "=========================================="
    if [ -f "01_phase_a_accessibility.sh" ]; then
        chmod +x 01_phase_a_accessibility.sh
        if ./01_phase_a_accessibility.sh; then
            echo "[✓] Phase A completed successfully!"
            touch "${HOME}/aeon-build/logs/phase_a_success.marker"
            
            # Optional: Trigger Phase B
            echo ""
            echo "[*] Phase A finished. Ready for Phase B (Dashboard)."
            echo "[?] To continue with Phase B, run: cd ~/aeon-build && ./02_phase_b_dashboard.sh"
        else
            echo "[✗] Phase A failed - check logs for details"
            exit 1
        fi
    else
        echo "[✗] ERROR: Phase A script not found"
        exit 1
    fi
    
    echo ""
    echo "=========================================="
    echo "Phase A deployment completed at $(date)"
    echo "=========================================="
    
} 2>&1 | tee -a "${LOGFILE}"
