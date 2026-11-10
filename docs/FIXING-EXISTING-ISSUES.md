# Finding and fixing security issues in code that is already committed

New problems get found in old code all the time: a key that was committed
months ago, or a library that was safe last year and has a new vulnerability
today. This guide shows how to find them and fix them.

## 1. Practice first (safe)

```bash
make practice                       # builds /tmp/security-practice with 3 planted problems
make audit TARGET=/tmp/security-practice
```
Everything is fake and local. The sandbox has a secret hidden in history, an
old vulnerable library, and risky code. Fix all three below, then run the audit again.

## 2. Audit a real repo

```bash
make audit TARGET=/path/to/your/repo
```
The audit only reads. It scans the full git history for secrets, checks
dependencies, and runs Semgrep. Reports are saved in that repo's `.git/security-reports/`,
so they can't be committed by mistake. Exit code `1` means issues were found.

Fix things in this order: **secrets first** (they are exploitable right now),
then vulnerable dependencies, then code patterns.

---

## A secret was committed

The audit shows the rule, file, line and commit, never the secret itself.

**Step 1: Revoke the secret. Do this before anything else.** Go to the service
that issued it (GitHub, AWS, Stripe, etc.), delete or rotate the key, and make
a new one. Once a secret has been in a pushed repo, assume it was copied.
Cleaning git history does not make a leaked key safe again.

**Step 2: Take it out of the current code.** Read it from an environment
variable and keep the real value in a `.env` file that is git-ignored:
```python
import os
TOKEN = os.environ["GITHUB_TOKEN"]
```
Commit this change with a normal pull request.

**Step 3 (optional, for tidiness): remove it from history.** This rewrites
history, so it is hard to undo and everyone who cloned the repo will need to
re-clone. Use it only after Step 1. Try it on the sandbox first.

```bash
# a. Keep a backup
git clone --mirror /path/to/repo /path/to/repo-backup.git

# b. Work in a FRESH clone (git-filter-repo refuses to run on old ones)
git clone /path/to/repo /path/to/repo-fixed
cd /path/to/repo-fixed

# c. Replace anything shaped like a GitHub token, in every commit
printf 'regex:ghp_[A-Za-z0-9]{36}==>REMOVED_SECRET\n' > /tmp/replacements.txt
git filter-repo --replace-text /tmp/replacements.txt     # pip install git-filter-repo

# d. Check it is gone from history, then re-audit
git log -p --all | grep -c 'ghp_'          # should print 0
make audit TARGET=.                         # run from the security-starter folder
```
To publish the rewritten history you would then add the remote back and run
`git push --force-with-lease --all`. Do that only on your own repo, and tell
collaborators first. GitHub may still show the old commits through cached
views, forks and pull requests, which is another reason Step 1 matters most.
Change the `ghp_` pattern to match your secret's format (for example `AKIA[0-9A-Z]{16}` for AWS).

**Already-reviewed old findings?** If you've revoked and reviewed everything but
the old commits still trigger alerts, create a baseline so only NEW secrets fail:
```bash
gitleaks git . --report-path .gitleaks-baseline.json
```
Then use `--baseline-path .gitleaks-baseline.json`. Use this carefully and only
after revoking.

## A dependency is vulnerable

The audit lists the package, your version, the ID (PYSEC/CVE) and the fix version.

- **Python:** change the version in `requirements.in`, then `make update-deps` to
  re-pin everything. Run `pip-audit -r requirements.txt` to confirm.
- **JavaScript:** run `npm audit fix`. If it needs breaking changes, read them first
  (`npm audit fix --force` can upgrade major versions and break things).
- Run your tests or the app before merging. Upgrades can change behaviour.
- If no fix exists yet, check whether you actually use the vulnerable function, and
  if it's low risk, ignore that ID with a written reason:
  `pip-audit --ignore-vuln PYSEC-XXXX-NN`.
- Dependabot opens these pull requests for you each week. Merging them is the
  easiest way to stay fixed.

## Semgrep flagged my code

Read the rule name and the message. Common fixes:

| Rule | Why it's risky | Fix |
|---|---|---|
| `eval-detected` | Runs any text as code | Use `ast.literal_eval` for data, or write explicit logic |
| `subprocess-shell-true` | Lets input inject shell commands | Pass a list: `subprocess.run(["ls", path])` and drop `shell=True` |
| SQL built with f-strings | SQL injection | Use parameterised queries (`cursor.execute(sql, (value,))`) |
| weak hashes (`md5`, `sha1`) | Easy to break for passwords | Use `bcrypt`, `argon2` or `hashlib.sha256` where hashing isn't for passwords |

If you're sure a finding is safe, add `# nosemgrep: <rule-id>` on that line with a comment
explaining why. Never use it just to make the red mark go away.

## Prove it's fixed

Run `make audit TARGET=<repo>` until it says "nothing found", then open a pull request
so CI confirms it. The weekly scheduled CI scan keeps checking old code
afterwards. It will tell you when a library that was fine last month becomes vulnerable.
