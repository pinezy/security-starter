---
inclusion: auto
name: sbom-generation
description: Use before a release to produce a software bill of materials listing every dependency and its exact version.
---

# SBOM generation playbook

## When to use this
Before a release, or any time someone (a judge, a user, a security
reviewer) might reasonably ask "what exactly is running in this?"

## Why it matters
A software bill of materials (SBOM) is just a complete, exact list of every
dependency and version shipping in the project. It makes future vulnerability
checks fast (you can re-check the same list against new CVE data later
without re-deriving it) and it's increasingly expected for serious releases.

## How to generate one
```bash
# Python
pip install pip-audit && pip-audit -r requirements.txt --format=cyclonedx-json -o sbom.json

# Node
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

## What to do with it
Commit it alongside a release tag, or attach it to a GitHub Release. Re-run
`dependency-audit` against it periodically, since a package safe today can
get a new CVE next month.
