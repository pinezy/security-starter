#!/usr/bin/env bash
# Builds a throwaway practice repo that ALREADY has security problems
# committed, so you can learn to find and fix them. Everything is local and
# fake. Nothing is pushed anywhere.
#
# Usage: bash scripts/practice-sandbox.sh [folder]   (default: /tmp/security-practice)
set -euo pipefail

DEST="${1:-/tmp/security-practice}"
if [ -e "$DEST" ]; then
  echo "$DEST already exists. Delete it (rm -rf \"$DEST\") or pass another folder." >&2
  exit 1
fi

mkdir -p "$DEST" && cd "$DEST"
git init -q -b main
G=(git -c user.name=practice -c user.email=practice@example.invalid)

# Commit 1: a hard-coded FAKE token (random characters, not a real credential)
FAKE_KEY="ghp_$(python3 -c "import secrets,string;print(''.join(secrets.choice(string.ascii_letters+string.digits) for _ in range(36)))")"
cat > settings.py <<EOF
# FAKE practice key, not a real credential
GITHUB_TOKEN = "$FAKE_KEY"
EOF
"${G[@]}" add settings.py && "${G[@]}" commit -q -m "Add settings"

# Commit 2: the secret is "deleted" from the file (but stays in history)
printf 'import os\n\nGITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")\n' > settings.py
"${G[@]}" commit -q -am "Remove token from settings"

# Commit 3: an old library with known vulnerabilities + risky code
printf 'requests==2.19.1\n' > requirements.txt
cat > app.py <<'EOF'
import subprocess


def run(command):
    # Risky on purpose: runs whatever string it is given through a shell
    return subprocess.run(command, shell=True)


def calc(expression):
    # Risky on purpose: eval runs arbitrary code
    return eval(expression)
EOF
"${G[@]}" add requirements.txt app.py && "${G[@]}" commit -q -m "Add app"

echo "Practice repo ready: $DEST"
echo "It has 3 problems: a secret in history, a vulnerable library, risky code."
echo "Audit it:   bash scripts/audit-existing-repo.sh $DEST"
echo "Then follow docs/FIXING-EXISTING-ISSUES.md"
