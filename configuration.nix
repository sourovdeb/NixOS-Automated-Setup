{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  # ── Boot (UEFI / GPT) ──────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "vfat" "ext4" "exfat" ];

  # ── File systems (labels written by automate_nixos_setup.sh) ─────────────
  fileSystems."/"     = { device = "/dev/disk/by-label/NixOS"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/EFI";   fsType = "vfat"; };

  # ── Network ───────────────────────────────────────────────────────────────
  networking.hostName = "nixos-writer";
  networking.networkmanager.enable = true;

  # ── Locale / timezone ─────────────────────────────────────────────────────
  time.timeZone      = "Asia/Dhaka";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── User ──────────────────────────────────────────────────────────────────
  users.users.sourov = {
    isNormalUser  = true;
    extraGroups   = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "nixos";
  };
  security.sudo.wheelNeedsPassword = false;

  # ── Packages ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [

    # ── Writing & research ─────────────────────────────────────────────────
    obsidian         # Primary notes app (Zettelkasten / linked notes)
    zettlr           # Markdown long-form writing
    focuswriter      # Distraction-free full-screen editor
    libreoffice      # Office suite (DOCX, spreadsheets)
    pandoc           # Convert Markdown -> DOCX / PDF / HTML
    aspell aspellDicts.en
    languagetool
    hunspell hunspellDicts.en_US
    vim              # Quick text editing in terminal

    # ── Publishing ─────────────────────────────────────────────────────────
    hugo             # Static site generator (one-command publish)
    git

    # ── Podcast / audio processing ─────────────────────────────────────────
    ffmpeg           # Audio/video processing
    openai-whisper   # AI speech-to-text transcription

    # ── AI / LLM ───────────────────────────────────────────────────────────
    ollama           # Run local LLMs offline (no internet needed)

    # ── VS Code + extensions ───────────────────────────────────────────────
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        streetsidesoftware.code-spell-checker
        redhat.vscode-yaml
        tamasfe.even-better-toml
        yzhang.markdown-all-in-one
        eamodio.gitlens
      ];
    })

    # ── ADHD / focus tools ─────────────────────────────────────────────────
    gnome-pomodoro   # Pomodoro timer
    taskwarrior3     # Task management (CLI)
    timewarrior      # Time tracking
    blanket          # Ambient sounds for focus
    libnotify        # Desktop notifications (notify-send)

    # ── Automation / scripting ─────────────────────────────────────────────
    python3
    python3Packages.requests
    python3Packages.playwright
    nodejs_22        # Node.js for web automation
    wp-cli           # WordPress management from terminal

    # ── Desktop & browser ──────────────────────────────────────────────────
    firefox
    alacritty        # Fast terminal emulator
    xfce4-terminal   # Backup terminal
    thunar           # File manager
    xarchiver        # Archive manager
    evince           # PDF reader
    rofi             # Keyboard-driven app launcher
    flameshot        # Screenshot tool

    # ── Accessibility ──────────────────────────────────────────────────────
    espeak-ng        # Text-to-speech (read notes aloud)
    wmctrl           # Window management via scripts
    xdotool          # Keyboard/mouse automation

    # ── System utilities ───────────────────────────────────────────────────
    wget curl htop unzip p7zip ntfs3g nano xclip rsync
  ];

  # ── Ollama service ────────────────────────────────────────────────────────
  services.ollama = { enable = true; port = 11434; };

  # ── nix-ld: lets VS Code extensions and FHS binaries run ─────────────────
  programs.nix-ld.enable = true;

  # ── NetworkManager tray applet ────────────────────────────────────────────
  programs.nm-applet.enable = true;

  # ── Xfce desktop + i3 available ───────────────────────────────────────────
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable  = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable     = true;
  };
  services.displayManager.defaultSession = "xfce";

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    dejavu_fonts roboto noto-fonts noto-fonts-emoji liberation_ttf
  ];

  # ── Accessibility / high-DPI ─────────────────────────────────────────────
  environment.variables = {
    QT_FONT_DPI   = "120";
    GDK_SCALE     = "2";
    GDK_DPI_SCALE = "0.5";
  };

  # ── Sound ─────────────────────────────────────────────────────────────────
  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };

  # ── Power management ──────────────────────────────────────────────────────
  powerManagement.enable          = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # ── Printing / USB drives ─────────────────────────────────────────────────
  services.printing.enable  = true;
  services.gvfs.enable      = true;
  services.udisks2.enable   = true;

  # ── Hourly focus reminder (ADHD) ─────────────────────────────────────────
  systemd.timers."focus-reminder" = {
    wantedBy = [ "timers.target" ];
    partOf   = [ "focus-reminder.service" ];
    timerConfig = { OnBootSec = "1h"; OnUnitActiveSec = "1h"; };
  };
  systemd.services."focus-reminder" = {
    script = ''
      ${pkgs.libnotify}/bin/notify-send -u normal "Focus Check" "What are you working on right now?"
    '';
    serviceConfig = { User = "sourov"; Type = "oneshot"; };
  };

  # ── Daily writing backup ──────────────────────────────────────────────────
  systemd.timers."writing-backup" = {
    wantedBy = [ "timers.target" ];
    partOf   = [ "writing-backup.service" ];
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
  };
  systemd.services."writing-backup" = {
    script = ''
      ${pkgs.rsync}/bin/rsync -a /home/sourov/Documents/ /home/sourov/Documents.backup/
    '';
    serviceConfig = { User = "sourov"; Type = "oneshot"; };
  };

  # ── Writer home directories ───────────────────────────────────────────────
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
