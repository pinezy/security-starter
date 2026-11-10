---
inclusion: auto
name: dependency-confusion-review
description: Use before release to check that internal or private package names can't be hijacked by a same-named public package.
---

# Dependency confusion review playbook

## When to use this
Before release, if the project uses any internally-named packages (e.g. a
company-internal npm/PyPI package not meant to be public).

## The core risk
If your build installs a package by name from a private registry, but
falls back to (or is misconfigured to check) the public registry, an
attacker can publish a package with the SAME NAME publicly. Depending on
config, your build may install the attacker's version instead of your
private one, running their code.

## What to check
- Internal package names are scoped (npm: `@your-org/pkg-name`; this
  prevents collision with unscoped public names) or otherwise namespaced.
- Package manager config pins the private registry as the explicit source
  for internal package names/scopes, not just as a generic extra registry
  that's checked second.
- Lockfiles (`package-lock.json`, `requirements.txt` with hashes) pin exact
  versions and, where supported, hashes — this alone blocks most dependency
  confusion and supply-chain tampering, since a swapped package won't match.

## What a false positive looks like
A solo/hackathon project with no internal private packages at all has
nothing for this to apply to — skip it unless you're using a private
registry.
