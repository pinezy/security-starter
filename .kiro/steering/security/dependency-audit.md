---
inclusion: auto
name: dependency-audit
description: Use before release to check Python or Node dependencies for known CVEs and find the safe upgrade version.
---

# Dependency audit playbook

## When to use this
Before a release, before a hackathon submission, and weekly in CI (already
scheduled in `.github/workflows/security.yml`).

## How to run it
```bash
# Python, pinned with hashes so sub-dependencies are included
pip-audit -r requirements.txt

# Node
npm audit --audit-level=high
```

## Reading the output
Each row: package name, your version, a vulnerability ID (`PYSEC-...` /
`CVE-...` / `GHSA-...`), and the version that fixes it.

## Fixing it
- Python: edit `requirements.in`, run `make update-deps`, re-run the audit.
- Node: `npm audit fix`; use `--force` only after reading what it would
  change, since it can jump major versions.
- No fix exists yet and you don't use the vulnerable function: document and
  ignore that one ID (`pip-audit --ignore-vuln <ID>`), don't suppress the
  whole tool.

## What a false positive / low-risk finding looks like
A vulnerability in a code path you never call (e.g. a flagged XML parser in
a library you only use for HTTP requests). Still worth upgrading when easy,
but it's not urgent the way a reachable one is.

## Related
If the project has native dependencies or a lockfile you don't fully trust,
also run `sbom-generation` to get a full list of what's actually shipping.
