---
inclusion: auto
name: iac-misconfig-scan
description: Use when Terraform, Kubernetes manifests, or docker-compose files changed, to catch open security groups, public storage buckets, or missing encryption.
---

# Infrastructure-as-code misconfiguration playbook

## When to use this
Any time a `.tf`, `.yaml`/`.yml` Kubernetes manifest, or `docker-compose.yml`
file is added or changed. These define real infrastructure, so a mistake
here is a live exposure the moment it's applied/deployed, not just a code bug.

## How to run it
```bash
bash scripts/iac-scan.sh .
```
This wraps `checkov` (Terraform, CloudFormation, Kubernetes, Dockerfiles) and
skips cleanly with instructions if it isn't installed
(`pip install checkov`).

## What it looks for
- Security groups / firewall rules open to `0.0.0.0/0` on sensitive ports.
- Storage buckets (S3, GCS) without `private` access or without encryption.
- Containers running as root, or with privileged mode on.
- Databases without encryption at rest, or with public endpoints.
- Hardcoded credentials inside `.tf` or manifest files (also caught by
  `secret-scanning`, but checkov understands provider-specific fields too).

## What a false positive looks like
A rule flags a dev/staging environment resource that's intentionally open
(e.g. a local Minikube manifest). Scope the scan to the folder that matters,
or suppress that one check ID with a comment explaining why, never globally.

## Fixing it
Checkov's output links to the specific control and a fix example for that
provider. Apply the fix, re-run `terraform plan` (or equivalent) to confirm
nothing else broke, then re-scan.
