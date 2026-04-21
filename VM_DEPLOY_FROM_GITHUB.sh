#!/bin/bash
# DEPLOY TO VM FROM GITHUB
# Run this script inside the VM to get all Aeon build files

echo "======================================"
echo "DEPLOYING AEON BUILD TO VM"
echo "======================================"
echo ""

# Create directory
mkdir -p ~/aeon-build
cd ~/aeon-build || exit 1

echo "[*] Cloning from GitHub..."
# Clone the repository
git clone -b aeon-writer-os https://github.com/sourovdeb/NixOS-Automated-Setup.git .

echo "[*] Making scripts executable..."
# Make all scripts executable
chmod +x linux_scripts/*.sh

echo "[*] Creating logs directory..."
mkdir -p logs

echo ""
echo "✅ DEPLOYMENT COMPLETE"
echo ""
echo "Available scripts:"
ls -la linux_scripts/

echo ""
echo "Quick start options:"
echo ""
echo "1. Phase A only:"
echo "   ./linux_scripts/01_phase_a_accessibility.sh"
echo ""
echo "2. Auto-service (Phase A):"
echo "   sudo cp linux_scripts/aeon-phase-a.service /etc/systemd/user/"
echo "   systemctl --user daemon-reload"
echo "   systemctl --user enable --now aeon-phase-a.service"
echo ""
echo "3. Full build (All phases A-K):"
echo "   ./linux_scripts/99_master_auto_execute.sh"
echo ""
echo "4. Apply nomodeset first (recommended):"
echo "   sudo nano /etc/default/grub"
echo "   # Add 'nomodeset' to GRUB_CMDLINE_LINUX_DEFAULT"
echo "   sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo "   sudo reboot"
echo ""
echo "Ready for Phase A execution!"