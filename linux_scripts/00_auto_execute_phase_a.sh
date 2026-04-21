#!/usr/bin/env bash
# AUTO-EXECUTE WRAPPER FOR PHASE A
# This script will be set to run automatically on first boot after nomodeset is applied
# Place in: ~/.config/autostart/ or as systemd service

set -euo pipefail

# Log everything
LOGDIR="${HOME}/aeon-build/logs"
mkdir -p "${LOGDIR}"
PHASE_LOG="${LOGDIR}/phase_a_auto_execute.log"

exec 1> >(tee -a "${PHASE_LOG}")
exec 2>&1

echo "=========================================="
echo "PHASE A AUTO-EXECUTE WRAPPER"
echo "Started: $(date)"
echo "=========================================="

# Check if nomodeset is applied
echo "[*] Verifying nomodeset kernel parameter..."
if grep -q "nomodeset" /proc/cmdline; then
    echo "[✓] nomodeset confirmed in kernel parameters"
else
    echo "[!] WARNING: nomodeset NOT found in /proc/cmdline"
    echo "[!] This may cause NVIDIA conflicts"
fi

# Wait for system to stabilize (network, services)
echo "[*] Waiting 5 seconds for system initialization..."
sleep 5

# Navigate to build directory
cd "${HOME}/aeon-build" || {
    echo "[✗] ERROR: Cannot access ~/aeon-build/"
    exit 1
}

# Check if Phase A script exists
if [ ! -f "01_phase_a_accessibility.sh" ]; then
    echo "[✗] ERROR: 01_phase_a_accessibility.sh not found"
    exit 1
fi

echo "[*] Making Phase A script executable..."
chmod +x 01_phase_a_accessibility.sh

echo "[*] Executing Phase A: Accessibility Setup..."
echo "=========================================="

# Execute Phase A
if ./01_phase_a_accessibility.sh; then
    echo "[✓] Phase A completed successfully"
    
    # Create completion marker
    touch "${LOGDIR}/phase_a_complete.marker"
    
    echo "[*] Phase A success marker created"
    echo "[*] Ready for Phase B execution"
    
else
    echo "[✗] Phase A execution FAILED"
    exit 1
fi

echo "=========================================="
echo "PHASE A AUTO-EXECUTE COMPLETED"
echo "Finished: $(date)"
echo "=========================================="
