{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot (UEFI / GPT) ──────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "vfat" "ext4" ];

  # ── File systems (labels written by partition_ssd.sh) ─────────────────────
  fileSystems."/" = { device = "/dev/disk/by-label/NixOS"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/EFI"; fsType = "vfat"; };

  # ── Network ───────────────────────────────────────────────────────────────
  networking.hostName = "nixos-writer";
  networking.networkmanager.enable = true;

  # ── Locale / timezone ─────────────────────────────────────────────────────
  time.timeZone = "Asia/Dhaka";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── User ──────────────────────────────────────────────────────────────────
  # Password is "nixos" — change it after first boot with: passwd
  users.users.sourov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };
  security.sudo.wheelNeedsPassword = false;

  # ── Packages ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [

    # ── Writing & research ─────────────────────────────────────────────────
    zettlr          # Zettelkasten / Markdown long-form writing
    focuswriter     # Distraction-free full-screen editor
    libreoffice     # Office suite (docs, spreadsheets)
    pandoc          # Convert between Markdown, DOCX, PDF, etc.
    aspell          # Spell check engine
    aspellDicts.en  # English dictionary
    languagetool    # Grammar / style checker (CLI)
    hunspell        # Additional spell check (used by LibreOffice)
    hunspellDicts.en_US

    # ── AI / LLM ───────────────────────────────────────────────────────────
    ollama          # Run local LLMs (service also enabled below)

    # ── VS Code + extensions ───────────────────────────────────────────────
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python                          # Python
        streetsidesoftware.code-spell-checker    # Spell check in editor
        redhat.vscode-yaml                        # YAML support
        tamasfe.even-better-toml                  # TOML support
        yzhang.markdown-all-in-one               # Markdown preview + shortcuts
        eamodio.gitlens                           # Git history in editor
      ];
    })

    # ── ADHD / focus tools ─────────────────────────────────────────────────
    gnome-pomodoro  # Pomodoro timer with GNOME integration
    taskwarrior3    # Task management (CLI)
    timewarrior     # Time tracking (pairs with taskwarrior)
    blanket         # Ambient sounds (focus / masking)

    # ── Desktop & browser ──────────────────────────────────────────────────
    firefox         # Main browser
    xfce4-terminal  # Terminal
    thunar          # File manager (Xfce default)
    xarchiver       # Archive manager
    evince          # PDF reader

    # ── System utilities ───────────────────────────────────────────────────
    git
    wget
    curl
    htop
    unzip
    p7zip
    ntfs3g          # Read/write Windows NTFS drives
    nano            # Simple text editor (for editing config files)
    xclip           # Clipboard CLI (useful for scripts)
  ];

  # ── Ollama service ────────────────────────────────────────────────────────
  services.ollama = {
    enable = true;
    port   = 11434;
  };

  # ── nix-ld: lets VS Code extensions & FHS binaries run ───────────────────
  programs.nix-ld.enable = true;

  # ── Xfce desktop ──────────────────────────────────────────────────────────
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };
  services.displayManager.defaultSession = "xfce";

  # NetworkManager tray applet so WiFi works from the taskbar
  programs.nm-applet.enable = true;

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    dejavu_fonts
    roboto
    noto-fonts
    noto-fonts-emoji   # Emoji support
    liberation_ttf     # Open replacements for Arial / Times / Courier
  ];

  # ── Accessibility / high-DPI scaling ─────────────────────────────────────
  environment.variables = {
    QT_FONT_DPI     = "120";
    GDK_SCALE       = "2";
    GDK_DPI_SCALE   = "0.5";
  };

  # ── Sound ─────────────────────────────────────────────────────────────────
  services.pipewire = {
    enable       = true;
    alsa.enable  = true;
    pulse.enable = true;
  };

  # ── Power management ──────────────────────────────────────────────────────
  powerManagement.enable          = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # ── Printing (optional — comment out if not needed) ───────────────────────
  services.printing.enable = true;

  # ── Auto-mount USB drives in Xfce ────────────────────────────────────────
  services.gvfs.enable  = true;
  services.udisks2.enable = true;

  # ── Writer home directory ─────────────────────────────────────────────────
  system.activationScripts.setupWriter = {
    text = ''
      mkdir -p /home/sourov/Documents/Writing
      mkdir -p /home/sourov/Documents/Notes
      chown -R sourov:users /home/sourov/Documents 2>/dev/null || true
    '';
    deps = [];
  };

  system.stateVersion = "24.05";
}
