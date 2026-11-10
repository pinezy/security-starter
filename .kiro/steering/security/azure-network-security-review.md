---
inclusion: auto
name: azure-network-security-review
description: Use when a Network Security Group, firewall rule, or public IP resource changed, to catch ports open to the whole internet.
---

# Azure network security playbook

## When to use this
A Network Security Group (NSG) rule, Azure Firewall rule, or public IP
association changed, in code or found live.

## What to check
- No inbound NSG rule allows `0.0.0.0/0` (or `Any`/`Internet`) on a
  sensitive port: SSH (22), RDP (3389), database ports (1433, 3306, 5432,
  6379, 27017, etc).
- Management ports (SSH/RDP) are reachable only via Azure Bastion, a VPN, or
  a specific known IP range, not directly from the internet.
- Databases (Azure SQL, PostgreSQL, Cosmos DB) have public network access
  disabled where possible, reachable only through a VNet/private endpoint.
- NSG rules are attached at the subnet or NIC level as intended, not left
  wide open "temporarily" and forgotten (a common source of drift between
  IaC and the live account — this is exactly what `azure-account-audit`
  catches that a one-time IaC review wouldn't).

## What a false positive looks like
A rule intentionally allowing public HTTP/HTTPS (80/443) to a public web
app's load balancer — that's expected, not a misconfiguration. The concern
is administrative/database ports open to the world, not a web server's
front door.

## Fixing it
```bash
az network nsg rule update --resource-group <rg> --nsg-name <nsg> \
  --name <rule-name> --source-address-prefixes <your-ip-or-range> \
  --access Deny  # or scope source-address-prefixes down instead of denying entirely
```
