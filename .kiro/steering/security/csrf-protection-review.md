---
inclusion: auto
name: csrf-protection-review
description: Use when a new state-changing form or API route was added, to check for CSRF token protection.
---

# CSRF protection review playbook

## When to use this
Any new route that changes state (create/update/delete) and is reachable
from a logged-in browser session using cookies for auth.

## What to check
- Does the framework's built-in CSRF protection cover this route (many
  frameworks protect form POSTs by default, but a hand-rolled `fetch()`
  call or a newly added route can slip outside that default)?
- Is the session cookie set with `SameSite=Lax` or `Strict`? This alone
  blocks most CSRF in modern browsers, even without a token.
- Pure JSON APIs using a bearer token in an `Authorization` header (not a
  cookie) for auth are generally not CSRF-vulnerable, because a cross-site
  form/script can't set that header — this is a frequent false positive.

## What a false positive looks like
An API that only ever reads an `Authorization: Bearer ...` header set by
your own frontend JS, with no cookie-based session. There's nothing for a
forged cross-site request to automatically attach, so CSRF tokens add
little here.

## Fixing it
Use the framework's CSRF middleware for cookie-session-based forms/routes,
and confirm the cookie's `SameSite` attribute as a second layer of defense.
