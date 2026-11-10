#!/usr/bin/env bash
# Scans a Dockerfile or built image for known-vulnerable OS packages.
# Read-only. Wraps trivy. Usage: bash scripts/container-scan.sh <path-or-image>
set -uo pipefail

TARGET="${1:-.}"

if ! command -v trivy >/dev/null 2>&1; then
  cat >&2 <<'EOF'
trivy is not installed. Install it, then re-run:
  brew install trivy

Skipping this check for now.
EOF
  exit 0
fi

if [ -f "$TARGET" ] || [ -d "$TARGET" ]; then
  echo "Scanning filesystem/config at: $TARGET"
  trivy config --quiet "$TARGET" 2>/dev/null || trivy fs --quiet "$TARGET"
else
  echo "Scanning image: $TARGET"
  trivy image --quiet "$TARGET"
fi
echo
echo "See .kiro/steering/security/container-image-scan.md for how to read and fix findings."
