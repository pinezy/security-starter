#!/usr/bin/env bash
# Read-only security audit of a live Azure subscription, via Prowler.
# Never creates, changes, or deletes anything — Prowler only calls Azure's
# read/list APIs. See docs/AZURE-SETUP.md before first use.
#
# Usage: bash scripts/azure-audit.sh [subscription-id]
# Needs: az CLI logged in (az login), prowler installed (pip install prowler)
set -uo pipefail

STARTER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATH="$STARTER_ROOT/.venv/bin:$PATH"
SUB="${1:-}"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI not found. Install it, then run: az login" >&2
  echo "https://learn.microsoft.com/cli/azure/install-azure-cli" >&2
  exit 0
fi

if ! az account show >/dev/null 2>&1; then
  echo "Not logged in to Azure CLI. Run: az login" >&2
  echo "Use an account/identity scoped to the Reader role only. See docs/AZURE-SETUP.md." >&2
  exit 0
fi

if ! command -v prowler >/dev/null 2>&1; then
  echo "prowler not installed. Install it, then re-run:" >&2
  echo "  .venv/bin/pip install prowler" >&2
  exit 0
fi

ACCOUNT_JSON="$(az account show ${SUB:+--subscription "$SUB"} 2>/dev/null)"
if [ -z "$ACCOUNT_JSON" ]; then
  echo "Could not read the target subscription (check the subscription ID, or your access)." >&2
  exit 2
fi
SUB_NAME="$(echo "$ACCOUNT_JSON" | python3 -c 'import sys,json;print(json.load(sys.stdin)["name"])')"
SUB_ID="$(echo "$ACCOUNT_JSON" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')"

echo "About to scan Azure subscription:"
echo "  Name: $SUB_NAME"
echo "  ID:   $SUB_ID"
echo "This only reads resource metadata. Press Ctrl+C now if this isn't the right subscription."
sleep 4

OUT="$STARTER_ROOT/.security-reports/azure/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
echo
echo "Running Prowler (this can take a few minutes)..."
prowler azure --az-cli-auth ${SUB:+--subscription-ids "$SUB"} \
  --output-directory "$OUT" --output-formats csv json-ocsf
STATUS=$?

echo
echo "Report saved to: $OUT"
echo "Read it with docs/AZURE-SETUP.md and .kiro/steering/security/azure-*.md for what each finding means."
exit "$STATUS"
