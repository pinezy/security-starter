# security-starter

A reusable starter that adds automated security checks to any repo.

| Check | Tool | Runs |
|---|---|---|
| Secret scanning | gitleaks | pre-commit hook and CI |
| Dependency vulnerabilities | Dependabot + pip-audit (or npm audit) | weekly PRs and CI |
| Static analysis | Semgrep | CI, results also in the Security tab |
| Demo still works | `demo-test` job | CI |

## Quick start

Needs Python 3.14 (see `.python-version`).

```bash
make setup     # creates .venv, installs tools, turns on the git hooks
make check     # runs every scan locally
make demo      # fake-key demo, see docs/DEMO.md
```

**Important:** the gitleaks hook only protects you after `pre-commit install`
(which `make setup` does). A fresh clone has no hooks until you run it. CI is
the backup, but it runs after the secret has already been pushed.

## Files

```
.pre-commit-config.yaml        local hooks (gitleaks + basic hygiene)
.gitleaks.toml                 gitleaks config and allowlist
.github/dependabot.yml         dependency + action update PRs
.github/workflows/security.yml CI: gitleaks, pip-audit, semgrep, demo-test
templates/node/                JavaScript versions of the workflow and Dependabot config
requirements.in                libraries you choose (edit this)
requirements.txt               generated: every library pinned with hashes (do not hand-edit)
Makefile                       setup / check / demo / update-deps
SECURITY.md                    how to report a vulnerability
docs/DEMO.md                   safe fake-key demo
docs/READING-RESULTS.md        tool explanations, reading output, false positives
docs/REEL-OUTLINE.md           5-step Instagram Reel outline
scripts/demo-fake-secret.sh    runs the demo for you
app.py                         tiny sample app so the scanners have input
```

## Managing dependencies

Edit `requirements.in`, then run `make update-deps`. It rewrites
`requirements.txt` with every sub-dependency pinned and hashed, so `pip-audit`
checks the full tree and tampered packages are rejected on install.

## Reuse in another repo

**Easiest:** click **Use this template** on the repo's GitHub page.

**Python project, copy files:**
`.pre-commit-config.yaml`, `.gitleaks.toml`, `.python-version`, `Makefile`,
`.github/dependabot.yml`, `.github/workflows/security.yml`. Then `make setup`.

**JavaScript project:** copy the same files, but use `templates/node/security.yml`
as `.github/workflows/security.yml` and `templates/node/dependabot.yml` as
`.github/dependabot.yml`. Delete `demo-test` references if you remove the demo script.
Run `pre-commit install` yourself instead of `make setup`.

Run `pre-commit autoupdate` now and then. Dependabot keeps the pinned CI action SHAs fresh.

## Turn on in GitHub (once per repo)

- Settings, Code security: Dependabot alerts, Dependabot security updates, secret scanning, push protection.
- Settings, Branches: protect `main` and require the `gitleaks`, `pip-audit` and `semgrep` checks.
- Settings, General: tick **Template repository** if you want to reuse it.

## Security choices in the workflow

- Actions are pinned to full commit SHAs, with the version in a comment, so a moved tag can't change what runs.
- Workflow-wide permissions are `contents: read`. Only the `semgrep` job adds `security-events: write`, to upload results.
- `persist-credentials: false` on checkout, so later steps don't keep the token.
- Tool versions (`pip-audit`, `semgrep`) are pinned.
- Dependabot waits 7 days (`cooldown`) before proposing brand-new releases.
- `gitleaks-action` is free for personal accounts. Organization repos need a free `GITLEAKS_LICENSE` secret.

See `docs/DEMO.md` to try it out.
