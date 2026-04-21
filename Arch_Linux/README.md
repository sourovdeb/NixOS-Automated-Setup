# Arch Linux Automated Setup for Writers (ADHD/Autism-Friendly)

A fully automated setup for installing Arch Linux on an external SSD with writing tools, VS Code, Ollama, and accessibility features — mirroring the NixOS setup in this repository.

## 📋 Overview

This project automates the installation of Arch Linux on an external SSD, creating a portable writing environment with:

- **Writing Tools**: Zettlr, FocusWriter, LibreOffice, Pandoc
- **Development**: VS Code with extensions, Python, Node.js
- **AI Assistance**: Ollama for local LLMs
- **Productivity**: Pomodoro timer, task management, time tracking
- **Accessibility**: Large text, high contrast, distraction-free interfaces

## 🚀 Quick Start

### Phase 1: Download Arch Linux ISO

Download the latest ISO from the [official Arch Linux website](https://archlinux.org/download/).

### Phase 2: Create Bootable USB

1. Use **Rufus** (Windows) or `dd` (Linux/Mac) with the downloaded ISO:
   ```bash
   dd bs=4M if=archlinux-*.iso of=/dev/sdX status=progress oflag=sync
   ```
2. Boot your PC from the USB drive (disable Secure Boot in UEFI settings)

### Phase 3: Install Arch Linux

Boot into the Arch Linux live environment, connect to the internet, then run:

```bash
curl -O https://raw.githubusercontent.com/sourovdeb/NixOS-Automated-Setup/main/Arch_Linux/automate_arch_setup.sh
chmod +x automate_arch_setup.sh
./automate_arch_setup.sh
```

## 📁 Project Structure

```
Arch_Linux/
├── README.md                  # This file
├── automate_arch_setup.sh     # Main installation script (run in Arch live)
├── partition_ssd.sh           # SSD partitioning helper script
├── packages.txt               # Full package list (pacman + AUR)
└── post_install.sh            # Post-installation configuration script
```

## 🔧 Prerequisites

### Windows
1. **Rufus** for USB creation
2. **External SSD** (fresh, no data)
3. **Spare USB drive** (2GB+)

### System Requirements
- UEFI firmware with Secure Boot **disabled**
- Boot order set to USB first
- Internet connection for package downloads

## 📝 Installation Phases

1. **Phase 1**: Download Arch Linux ISO
2. **Phase 2**: Create bootable USB (Rufus/`dd`)
3. **Phase 3**: Boot into Arch Linux live environment
4. **Phase 4**: Automated SSD partitioning & base install (`automate_arch_setup.sh`)
5. **Phase 5**: Post-installation setup (`post_install.sh` runs automatically)
6. **Phase 6**: First login — change password, pull Ollama model

## 🛠️ Configuration

The setup configures:

- **Bootloader**: systemd-boot for UEFI
- **Desktop**: Xfce (lightweight and accessible) + i3 available
- **Shell**: bash with sensible defaults
- **User**: `sourov` (change in the script if needed)
- **Timezone**: Asia/Dhaka
- **Services**: Ollama AI service, NetworkManager, PipeWire audio

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License — see the root LICENSE file for details.

## 🙏 Acknowledgments

- Arch Linux community and the [ArchWiki](https://wiki.archlinux.org/)
- All open-source tool developers included in this setup

---

**Note**: This setup is designed for writers with ADHD/autism but works for anyone wanting a portable, reproducible Arch Linux environment with writing tools.
