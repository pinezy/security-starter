"""Tiny sample app so the scanners have something to look at.

Replace this with your real code when you copy the template.
"""
import os

import requests


def fetch_status(url: str) -> int:
    # Read secrets from the environment, never hard-code them.
    token = os.environ.get("API_TOKEN", "")
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    return requests.get(url, headers=headers, timeout=10).status_code


if __name__ == "__main__":
    print(fetch_status("https://example.com"))
