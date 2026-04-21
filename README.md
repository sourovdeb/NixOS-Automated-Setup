# NixOS Automated Setup for Writers (ADHD/Autism-Friendly)

A fully automated setup for installing NixOS on an external SSD with writing tools, VS Code, Ollama, and accessibility features.

## 📋 Overview

This project automates the installation of NixOS on an external SSD, creating a portable writing environment with:

- **Writing Tools**: Zettlr, FocusWriter, LibreOffice, Pandoc
- **Development**: VS Code with extensions, Nix-LD for compatibility
- **AI Assistance**: Ollama for local LLMs
- **Productivity**: Pomodoro timer, task management, time tracking
- **Accessibility**: Large text, high contrast, distraction-free interfaces

## 🚀 Quick Start

### Phase 1: Download NixOS ISO
```bash
python download_nixos_playwright.py
```
*Requires: Python 3.8+, Playwright, Firefox*

### Phase 2: Create Bootable USB
1. Use **Rufus** (Windows) or `dd` (Linux/Mac) with the downloaded ISO
2. Boot your PC from the USB drive

### Phase 3: Install NixOS
In the NixOS live environment:
```bash
curl -O https://raw.githubusercontent.com/sourovdeb/NixOS-Automated-Setup/main/automate_nixos_setup.sh
chmod +x automate_nixos_setup.sh
./automate_nixos_setup.sh
```

## 📁 Project Structure

```
├── download_nixos_playwright.py    # Playwright script to download NixOS ISO
├── automate_nixos_setup.sh         # Main installation script (run in NixOS live)
├── partition_ssd.sh                # SSD partitioning helper script
├── configuration.nix               # NixOS configuration with all tools
├── instructions.md                 # Complete step-by-step guide
├── video_script.md                 # AI narration script for video
├── .env                            # WordPress API credentials
├── README.md                       # This file
└── Arch_Linux/                     # Arch Linux equivalent setup
    ├── README.md                   # Arch Linux overview and quick-start
    ├── automate_arch_setup.sh      # Main installation script (run in Arch live)
    ├── partition_ssd.sh            # SSD partitioning helper for Arch
    ├── packages.txt                # Full package list (pacman + AUR)
    └── post_install.sh             # Post-installation configuration script
```

## 🔧 Prerequisites

### Windows
1. **Python 3.8+** with Playwright:
   ```bash
   pip install playwright
   playwright install firefox
   ```
2. **Rufus** for USB creation
3. **External SSD** (fresh, no data)
4. **Spare USB drive** (8GB+)

### System Requirements
- UEFI firmware with Secure Boot disabled
- Boot order set to USB first
- Internet connection for downloads

## 📝 Detailed Instructions

See [instructions.md](instructions.md) for complete step-by-step guide with all 7 phases:

1. **Phase 1**: Download NixOS ISO (Playwright automation)
2. **Phase 2**: Create bootable USB (Rufus/`dd`)
3. **Phase 3**: Boot into NixOS live environment
4. **Phase 4**: Automated SSD partitioning & installation
5. **Phase 5**: Post-installation setup
6. **Phase 6**: Create reusable automation script
7. **Phase 7**: Future reuse and testing

## 🛠️ Configuration

The `configuration.nix` file includes:

- **Bootloader**: systemd-boot for UEFI
- **Desktop**: Xfce (lightweight and accessible)
- **Tools**: Complete writing and development stack
- **Accessibility**: Large text, high DPI scaling
- **Services**: Ollama AI service, network management

## 🌐 WordPress Integration

Use the browser_bot tool to post this workflow to WordPress:

```bash
cd ../browser_bot
python browser_bot.py --mode blog --title "NixOS Automated Setup" --content "Full automation guide..."
```

*Requires `.env` file with WordPress credentials*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- NixOS community for the amazing package manager
- Playwright team for browser automation
- All open-source tool developers included in this setup

## 📧 Contact

For issues or questions, please open an issue on GitHub or contact the maintainer.

---

**Note**: This setup is designed for writers with ADHD/autism but works for anyone wanting a portable, reproducible NixOS environment with writing tools.