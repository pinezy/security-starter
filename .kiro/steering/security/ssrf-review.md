---
inclusion: auto
name: ssrf-review
description: Use when code fetches a URL that comes from user input, to check for server-side request forgery risk.
---

# SSRF (server-side request forgery) review playbook

## When to use this
Any feature where the server itself makes an outbound HTTP request to a URL
that a user supplied or influenced (webhook URLs, "fetch this image/link",
PDF-from-URL generators, URL preview/unfurling features).

## The core risk
If a user can make your server request `http://169.254.169.254/...` (cloud
metadata endpoints) or `http://localhost:<internal-port>/...`, they can
sometimes reach internal services or steal cloud credentials, even though
they can't reach those addresses directly from the internet.

## What to check
- Is the user-supplied URL's host resolved and checked against a blocklist
  of private/internal IP ranges (`127.0.0.1`, `169.254.169.254`,
  `10.0.0.0/8`, `192.168.0.0/16`, etc.) before the request is made?
- Does the check happen AFTER DNS resolution, not just on the string (a
  hostname can resolve to an internal IP even if the string looks external;
  this is the usual way naive blocklists get bypassed)?
- Are redirects followed blindly? A URL that looks external can redirect to
  an internal address.

## What a false positive looks like
A feature that only ever fetches URLs from a small admin-configured
allowlist (not arbitrary user input) has much lower SSRF risk — the concern
is specifically about untrusted, user-controlled URLs.

## Fixing it
Use an allowlist of permitted destination patterns where possible. Where
that's not possible, resolve the hostname first, reject private/reserved IP
ranges, and disable automatic redirect-following (or re-check the redirect
target against the same rules).
