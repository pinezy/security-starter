# Shortcuts. Run `make setup` once after cloning.
.PHONY: setup check audit practice demo update-deps iac-scan container-scan headers-check

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

iac-scan: ## Scan Terraform/K8s/docker-compose files: make iac-scan TARGET=/path (needs: pip install checkov)
	bash scripts/iac-scan.sh $(or $(TARGET),.)

container-scan: ## Scan a Dockerfile/image: make container-scan TARGET=Dockerfile (needs: brew install trivy)
	bash scripts/container-scan.sh $(or $(TARGET),.)

headers-check: ## Check HTTP security headers on YOUR OWN site: make headers-check URL=https://your-site.example.com
	bash scripts/headers-check.sh $(URL)
