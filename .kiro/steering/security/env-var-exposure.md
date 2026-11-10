---
inclusion: auto
name: env-var-exposure
description: Use before release to check that server-only secrets aren't being bundled into client-side JavaScript.
---

# Environment variable exposure playbook

## When to use this
Before any release of a frontend app (React/Vite/Next/etc), especially if
new environment variables were added recently.

## The core trap
Frameworks like Vite/Next/Create React App only expose variables prefixed a
certain way (`VITE_*`, `NEXT_PUBLIC_*`, `REACT_APP_*`) to the browser bundle
— but anything with that prefix ships to EVERY visitor's browser, readable
in dev tools. It's easy to accidentally prefix a secret key that way.

## How to check
```bash
# Search the built output for anything that looks like a real secret
grep -rE "(sk_live|AKIA|ghp_|-----BEGIN)" dist/ build/ .next/ 2>/dev/null
```
Also grep your `.env` files for the framework's public-prefix and manually
confirm nothing secret uses it.

## What good looks like
Only truly public values (a public API base URL, a publishable/public key
like Stripe's `pk_live_...`) use the public prefix. Anything that grants
write access, billing access, or admin capability stays server-only and is
read in server code / API routes, never shipped to the browser.

## What a false positive looks like
A `pk_live_` (Stripe publishable key) or similar key that is DESIGNED to be
public — check the provider's docs to confirm which key types are meant for
client-side use before "fixing" something that's actually fine.
