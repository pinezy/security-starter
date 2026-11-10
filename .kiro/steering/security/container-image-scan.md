---
inclusion: auto
name: container-image-scan
description: Use when a Dockerfile or base image changed, to check for known vulnerabilities in OS packages inside the image.
---

# Container image scan playbook

## When to use this
When `Dockerfile` changes, or before pushing/releasing an image, especially
if the base image (`FROM ...`) hasn't been rebuilt in a while.

## How to run it
```bash
bash scripts/container-scan.sh <dockerfile-or-image>
```
Wraps `trivy` (`brew install trivy`). Skips cleanly with install
instructions if it isn't present.

## What it looks for
- Known-vulnerable OS packages baked into the base image.
- Outdated base image tags (e.g. `python:3.9` pulling years-old patches).
- Secrets accidentally baked into image layers (separate from, but
  overlapping with, `secret-scanning`).

## Fixing it
- Pin a newer/patched base image tag, rebuild, re-scan.
- Use a slimmer base image (e.g. `-slim` or `-alpine` variants) to reduce
  what's inside to worry about.
- If a vulnerable package isn't actually used by your app, note it and move
  on rather than chasing every low-severity OS package finding.
