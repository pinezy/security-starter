---
inclusion: auto
name: rate-limit-review
description: Use when an authentication or public API route was added, to check for request throttling that prevents brute force and abuse.
---

# Rate limiting review playbook

## When to use this
Any new login, signup, password-reset, OTP-verification, or public API
route, especially anything free to call and costing you money per call
(e.g. one that triggers an email, SMS, or third-party API request).

## What to check
- Is there a limit on attempts per account and per IP for auth endpoints?
- Is there a limit on calls per API key/user for metered/costly endpoints?
- Does the limit apply server-side (a middleware, a counter in
  Redis/database), not just a frontend debounce that's trivial to bypass by
  calling the API directly?

## What good looks like
A small, fixed number of attempts per time window (e.g. 5 login attempts
per 15 minutes per account), with a clear error response, and ideally a
backoff or temporary lockout rather than a silent block that's easy to miss.

## What a false positive looks like
An internal admin-only endpoint reachable only from a private network or
behind its own separate auth layer may not need public-style rate limiting.
Judge based on who can actually reach the route.

## Fixing it
Most frameworks have a drop-in middleware (`express-rate-limit`,
`django-ratelimit`, API gateway throttling rules). Prefer these over a
custom counter unless you have a specific reason not to.
