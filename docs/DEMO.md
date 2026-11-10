# Safe demo: watch gitleaks catch a fake key

The "key" is random characters shaped like a GitHub token. It is not a real
credential and cannot log in anywhere. Everything happens on a throwaway
branch, and you never push it.

## Before you start

```bash
make setup                  # installs tools and turns the hooks on
git status                  # must be clean: commit anything pending first
```
The repo needs at least one real commit before the demo.

## Steps

**1. Make a test branch.**
```bash
git checkout -b test/fake-secret-demo
```

**2. Create a file with a fake key.** Build the key yourself so it is never
stored in the repo:
```bash
python3 -c "import secrets,string;print('GITHUB_TOKEN = \"ghp_'+''.join(secrets.choice(string.ascii_letters+string.digits) for _ in range(36))+'\"')" > config_demo.py
```
(Or run `bash scripts/demo-fake-secret.sh`, which does steps 1 to 3 for you.)

Note: gitleaks ignores strings that look too repetitive, such as
`ghp_FAKEFAKEFAKE...`, because real keys are random-looking. That is why the
demo key is random.

**3. Try to commit it.**
```bash
git add config_demo.py
git commit -m "demo: add fake token"
```

**4. Read the result.** The commit is blocked and you see something like:
```
Detect hardcoded secrets.....Failed
Finding:     GITHUB_TOKEN = "REDACTED
RuleID:      github-pat
File:        config_demo.py
Line:        2
```
`RuleID` says which pattern matched, `File` and `Line` tell you where.
gitleaks hides the secret itself (`REDACTED`) so it doesn't leak into logs.

**5. Clean up properly.** Pick the case that matches what happened.

*Case A: the hook blocked the commit (the normal case).* Nothing was saved to
history, so just undo the staging and delete the branch:
```bash
git restore --staged config_demo.py
rm config_demo.py
git checkout main
git branch -D test/fake-secret-demo
```

*Case B: the commit went through locally (hook not installed), nothing pushed.*
The branch is throwaway, so deleting it removes the commit from view:
```bash
git checkout main
git branch -D test/fake-secret-demo
```

*Case C: you pushed it.* Delete the remote branch. If this had been a REAL
key, deleting is not enough, because the key stays in git history and may
already be copied. In that case:
1. Revoke or rotate the key first (in the service that issued it).
2. Then remove it from history (for example with `git filter-repo`).
```bash
git push origin --delete test/fake-secret-demo
```

**6. (Optional) See the CI catch it too.** Push the demo branch, open a pull
request, and the `gitleaks` job fails with the same finding. Then close the PR
and delete the branch as in Case C. Only do this with the fake key.
