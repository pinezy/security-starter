# Reading scan results

## The three tools in plain English

**gitleaks (secret scanning).** It searches your code and git history for
things that look like passwords, API keys and tokens. If a secret gets
committed, anyone who can see the repo (or its history) can use it, so it's
better to stop it before the commit happens.

**pip-audit / npm audit and Dependabot (dependency checks).** Your project
uses libraries written by other people, and sometimes they have known
security bugs. `pip-audit` (Python) or `npm audit` (JavaScript) compares your
library versions to a public list of known bugs. Dependabot opens pull
requests to upgrade you to safe versions.

**Semgrep (static analysis).** It reads your source code without running it
and looks for risky patterns, like building a SQL query from user input or
using a weak hash. Think of it as a spell-checker for security mistakes.

## gitleaks output

| Field | Meaning |
|---|---|
| `RuleID` | Which pattern matched (for example `github-pat`, `aws-access-token`) |
| `File` / `Line` | Where it is |
| `Entropy` | How random the string looks. Higher (above about 3.5) is more key-like |
| `Fingerprint` | A stable ID you can put in `.gitleaksignore` to silence one finding |

What to do with a real finding: revoke the key, move it to an environment
variable or secret manager, then remove it from the code.

## pip-audit output

Each row shows the package, your version, a vulnerability ID (`PYSEC-...` or
`CVE-...`), and the version that fixes it. Upgrade to the fix version and
re-run. "No known vulnerabilities found" means clean.

## Semgrep output

Each finding has a rule name, a message explaining the risk, the file and
lines, and a link with details. Read the message, decide if the code is
really exploitable, then fix it. In this template, Semgrep already caught a
real issue in the Dependabot config (missing `cooldown`), which is fixed.

## What a false positive looks like

A false positive is a warning about something that is actually safe.

- **gitleaks:** a long random-looking string that isn't a secret. For example a
  test fixture, a hash of a file, an ID in a lockfile, or `API_KEY = "your-key-here"`
  in an example file.
- **Semgrep:** it flags `subprocess` use where the input is a hard-coded constant,
  not user input.
- **pip-audit:** a vulnerability in a part of the library you never call. This
  one is usually "real but low risk", not false.

How to tell: ask "could an attacker use this?" For gitleaks, try the string in
the service it claims to belong to, or check where it came from. If it's not a
credential, it's a false positive.

## Silencing a false positive (carefully)

Never switch the tool off. Silence the one finding and write down why.

- gitleaks, one finding: add its `Fingerprint` to a `.gitleaksignore` file.
- gitleaks, a pattern or path: add it to `[allowlist]` in `.gitleaks.toml`.
- Semgrep, one line: add `# nosemgrep: <rule-id>` on that line, with a reason.
- pip-audit: `pip-audit --ignore-vuln <ID>` with a comment explaining why.
