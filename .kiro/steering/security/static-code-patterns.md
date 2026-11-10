---
inclusion: auto
name: static-code-patterns
description: Use to scan source code for risky patterns like eval, shell=True, weak hashes, and SQL built from string concatenation.
---

# Static code pattern playbook

## When to use this
Before commit (CI already runs this), and any time you write code that
touches user input, a shell, a database query, or a hash/crypto function.

## How to run it
```bash
semgrep scan --config p/default --error --metrics=off
```

## Common findings and fixes

| Pattern | Risk | Fix |
|---|---|---|
| `eval(x)` / `exec(x)` | Runs arbitrary code | Parse data explicitly, or `ast.literal_eval` |
| `subprocess.run(cmd, shell=True)` | Shell injection via input | Pass a list, drop `shell=True` |
| SQL via f-string/concatenation | SQL injection | Parameterized queries (`cursor.execute(sql, (val,))`) |
| `md5`/`sha1` for passwords | Easily cracked | `bcrypt` / `argon2` for passwords; `sha256` is fine for non-password hashing |
| `pickle.load` on untrusted data | Arbitrary code execution on deserialize | Use `json` for untrusted data |

## What a false positive looks like
`subprocess` called with a hardcoded, constant command and no user input
reaching it. Still prefer the list form for clarity, but it's not exploitable.

## Suppressing one line (only after confirming it's safe)
```python
subprocess.run(cmd, shell=True)  # nosemgrep: subprocess-shell-true — cmd is a hardcoded constant, see line 10
```
