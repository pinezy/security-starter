# Setting up Azure cloud scanning

This lets `make azure-audit` check your live Azure subscription for
misconfigurations, using [Prowler](https://docs.prowler.com) (open source,
read-only, maps findings to CIS benchmarks). This is separate from
`iac-misconfig-scan`, which checks Terraform/Bicep files before deployment —
this checks what's actually live, including anything changed by hand in the
Portal.

## The one rule: read-only, always

Whatever identity you use must only ever have the built-in **`Reader`** role
at the subscription scope. Never grant `Contributor` or `Owner` for a
security scan. `Reader` can see configuration but cannot create, change, or
delete anything, so a mistake or a leaked credential here can't modify your
infrastructure.

## Option A: scan with your own login (simplest, for solo projects)

If you're the only person on the subscription and already have access:

```bash
az login
az account show   # confirm you're on the right subscription
pip install prowler   # or: .venv/bin/pip install prowler
make azure-audit
```

The script shows the subscription name/ID and pauses before scanning, so you
can cancel if it's the wrong one.

## Option B: a dedicated read-only identity (better for teams/CI)

Create a service principal with only the `Reader` role, scoped to one
subscription:

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az ad sp create-for-rbac \
  --name "prowler-readonly" \
  --role "Reader" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID"
```

This prints an `appId` (client ID), `password` (client secret) and
`tenant`. Store the secret in a vault or CI secret store, never in the repo.
Use it with:

```bash
export AZURE_CLIENT_ID="<appId>"
export AZURE_CLIENT_SECRET="<password>"
export AZURE_TENANT_ID="<tenant>"
prowler azure --sp-env-auth
```

Rotate this secret periodically (`az ad sp credential reset`).

## Option C: no stored secret at all, for GitHub Actions

Azure supports OIDC: GitHub proves who it is with a short-lived token, Azure
trusts it via a federated credential, and no secret is stored anywhere. Set
up a federated credential on the same `Reader`-scoped app registration from
Option B (skip creating a client secret), then in the workflow:

```yaml
permissions:
  id-token: write   # required for OIDC
  contents: read
steps:
  - uses: azure/login@a641126d1b8aa4d1fa005f4f92df94a3a4c4c906 # v3.1.0
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}     # not a secret value, just an ID
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}     # not a secret value, just an ID
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  - run: pip install prowler && prowler azure --az-cli-auth
```
`azure/login` leaves the `az` CLI authenticated for later steps, so Prowler's
`--az-cli-auth` picks it up with no secret involved. See
[GitHub's Azure OIDC guide](https://docs.github.com/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
for the one-time trust setup. This repo doesn't wire this into CI by default
— add it once you actually have a subscription to point at.

## Optional: deeper identity (Entra ID) checks

A few checks (guest user review, privileged role review) need extra
Microsoft Graph permissions beyond `Reader`:
`AuditLog.Read.All`, `Directory.Read.All` (or the narrower `Domain.Read.All`),
`Policy.Read.All`. These need a tenant admin to grant consent. Skip this
entirely if you're not a tenant admin or don't need those specific checks —
the subscription-level scan works fully without them.

## Running it

```bash
make azure-audit                         # current az-cli subscription
make azure-audit SUBSCRIPTION=<sub-id>    # a specific one
```

Reports are saved under `.security-reports/azure/` (git-ignored — never
commit a report, it's a map of your real infrastructure). Read the CSV/JSON
with the playbooks in `.kiro/steering/security/azure-*.md` for what each
finding means and how to fix it.
