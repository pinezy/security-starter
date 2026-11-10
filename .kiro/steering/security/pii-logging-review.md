---
inclusion: auto
name: pii-logging-review
description: Use before release to check that logs and error messages don't print passwords, tokens, emails, or other personal data.
---

# PII-in-logs review playbook

## When to use this
Before release, and any time you add logging/error-reporting near
authentication, forms, or user data.

## How to check
```bash
grep -rniE "print\(.*\b(password|token|ssn|credit_?card)\b" --include="*.py" .
grep -rniE "console\.(log|error)\(.*\b(password|token)\b" --include="*.js" --include="*.ts" .
```
Also check error-tracking integrations (Sentry, etc.) for whether request
bodies/headers are captured by default — many do unless configured not to.

## Why it matters
Logs are often readable by more people/tools than the app's database (CI
logs, log aggregators, third-party error trackers), so secrets or personal
data that land in logs have a wider blast radius than people expect.

## Fixing it
- Log identifiers (user ID), not sensitive fields (password, full card
  number, SSN).
- Mask/redact: show the last 4 digits of a card, not the whole number.
- Configure error-tracking SDKs to scrub known-sensitive field names before
  they leave the app (most have a `beforeSend`/scrubbing hook for this).

## What a false positive looks like
A log statement that prints a variable literally named `token` but which
actually holds a non-secret pagination cursor or CSRF token meant to be
visible to the client anyway. Confirm what the value actually is before
"fixing" it.
