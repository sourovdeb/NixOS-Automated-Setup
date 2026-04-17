#!/usr/bin/env python3
"""
Test Python environment and dependencies for NixOS setup.
"""

import sys
import subprocess
import os

def test_python():
    print("=" * 60)
    print("Python Environment Test")
    print("=" * 60)
    
    # Test Python version
    print(f"Python version: {sys.version}")
    print(f"Python executable: {sys.executable}")
    
    # Test import of required modules
    required_modules = ['playwright', 'os', 'sys']
    
    for module in required_modules:
        try:
            __import__(module)
            print(f"✓ {module} is available")
        except ImportError as e:
            print(f"✗ {module} is NOT available: {e}")
    
    # Test pip
    try:
        import pip
        print(f"✓ pip is available (version: {pip.__version__})")
    except ImportError:
        print("✗ pip is NOT available")
    
    # Test if we can run playwright install
    print("\n" + "=" * 60)
    print("Testing Playwright Installation")
    print("=" * 60)
    
    try:
        # Try to import playwright
        import playwright
        print("✓ Playwright Python package is installed")
        
        # Check if browsers are installed
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            browsers = [
                ('firefox', p.firefox),
                ('chromium', p.chromium),
                ('webkit', p.webkit)
            ]
            
            for name, browser_type in browsers:
                try:
                    # Try to get executable path
                    executable = browser_type.executable_path
                    if os.path.exists(executable):
                        print(f"✓ {name.capitalize()} browser is installed: {executable}")
                    else:
                        print(f"✗ {name.capitalize()} browser is NOT installed")
                except Exception as e:
                    print(f"✗ {name.capitalize()} browser check failed: {e}")
                    
    except ImportError as e:
        print(f"✗ Playwright is NOT installed: {e}")
        print("\nTo install Playwright, run:")
        print("  python -m pip install playwright")
        print("  python -m playwright install firefox")
    
    # Test file system permissions
    print("\n" + "=" * 60)
    print("Testing File System Access")
    print("=" * 60)
    
    test_dirs = [
        os.path.expanduser("~/Desktop"),
        os.path.expanduser("~/Desktop/NixOS_Installer"),
        "."
    ]
    
    for test_dir in test_dirs:
        try:
            os.makedirs(test_dir, exist_ok=True)
            test_file = os.path.join(test_dir, "test_write.txt")
            with open(test_file, 'w') as f:
                f.write("test")
            os.remove(test_file)
            print(f"✓ Can write to: {test_dir}")
        except Exception as e:
            print(f"✗ Cannot write to {test_dir}: {e}")
    
    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    
    # Final recommendations
    print("\nNext steps:")
    print("1. If Playwright is not installed, run:")
    print("   python -m pip install playwright")
    print("   python -m playwright install firefox")
    print("\n2. Test the download script:")
    print("   python download_nixos_playwright.py")
    print("\n3. Check browser_bot:")
    print("   cd ../browser_bot")
    print("   python browser_bot.py --mode interactive")

if __name__ == "__main__":
    test_python()