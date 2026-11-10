---
inclusion: auto
name: azure-logging-monitoring-review
description: Use before release, or periodically, to check that Azure Activity Log and resource diagnostic logging are enabled and retained.
---

# Azure logging and monitoring playbook

## When to use this
Before release, and periodically via `azure-account-audit` — logging gaps
are invisible until you need the log that doesn't exist.

## What to check
- **Activity Log retention/export** configured (Activity Log itself is free
  and always on, but confirm it's exported to a Log Analytics workspace or
  Storage Account for retention beyond the default window).
- **Diagnostic settings enabled** on resources that matter (databases, Key
  Vault, App Service, NSGs) — these are NOT on by default and must be
  configured per resource.
- **Microsoft Defender for Cloud** enabled at least at the free tier for
  baseline recommendations; consider the paid tier for production workloads
  handling real user data.
- **Alerts configured** for high-signal security events (e.g. a Key Vault
  access policy change, a new Owner role assignment), not just
  infrastructure health.

## What a false positive looks like
A throwaway sandbox subscription with no real data has little need for
alerting/retention investment yet — prioritize this once the project holds
anything real.

## Fixing it
```bash
az monitor diagnostic-settings create --name "send-to-law" \
  --resource <resource-id> --workspace <log-analytics-workspace-id> \
  --logs '[{"category": "allLogs", "enabled": true}]'
```
