#!/bin/bash

# Arch Linux Post-Installation Configuration for Writers (ADHD/Autism-Friendly)
# Run this script inside the arch-chroot environment, or as root after first boot.
# It configures locale, users, desktop, writing tools, and system services.

set -e

LOG="/tmp/arch_post_install.log"
exec > >(tee -a "$LOG") 2>&1

echo "=============================================="
echo " Arch Linux Post-Installation Setup"
echo "=============================================="
echo "Log: $LOG"
echo ""

# ── Step 1: Timezone & locale ─────────────────────────────────────────────────
echo "=== Step 1: Timezone & locale ==="
ln -sf /usr/share/zoneinfo/Asia/Dhaka /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Timezone and locale configured."

# ── Step 2: Hostname & hosts ──────────────────────────────────────────────────
echo ""
echo "=== Step 2: Hostname ==="
echo "arch-writer" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch-writer.localdomain arch-writer
EOF
echo "Hostname set to arch-writer."

# ── Step 3: Create user ───────────────────────────────────────────────────────
echo ""
echo "=== Step 3: Creating user 'sourov' ==="
if ! id sourov &>/dev/null; then
    useradd -m -G wheel,audio,video,networkmanager -s /bin/bash sourov
    echo ""
    echo "Set a password for user 'sourov':"
    passwd sourov
    echo "User 'sourov' created."
else
    echo "User 'sourov' already exists, skipping."
fi

# Allow wheel group to use sudo without password (convenience for initial setup).
# WARNING: Remove or comment out this line after first login to re-enable password
# prompts for sudo — keeping it passwordless is a security risk in a shared environment.
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# ── Step 4: Install systemd-boot ─────────────────────────────────────────────
echo ""
echo "=== Step 4: Installing systemd-boot ==="
bootctl install
cat > /boot/loader/loader.conf << 'EOF'
default arch.conf
timeout 3
console-mode max
editor no
EOF

PARTUUID=$(blkid -s PARTUUID -o value "$(findmnt -no SOURCE /)")
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux (Writer)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=${PARTUUID} rw quiet splash
EOF
echo "systemd-boot installed."

# ── Step 5: Enable core services ─────────────────────────────────────────────
echo ""
echo "=== Step 5: Enabling core services ==="
systemctl enable NetworkManager
systemctl enable lightdm
systemctl enable fstrim.timer
echo "Core services enabled."

# ── Step 6: Configure pacman mirrors ─────────────────────────────────────────
echo ""
echo "=== Step 6: Ranking mirrors ==="
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null || \
    echo "  reflector not available yet, skipping mirror ranking."

# ── Step 7: Install AUR helper (yay) ─────────────────────────────────────────
echo ""
echo "=== Step 7: Installing yay (AUR helper) ==="
if ! command -v yay &>/dev/null; then
    sudo -u sourov bash -c '
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd /tmp
        rm -rf yay
    '
    echo "yay installed."
else
    echo "yay already installed, skipping."
fi

# ── Step 8: Install packages ──────────────────────────────────────────────────
echo ""
echo "=== Step 8: Installing packages ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_FILE="$SCRIPT_DIR/packages.txt"

if [ -f "$PKG_FILE" ]; then
    # Separate pacman packages from AUR packages
    # Lines with [AUR] comment are AUR packages; install their package name
    PACMAN_PKGS=()
    AUR_PKGS=()
    while IFS= read -r line; do
        # Skip empty lines and pure comment lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        # Extract package name (first word before any spaces/comments)
        pkg=$(echo "$line" | awk '{print $1}')
        if echo "$line" | grep -q '\[AUR\]'; then
            AUR_PKGS+=("$pkg")
        else
            PACMAN_PKGS+=("$pkg")
        fi
    done < "$PKG_FILE"

    echo "  Installing ${#PACMAN_PKGS[@]} pacman packages..."
    pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}" 2>/dev/null || \
        echo "  Some pacman packages may have failed — check the log."

    echo "  Installing ${#AUR_PKGS[@]} AUR packages..."
    sudo -u sourov yay -S --needed --noconfirm "${AUR_PKGS[@]}" 2>/dev/null || \
        echo "  Some AUR packages may have failed — check the log."
else
    echo "  packages.txt not found at $PKG_FILE, skipping package install."
fi

# ── Step 9: Desktop environment tweaks ───────────────────────────────────────
echo ""
echo "=== Step 9: Desktop tweaks ==="

# High-DPI / accessibility environment variables
mkdir -p /etc/environment.d
cat > /etc/environment.d/90-writer-dpi.conf << 'EOF'
QT_FONT_DPI=120
GDK_SCALE=2
GDK_DPI_SCALE=0.5
EOF

# LightDM default session
sed -i 's/^#user-session=.*/user-session=xfce/' /etc/lightdm/lightdm.conf 2>/dev/null || true
echo "Desktop tweaks applied."

# ── Step 10: Create writer home directories ───────────────────────────────────
echo ""
echo "=== Step 10: Creating writer directories ==="
sudo -u sourov mkdir -p \
    /home/sourov/Documents/Writing \
    /home/sourov/Documents/Notes \
    /home/sourov/Documents/Podcast \
    /home/sourov/Sites \
    /home/sourov/scripts
echo "Writer directories created."

# ── Step 11: Hourly focus reminder (systemd user timer) ──────────────────────
echo ""
echo "=== Step 11: Setting up focus reminder timer ==="
TIMER_DIR="/home/sourov/.config/systemd/user"
mkdir -p "$TIMER_DIR"

cat > "$TIMER_DIR/focus-reminder.service" << 'EOF'
[Unit]
Description=ADHD Focus Reminder

[Service]
Type=oneshot
ExecStart=/usr/bin/notify-send -u normal "Focus Check" "What are you working on right now?"
EOF

cat > "$TIMER_DIR/focus-reminder.timer" << 'EOF'
[Unit]
Description=Hourly ADHD Focus Reminder

[Timer]
OnBootSec=1h
OnUnitActiveSec=1h

[Install]
WantedBy=timers.target
EOF

chown -R sourov:sourov "$TIMER_DIR"
sudo -u sourov systemctl --user enable focus-reminder.timer 2>/dev/null || true
echo "Focus reminder timer configured."

# ── Step 12: Daily writing backup (systemd user timer) ───────────────────────
echo ""
echo "=== Step 12: Setting up writing backup timer ==="
cat > "$TIMER_DIR/writing-backup.service" << 'EOF'
[Unit]
Description=Daily Writing Backup

[Service]
Type=oneshot
ExecStart=/usr/bin/rsync -a /home/sourov/Documents/ /home/sourov/Documents.backup/
EOF

cat > "$TIMER_DIR/writing-backup.timer" << 'EOF'
[Unit]
Description=Daily Writing Backup

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

chown -R sourov:sourov "$TIMER_DIR"
sudo -u sourov systemctl --user enable writing-backup.timer 2>/dev/null || true
echo "Writing backup timer configured."

# ── Step 13: Ollama service ───────────────────────────────────────────────────
echo ""
echo "=== Step 13: Configuring Ollama ==="
if command -v ollama &>/dev/null; then
    cat > /etc/systemd/system/ollama.service << 'EOF'
[Unit]
Description=Ollama Local LLM Service
After=network.target

[Service]
Type=simple
User=sourov
ExecStart=/usr/bin/ollama serve
Restart=on-failure
Environment=OLLAMA_HOST=127.0.0.1:11434

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable ollama
    echo "Ollama service enabled."
else
    echo "  Ollama not found, skipping service setup."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=============================================="
echo " Post-installation complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. exit   (leave chroot if applicable)"
echo "  2. reboot"
echo "  3. Remove the USB when the PC restarts"
echo "  4. Select the SSD from your boot menu"
echo "  5. Log in as 'sourov' with password 'arch'"
echo "  6. Change your password:  passwd"
echo "  7. Pull AI model:  ollama pull llama3.2"
echo ""
echo "Log saved to: $LOG"
