---
inclusion: auto
name: license-compliance
description: Use before release to check that dependency licenses are compatible with how you plan to distribute, sell, or open-source the project.
---

# License compliance playbook

## When to use this
Before a release, especially before selling the project, offering it as a
closed-source SaaS, or submitting it to a hackathon with IP/licensing rules.

## How to check
```bash
# Python
pip install pip-licenses && pip-licenses --format=markdown

# Node
npx license-checker --summary
```

## What to look for
- **GPL / AGPL** dependencies: these can require you to open-source code
  that links against them, depending on how you use them. AGPL specifically
  extends this to network/SaaS use, not just distributed binaries.
- **"No license" / unlicensed** packages: legally risky to depend on,
  regardless of what the code looks like.
- Most permissive licenses (MIT, Apache-2.0, BSD) are low-risk for nearly
  any use case.

## What a false positive looks like
A GPL-licensed dev-only tool (a linter, a test runner) that never ships
inside your product is generally fine — the concern is about code that
links into what you distribute or run as a service, not your toolchain.

## This isn't legal advice
This check flags things worth a real look, not a legal verdict. For a
funded startup or a commercial release, have an actual lawyer review
anything flagged as GPL/AGPL before launch.
