#!/usr/bin/env bash
# Scans Terraform / Kubernetes / docker-compose files for misconfigurations.
# Read-only. Wraps checkov. Usage: bash scripts/iac-scan.sh [path]  (default: .)
set -uo pipefail

TARGET="${1:-.}"

if ! command -v checkov >/dev/null 2>&1; then
  cat >&2 <<'EOF'
checkov is not installed. Install it, then re-run:
  pip install checkov
(or, inside this project's venv: .venv/bin/pip install checkov)

Skipping this check for now.
EOF
  exit 0
fi

echo "Scanning infrastructure files under: $TARGET"
checkov --directory "$TARGET" --compact --quiet
echo
echo "See .kiro/steering/security/iac-misconfig-scan.md for how to read and fix findings."
