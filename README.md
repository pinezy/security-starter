# security-starter

A reusable starter that adds three automated security checks to any repo.

| Check | Tool | Runs |
|---|---|---|
| Secret scanning | gitleaks | pre-commit hook and CI |
| Dependency vulnerabilities | Dependabot + pip-audit (or npm audit) | weekly PRs and CI |
| Static analysis | Semgrep | CI |

## Files

```
.pre-commit-config.yaml        local hooks (gitleaks + basic hygiene)
.gitleaks.toml                 gitleaks config and allowlist
.github/dependabot.yml         dependency + action update PRs
.github/workflows/ci-cd.yml    CI: gitleaks, pip-audit, semgrep
docs/DEMO.md                   safe fake-key demo
docs/READING-RESULTS.md        tool explanations, reading output, false positives
docs/REEL-OUTLINE.md           5-step Instagram Reel outline
scripts/demo-fake-secret.sh    runs the demo for you
app.py, requirements.txt       tiny sample app so the scanners have input
```

## Use it locally

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install pre-commit
pre-commit install
```

## Publish it

1. On github.com, create an empty repo named `security-starter` under your account (no README).
2. In this folder:
   ```bash
   git add -A && git commit -m "Add security checks"
   git remote add origin https://github.com/pinezy/security-starter.git
   git push -u origin main
   ```
3. In the repo's Settings, turn on **Dependabot alerts** and **Dependabot security updates**
   (Settings, then Code security). Optionally turn on branch protection and require the
   three CI jobs to pass.
4. Mark the repo as a **Template repository** (Settings, General) so new repos can start from it.

## Reuse in another repo

Copy these into the new repo, keeping the paths:
`.pre-commit-config.yaml`, `.gitleaks.toml`, `.github/dependabot.yml`,
`.github/workflows/ci-cd.yml`. Then:

- **Not Python?** In `dependabot.yml`, swap `pip` for `npm` (a commented block is there). In
  `ci-cd.yml`, replace the `pip-audit` job steps with `setup-node` + `npm audit --audit-level=high`
  (pin `setup-node` by SHA like the others).
- Run `pre-commit install` in the new repo.
- Run `pre-commit autoupdate` now and then. Dependabot keeps the pinned CI action SHAs fresh.

## Security choices in the workflow

- Actions are pinned to full commit SHAs, with the version in a comment, so a moved tag can't change what runs.
- Workflow-wide permissions are `contents: read`. Jobs ask for more only if needed.
- `persist-credentials: false` on checkout, so later steps don't keep the token.
- Tool versions (`pip-audit`, `semgrep`) are pinned.
- `gitleaks-action` is free for personal accounts. Organization repos need a free `GITLEAKS_LICENSE` secret.

See `docs/DEMO.md` to try it out.
