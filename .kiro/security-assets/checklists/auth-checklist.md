# Auth flow checklist (hard asset for `auth-flow-review`)

This is the full checklist referenced by the auth playbook. It's kept in a
separate file so it's only read when that playbook is actually relevant.

## Password storage
- [ ] Hashed with `bcrypt`, `argon2`, or `scrypt` (not `md5`/`sha1`/plaintext)
- [ ] Library handles salting automatically (don't roll your own)

```python
# Python example (argon2-cffi)
from argon2 import PasswordHasher
ph = PasswordHasher()
hashed = ph.hash(password)
ph.verify(hashed, password)  # raises on mismatch
```

```js
// Node example (bcrypt)
const bcrypt = require("bcrypt");
const hash = await bcrypt.hash(password, 12);
const ok = await bcrypt.compare(password, hash);
```

## Session cookies
- [ ] `HttpOnly` set
- [ ] `Secure` set (HTTPS only)
- [ ] `SameSite=Lax` or `Strict`
- [ ] Session ID regenerated on login (not reused from pre-login state)

```python
# Flask example
response.set_cookie(
    "session_id", value, httponly=True, secure=True, samesite="Lax"
)
```

## Login attempts
- [ ] Rate limited per account and per IP (see `rate-limit-review`)
- [ ] Generic error message ("invalid email or password"), not
      "no such user" vs "wrong password" (avoids confirming which emails exist)

## Password reset
- [ ] Token is random (not predictable/sequential)
- [ ] Token is single-use
- [ ] Token expires (15-60 minutes is typical)
- [ ] Token is invalidated once the password is actually changed

## OAuth / SSO
- [ ] Redirect URI checked against an EXACT allowlist (not prefix/substring match)
- [ ] `state` parameter used and validated, to prevent CSRF on the OAuth flow
