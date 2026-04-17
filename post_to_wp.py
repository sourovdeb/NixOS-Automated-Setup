#!/usr/bin/env python3
"""Post to WordPress via REST API. Reads credentials from ~/.wp-env"""

import os
import sys
import requests
from base64 import b64encode

def load_creds():
    env_file = os.path.expanduser("~/.wp-env")
    creds = {}
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                creds[k.strip()] = v.strip().strip("'\"")
    return creds

def post_to_wp(title, content, status="draft"):
    creds = load_creds()
    url  = creds["WP_URL"].rstrip("/") + "/wp-json/wp/v2/posts"
    user = creds.get("WP_USER", "")
    pwd  = creds.get("WP_APP_PASSWORD", creds.get("WP_PASS", ""))

    token = b64encode(f"{user}:{pwd}".encode()).decode()
    headers = {"Authorization": f"Basic {token}", "Content-Type": "application/json"}

    payload = {"title": title, "content": content, "status": status}
    resp = requests.post(url, headers=headers, json=payload, timeout=30)
    resp.raise_for_status()

    post = resp.json()
    print(f"Post created: {post.get('link', 'unknown URL')}")
    print(f"Status: {post.get('status')}  ID: {post.get('id')}")
    return post

if __name__ == "__main__":
    title   = sys.argv[1] if len(sys.argv) > 1 else "Automated Post from NixOS"
    content = sys.argv[2] if len(sys.argv) > 2 else "Posted automatically via Python + WordPress REST API."
    status  = sys.argv[3] if len(sys.argv) > 3 else "draft"
    post_to_wp(title, content, status)
