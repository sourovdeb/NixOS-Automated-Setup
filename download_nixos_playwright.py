#!/usr/bin/env python3
"""
NixOS ISO Downloader
Downloads the latest NixOS graphical installer ISO directly via HTTP.
Falls back to Playwright browser if direct download fails.
"""

import os
import sys
import urllib.request
import urllib.error

DOWNLOAD_DIR = os.path.join(os.path.expanduser("~"), "Desktop", "NixOS_Installer")
ISO_PATH     = os.path.join(DOWNLOAD_DIR, "nixos-graphical-installer.iso")

# Direct URLs — tried in order, first reachable one wins
DIRECT_URLS = [
    # ── GitHub releases (NixOS/nixos-images) — often fastest ──────────────────
    "https://github.com/NixOS/nixos-images/releases/download/nixos-24.11/nixos-graphical-installer-24.11-x86_64-linux.iso",
    # ── Official NixOS channels CDN ────────────────────────────────────────────
    "https://channels.nixos.org/nixos-24.11/latest-nixos-gnome-x86_64-linux.iso",
    "https://channels.nixos.org/nixos-24.11/latest-nixos-plasma6-x86_64-linux.iso",
    # ── Community mirrors ──────────────────────────────────────────────────────
    "https://mirror.sjtu.edu.cn/nix-channels/releases/nixos-24.11/latest-nixos-gnome-x86_64-linux.iso",
    "https://mirror.iscas.ac.cn/nixos-images/nixos/24.11/latest-nixos-gnome-x86_64-linux.iso",
    # ── Minimal as last resort ─────────────────────────────────────────────────
    "https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-x86_64-linux.iso",
]

MIN_ISO_BYTES = 500 * 1024 * 1024  # 500 MB sanity check


def _progress(block_num, block_size, total_size):
    downloaded = block_num * block_size
    if total_size > 0:
        pct = min(downloaded / total_size * 100, 100)
        bar = "#" * int(pct / 2)
        print(f"\r  [{bar:<50}] {pct:5.1f}%  "
              f"{downloaded/1024/1024:.0f}/{total_size/1024/1024:.0f} MB",
              end="", flush=True)
    else:
        print(f"\r  Downloaded {downloaded/1024/1024:.0f} MB...", end="", flush=True)


def download_direct():
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)

    for url in DIRECT_URLS:
        print(f"\nTrying: {url}")
        try:
            # HEAD request — short timeout so we skip dead mirrors fast
            req = urllib.request.Request(url, method="HEAD")
            with urllib.request.urlopen(req, timeout=8) as resp:
                size_mb = int(resp.headers.get("Content-Length", 0)) // (1024 * 1024)
                print(f"  File size: ~{size_mb} MB — starting download...")

            urllib.request.urlretrieve(url, ISO_PATH, reporthook=_progress)
            print()  # newline after progress bar

            if os.path.exists(ISO_PATH) and os.path.getsize(ISO_PATH) >= MIN_ISO_BYTES:
                gb = os.path.getsize(ISO_PATH) / (1024 ** 3)
                print(f"\n✅  Download complete!")
                print(f"    File : {ISO_PATH}")
                print(f"    Size : {gb:.2f} GB")
                return True
            else:
                print("  File too small — trying next URL.")
                os.remove(ISO_PATH)

        except urllib.error.URLError as e:
            print(f"  Failed: {e}")
        except Exception as e:
            print(f"  Error: {e}")

    return False


def download_playwright():
    """Fallback: open NixOS download page in Firefox so user can click manually."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("Playwright not available for fallback.")
        return False

    print("\nOpening NixOS download page in Firefox...")
    print("Please click the 'Graphical installer' download link manually.")
    print(f"Save the file to: {DOWNLOAD_DIR}")

    with sync_playwright() as p:
        browser = p.firefox.launch(headless=False)
        page = browser.new_page()
        page.goto("https://nixos.org/download/")
        page.wait_for_load_state("networkidle")

        print("\nBrowser is open. Download the ISO, then press Enter here to continue.")
        input("Press Enter once the download has finished...")
        browser.close()

    # Check common download locations
    candidates = [
        ISO_PATH,
        os.path.join(os.path.expanduser("~"), "Downloads", "nixos-graphical-installer.iso"),
    ]
    # Also check Downloads folder for any .iso file
    downloads_dir = os.path.join(os.path.expanduser("~"), "Downloads")
    for f in os.listdir(downloads_dir):
        if f.lower().endswith(".iso") and "nixos" in f.lower():
            candidates.append(os.path.join(downloads_dir, f))

    for path in candidates:
        if os.path.exists(path) and os.path.getsize(path) >= MIN_ISO_BYTES:
            if path != ISO_PATH:
                print(f"Found ISO at {path}, moving to {ISO_PATH}...")
                os.makedirs(DOWNLOAD_DIR, exist_ok=True)
                os.rename(path, ISO_PATH)
            print(f"✅  ISO ready at: {ISO_PATH}")
            return True

    return False


if __name__ == "__main__":
    print("=" * 60)
    print("NixOS ISO Downloader")
    print("=" * 60)
    print(f"Destination: {ISO_PATH}")

    # Skip download if a valid ISO already exists
    if os.path.exists(ISO_PATH) and os.path.getsize(ISO_PATH) >= MIN_ISO_BYTES:
        gb = os.path.getsize(ISO_PATH) / (1024 ** 3)
        print(f"\n✅  ISO already exists ({gb:.2f} GB) — skipping download.")
        print("    Delete the file and re-run if you want a fresh copy.")
        sys.exit(0)

    success = download_direct()

    if not success:
        print("\nDirect download failed. Trying browser fallback...")
        success = download_playwright()

    if success:
        print("\n" + "=" * 60)
        print("Next steps:")
        print("  1. Run flash_usb_rufus.ps1 to flash the ISO to USB E:")
        print("  2. Boot from USB (press F12 at startup)")
        print("  3. Run automate_nixos_setup.sh in the NixOS live environment")
        print("=" * 60)
    else:
        print("\n❌  Download failed.")
        print("    Please download manually from: https://nixos.org/download/")
        print(f"    Save the .iso file to: {DOWNLOAD_DIR}")
        sys.exit(1)
