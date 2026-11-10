---
inclusion: auto
name: http-security-headers
description: Use before releasing a website to check response headers for missing CSP, HSTS, X-Frame-Options and similar protections.
---

# HTTP security headers playbook

## When to use this
Right before a release or demo, against your own deployed URL (staging or
production that you own). This is a passive read of response headers, not
an attack.

## How to run it
```bash
bash scripts/headers-check.sh https://your-own-site.example.com
```

## What it checks for
| Header | Why it matters |
|---|---|
| `Content-Security-Policy` | Limits what scripts/styles/frames can load, reduces XSS impact |
| `Strict-Transport-Security` | Forces HTTPS on repeat visits |
| `X-Content-Type-Options: nosniff` | Stops browsers guessing content types in risky ways |
| `X-Frame-Options` / `frame-ancestors` | Prevents clickjacking via iframes |
| `Referrer-Policy` | Controls what leaks to third parties via the Referer header |
| `Set-Cookie: ... Secure; HttpOnly; SameSite` | Protects session cookies from theft/CSRF |

## What a false positive looks like
A static site with no cookies and no user input may not need every header
(e.g. `HttpOnly` cookie flags are irrelevant if there are no cookies). Judge
each missing header against what the site actually does.

## Fixing it
Most frameworks have a one-line way to add these (e.g. `helmet` for
Express, `django-csp`, a few lines in nginx/Caddy config). Add them, redeploy,
re-run the check.
