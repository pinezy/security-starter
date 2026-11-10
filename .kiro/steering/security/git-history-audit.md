---
inclusion: auto
name: git-history-audit
description: Use to check whether a secret that was removed from the current code is still sitting in old git commits.
---

# Git history audit playbook

## When to use this
After you notice a secret was ever committed, even if it's since been
deleted from the file. Also good practice right before making a repo public.

## How to run it
```bash
bash scripts/audit-existing-repo.sh /path/to/repo
```
This scans every commit, not just the current files, and writes a report
under that repo's `.git/security-reports/` (never inside the tracked tree).

## If it finds something
1. Revoke the secret first, always, regardless of what you do to history.
2. Removing it from history is optional cosmetic cleanup after that — see
   `docs/FIXING-EXISTING-ISSUES.md` for the `git filter-repo` steps.
3. Remember: if the repo was ever pushed publicly, assume the secret was
   already copied. History rewriting does not undo that.

## Practice first
`make practice` builds a throwaway local repo with a planted secret in
history, so you can try this safely before doing it on a real project.
