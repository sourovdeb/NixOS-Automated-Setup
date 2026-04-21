#!/bin/bash

# Arch Linux Automated Setup for Writers (ADHD/Autism-Friendly)
# Run this script inside the Arch Linux live USB environment.
# It will: partition the SSD, install the base system, and run post-install config.

set -e

LOG="/tmp/arch_setup.log"
exec > >(tee -a "$LOG") 2>&1

echo "=============================================="
echo " Arch Linux Automated Setup for Writers"
echo "=============================================="
echo "Log: $LOG"
echo ""

# ── Step 1: Verify UEFI boot mode ────────────────────────────────────────────
echo "=== Step 1: Verify UEFI boot mode ==="
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI mode confirmed."
else
    echo "ERROR: Not booted in UEFI mode. Disable CSM in BIOS and retry."
    exit 1
fi

# ── Step 2: Connect to the internet ──────────────────────────────────────────
echo ""
echo "=== Step 2: Internet connectivity ==="
if ping -c1 archlinux.org &>/dev/null; then
    echo "Internet connection confirmed."
else
    echo "No internet detected. Attempting to bring up NetworkManager..."
    systemctl start NetworkManager
    sleep 3
    if ! ping -c1 archlinux.org &>/dev/null; then
        echo "ERROR: No internet connection. Connect via 'nmtui' or Ethernet and rerun."
        exit 1
    fi
fi

# ── Step 3: Identify the external SSD ────────────────────────────────────────
echo ""
echo "=== Step 3: Identify your external SSD ==="
echo "--- All disks ---"
lsblk -dpno NAME,SIZE,MODEL | grep -v loop
echo ""
echo "TIP: Your target SSD is the largest non-USB disk above."
echo "     Do NOT select the live USB itself."
echo ""
read -p "Enter the SSD device (e.g. /dev/sdb or /dev/nvme0n1): " SSD

if [ -z "$SSD" ] || [ ! -b "$SSD" ]; then
    echo "ERROR: '$SSD' is not a valid block device. Aborting."
    exit 1
fi

echo ""
echo "You selected: $SSD"
lsblk "$SSD"
echo ""
echo "WARNING: ALL DATA on $SSD will be permanently erased!"
read -p "Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted by user."
    exit 0
fi

# ── Step 4: Partition and format (GPT for UEFI) ───────────────────────────────
echo ""
echo "=== Step 4: Partitioning $SSD (GPT) ==="
parted "$SSD" -- mklabel gpt
parted "$SSD" -- mkpart ESP fat32 1MB 512MB
parted "$SSD" -- set 1 esp on
parted "$SSD" -- mkpart primary ext4 512MB 100%

sleep 1
partprobe "$SSD" 2>/dev/null || true
sleep 1

if [[ "$SSD" == *"nvme"* ]]; then
    PART1="${SSD}p1"
    PART2="${SSD}p2"
else
    PART1="${SSD}1"
    PART2="${SSD}2"
fi

echo "Formatting EFI partition as FAT32 (label: EFI)..."
mkfs.fat -F32 -n EFI "$PART1"

echo "Formatting root partition as ext4 (label: ArchLinux)..."
mkfs.ext4 -L ArchLinux "$PART2"
echo "Partitioning complete."

# ── Step 5: Mount partitions ──────────────────────────────────────────────────
echo ""
echo "=== Step 5: Mounting partitions ==="
mount "$PART2" /mnt
mkdir -p /mnt/boot
mount "$PART1" /mnt/boot
echo "Partitions mounted."

# ── Step 6: Update mirrors and install base system ────────────────────────────
echo ""
echo "=== Step 6: Ranking mirrors ==="
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
echo "Mirrors updated."

echo ""
echo "=== Step 6b: Installing base system (pacstrap) ==="
echo "This may take several minutes..."
pacstrap /mnt base base-devel linux linux-firmware networkmanager \
    sudo git curl wget nano reflector
echo "Base system installed."

# ── Step 7: Generate fstab ────────────────────────────────────────────────────
echo ""
echo "=== Step 7: Generating fstab ==="
genfstab -U /mnt >> /mnt/etc/fstab
echo "fstab generated."

# ── Step 8: Copy setup scripts into chroot ───────────────────────────────────
echo ""
echo "=== Step 8: Copying setup scripts ==="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p /mnt/root/arch_setup

for f in post_install.sh packages.txt; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        cp "$SCRIPT_DIR/$f" /mnt/root/arch_setup/
        echo "  Copied: $f"
    else
        # Try common alternative locations
        for loc in "/tmp/$f" "/root/$f"; do
            if [ -f "$loc" ]; then
                cp "$loc" /mnt/root/arch_setup/
                echo "  Copied: $f (from $loc)"
                break
            fi
        done
    fi
done

chmod +x /mnt/root/arch_setup/post_install.sh 2>/dev/null || true
echo "Setup scripts ready in /root/arch_setup/."

# ── Step 9: Run post-install inside chroot ───────────────────────────────────
echo ""
echo "=== Step 9: Running post-install configuration (chroot) ==="
arch-chroot /mnt /root/arch_setup/post_install.sh

# ── Step 10: Save setup log ───────────────────────────────────────────────────
echo ""
echo "=== Step 10: Saving setup log ==="
cp "$LOG" /mnt/home/sourov/arch_setup_log.txt 2>/dev/null || \
    cp "$LOG" /mnt/root/arch_setup_log.txt
echo "Log saved."

echo ""
echo "=============================================="
echo " Setup complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. umount -R /mnt"
echo "  2. reboot"
echo "  3. Remove the USB when the PC restarts"
echo "  4. Select the SSD from your boot menu"
echo "  5. Log in as 'sourov' with password 'arch'"
echo "  6. Change your password:  passwd"
echo "  7. Pull AI model:  ollama pull llama3.2"
