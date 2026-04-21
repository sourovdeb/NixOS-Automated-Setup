#!/bin/bash

# Partition and format an external SSD for Arch Linux (UEFI/GPT).
# WARNING: This ERASES ALL DATA on the target disk!
# Run in the Arch Linux live environment after booting from USB.

set -e

# ── Identify the SSD ──────────────────────────────────────────────────────────
echo "Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter the SSD device (e.g. /dev/sdb or /dev/nvme0n1): " SSD

if [ -z "$SSD" ] || [ ! -b "$SSD" ]; then
    echo "ERROR: '$SSD' is not a valid block device. Aborting."
    exit 1
fi

# ── Confirm ───────────────────────────────────────────────────────────────────
echo ""
echo "Target device : $SSD"
lsblk "$SSD"
echo ""
echo "WARNING: ALL DATA on $SSD will be permanently erased!"
read -p "Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# ── Partition (GPT) ───────────────────────────────────────────────────────────
echo "Creating GPT partition table..."
parted "$SSD" -- mklabel gpt

echo "Creating EFI partition (512 MB)..."
parted "$SSD" -- mkpart ESP fat32 1MB 512MB
parted "$SSD" -- set 1 esp on

echo "Creating root partition (remaining space)..."
parted "$SSD" -- mkpart primary ext4 512MB 100%

# Give the kernel a moment to see the new partitions
sleep 1
partprobe "$SSD" 2>/dev/null || true
sleep 1

# ── Detect partition names ────────────────────────────────────────────────────
# Handles both /dev/sdXN and /dev/nvme0nXpN naming
if [[ "$SSD" == *"nvme"* ]]; then
    PART1="${SSD}p1"
    PART2="${SSD}p2"
else
    PART1="${SSD}1"
    PART2="${SSD}2"
fi

# ── Format ────────────────────────────────────────────────────────────────────
echo "Formatting EFI partition as FAT32 (label: EFI)..."
mkfs.fat -F32 -n EFI "$PART1"

echo "Formatting root partition as ext4 (label: ArchLinux)..."
mkfs.ext4 -L ArchLinux "$PART2"

echo ""
echo "Done! Partition layout:"
lsblk "$SSD" -o NAME,SIZE,FSTYPE,LABEL
echo ""
echo "EFI  : $PART1  (label: EFI)"
echo "Root : $PART2  (label: ArchLinux)"
echo ""
echo "Next steps:"
echo "  mount $PART2 /mnt"
echo "  mkdir -p /mnt/boot"
echo "  mount $PART1 /mnt/boot"
echo "  pacstrap /mnt base linux linux-firmware"
echo "  genfstab -U /mnt >> /mnt/etc/fstab"
echo "  arch-chroot /mnt"
