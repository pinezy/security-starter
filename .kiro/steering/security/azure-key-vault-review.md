---
inclusion: auto
name: azure-key-vault-review
description: Use when Key Vault access policies or secrets changed, to check soft-delete/purge protection and who can read secrets.
---

# Azure Key Vault review playbook

## When to use this
A Key Vault was created, or its access policies / RBAC role assignments on
it changed.

## What to check
- **Soft-delete enabled** (on by default for new vaults) and **purge
  protection enabled**, so a deleted secret/vault can be recovered rather
  than permanently destroyed by mistake or by an attacker covering tracks.
- **Access scoped per-identity to only the secrets it needs**, using
  Azure RBAC for Key Vault (preferred over legacy vault access policies,
  which are harder to scope narrowly).
- **Apps read secrets via managed identity**, not a stored connection
  string/API key to the vault itself (otherwise you've just moved the
  secret-management problem one level, not solved it).
- **Secret expiry/rotation configured** where the secret type supports it
  (e.g. certificates, some API keys), rather than secrets living forever.
- **Network access restricted** (private endpoint or selected networks)
  if the vault holds anything sensitive and doesn't need to be reachable
  from the whole internet.

## What a false positive looks like
A vault scoped to a single dev sandbox, with access limited to the one
developer's managed identity, has low exposure even without private
networking — the networking control matters most once more people/services
can reach it.

## Fixing it
```bash
az keyvault update --name <vault> --enable-purge-protection true
az keyvault update --name <vault> --enable-rbac-authorization true
```
