---
inclusion: auto
name: secret-scanning
description: Use before every commit or release to find hardcoded API keys, passwords, tokens and private keys in changed files and the full git history.
---

# Secret scanning playbook

## When to use this
Before any commit, before merging, and always before a hackathon demo or a
release (secrets in a public repo get copied within minutes of going public).

## What it checks
Text patterns shaped like credentials: `ghp_`, `AKIA`, `sk_live_`, JWTs,
private key headers (`-----BEGIN ... PRIVATE KEY-----`), and generic
high-entropy strings next to words like `key`, `token`, `secret`, `password`.

## How to run it
```bash
# Changed files only (what the pre-commit hook does automatically)
gitleaks protect --staged --redact

# Full history of this repo, or any repo you point it at
bash scripts/audit-existing-repo.sh .
```

## Red flags in the output
- `RuleID` matches a known provider (`github-pat`, `aws-access-token`,
  `stripe-access-token`): treat as real until proven otherwise.
- High `Entropy` (above ~3.5) on a string near a credential-sounding
  variable name.
- A secret present in an OLD commit but absent from the current file: it's
  still in history and still copyable. See `git-history-audit`.

## What a false positive looks like
A long random-looking string that isn't a credential: a lockfile hash, a
test fixture ID, a UUID, or a placeholder like `your-key-here`. If it's not
usable to authenticate anywhere, it's a false positive — add it to
`.gitleaksignore` or `.gitleaks.toml`'s allowlist with a one-line reason.

## If it finds a real secret
1. Revoke/rotate it at the provider first. This is the only step that
   actually makes you safe.
2. Move it to an environment variable or secret manager.
3. See `docs/FIXING-EXISTING-ISSUES.md` if it's already in history.
