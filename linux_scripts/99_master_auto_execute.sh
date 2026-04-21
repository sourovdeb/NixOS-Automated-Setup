#!/usr/bin/env bash
# MASTER AUTO-EXECUTE WRAPPER - ALL PHASES
# Executes all phases A-K sequentially with proper error handling and snapshots

set -euo pipefail

LOGDIR="${HOME}/aeon-build/logs"
mkdir -p "${LOGDIR}"

MASTER_LOG="${LOGDIR}/master_build_log.txt"
exec 1> >(tee -a "${MASTER_LOG}")
exec 2>&1

BUILD_START=$(date)
echo "=========================================="
echo "AEON BUILD SYSTEM - MASTER AUTO-EXECUTE"
echo "Started: ${BUILD_START}"
echo "=========================================="

cd "${HOME}/aeon-build" || {
    echo "[✗] ERROR: Cannot access ~/aeon-build/"
    exit 1
}

# Array of phases
declare -a PHASES=(
    "01_phase_a_accessibility"
    "02_phase_b_dashboard"
    "03_phase_c_writing"
    "04_phase_d_podcast"
    "05_phase_e_publishing"
    "06_phase_f_ai"
    "07_phase_g_notifications"
    "08_phase_h_safety"
    "09_phase_i_services"
    "10_phase_j_habits"
    "11_phase_k_packaging"
)

# Counter for phases completed
PHASES_COMPLETED=0
PHASES_FAILED=0

echo ""
echo "========== PHASE EXECUTION PLAN =========="
for phase in "${PHASES[@]}"; do
    echo "  [ ] $phase"
done
echo "=========================================="
echo ""

# Execute each phase
for phase in "${PHASES[@]}"; do
    SCRIPT="${phase}.sh"
    
    if [ ! -f "${SCRIPT}" ]; then
        echo "[✗] ERROR: ${SCRIPT} not found, skipping..."
        ((PHASES_FAILED++))
        continue
    fi
    
    echo ""
    echo "=========================================="
    echo "[*] Starting: ${phase} ($(date))"
    echo "=========================================="
    
    chmod +x "${SCRIPT}"
    
    if ./"${SCRIPT}"; then
        echo "[✓] ${phase} completed successfully"
        ((PHASES_COMPLETED++))
        
        # Create completion marker
        touch "${LOGDIR}/${phase}_complete.marker"
        
        # Take Timeshift snapshot after each phase
        echo "[*] Creating Timeshift snapshot: post-${phase}..."
        if sudo timeshift --create --comments "post-${phase}" 2>/dev/null; then
            echo "[✓] Snapshot created: post-${phase}"
        else
            echo "[!] WARNING: Timeshift snapshot creation failed (non-critical)"
        fi
        
    else
        echo "[✗] ERROR: ${phase} FAILED"
        ((PHASES_FAILED++))
        
        echo ""
        echo "========== FAILURE DETAILS =========="
        echo "Phase: ${phase}"
        echo "Log: ${LOGDIR}/${phase}.log"
        echo "===================================="
        echo ""
        echo "[!] Continuing to next phase (you can debug later)"
    fi
    
    # Small delay between phases
    sleep 3
done

echo ""
echo "=========================================="
echo "AEON BUILD SYSTEM - COMPLETION REPORT"
echo "=========================================="
echo "Started: ${BUILD_START}"
echo "Completed: $(date)"
echo ""
echo "Phases Completed: ${PHASES_COMPLETED}/${#PHASES[@]}"
echo "Phases Failed: ${PHASES_FAILED}"
echo ""

if [ ${PHASES_FAILED} -eq 0 ]; then
    echo "[✓] ALL PHASES COMPLETED SUCCESSFULLY!"
    echo ""
    echo "Next steps:"
    echo "  1. Reboot the system: sudo reboot"
    echo "  2. Verify all components are working"
    echo "  3. Check build log: cat ~/aeon-build/logs/master_build_log.txt"
    touch "${LOGDIR}/build_complete.marker"
else
    echo "[!] Some phases failed: ${PHASES_FAILED}"
    echo "Review logs in: ${LOGDIR}/"
    echo "Re-run failed phases manually as needed"
fi

echo ""
echo "Build Log: ${MASTER_LOG}"
echo "=========================================="
