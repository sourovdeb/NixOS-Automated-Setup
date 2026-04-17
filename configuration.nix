{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader for UEFI (GPT)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "vfat" "ext4" ];

  # File systems (labels set by partition_ssd.sh)
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

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Users — change the initialPassword after first boot with `passwd`
  users.users.sourov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };

  # Allow sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # System packages: Writing tools, VS Code, Ollama, ADHD/autism tools
  environment.systemPackages = with pkgs; [
    # Writing tools
    zettlr
    focuswriter
    libreoffice
    pandoc
    aspell
    aspellDicts.en
    languagetool

    # VS Code with useful extensions
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        streetsidesoftware.code-spell-checker
        redhat.vscode-yaml
        tamasfe.even-better-toml
      ];
    })

    # Ollama (local LLM — service also enabled below)
    ollama

    # ADHD/Autism productivity tools
    gnome-pomodoro    # Pomodoro timer
    taskwarrior3      # Task management (v3)
    timewarrior       # Time tracking
    xfce4-terminal
    falkon            # Lightweight browser

    # Utilities
    git
    wget
    curl
    htop
    unzip
  ];

  # Enable Ollama service
  services.ollama = {
    enable = true;
    port = 11434;
  };

  # Enable nix-ld so VS Code extensions (and other FHS binaries) work
  programs.nix-ld.enable = true;

  # Xfce desktop (lightweight and accessible)
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };
  services.displayManager.defaultSession = "xfce";

  # Fonts — readable, high-DPI friendly
  fonts.packages = with pkgs; [
    dejavu_fonts
    roboto
    noto-fonts
  ];

  # High-DPI / accessibility scaling
  environment.variables = {
    QT_FONT_DPI = "120";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  # Power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Enable SSH (optional, useful for remote management)
  services.openssh.enable = false;

  # Create writing directory on first activation
  system.activationScripts.setupWriter = {
    text = ''
      mkdir -p /home/sourov/Documents/Writing
      chown sourov:users /home/sourov/Documents/Writing 2>/dev/null || true
    '';
    deps = [];
  };

  # NixOS release — keep in sync with nixos-rebuild
  system.stateVersion = "24.05";
}
