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

# Use configuration.nix from scripts folder if available, otherwise use embedded
CONFIG_SRC=""
for loc in "/tmp/configuration.nix" "/mnt/windows/nixos_setup/configuration.nix"; do
    if [ -f "$loc" ]; then
        CONFIG_SRC="$loc"
        echo "Using configuration.nix from: $loc"
        break
    fi
done

if [ -n "$CONFIG_SRC" ]; then
    cp "$CONFIG_SRC" /mnt/etc/nixos/configuration.nix
else
    echo "Using embedded configuration.nix"
cat > /mnt/etc/nixos/configuration.nix << 'NIXCFG'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "vfat" "ext4" "exfat" ];

  fileSystems."/"     = { device = "/dev/disk/by-label/NixOS"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/EFI";   fsType = "vfat"; };

  networking.hostName = "nixos-writer";
  networking.networkmanager.enable = true;

  time.timeZone      = "Asia/Dhaka";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.sourov = {
    isNormalUser  = true;
    extraGroups   = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    obsidian zettlr focuswriter libreoffice pandoc vim
    aspell aspellDicts.en languagetool hunspell hunspellDicts.en_US
    hugo git ffmpeg openai-whisper ollama
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python streetsidesoftware.code-spell-checker
        redhat.vscode-yaml tamasfe.even-better-toml
        yzhang.markdown-all-in-one eamodio.gitlens
      ];
    })
    gnome-pomodoro taskwarrior3 timewarrior blanket libnotify
    python3 python3Packages.requests python3Packages.playwright
    nodejs_22 wp-cli
    firefox alacritty xfce4-terminal thunar xarchiver evince
    rofi flameshot espeak-ng wmctrl xdotool
    wget curl htop unzip p7zip ntfs3g nano xclip rsync
  ];

  services.ollama = { enable = true; port = 11434; };
  programs.nix-ld.enable = true;
  programs.nm-applet.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.xfce.enable  = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable     = true;
  };
  services.displayManager.defaultSession = "xfce";

  fonts.packages = with pkgs; [ dejavu_fonts roboto noto-fonts noto-fonts-emoji liberation_ttf ];

  environment.variables = { QT_FONT_DPI = "120"; GDK_SCALE = "2"; GDK_DPI_SCALE = "0.5"; };

  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
  services.printing.enable = true;
  services.gvfs.enable     = true;
  services.udisks2.enable  = true;

  powerManagement.enable          = true;
  powerManagement.cpuFreqGovernor = "powersave";

  systemd.timers."focus-reminder" = {
    wantedBy = [ "timers.target" ];
    partOf   = [ "focus-reminder.service" ];
    timerConfig = { OnBootSec = "1h"; OnUnitActiveSec = "1h"; };
  };
  systemd.services."focus-reminder" = {
    script = ''${pkgs.libnotify}/bin/notify-send -u normal "Focus Check" "What are you working on right now?"'';
    serviceConfig = { User = "sourov"; Type = "oneshot"; };
  };

  systemd.timers."writing-backup" = {
    wantedBy = [ "timers.target" ];
    partOf   = [ "writing-backup.service" ];
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
  };
  systemd.services."writing-backup" = {
    script = ''${pkgs.rsync}/bin/rsync -a /home/sourov/Documents/ /home/sourov/Documents.backup/'';
    serviceConfig = { User = "sourov"; Type = "oneshot"; };
  };

  system.activationScripts.setupWriter = {
    text = ''
      mkdir -p /home/sourov/Documents/Writing
      mkdir -p /home/sourov/Documents/Notes
      mkdir -p /home/sourov/Documents/Podcast
      mkdir -p /home/sourov/Sites
      chown -R sourov:users /home/sourov/Documents /home/sourov/Sites 2>/dev/null || true
    '';
    deps = [];
  };

  system.stateVersion = "24.05";
}
NIXCFG
fi

echo "configuration.nix written."

# ── Step 6: Copy utility scripts to new system ────────────────────────────────
echo ""
echo "=== Step 6: Copying utility scripts ==="
mkdir -p /mnt/home/sourov/scripts

for script in research.py post_to_wp.py; do
    for loc in "/tmp/$script" "/mnt/windows/nixos_setup/$script"; do
        if [ -f "$loc" ]; then
            cp "$loc" /mnt/home/sourov/scripts/
            echo "  Copied: $script"
            break
        fi
    done
done

chmod +x /mnt/home/sourov/scripts/*.py 2>/dev/null || true

# ── Step 7: Install NixOS ─────────────────────────────────────────────────────
echo ""
echo "=== Step 7: Installing NixOS (this takes 10-30 minutes) ==="
nixos-install --root /mnt --no-root-passwd
echo "NixOS installation complete."

# ── Step 8: Save setup log ────────────────────────────────────────────────────
echo ""
echo "=== Step 8: Saving setup log ==="
cp "$LOG" /mnt/home/sourov/nixos_setup_log.txt
echo "Log saved to /home/sourov/nixos_setup_log.txt"

echo ""
echo "=============================================="
echo " Setup complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. reboot"
echo "  2. Remove the USB when the PC restarts"
echo "  3. Select the SSD from your boot menu"
echo "  4. Log in as 'sourov' with password 'nixos'"
echo "  5. Change your password:  passwd"
echo "  6. Pull AI model:  ollama pull llama3.2"
