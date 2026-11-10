#!/usr/bin/env bash
# Read-only security audit of an EXISTING git repo (yours or a practice one).
# It changes nothing in the repo. Reports are saved inside the repo's .git
# folder, so they can never be committed by accident.
#
# Usage:  bash scripts/audit-existing-repo.sh [path-to-repo]     (default: .)
# Needs:  gitleaks (brew install gitleaks). Optional: pip-audit, npm, semgrep.
# Exit code: 0 = nothing found, 1 = findings, 2 = could not run.
set -uo pipefail

STARTER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Use the tools installed by `make setup`, if present.
PATH="$STARTER_ROOT/.venv/bin:$PATH"

TARGET="${1:-.}"
cd "$TARGET" 2>/dev/null || { echo "Cannot open: $TARGET" >&2; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo: $TARGET" >&2; exit 2; }
command -v gitleaks >/dev/null 2>&1 || { echo "gitleaks not found. Install it: brew install gitleaks" >&2; exit 2; }

REPO="$(git rev-parse --show-toplevel)"
OUT="$(cd "$REPO" && cd "$(git rev-parse --git-dir)" && pwd)/security-reports"
mkdir -p "$OUT"
FOUND=0

echo "Auditing: $REPO"
echo "Reports:  $OUT"
echo

# 1. Secrets anywhere in the full git history ------------------------------
echo "== 1/3 Secrets in git history (gitleaks) =="
CONFIG_ARGS=()
[ -f "$REPO/.gitleaks.toml" ] && CONFIG_ARGS=(--config "$REPO/.gitleaks.toml")
gitleaks git "$REPO" ${CONFIG_ARGS[@]+"${CONFIG_ARGS[@]}"} --redact --no-banner --log-level error \
  --report-format json --report-path "$OUT/gitleaks.json" >/dev/null 2>&1
GL=$?
if [ "$GL" -eq 0 ]; then
  echo "OK: no secrets found in history."
elif [ "$GL" -eq 1 ]; then
  FOUND=1
  python3 - "$OUT/gitleaks.json" <<'PY'
import json, sys
items = json.load(open(sys.argv[1]))
print(f"FOUND {len(items)} possible secret(s). Secret values are hidden.")
for i in items:
    print(f"  - rule {i['RuleID']}  {i['File']}:{i['StartLine']}  commit {i['Commit'][:7]}  ({i['Date'][:10]})")
print("Next: docs/FIXING-EXISTING-ISSUES.md, section 'A secret was committed'.")
PY
else
  echo "gitleaks failed to run (exit $GL)."; FOUND=1
fi
echo

# 2. Vulnerable dependencies -----------------------------------------------
echo "== 2/3 Dependencies =="
RAN_DEPS=0
if [ -f "$REPO/requirements.txt" ]; then
  RAN_DEPS=1
  if command -v pip-audit >/dev/null 2>&1; then
    if (cd "$REPO" && pip-audit -r requirements.txt >"$OUT/pip-audit.txt" 2>&1); then
      echo "OK: pip-audit found no known vulnerabilities."
    else
      FOUND=1; echo "FOUND vulnerable Python packages:"; sed 's/^/  /' "$OUT/pip-audit.txt" | head -25
      echo "Next: docs/FIXING-EXISTING-ISSUES.md, section 'A dependency is vulnerable'."
    fi
  else
    echo "SKIPPED requirements.txt: pip-audit not installed (run make setup)."
  fi
fi
if [ -f "$REPO/package-lock.json" ]; then
  RAN_DEPS=1
  if command -v npm >/dev/null 2>&1; then
    if (cd "$REPO" && npm audit --audit-level=low >"$OUT/npm-audit.txt" 2>&1); then
      echo "OK: npm audit found no known vulnerabilities."
    else
      FOUND=1; echo "FOUND vulnerable npm packages:"; sed 's/^/  /' "$OUT/npm-audit.txt" | head -25
      echo "Next: docs/FIXING-EXISTING-ISSUES.md, section 'A dependency is vulnerable'."
    fi
  else
    echo "SKIPPED package-lock.json: npm not installed."
  fi
fi
[ "$RAN_DEPS" -eq 0 ] && echo "No requirements.txt or package-lock.json found, skipping."
echo

# 3. Risky code patterns ---------------------------------------------------
echo "== 3/3 Code patterns (Semgrep) =="
if command -v semgrep >/dev/null 2>&1; then
  (cd "$REPO" && semgrep scan --config p/default --metrics=off --quiet \
      --json --output "$OUT/semgrep.json" >/dev/null 2>&1)
  python3 - "$OUT/semgrep.json" <<'PY'
import json, sys
try:
    res = json.load(open(sys.argv[1]))["results"]
except Exception:
    print("Semgrep produced no report (it may have failed to run)."); sys.exit(3)
if not res:
    print("OK: Semgrep found nothing."); sys.exit(0)
print(f"FOUND {len(res)} finding(s):")
for r in res[:25]:
    rule = r["check_id"].split(".")[-1]
    print(f"  - {r['path']}:{r['start']['line']}  {rule}")
print("Next: docs/FIXING-EXISTING-ISSUES.md, section 'Semgrep flagged my code'.")
sys.exit(1)
PY
  S=$?
  [ "$S" -ne 0 ] && FOUND=1
else
  echo "SKIPPED: semgrep not installed (run make setup)."
fi
echo

if [ "$FOUND" -eq 0 ]; then
  echo "Audit finished: nothing found."
else
  echo "Audit finished: issues found. Nothing was changed."
fi
exit "$FOUND"
