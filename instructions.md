

## **AI Instruction File: `NixOS_Automated_Setup_for_Writers.md`**
*(Save this as a `.md` file and feed it to your AI tool, e.g., Mistral Vibe.)*

```markdown
# NixOS Automated Setup for Writers (ADHD/Autism-Friendly)
**Goal**: Fully automate the installation of NixOS on an external SSD with VS Code, Ollama, and writing tools, using Playwright + Firefox for browser automation and system configuration.

**Prerequisites**:
- Windows PC with UEFI, Secure Boot disabled, and boot order set to USB first.
- Spare USB drive (8GB+).
- External SSD (brand new, no data).
- ai agent (or similar AI) with access to:
  - Web browsing (Firefox).
  - File system (to save/download files).
  - Terminal/command-line execution.
  - Playwright for browser automation.
  - "C:\Users\souro\Desktop\rufus-4.13p.exe"
  - USB - E:\
  - SSD - D:\

---

---

## **Phase 1: Download and Prepare NixOS ISO (Browser Automation)**
**Objective**: Use Playwright + Firefox to download the NixOS graphical installer ISO.

### **AI Tasks**:
1. **Open Firefox via Playwright**:
   - Use Playwright to launch Firefox in headless or headed mode (for debugging).
   - Example Playwright code (save as `download_nixos.py`):
     ```python
     from playwright.sync_api import sync_playwright

     def download_nixos_iso():
         with sync_playwright() as p:
             browser = p.firefox.launch(headless=False)
             page = browser.new_page()
             page.goto("https://nixos.org/download.html")
             # Click the download link for the latest graphical ISO (e.g., KDE Plasma)
             page.click('text="NixOS 23.11"')  # Update selector as needed
             # Wait for download to start
             with page.expect_download() as download_info:
                 page.click('text="ISO"')
             download = download_info.value
             download.save_as("C:/Users/YourName/Desktop/NixOS_Installer/nixos.iso")
             browser.close()

     if __name__ == "__main__":
         download_nixos_iso()
     ```
   - **Note**: Adjust the selector (`text="NixOS 23.11"`) to match the current download link on the page.

2. **Verify the ISO**:
   - Check that `nixos.iso` exists in `C:/Users/YourName/Desktop/NixOS_Installer/`.
   - If not, retry or manually download from [NixOS Download Page](https://nixos.org/download.html).
   or https://nixos.org/download/#nix-install-window 
---

---

## **Phase 2: Create Bootable USB (Automated)**
**Objective**: Use Rufus (Windows) or `dd` (Linux) to create a bootable USB from the ISO.

### **AI Tasks**:
#### **Option A: Rufus (Windows GUI Automation)**
1. **Download Rufus**:
   - Use Playwright to download Rufus from [https://rufus.ie/](https://rufus.ie/) and save to `C:/Users/YourName/Desktop/NixOS_Installer/rufus.exe`.

2. **Run Rufus via Command Line**:
   - Use Playwright to simulate Rufus GUI actions **or** use Rufus in command-line mode (if supported).
   - **Manual Fallback**: If automation fails, instruct the user to:
     - Open Rufus.
     - Select USB drive.
     - Select `nixos.iso`.
     - Click **Start** (DD mode).

#### **Option B: `dd` (Linux/Mac)**
   - If on Linux/Mac, run:
     ```bash
     sudo dd if=C:/Users/YourName/Desktop/NixOS_Installer/nixos.iso of=/dev/sdX bs=4M status=progress
     ```
     (Replace `/dev/sdX` with the USB device, e.g., `/dev/sdb`.)

---

---

## **Phase 3: Boot into NixOS Live USB (Manual Step)**
**Objective**: Boot the PC from the USB drive.
**Note**: This step **cannot be automated** (requires physical access to the PC).
**AI Task**:
- Instruct the user:
  1. Plug in the USB.
  2. Restart the PC.
  3. Press the boot menu key (e.g., F12) and select the USB.

---

---

## **Phase 4: Automate NixOS Installation (Partitioning + Config)**
**Objective**: Use a **pre-written NixOS configuration** and a script to automate partitioning, installation, and setup.

### **AI Tasks**:
1. **Identify the External SSD**:
   - In the NixOS live environment, run:
     ```bash
     lsblk -f
     ```
   - Save the output to `/tmp/disk_info.txt` for logging.

2. **Partition the SSD**:
   - Use `parted` or `gdisk` in a script to create:
     - Partition 1: 512MB Fat32 (EFI).
     - Partition 2: ext4 (root).
   - Example script (`partition_ssd.sh`):
     ```bash
     #!/bin/bash
     SSD="/dev/sdX"  # Replace with actual SSD (e.g., /dev/sdb)
     echo -e "o\nn\n1\n\n+512M\nt\n1\nE\nn\n2\n\n\nt\n2\n83\nw" | fdisk $SSD
     mkfs.fat -F32 ${SSD}1
     mkfs.ext4 -L NixOS ${SSD}2
     ```
   - **Note**: Replace `/dev/sdX` with the correct device (e.g., `/dev/sdb`).

3. **Mount Partitions**:
   ```bash
   mount /dev/disk/by-label/NixOS /mnt
   mkdir -p /mnt/boot/efi
   mount /dev/disk/by-label/EFI /mnt/boot/efi
   ```

4. **Generate Hardware Config**:
   ```bash
   nixos-generate-config --root /mnt
   ```

5. **Replace `/mnt/etc/nixos/configuration.nix`**:
   - Use the **pre-configured `configuration.nix`** from the previous guide (with VS Code, Ollama, writing tools, etc.).
   - Example (save as `config.nix` and copy to `/mnt/etc/nixos/`):
     ```nix
     { config, pkgs, ... }:
     {
       imports = [ ./hardware-configuration.nix ];
       boot.loader.systemd-boot.enable = true;
       boot.supportedFilesystems = [ "ntfs" "fat32" ];
       fileSystems."/" = { device = "/dev/disk/by-label/NixOS"; fsType = "ext4"; };
       fileSystems."/boot/efi" = { device = "/dev/disk/by-label/EFI"; fsType = "vfat"; };
       environment.systemPackages = with pkgs; [
         vscode nix-ld ollama zettlr focuswriter libreoffice pomotodo taskwarrior
       ];
       services.ollama.enable = true;
       services.xserver.desktopManager.xfce.enable = true;
       environment.variables = { QT_FONT_DPI = "120"; GDK_SCALE = "2"; };
       users.users.sourov = { isNormalUser = true; extraGroups = [ "wheel" "networkmanager" ]; };
     }
     ```

6. **Install NixOS**:
   ```bash
   nixos-install --root /mnt --no-channel-copy
   ```
   - **Note**: Add `--option substituters "https://cache.nixos.org" --option trusted-substituters ""` if offline.

7. **Set Root Password**:
   - Use `passwd` in the script or prompt the user.

---

---

## **Phase 5: Post-Installation Setup (Automated)**
**Objective**: Ensure all tools are ready and the system is mobile.

### **AI Tasks**:
1. **Copy the `configuration.nix` to the new system**:
   ```bash
   cp /mnt/etc/nixos/configuration.nix /etc/nixos/
   ```

2. **Rebuild the System**:
   ```bash
   nixos-rebuild switch
   ```

3. **Enable Services**:
   ```bash
   systemctl enable ollama
   systemctl start ollama
   ```

4. **Create a Setup Log**:
   - Save all commands and outputs to `/home/sourov/nixos_setup_log.txt`.

---

---

## **Phase 6: Save the Entire Process as a Reusable Script**
**Objective**: Create a **single script** (`automate_nixos_setup.sh`) that combines all steps for future use.

### **AI Tasks**:
1. **Combine all scripts** into one file:
   ```bash
   #!/bin/bash
   # automate_nixos_setup.sh
   echo "Starting NixOS automated setup..."
   # Add all commands from Phases 1-5 here
   echo "Setup complete. Log saved to /home/sourov/nixos_setup_log.txt"
   ```
2. **Save the script** to a GitHub repo or local folder for reuse.

3. **Document Dependencies**:
   - List all required tools (Playwright, Firefox, Rufus, etc.).
   - Include a `requirements.txt` for Python (e.g., `playwright`).

---

---

## **Phase 7: Future Reuse**
**Objective**: Reuse this workflow for other PCs or SSD setups.

### **AI Tasks**:
1. **Update the script** for new hardware (e.g., change `/dev/sdX`).
2. **Add error handling** (e.g., check if USB/SSD is plugged in).
3. **Test on a VM** (e.g., VirtualBox) first to validate changes.

---

---

## **Error Handling and Fallbacks**
| Step | Potential Issue | Fallback |
|------|-----------------|----------|
| ISO Download | Link broken | Manually download from [NixOS Download Page](https://nixos.org/download.html). |
| USB Creation | Rufus fails | Use `dd` or Balena Etcher. |
| Partitioning | Wrong disk selected | Double-check `lsblk -f` output. |
| NixOS Install | Missing packages | Use `--option substituters` for offline installs. |
| Ollama/VS Code | Extensions fail | Run `nixos-rebuild switch` after boot. |

---

---

## **Final Outputs**
1. **`NixOS_Automated_Setup_for_Writers.md`** (this file).
2. **`download_nixos.py`** (Playwright script).
3. **`partition_ssd.sh`** (partitioning script).
4. **`configuration.nix`** (NixOS config).
5. **`automate_nixos_setup.sh`** (full automation script).
6. **`nixos_setup_log.txt`** (log file for debugging).

Important Notes

For download_nixos.py, you must have Python and Playwright installed:
bash
Copy

pip install playwright
playwright install firefox

Github - https://github.com/sourovdeb/free_education
save the workflow here




---
---


---
---
---
#