#!/usr/bin/env bash
# Safe gitleaks demo. Creates a FAKE token (random characters, not a real
# credential) on a throwaway branch and tries to commit it.
# Nothing is pushed. Run from the repo root: bash scripts/demo-fake-secret.sh
set -euo pipefail

if [ -n "$(git status --porcelain)" ]; then
  echo "Please commit or stash your changes first, then re-run." >&2
  exit 1
fi

START_BRANCH=$(git symbolic-ref --short HEAD)
DEMO_BRANCH="test/fake-secret-demo"

git checkout -b "$DEMO_BRANCH"

# Build the fake key at run time so it is never stored in the repo.
FAKE_KEY="ghp_$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"
printf '# FAKE DEMO KEY, not a real credential\nGITHUB_TOKEN = "%s"\n' "$FAKE_KEY" > config_demo.py

git add config_demo.py
echo
echo ">>> Trying to commit. The gitleaks hook should BLOCK this:"
git commit -m "demo: add fake token" || echo ">>> Commit blocked. That is the expected result."

echo
echo "Now clean up (see docs/DEMO.md, Step 5):"
echo "  git restore --staged config_demo.py && rm config_demo.py"
echo "  git checkout $START_BRANCH && git branch -D $DEMO_BRANCH"
