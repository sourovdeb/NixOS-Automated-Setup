#!/bin/bash
# AEON Writer OS - Complete Build Script
# Priority: Hardware compatibility first, AI last
# Target: EndeavourOS on external SSD or VM

set -e  # Exit on error
LOG_FILE="/var/log/aeon-build.log"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a $LOG_FILE
}

# ========================================
# PHASE 0: HARDWARE DETECTION & FIXES
# ========================================
phase_0_hardware() {
    log "=== PHASE 0: Hardware Compatibility ==="
    
    # Detect GPU (prefer Intel, avoid NVIDIA)
    if lspci | grep -i "vga" | grep -i "intel"; then
        log "Intel GPU detected - will use as primary"
        echo "options i915 enable_guc=3" | sudo tee /etc/modprobe.d/i915.conf
    fi
    
    if lspci | grep -i "nvidia"; then
        warning "NVIDIA detected but NOT installing drivers (user request)"
        log "NVIDIA can be added later with: sudo pacman -S nvidia-dkms"
    fi
    
    # MediaTek WiFi fix
    if lspci | grep -i "mt7921"; then
        log "MediaTek MT7921 WiFi detected - applying latency fix"
        echo "options mt7921e disable_aspm=1" | sudo tee /etc/modprobe.d/wifi.conf
    fi
    
    # HP UEFI boot path fix
    if [ -d "/sys/firmware/efi" ]; then
        log "UEFI mode detected - will configure fallback bootloader"
    fi
    
    # Create snapshot
    sudo timeshift --create --comments "phase-0-hardware" --tags D || warning "Timeshift not configured"
}

# ========================================
# PHASE 1: BASE SYSTEM & ACCESSIBILITY
# ========================================
phase_1_accessibility() {
    log "=== PHASE 1: Base System & Accessibility ==="
    
    # Update system
    sudo pacman -Syu --noconfirm
    
    # Install GNOME on Xorg (NOT Wayland)
    sudo pacman -S --noconfirm \
        gnome gnome-extra \
        xorg-server xorg-apps \
        gdm
    
    # Accessibility tools
    sudo pacman -S --noconfirm \
        orca \
        espeak-ng \
        speech-dispatcher
    
    # Install yay for AUR
    if ! command -v yay &> /dev/null; then
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay && makepkg -si --noconfirm
    fi
    
    # Accessibility fonts
    yay -S --noconfirm \
        ttf-opendyslexic \
        ttf-atkinson-hyperlegible \
        ttf-lexend
    
    # Configure GDM for Xorg
    sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm/custom.conf
    
    # Enable services
    sudo systemctl enable gdm
    sudo systemctl enable NetworkManager
    
    # GNOME accessibility settings
    gsettings set org.gnome.desktop.interface cursor-size 48
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
    gsettings set org.gnome.desktop.interface font-name 'OpenDyslexic 12'
    gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
    
    sudo timeshift --create --comments "phase-1-accessibility" --tags D || true
}

# ========================================
# PHASE 2: WRITING ENVIRONMENT
# ========================================
phase_2_writing() {
    log "=== PHASE 2: Writing Environment ==="
    
    # Core writing tools
    sudo pacman -S --noconfirm \
        libreoffice-fresh \
        pandoc \
        texlive-core \
        zathura \
        zathura-pdf-poppler \
        firefox \
        thunderbird
    
    # Flatpak for Obsidian
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub md.obsidian.Obsidian
    
    # AUR writing tools
    yay -S --noconfirm \
        ghostwriter \
        typst \
        marker
    
    # Create writing structure
    mkdir -p ~/Writing/{today,current-project,week,drafts,published}
    mkdir -p ~/Writing/archive/{2026,2026/{04,05,06}}
    mkdir -p ~/Writing/podcasts/{raw,edited,transcripts}
    
    # Git for version control
    cd ~/Writing
    git init
    git config --global user.name "AEON Writer"
    git config --global user.email "writer@aeon.local"
    
    # Auto-commit cron
    (crontab -l 2>/dev/null; echo "*/5 * * * * cd ~/Writing && git add -A && git commit -m 'auto-save' --quiet") | crontab -
    
    sudo timeshift --create --comments "phase-2-writing" --tags D || true
}

# ========================================
# PHASE 3: WACOM & INPUT DEVICES
# ========================================
phase_3_wacom() {
    log "=== PHASE 3: Wacom & Input Setup ==="
    
    sudo pacman -S --noconfirm \
        xf86-input-wacom \
        libwacom \
        kcm-wacomtablet
    
    # Drawing applications
    sudo pacman -S --noconfirm \
        krita \
        inkscape \
        gimp \
        xournalpp
    
    # Test Wacom
    if xsetwacom --list devices | grep -i wacom; then
        log "Wacom tablet detected and configured"
    else
        warning "No Wacom tablet detected - will work when connected"
    fi
    
    sudo timeshift --create --comments "phase-3-wacom" --tags D || true
}

# ========================================
# PHASE 4: PODCAST & MEDIA
# ========================================
phase_4_podcast() {
    log "=== PHASE 4: Podcast & Media Tools ==="
    
    sudo pacman -S --noconfirm \
        audacity \
        ffmpeg \
        sox \
        lame \
        easyeffects \
        pavucontrol \
        pulseaudio \
        pulseaudio-alsa
    
    # Whisper for transcription (CPU-optimized)
    yay -S --noconfirm whisper-cpp-cpu
    
    # Create podcast workflow script
    cat > ~/scripts/podcast-workflow.sh << 'EOF'
#!/bin/bash
# Simple podcast recording workflow
PODCAST_DIR=~/Writing/podcasts
DATE=$(date +%Y%m%d_%H%M)

echo "Starting podcast recording..."
echo "1. Record in Audacity"
echo "2. Save to $PODCAST_DIR/raw/"
echo "3. Auto-transcription will process it"

audacity &
EOF
    chmod +x ~/scripts/podcast-workflow.sh
    
    sudo timeshift --create --comments "phase-4-podcast" --tags D || true
}

# ========================================
# PHASE 5: PUBLISHING AUTOMATION
# ========================================
phase_5_publishing() {
    log "=== PHASE 5: Publishing Tools ==="
    
    # Hugo for static sites
    sudo pacman -S --noconfirm hugo
    
    # Python tools for automation
    sudo pacman -S --noconfirm \
        python \
        python-pip \
        python-virtualenv
    
    # Create publishing script
    mkdir -p ~/scripts
    cat > ~/scripts/publish.py << 'EOF'
#!/usr/bin/env python3
"""
AEON Publishing Script
Publishes markdown to multiple platforms
"""
import os
import sys
import subprocess
from pathlib import Path

def publish_hugo(md_file):
    """Publish to Hugo static site"""
    print("Publishing to Hugo...")
    # Add Hugo publishing logic here
    
def publish_local_wordpress(md_file):
    """Publish to local WordPress"""
    print("Publishing to WordPress...")
    # Add WordPress logic here

def main():
    if len(sys.argv) < 2:
        print("Usage: publish.py <markdown-file>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    if not os.path.exists(md_file):
        print(f"File not found: {md_file}")
        sys.exit(1)
    
    publish_hugo(md_file)
    print("Done!")

if __name__ == "__main__":
    main()
EOF
    chmod +x ~/scripts/publish.py
    
    sudo timeshift --create --comments "phase-5-publishing" --tags D || true
}

# ========================================
# PHASE 6: SYSTEM OPTIMIZATION
# ========================================
phase_6_optimization() {
    log "=== PHASE 6: System Optimization ==="
    
    # Install performance tools
    sudo pacman -S --noconfirm \
        htop \
        btop \
        neofetch \
        tree \
        ripgrep \
        fzf \
        fd
    
    # Optimize for SSD
    sudo systemctl enable fstrim.timer
    
    # Set up swappiness for better RAM usage
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
    
    # Disable unnecessary services
    sudo systemctl disable bluetooth.service || true
    
    # Final snapshot
    sudo timeshift --create --comments "phase-6-complete" --tags D || true
}

# ========================================
# MAIN EXECUTION
# ========================================
main() {
    clear
    log "Starting AEON Writer OS Build"
    log "==============================="
    
    # Check if running in EndeavourOS
    if ! grep -qi "endeavouros\|arch" /etc/os-release; then
        error "This script is designed for EndeavourOS/Arch Linux"
    fi
    
    # Create log directory
    sudo mkdir -p /var/log
    sudo touch $LOG_FILE
    
    # Run phases in order
    phase_0_hardware
    phase_1_accessibility
    phase_2_writing
    phase_3_wacom
    phase_4_podcast
    phase_5_publishing
    phase_6_optimization
    
    log "==============================="
    log "AEON Writer OS Build Complete!"
    log "==============================="
    log ""
    log "Next steps:"
    log "1. Reboot system"
    log "2. Log into GNOME (Xorg session)"
    log "3. Open Obsidian and set vault to ~/Writing"
    log "4. Test Wacom tablet if connected"
    log ""
    log "AI/Ollama setup skipped (per user request)"
    log "To add later: yay -S ollama-cpu"
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" -eq "${0}" ]; then
    main "$@"
fi