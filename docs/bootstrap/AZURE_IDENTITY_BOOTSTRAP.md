# Azure identity bootstrap

## Purpose

`scripts/bootstrap-azure-identity.ps1` prepares the one-time Azure identity
boundary required before Terraform and deployment workflows can authenticate
through GitHub OIDC.

The script is intentionally separate from Terraform because Terraform cannot
grant its own initial Azure permissions. It is idempotent: existing matching
objects are reported as `existing`, while configuration drift causes the script
to stop instead of silently overwriting security-sensitive settings.

## Current status

Atomic change-set #16 executed the script successfully on 2026-08-31. The
resource group, four GitHub identities, four federated credentials, and three
bootstrap role assignments were independently verified after execution. No
client secret or paid Azure service was created.

## Mental model

A GitHub managed identity is an Azure account-like object, not a GitHub runner.
A temporary GitHub-hosted runner presents an OIDC token. Azure validates its
repository and environment claims against the federated credential, then issues
a short-lived token for the selected managed identity. The runner can perform
only operations allowed by roles assigned to that identity.

The four GitHub identities separate responsibilities:

- Terraform plan reads infrastructure state and Azure resources;
- Terraform apply changes approved infrastructure;
- frontend deployment will push the frontend image and update only the
  frontend Container App;
- backend deployment will push the backend image, run the migration job, and
  update only the backend Container App.

Deployment identities do not pull images to run containers. Future runtime
identities, `id-app-frontend-dev` and `id-app-backend-dev`, will allow Container
Apps to pull images from ACR. The backend runtime identity will also receive the
approved Key Vault secret access.

The two deployment identities currently have federated credentials but no ACR
or Container Apps role assignments because those target resources do not exist
yet. Terraform apply will create narrowly scoped assignments after creating the
resources.

## Objects in scope

When run with `-Execute`, the script creates or reuses:

- resource group `rg-devopslab-dev-polandcentral`;
- `id-gh-tf-plan-dev`;
- `id-gh-tf-apply-dev`;
- `id-gh-frontend-deploy-dev`;
- `id-gh-backend-deploy-dev`;
- one GitHub environment federated credential on each identity.

Every federated credential uses:

```text
issuer:   https://token.actions.githubusercontent.com
subject:  repo:WiktorL123@123184089/devops-lab@1346681774:environment:dev
audience: api://AzureADTokenExchange
```

The subject uses GitHub's immutable OIDC format. The owner and repository names
remain human-readable, while `123184089` is the GitHub owner ID and `1346681774`
is the repository ID. This prevents a renamed, transferred, deleted, or
recreated namespace from inheriting the old repository's Azure trust.

The initial bootstrap used GitHub's earlier name-only subject format. GitHub
issued the immutable format when the first infrastructure workflow ran, so
change-set #32 updated all four Azure federated credentials and the bootstrap
defaults to match the token GitHub actually issues.

The script grants:

- `Reader` to the Terraform plan identity at application resource-group scope;
- `Contributor` to the Terraform apply identity at the same scope;
- `Role Based Access Control Administrator` to the apply identity at the same
  scope, with an Azure ABAC condition.

These bootstrap objects remain outside the initial application Terraform state.
Terraform must treat the resource group and four GitHub identities as existing
inputs rather than declaring duplicate resources. Moving them under Terraform
would require a later, explicitly reviewed import or bootstrap-state design.
Runtime frontend and backend identities remain Terraform-managed resources.

The condition permits only the approved reader, registry, Container Apps, job,
and Key Vault secret roles to be assigned to service principals. It does not
permit `Owner`, `User Access Administrator`, `Contributor`, or arbitrary roles.

Runtime identities do not exist yet, so this initial condition restricts target
principal type rather than exact object IDs. A later approved change should
tighten the condition to specific runtime and deployment principal IDs after
those identities exist. Until then, the constrained apply identity still cannot
grant privileged administrator roles.

## Explicitly out of scope

The script does not create:

- runtime frontend or backend identities;
- ACR, Key Vault, PostgreSQL, Container Apps, networking, or logging resources;
- Terraform state storage;
- GitHub environments, variables, secrets, or workflows;
- DNS records or certificates.

It does not run Terraform and does not commit or push repository changes.

## Prerequisites

- PowerShell 7 (`pwsh`), required for consistent cross-platform UTF-8 output;
- Azure CLI available as `az`;
- an interactive login to the private devops-lab tenant;
- the intended subscription selected before execution;
- `Owner` or equivalent resource and RBAC bootstrap permissions;
- the required Azure Resource Providers registered.

The script refuses to switch tenants or subscriptions. Both identifiers must
match the active Azure CLI context exactly.

## Review-only preview

Omitting `-Execute` validates the local tools and active Azure context, then
prints the planned object inventory without changing Azure:

```powershell
./scripts/bootstrap-azure-identity.ps1 `
  -SubscriptionId '<subscription-id>' `
  -TenantId '<private-tenant-id>'
```

## Execution

The initial execution was separately approved as change-set #16. Any rerun that
could mutate Azure still requires an appropriate atomic approval gate. The
execution form is:

```powershell
./scripts/bootstrap-azure-identity.ps1 `
  -SubscriptionId '<subscription-id>' `
  -TenantId '<private-tenant-id>' `
  -Execute
```

At completion, the script prints:

- every object it created or reused;
- each identity's client ID and principal ID;
- federated credential subjects;
- role assignments and their status;
- confirmation that no client secret or paid service was created.

Client IDs, tenant ID, and subscription ID are configuration identifiers rather
than secrets. Adding them to a GitHub environment remains a separate approved
change.

## Failure behavior

The script stops on the first Azure CLI failure. It never deletes resources or
automatically replaces an existing federated credential or conditioned role
assignment whose security settings differ from the expected configuration.

Azure role assignments are eventually consistent. If a role assignment fails
immediately after identity creation, wait briefly and rerun the same command;
the script will reuse matching objects created during the first attempt.
