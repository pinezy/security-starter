---
inclusion: auto
name: auth-flow-review
description: Use when login, signup, session, or password-reset code changed, to check password hashing, session cookie flags, lockout, and reset-token expiry.
---

# Authentication flow review playbook

## When to use this
Any time you touch login, signup, session creation, password reset, or
OAuth/SSO redirect handling. Full checklist:
`.kiro/security-assets/checklists/auth-checklist.md`

## Core checks

**Password storage.** Hashed with `bcrypt`/`argon2`/`scrypt`, never `md5`,
`sha1`, or plaintext. Each password should get a unique salt (these
libraries do this for you automatically).

**Session cookies.** Set `HttpOnly` (JS can't read it), `Secure` (HTTPS
only), and `SameSite=Lax` or `Strict` (limits CSRF). Session IDs should be
long, random, and regenerated on login (not reused from before
authentication).

**Login rate limiting.** A fixed number of failed attempts per
account/IP per time window, to resist brute-force and credential stuffing.
See `rate-limit-review`.

**Password reset tokens.** Random, single-use, short expiry (15-60 min
typical), invalidated once used or once the password changes.

**OAuth/SSO redirects.** The redirect URI must be checked against an exact
allowlist, not just a prefix or substring match (open redirect risk).

## What a false positive looks like
A test account with a known/weak password, used only in a `.env.example`-only
`fixtures.py` that never touches production data. Note it instead of
"fixing" test fixtures into unusable test data.

## Fixing it
See the before/after snippets in
`.kiro/security-assets/checklists/auth-checklist.md`.
