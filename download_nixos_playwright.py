#!/usr/bin/env python3
"""
NixOS ISO Download Script using Playwright
Downloads the latest NixOS graphical installer ISO automatically.
"""

import os
import sys
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeoutError

def download_nixos_iso():
    """
    Download the latest NixOS graphical installer ISO using Firefox.
    """
    # Create download directory
    download_dir = os.path.expanduser("~/Desktop/NixOS_Installer")
    os.makedirs(download_dir, exist_ok=True)
    iso_path = os.path.join(download_dir, "nixos-graphical-installer.iso")
    
    print(f"Download directory: {download_dir}")
    print(f"Target ISO path: {iso_path}")
    
    try:
        with sync_playwright() as p:
            print("Launching Firefox browser...")
            browser = p.firefox.launch(headless=False)
            page = browser.new_page()
            
            print("Navigating to NixOS download page...")
            page.goto("https://nixos.org/download.html")
            
            # Wait for page to load
            page.wait_for_load_state("networkidle")
            
            print("Looking for download links...")
            
            # Try multiple selectors for the download link
            # The website structure may change, so we try several approaches
            
            # Option 1: Look for graphical installer links
            graphical_selectors = [
                'a:has-text("Graphical installer")',
                'a:has-text("graphical")',
                'a:has-text("ISO")',
                'a[href*=".iso"]',
                'a[href*="graphical"]',
                'a[href*="plasma"]',
                'a[href*="gnome"]',
                'a[href*="xfce"]'
            ]
            
            downloaded = False
            for selector in graphical_selectors:
                try:
                    elements = page.query_selector_all(selector)
                    if elements:
                        print(f"Found {len(elements)} elements with selector: {selector}")
                        # Click the first one
                        with page.expect_download() as download_info:
                            elements[0].click()
                        download = download_info.value
                        download.save_as(iso_path)
                        print(f"✓ Successfully downloaded: {iso_path}")
                        print(f"  File size: {os.path.getsize(iso_path) if os.path.exists(iso_path) else 'unknown'} bytes")
                        downloaded = True
                        break
                except Exception as e:
                    print(f"  Selector '{selector}' failed: {e}")
                    continue
            
            # Option 2: If no graphical installer found, try manual approach
            if not downloaded:
                print("Could not find graphical installer automatically.")
                print("Please manually select the download on the page.")
                print("The browser will stay open for 60 seconds for manual download.")
                page.pause()  # Pause for manual intervention
                
                # Check if file was manually downloaded
                if os.path.exists(iso_path):
                    print(f"✓ Found manually downloaded file: {iso_path}")
                else:
                    # Try default NixOS ISO
                    print("Trying default NixOS minimal ISO...")
                    page.goto("https://nixos.org/download#nix-install-windows")
                    page.wait_for_load_state("networkidle")
                    
                    # Look for Windows installer link
                    win_selector = 'a[href*="nixos-minimal"]'
                    with page.expect_download() as download_info:
                        page.click(win_selector)
                    download = download_info.value
                    download.save_as(iso_path)
                    print(f"✓ Downloaded minimal ISO: {iso_path}")
            
            browser.close()
            
            # Verify download
            if os.path.exists(iso_path):
                file_size = os.path.getsize(iso_path)
                if file_size > 1000000:  # At least 1MB
                    print(f"\n✅ Download successful!")
                    print(f"   File: {iso_path}")
                    print(f"   Size: {file_size / (1024*1024*1024):.2f} GB")
                    return True
                else:
                    print(f"❌ File too small: {file_size} bytes")
                    return False
            else:
                print("❌ Download failed: File not found")
                return False
                
    except Exception as e:
        print(f"❌ Error during download: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("NixOS ISO Download Script")
    print("=" * 60)
    
    # Check if Playwright is installed
    try:
        import playwright
    except ImportError:
        print("Playwright not installed. Installing...")
        os.system("pip install playwright")
        os.system("playwright install firefox")
    
    success = download_nixos_iso()
    
    if success:
        print("\n✅ NixOS ISO download completed successfully!")
        print("\nNext steps:")
        print("1. Use Rufus to create bootable USB from the ISO")
        print("2. Boot your PC from the USB drive")
        print("3. Run the automate_nixos_setup.sh script in NixOS live environment")
    else:
        print("\n❌ Download failed. Please try manually:")
        print("   - Visit: https://nixos.org/download.html")
        print("   - Download the graphical installer ISO")
        print("   - Save to: ~/Desktop/NixOS_Installer/")
        sys.exit(1)