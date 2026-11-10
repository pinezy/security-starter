---
inclusion: auto
name: azure-iam-rbac-review
description: Use before release, or when role assignments changed, to check for overly broad RBAC roles, unused accounts, and missing MFA.
---

# Azure IAM / RBAC review playbook

## When to use this
Before a release, when a new role assignment or service principal was
created, or periodically via `azure-account-audit`.

## What to check
- **Least privilege on role assignments.** Prefer a scoped built-in role
  (`Reader`, `Storage Blob Data Contributor`, etc.) over `Contributor` or
  `Owner` at a broad scope (subscription-wide) when a narrower one would do.
- **Service principals use certificates or federated credentials (OIDC),
  not long-lived client secrets**, where the integration supports it (e.g.
  GitHub Actions via `azure/login` with workload identity federation needs
  no stored secret at all).
- **No credentials stored in app config/source** — this overlaps with
  `secret-scanning`, but Azure-specific: connection strings, storage keys,
  and service principal secrets all count.
- **MFA required** for any human account with `Owner`/`Contributor` at
  subscription scope (enforced via Conditional Access, part of Microsoft
  Entra ID, needs the optional Entra permissions noted in
  `docs/AZURE-SETUP.md` to check automatically).
- **Unused/stale role assignments** removed — a service principal or user
  no longer in use that still has standing access is needless exposure.

## What a false positive looks like
A subscription `Owner` assignment on the single personal account used to
set up a brand-new hackathon project, with no other users, is low risk by
virtue of having nothing else to compromise — still worth tightening before
the project grows, but not urgent for a one-person sandbox.

## Fixing it
```bash
az role assignment list --scope /subscriptions/<sub-id> --output table
az role assignment delete --assignee <principal-id> --role Owner --scope <scope>
az role assignment create --assignee <principal-id> --role Reader --scope <narrower-scope>
```
