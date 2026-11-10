---
inclusion: auto
name: cors-config-review
description: Use when CORS middleware or headers changed, to catch wildcard origins or reflected-origin configurations that let any site read API responses.
---

# CORS configuration review playbook

## When to use this
Whenever you add or edit CORS settings (`Access-Control-Allow-Origin`,
`cors()` middleware, API gateway CORS config).

## What to look for in the code
- `Access-Control-Allow-Origin: *` combined with
  `Access-Control-Allow-Credentials: true` — this combination is invalid per
  spec in most browsers, but some frameworks let you misconfigure it anyway,
  and it defeats the point of using credentials/cookies with CORS.
- "Reflected origin" code that echoes back whatever `Origin` header the
  request sent as the allowed origin, with no allowlist check. This is
  effectively the same as `*` but looks safer at a glance.
- An allowlist that includes a dangerously broad pattern, like allowing any
  subdomain of a domain you don't fully control.

## What good looks like
An explicit allowlist of the exact origins your frontend is served from,
checked against a fixed list or a narrow validated pattern, with credentials
only enabled if the API actually needs cookies/auth headers cross-origin.

## How to verify after fixing
```bash
bash scripts/headers-check.sh https://your-api.example.com
```
Check the `Access-Control-Allow-Origin` value in the response for an
endpoint, requesting with a `curl -H "Origin: https://evil.example"` test
against your OWN deployed API, confirming it is NOT reflected back.
