# NixOS Automated Setup for Writers - Video Script for AI Narration

## Introduction (0:00 - 0:30)
- "Hello, Sourov. I will now guide you through the fully automated setup of NixOS on your external SSD."
- "This process will use Playwright and Firefox to download files, and scripts to handle the rest."
- "You only need to intervene for physical actions, like plugging in the USB or restarting your PC."

## Phase 1: Download NixOS ISO (0:30 - 2:00)
- "First, I will use Playwright and Firefox to download the latest NixOS graphical installer ISO."
- "I am now launching Firefox and navigating to the NixOS download page."
- "I am clicking the download link for the NixOS 23.11 ISO with a graphical installer."
- "The ISO is now downloading to your Desktop in a folder called NixOS_Installer."
- "Download complete. The file is saved as nixos.iso."

## Phase 2: Create Bootable USB (2:00 - 4:00)
- "Next, I will create a bootable USB drive using Rufus."
- "I am now downloading Rufus from rufus.ie."
- "Please plug in your spare USB drive (8GB or larger)."
- "I am opening Rufus and selecting the NixOS ISO."
- "I am starting the USB creation process in DD mode. This may take a few minutes."
- "USB creation complete. Your bootable NixOS installer is ready."

## Phase 3: Boot into NixOS Live USB (4:00 - 5:00)
- "Now, please restart your PC and boot from the USB drive."
- "Press the boot menu key (usually F12, F9, or ESC) and select the USB."
- "The NixOS live environment will load with a graphical interface."
- "Once loaded, open a terminal and run 'lsblk -f' to identify your external SSD."

## Phase 4: Partition the SSD (5:00 - 7:00)
- "I will now run the partition_ssd.sh script to prepare your external SSD."
- "Please confirm the SSD device (e.g., /dev/sdb) when prompted."
- "The script will create two partitions: a 512MB Fat32 partition for EFI, and an ext4 partition for NixOS."
- "Partitioning complete. Your SSD is now ready for installation."

## Phase 5: Install NixOS (7:00 - 15:00)
- "I will now start the NixOS installation with your pre-configured settings."
- "This includes VS Code, Ollama, Zettlr, FocusWriter, and all ADHD/autism-friendly tools."
- "The installation may take 10-30 minutes. I will notify you when it is done."
- "Installation complete! Your NixOS system is now ready on the external SSD."

## Phase 6: First Boot (15:00 - 17:00)
- "Please unplug the USB and restart your PC."
- "Select your external SSD from the boot menu if it does not boot automatically."
- "Log in with your username and password."
- "Your system is now ready with all tools pre-installed."

## Phase 7: Verify Setup (17:00 - 20:00)
- "Let's verify everything is working."
- "Open VS Code, Ollama, Zettlr, and FocusWriter to confirm they are installed."
- "Test Ollama by running 'ollama pull llama3.2:3b' in the terminal."
- "All tools are working correctly. Your mobile NixOS setup is complete!"

## Conclusion (20:00 - 21:00)
- "Congratulations, Sourov! Your NixOS system is now fully set up on your external SSD."
- "You can now use this SSD on any UEFI PC by selecting it from the boot menu."
- "All your files and settings will persist across reboots and on different computers."
- "If you need to reuse this process in the future, simply run the automate_nixos_setup.sh script."
- "Thank you for using this automated workflow. If you have any questions, let me know!"