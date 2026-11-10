# security-starter

A reusable starter that adds automated security checks to any repo.

| Check | Tool | Runs |
|---|---|---|
| Secret scanning | gitleaks | pre-commit hook and CI |
| Dependency vulnerabilities | Dependabot + pip-audit (or npm audit) | weekly PRs and CI |
| Static analysis | Semgrep | CI, results also in the Security tab |
| Infra misconfig | checkov | on demand (`make iac-scan`) |
| Container image | trivy | on demand (`make container-scan`) |
| HTTP headers | curl-based checker | on demand (`make headers-check`) |
| Demo still works | `demo-test` job | CI |

## Quick start

Needs Python 3.14 (see `.python-version`).

```bash
make setup     # creates .venv, installs tools, turns on the git hooks
make check     # runs every scan locally
make demo      # fake-key demo, see docs/DEMO.md
make audit TARGET=/path/to/repo   # read-only audit of an existing repo (needs: brew install gitleaks)
make practice  # builds a practice repo with planted problems to find and fix
```

## Already-committed code

The hook only stops NEW secrets. For code that is already committed, use
`make audit` to scan the whole git history, dependencies and code, then follow
`docs/FIXING-EXISTING-ISSUES.md` to fix what it finds. CI also re-scans every
Monday (and on demand from the Actions tab), so newly published vulnerabilities
in old dependencies show up without you pushing anything.

**Important:** the gitleaks hook only protects you after `pre-commit install`
(which `make setup` does). A fresh clone has no hooks until you run it. CI is
the backup, but it runs after the secret has already been pushed.

## Pre-release security agent (Kiro)

If you're working in Kiro, this repo also carries a small agent that reviews
changes before you commit, submit, or deploy — useful for hackathons and
releases, not just day-to-day commits. It's built in three tiers so it stays
cheap to run:

1. **Manifests** (`.kiro/steering/security/*.md`, 19 files): each is a short
   `name` + one-sentence `description` of a check — secret scanning, auth
   review, file uploads, CORS, SSRF, IaC misconfig, and more. These are
   always visible to the agent but don't cost much context.
2. **Playbooks**: the full body of whichever manifest(s) turn out to be
   relevant to what changed. Loaded on demand via `disclose_context`, not all
   19 at once. For example, touching login code loads `auth-flow-review`;
   touching a `Dockerfile` loads `container-image-scan`.
3. **Hard assets** (`.kiro/security-assets/`): deeper checklists, code
   snippets, and safe self-test strings, pulled in only when a loaded
   playbook points to them.

The orchestrator is `.kiro/agents/security-pre-release-reviewer.md` — a
read-only custom agent (git diff + the scripts in `scripts/`, no write
access) that picks relevant playbooks, runs the matching scripts, and
reports findings secrets-first, in plain English. Two hooks in `.kiro/hooks/`
nudge toward using it: one fires when you say something like "ready to
commit" or "about to deploy," the other when you save a Dockerfile/IaC file.

This only ever looks at your own repo. It won't scan or send requests to a
third-party site; `scripts/headers-check.sh` only runs against a URL you
confirm is yours.

Copy `.kiro/steering/security/`, `.kiro/security-assets/`, `.kiro/agents/`,
and `.kiro/hooks/` into another project to bring this along.

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
scripts/audit-existing-repo.sh read-only audit of any existing repo (history, deps, code)
scripts/practice-sandbox.sh    builds a practice repo with planted problems
docs/FIXING-EXISTING-ISSUES.md how to fix secrets, dependencies and code after commit
scripts/iac-scan.sh            checkov wrapper for Terraform/K8s/docker-compose
scripts/container-scan.sh      trivy wrapper for Dockerfiles/images
scripts/headers-check.sh       checks HTTP security headers on a URL you own
.kiro/steering/security/       19 manifest+playbook docs for the pre-release agent
.kiro/security-assets/         deeper checklists and safe self-test strings
.kiro/agents/                  the Security Pre-Release Reviewer custom agent
.kiro/hooks/                   nudges toward running the agent at the right time
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
