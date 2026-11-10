---
inclusion: auto
name: azure-account-audit
description: Use before deploying to Azure, or periodically after, to scan the live subscription itself (not just IaC files) for misconfigurations.
---

# Azure account audit playbook (umbrella)

## Why this is different from `iac-misconfig-scan`
`iac-misconfig-scan` checks your Terraform/Bicep files BEFORE anything is
deployed. It can't see a setting someone changed by hand in the Azure
Portal, or a resource created outside of IaC entirely. This playbook covers
the deployed subscription itself, read-only, using
[Prowler](https://docs.prowler.com) (open source, multi-cloud, maps findings
to CIS benchmarks).

## Before running this
See `docs/AZURE-SETUP.md` once, to set up least-privilege read access. In
short: the account/service principal Prowler uses should only ever have the
built-in `Reader` role at the subscription scope. Never grant `Contributor`
or `Owner` for a security scan.

## How to run it
```bash
make azure-audit                          # scans the current az-cli subscription
make azure-audit SUBSCRIPTION=<sub-id>     # scans one specific subscription
```
This wraps `scripts/azure-audit.sh`, which prints the subscription name/ID
before scanning and pauses briefly so you can cancel if it's not the one you
meant to scan.

## What it covers
The specific checks are grouped into their own playbooks, loaded only if
relevant: `azure-storage-exposure-review`, `azure-network-security-review`,
`azure-iam-rbac-review`, `azure-key-vault-review`,
`azure-logging-monitoring-review`. For a first run, or before a release, load
all five; day-to-day, load only the ones related to what you changed.

## What a false positive looks like
A dev/sandbox subscription with intentionally loose settings that will never
hold real user data. Scope the scan to your production subscription for
anything that actually matters, and don't over-fix a throwaway sandbox.

## Safety
This only ever reads. Prowler with a `Reader`-scoped identity cannot change
or delete anything in your subscription, by design of that role.
