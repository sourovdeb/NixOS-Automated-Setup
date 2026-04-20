# AEON Writer OS — Phase 0 Report
> **Windows Preparation & Staging**  
> Completed: 2026-04-20  
> Agent: GitHub Copilot (Claude Opus 4.6)

---

## 1. Executive Summary

Phase 0 prepared the Windows environment for EndeavourOS installation and is now **ready for Phase 1**. The boot USB has been created, Secure Boot is confirmed off, and the external SSD is connected and visible to Windows.

| Category | Done | Remaining |
|----------|------|-----------|
| Software downloads | 3/3 | — |
| System config changes | 2/2 | — |
| Tool installs | 2/2 | — |
| VS Code extensions | 20/20 | — |
| ISO integrity verification | 1/1 | — |
| Physical hardware tasks | 3/3 | — |

---

## 2. Actions Completed

### 2.1 Fast Startup Disabled
- **Before:** `HiberbootEnabled = 1`
- **After:** `HiberbootEnabled = 0`
- **Method:** Elevated batch script → `reg add HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 0 /f`
- **Why:** Fast Startup locks NTFS partitions, corrupts dual-boot, and interferes with UEFI firmware handoff

### 2.2 Rufus Installed
- **Version:** 4.13
- **Method:** `winget install Rufus.Rufus`
- **Purpose:** Primary USB creation tool used for the final bootable installer

### 2.3 EndeavourOS ISO Downloaded & Verified
- **File:** `EndeavourOS_Titan-2026.03.06.iso`
- **Size:** 3,527.8 MB (3,699,195,904 bytes)
- **Source:** mirror.alpix.eu (official EndeavourOS mirror)
- **Integrity:** SHA512 verified ✅
  ```
  Expected:  31fb24bbca430aa6dc975f6b68f4e51432f7695e08a224fe2b9af984ac270c6f456482724188f7b437107ec351882cb63151124f9b35de294452921326dece6d
  Computed:  31FB24BBCA430AA6DC975F6B68F4E51432F7695E08A224FE2B9AF984AC270C6F456482724188F7B437107EC351882CB63151124F9B35DE294452921326DECE6D
  Match:     YES
  ```

### 2.4 Ventoy Downloaded & Extracted
- **File:** `ventoy-1.1.11-windows.zip` (15.9 MB)
- **Source:** GitHub releases (official)
- **Extracted to:** `downloads/ventoy/ventoy-1.1.11/`
- **Key executable:** `Ventoy2Disk.exe`
- **Status:** Kept as a fallback utility. Repeated USB instability made Rufus the successful method for the final boot media.

### 2.5 GParted Live ISO Downloaded
- **File:** `gparted-live-1.8.1-3-amd64.iso`
- **Size:** 619 MB
- **Source:** SourceForge (official GParted distribution)
- **Purpose:** Emergency partition rescue. Supports UEFI Secure Boot.
- **Note:** Conditional — EndeavourOS's Calamares installer handles normal partitioning. GParted is a safety net only.

### 2.6 Bootable EndeavourOS USB Created
- **Method:** Rufus in **ISO Image mode (Recommended)**
- **Target device:** Verbatim removable USB drive
- **Verified result:** Volume label `ARCH`, FAT32, 29.3 GB, EFI boot file present at `D:\EFI\BOOT\BOOTx64.EFI`
- **Status:** Ready for first boot into the live environment

### 2.7 Project Reports Backed Up to USB
- **Backup location:** `D:\AEON_Backup`
- **Files copied:** build plan, anticipated issues, assistive tools research, software inventory, hardware info, and the Phase 0 report
- **Purpose:** Offline recovery and continuity during installation

### 2.8 VS Code Extensions Installed
20 extensions total (9 new + 11 pre-existing):

| Extension | Status | Purpose |
|-----------|--------|---------|
| `bierner.markdown-preview-github-styles` | ✅ New | GitHub-style MD preview |
| `dbaeumer.vscode-eslint` | Pre-existing | JS/TS linting |
| `esbenp.prettier-vscode` | ✅ New | Code formatting |
| `foxundermoon.shell-format` | ✅ New | Shell script formatting |
| `github.copilot-chat` | Pre-existing | AI pair programming |
| `github.vscode-pull-request-github` | Pre-existing | GitHub PR management |
| `ms-azuretools.vscode-containers` | Pre-existing | Container tools |
| `ms-azuretools.vscode-docker` | ✅ New | Docker integration |
| `ms-python.debugpy` | Pre-existing | Python debugging |
| `ms-python.python` | Pre-existing | Python language support |
| `ms-python.vscode-pylance` | Pre-existing | Python type checking |
| `ms-python.vscode-python-envs` | Pre-existing | Python environments |
| `ms-vscode-remote.remote-ssh` | Pre-existing | Remote SSH |
| `ms-vscode-remote.remote-ssh-edit` | Pre-existing | Remote SSH editing |
| `ms-vscode.remote-explorer` | Pre-existing | Remote explorer |
| `redhat.vscode-yaml` | ✅ New | YAML support |
| `shd101wyy.markdown-preview-enhanced` | ✅ New | Advanced MD preview |
| `streetsidesoftware.code-spell-checker` | ✅ New | Spell checking |
| `timonwong.shellcheck` | ✅ New | Shell script linting |
| `yzhang.markdown-all-in-one` | ✅ New | MD editing tools |

---

## 3. System Dependency Audit

### 3.1 Existing Tools (already installed on Windows)

| Tool | Version | Relevant to AEON? |
|------|---------|-------------------|
| Git | 2.53.0 | Yes — version control for dotfiles/configs |
| Python | 3.11.9 | Yes — scripts, Board Screen GTK app (needs elevation to run) |
| Node.js | 25.8.1 (via fnm) | Partial — some tools use it, not core to Linux build |
| Pandoc | 3.9.0.2 | Yes — document conversion pipeline |
| FFmpeg | 8.1 | Yes — podcast/audio processing |
| Ollama | 0.21.0 | Yes — local AI (same version will be used on Linux) |
| PowerShell | 7.5.5 | Windows only |
| Rust/Cargo | Installed (via rustup) | Yes — needed for some AUR builds |
| DaVinci Resolve | 20.3 | Reference — not on Linux build |
| VirtualBox | 7.2.6 | Not needed for bare-metal install |
| WSL | 2.6.3 | Not needed — going bare-metal |
| Wacom Driver | 6.4.11 | Windows only — Linux uses libwacom |
| NVIDIA Driver | 591.74 | Windows only — Linux uses nvidia-open |

### 3.2 Key Observations
- **Python 3.11.9** requires elevation to run (app execution alias issue). On Linux this won't be a problem.
- **Node.js** managed via `fnm` — good practice, same approach works on Linux.
- **Ollama 0.21.0** already installed — user has experience with local AI. Linux config will be similar.
- **Rust toolchain** present — beneficial for compiling AUR packages that require Rust (e.g., `helix-editor`).
- **No Docker on Windows** — will be fresh install on Linux via `docker` + `docker-compose`.

---

## 4. Files Over 500 MB — Evaluation

| File | Size | Indispensable? | Action |
|------|------|---------------|--------|
| EndeavourOS ISO | 3,528 MB | **YES** — the OS itself | Delete after the first successful USB boot |
| GParted Live ISO | 619 MB | **CONDITIONAL** — safety net only | Delete after Phase 2 succeeds |

**Total download footprint:** ~4,163 MB  
**Disk space remaining:** ~203 GB free (ample)  
**Post-USB-creation savings:** Delete originals → reclaim ~4.1 GB

---

## 5. Downloads Inventory

```
C:\Users\souro\Desktop\Arch_Linus\downloads\
├── EndeavourOS_Titan-2026.03.06.iso          3,527.8 MB  ✅ SHA512 verified
├── EndeavourOS_Titan-2026.03.06.iso.sha512       0.1 KB  ✅ checksum file
├── gparted-live-1.8.1-3-amd64.iso              619.0 MB  ✅ downloaded
├── ventoy-1.1.11-windows.zip                    15.9 MB  ✅ archive
└── ventoy/ventoy-1.1.11/                                  ✅ extracted
    ├── Ventoy2Disk.exe                           0.6 MB
    ├── VentoyPlugson.exe                         0.4 MB
    ├── VentoyVlnk.exe                            0.1 MB
    ├── altexe/
    ├── boot/
    └── plugin/
```

---

## 6. Workspace Files

```
C:\Users\souro\Desktop\Arch_Linus\
├── ai_agent_instruction.md          Master build blueprint (1300+ lines)
├── windows_hardware_info.txt        Hardware dump (UTF-16)
├── BUILD_PLAN.md                    Phase-by-phase build plan
├── ANTICIPATED_ISSUES.md            Hardware issues + fixes (updated)
├── ASSISTIVE_TOOLS_RESEARCH.md      MIT/Stanford/Yale research
├── SOFTWARE_INVENTORY.md            Complete package inventory (~96 components)
├── PHASE_0_REPORT.md                ← This file
└── downloads/                       ISOs + Ventoy (see §5)
```

---

## 7. Next Boot Steps (User Action Required)

### 7.1 Boot the Live USB
1. Leave the external JMicron SSD connected
2. Reboot the laptop
3. Open the HP boot menu and choose the USB drive in **UEFI** mode
4. Start the EndeavourOS live session

### 7.2 Install to the External SSD
- The installer target drive is the **JMicron Tech 465.8 GB** external SSD
- Windows currently shows it as:
  - Partition 1: 0.5 GB System
  - Partition 2: 465.3 GB Unknown
- This is acceptable for the installer. Leave it untouched in Windows and select it from Calamares during install

### 7.3 Preserve the Internal Windows Drive
- Keep the internal NVMe drive (**Disk 0 / C:**) unchanged
- Only the external SSD should be selected as the Linux install destination

---

## 8. Risk Register (Carried to Phase 1)

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | HP hardcoded UEFI boot path | HIGH | Copy systemd-boot to `\EFI\BOOT\BOOTx64.EFI` |
| 2 | Alder Lake suspend freeze | MEDIUM | Kernel param `i915.enable_dc=0` if triggered |
| 3 | NVIDIA GSP firmware hangs | MEDIUM | `NVreg_EnableGpuFirmware=0` in modprobe.d |
| 4 | MT7921 WiFi high latency | MEDIUM | `options mt7921e disable_aspm=1` |
| 5 | Intel PSR screen flicker | LOW | `i915.enable_psr=0` if triggered |
| 6 | Optimus complexity | MEDIUM | PRIME render offload, test with `prime-run` |
| 7 | External SSD layout not readable by Windows | LOW | Expected for non-Windows or unassigned partitions; installer can still use the disk |

---

## 9. Phase 0 → Phase 1 Transition Criteria

All must be true before starting Phase 1:

- [x] EndeavourOS ISO downloaded and SHA512 verified
- [x] Ventoy downloaded and extracted
- [x] GParted Live ISO downloaded (safety net)
- [x] Fast Startup disabled
- [x] Rufus installed and used successfully
- [x] VS Code extensions ready
- [x] System audit complete
- [x] **Bootable USB created and verified**
- [x] **Secure Boot disabled**
- [x] **External SSD connected and online**

**Phase 0 software completion: 100%**  
**Phase 0 overall completion: 100%**

---

*Report generated automatically. Next report: PHASE_1_REPORT.md (after EndeavourOS installation)*
