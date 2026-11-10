# Instagram Reel outline (30 to 45 seconds)

1. **Hook (0 to 3s).** On camera or text on screen: "I tried to commit a
   password to GitHub. My laptop said no." Show the terminal in the shot.
2. **Demo (3 to 18s).** Screen recording: run the fake-key demo, type
   `git commit`, and show the red `Failed` and `RuleID: github-pat` lines.
   Add a caption that says the key is fake.
3. **Result (18 to 28s).** Switch to the GitHub Actions tab and show the three
   jobs (gitleaks, pip-audit, semgrep) with green ticks. Mention that CI is
   the backup if someone skips the local hook.
4. **Lesson (28 to 38s).** "Deleting a leaked key isn't enough, because it
   stays in git history. Revoke it first." One line each: scan for secrets,
   check dependencies, read code for risky patterns.
5. **Call to action (38 to 45s).** "Template is free on my GitHub, link in
   bio. Comment SECURE and I'll show how to add it to your repo."

Tips: use only the fake key on screen, blur your username if you like, and
add captions because most people watch without sound.
