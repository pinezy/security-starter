# Shortcuts. Run `make setup` once after cloning.
.PHONY: setup check audit practice demo update-deps

setup: ## Create .venv, install tools and turn on the git hooks
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install pre-commit pip-audit==2.10.1 semgrep==1.184.0 pip-tools==7.6.2
	.venv/bin/pre-commit install
	@echo "Done. Hooks are on: gitleaks now runs on every commit."

check: ## Run every scan locally
	.venv/bin/pre-commit run --all-files
	.venv/bin/pip-audit -r requirements.txt
	.venv/bin/semgrep scan --config p/default --error --metrics=off

audit: ## Read-only audit of an existing repo: make audit TARGET=/path/to/repo
	bash scripts/audit-existing-repo.sh $(or $(TARGET),.)

practice: ## Build a practice repo with planted problems (see docs/FIXING-EXISTING-ISSUES.md)
	bash scripts/practice-sandbox.sh

demo: ## Run the fake-key demo (see docs/DEMO.md)
	bash scripts/demo-fake-secret.sh

update-deps: ## Re-pin requirements.txt (with hashes) from requirements.in
	.venv/bin/pip-compile --generate-hashes --strip-extras --upgrade -o requirements.txt requirements.in
