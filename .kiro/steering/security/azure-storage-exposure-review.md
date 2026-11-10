---
inclusion: auto
name: azure-storage-exposure-review
description: Use when a Storage Account, Blob container, or Bicep/Terraform storage resource changed, to check for public access and missing encryption.
---

# Azure storage exposure playbook

## When to use this
A Storage Account or Blob container was added/changed, in code (Bicep/
Terraform) or found live via `azure-account-audit`.

## What to check
- **Blob public access** disabled at the Storage Account level
  (`allowBlobPublicAccess: false`), unless a specific container is
  intentionally meant to serve public content (e.g. a CDN origin for static
  assets) — if so, scope public access to that one container only, not the
  whole account.
- **Encryption at rest** is on by default for Azure Storage, but confirm
  customer-managed keys are used instead of Microsoft-managed keys if the
  project has that requirement.
- **Secure transfer required** (`supportsHttpsTrafficOnly: true`) so data
  can't be read over plain HTTP.
- **Shared Access Signatures (SAS)** used for temporary access have an
  expiry time set, and aren't generated with broader permissions than
  needed (e.g. don't hand out account-level SAS when a single-blob,
  read-only SAS would do).
- **Storage account keys** aren't hardcoded in app config — use managed
  identity or Key Vault-stored connection strings instead (see
  `azure-key-vault-review`).

## What a false positive looks like
A storage account serving a public static website or public assets on
purpose, where "public" is the intended behavior for that specific
container, not the account's other containers.

## Fixing it
```bash
az storage account update --name <account> --resource-group <rg> \
  --allow-blob-public-access false --https-only true
```
