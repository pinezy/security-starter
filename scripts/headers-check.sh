#!/usr/bin/env bash
# Checks HTTP security response headers on a URL YOU OWN (staging/prod).
# Read-only: sends a single GET request, same as opening it in a browser.
# Usage: bash scripts/headers-check.sh https://your-own-site.example.com
set -euo pipefail

URL="${1:-}"
if [ -z "$URL" ]; then
  echo "Usage: bash scripts/headers-check.sh <url-you-own>" >&2
  exit 2
fi

echo "Checking response headers for: $URL"
echo "(Only run this against a site you own or are authorized to test.)"
echo

HEADERS="$(curl -s -D - -o /dev/null --max-time 15 "$URL" || true)"
if [ -z "$HEADERS" ]; then
  echo "Could not reach $URL" >&2
  exit 2
fi

echo "$HEADERS"
echo
echo "== Check results =="

check() {
  local name="$1" pattern="$2"
  if echo "$HEADERS" | grep -qi "$pattern"; then
    echo "OK       $name present"
  else
    echo "MISSING  $name"
  fi
}

check "Content-Security-Policy"   "^content-security-policy:"
check "Strict-Transport-Security" "^strict-transport-security:"
check "X-Content-Type-Options"    "^x-content-type-options:"
check "X-Frame-Options / frame-ancestors" "^x-frame-options:\|frame-ancestors"
check "Referrer-Policy"           "^referrer-policy:"

if echo "$HEADERS" | grep -qi "^set-cookie:"; then
  echo "$HEADERS" | grep -i "^set-cookie:" | while read -r line; do
    missing=""
    echo "$line" | grep -qi "httponly" || missing="$missing HttpOnly"
    echo "$line" | grep -qi "secure"   || missing="$missing Secure"
    echo "$line" | grep -qi "samesite" || missing="$missing SameSite"
    if [ -n "$missing" ]; then
      echo "ISSUE    cookie missing:$missing  ->  $line"
    else
      echo "OK       cookie flags look complete"
    fi
  done
fi

echo
echo "See .kiro/steering/security/http-security-headers.md for what each header does and how to add it."
