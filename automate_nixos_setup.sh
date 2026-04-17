#!/bin/bash

# NixOS Automated Setup for Writers (ADHD/Autism-Friendly)
# Run this script inside the NixOS live USB environment.
# It will: partition the SSD, install NixOS, configure writing tools.

set -e

LOG="/tmp/nixos_setup.log"
exec > >(tee -a "$LOG") 2>&1

echo "=============================================="
echo " NixOS Automated Setup for Writers"
echo "=============================================="
echo "Log: $LOG"
echo ""

# ── Step 1: Identify the external SSD ────────────────────────────────────────
echo "=== Step 1: Identify your external SSD ==="
echo "Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -v loop
echo ""
read -p "Enter the SSD device (e.g. /dev/sdb or /dev/nvme0n1): " SSD

if [ -z "$SSD" ] || [ ! -b "$SSD" ]; then
    echo "ERROR: '$SSD' is not a valid block device. Aborting."
    exit 1
fi

lsblk "$SSD"
echo ""
echo "WARNING: ALL DATA on $SSD will be permanently erased!"
read -p "Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted by user."
    exit 0
fi

# ── Step 2: Partition and format (GPT for UEFI) ───────────────────────────────
echo ""
echo "=== Step 2: Partitioning $SSD (GPT) ==="
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

mkfs.fat -F32 -n EFI "$PART1"
mkfs.ext4 -L NixOS "$PART2"
echo "Partitioning complete."

# ── Step 3: Mount partitions ──────────────────────────────────────────────────
echo ""
echo "=== Step 3: Mounting partitions ==="
mount "$PART2" /mnt
mkdir -p /mnt/boot
mount "$PART1" /mnt/boot
echo "Partitions mounted."

# ── Step 4: Generate hardware config ─────────────────────────────────────────
echo ""
echo "=== Step 4: Generating hardware config ==="
nixos-generate-config --root /mnt

# ── Step 5: Write configuration.nix ──────────────────────────────────────────
echo ""
echo "=== Step 5: Writing configuration.nix ==="
cat > /mnt/etc/nixos/configuration.nix << 'NIXCFG'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "vfat" "ext4" ];

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  # Networking
  networking.hostName = "nixos-writer";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Asia/Dhaka";
  i18n.defaultLocale = "en_US.UTF-8";

  # User — change password after first boot with `passwd`
  users.users.sourov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };
  security.sudo.wheelNeedsPassword = false;

  # System packages
  environment.systemPackages = with pkgs; [
    # Writing tools
    zettlr focuswriter libreoffice pandoc aspell aspellDicts.en languagetool

    # VS Code with extensions
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        streetsidesoftware.code-spell-checker
        redhat.vscode-yaml
        tamasfe.even-better-toml
      ];
    })

    # Local LLM
    ollama

    # Productivity / ADHD tools
    gnome-pomodoro taskwarrior3 timewarrior
    xfce4-terminal falkon

    # Utilities
    git wget curl htop unzip
  ];

  # Ollama service
  services.ollama.enable = true;
  services.ollama.port = 11434;

  # VS Code FHS compatibility
  programs.nix-ld.enable = true;

  # Xfce desktop
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "xfce";

  # Fonts
  fonts.packages = with pkgs; [ dejavu_fonts roboto noto-fonts ];

  # High-DPI scaling
  environment.variables = {
    QT_FONT_DPI = "120";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  # Power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Create writing directory on first boot
  system.activationScripts.setupWriter = {
    text = ''
      mkdir -p /home/sourov/Documents/Writing
      chown sourov:users /home/sourov/Documents/Writing 2>/dev/null || true
    '';
    deps = [];
  };

  system.stateVersion = "24.05";
}
NIXCFG
echo "configuration.nix written."

# ── Step 6: Install NixOS ─────────────────────────────────────────────────────
echo ""
echo "=== Step 6: Installing NixOS (this takes 10-30 minutes) ==="
nixos-install --root /mnt --no-root-passwd
echo "NixOS installation complete."

# ── Step 7: Save setup log to the new system ──────────────────────────────────
echo ""
echo "=== Step 7: Saving setup log ==="
mkdir -p /mnt/home/sourov
cp "$LOG" /mnt/home/sourov/nixos_setup_log.txt
echo "Log saved to /home/sourov/nixos_setup_log.txt on the new system."

echo ""
echo "=============================================="
echo " Setup complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Reboot:   reboot"
echo "  2. Remove the USB when the PC restarts"
echo "  3. Select the SSD from your boot menu"
echo "  4. Log in as 'sourov' with password 'nixos'"
echo "  5. Change your password:  passwd"
echo "  6. Run Ollama:  ollama pull llama3.2"
