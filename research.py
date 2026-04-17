#!/usr/bin/env python3
from playwright.sync_api import sync_playwright
import sys

def scrape_url(url, output_file):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(url)
        content = page.content()
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(content)
        browser.close()
        print(f"Saved {url} to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python research.py <url> <output_file>")
        sys.exit(1)
    scrape_url(sys.argv[1], sys.argv[2])