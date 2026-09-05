# Stage 4 Terraform handoff

## Purpose

This handoff lets a fresh Codex session continue `devops-lab` on another
computer without relying on conversation history.

It records repository state and approved decisions only. It does not authorize
repository changes, Azure mutations, role assignments, Terraform `plan` or
`apply`, commits, pushes, or merges.

## Repository handoff

- Current review branch: `terraform-remote_state`.
- After the repository owner merges this branch, the next Stage 4 branch must
  be created from the updated `main`; its name is not selected by this handoff.
- On the current computer, verify the checked-out branch and worktree before
  continuing. If work later moves to another computer, the repository owner
  must first review, commit, and push the branch, then fetch and check it out on
  the destination computer.
- Agents never commit, push, or merge unless the user explicitly authorizes the
  specific operation. Agents never merge pull requests.

Suggested read-only checks at the start of a new session:

```bash
git branch --show-current
git status --short
git log -1 --oneline --decorate
terraform version
```

The repository owner performs Git integration. A fresh agent should not assume
that an uncommitted worktree from the previous computer exists remotely.

## Required reading order

1. `AGENTS.md`
2. `docs/AGENT_INDEX.md`
3. `docs/LAB_SPEC.md`
4. `docs/WORKFLOW.md`
5. `docs/PROGRESS.md`
6. `docs/architecture/ADR-001-platform-architecture.md`
7. `docs/architecture/PLATFORM_OPTIONS.md`
8. `infra/README.md`
9. `infra/modules/README.md`
10. this handoff

The active role for the next implementation work is **DevOps Builder**.

## Current project state

- Current stage: **Stage 4 — Initial Terraform with Azure Blob remote state**.
- Stage 3 selected Option B, the balanced private-data-plane architecture, in
  `polandcentral`.
- The public application hostname will be `app.devopslab.com.pl`; DNS remains
  hosted at home.pl.
- Frontend is public and proxies `/api/*` to an internally exposed backend.
- PostgreSQL is private. ACR and Key Vault initially retain public service
  endpoints protected by identity and RBAC.
- GitHub Actions is the only active CI/CD provider.
- The Azure Portal balance reported on 2026-09-05 is EUR 171.72 and expires on
  2026-09-24. This is dynamic account state and must be rechecked before a
  cost-sensitive decision or provisioning.

## Completed Stage 4 work

Atomic change-set #11 created the initial Terraform bootstrap:

- Terraform `1.16.0`;
- AzureRM `5.2.0` constrained to the `5.2.x` patch line;
- `infra/environments/dev` as the dev composition root;
- local Terraform state, with no `azurerm` backend block;
- no Terraform `resource` or `data` blocks;
- documented capability-module boundaries;
- a committed provider lock file with checksums for `darwin_arm64`,
  `linux_amd64`, and `windows_amd64`;
- repository ignores for state, generated directories, variable files, and
  saved plans.

Verification completed on the original macOS ARM64 workstation:

- `terraform fmt -check` passed;
- `terraform init -backend=false` selected the signed
  `hashicorp/azurerm v5.2.0` provider;
- `terraform validate` passed;
- `git diff --check` passed;
- no `plan`, `apply`, Azure login, Azure mutation, or cost-producing operation
  occurred.

The new computer must have Terraform `1.16.x`. Run `terraform init
-backend=false` in `infra/environments/dev` after checkout to restore the
ignored provider cache, then run `terraform validate`. Provider download is a
local dependency operation, not Azure provisioning.

Atomic change-sets #13 through #16 completed the Azure preflight and identity
bootstrap:

- Azure CLI `2.89.1` and Terraform `1.16.0` were confirmed on Windows; the same
  versions were confirmed on macOS;
- the private devops-lab tenant is the only operational tenant; the Kainos
  tenant is explicitly out of scope;
- the required Azure Resource Providers were registered;
- Container Apps quota in `polandcentral` now permits one managed environment;
- `rg-devopslab-dev-polandcentral` was created;
- four GitHub user-assigned managed identities and four environment-bound
  federated credentials were created;
- the plan identity received `Reader` at application resource-group scope;
- the apply identity received `Contributor` and conditioned `Role Based Access
  Control Administrator` at the same scope;
- the condition limits delegable roles and target principal type and does not
  permit `Owner`, `User Access Administrator`, or `Contributor` delegation;
- no client secret or paid Azure service was created.

The bootstrap implementation and operating guide are in
`scripts/bootstrap-azure-identity.ps1` and
`docs/bootstrap/AZURE_IDENTITY_BOOTSTRAP.md`.

Atomic change-set #19 implemented the first capability module:

- `infra/modules/network` owns the VNet, delegated Container Apps and
  PostgreSQL subnets, PostgreSQL private DNS zone, and VNet link;
- the `dev` root uses `10.20.0.0/16`, a `/23` Container Apps subnet, and a
  `/28` PostgreSQL subnet;
- the existing application resource group remains a module input and is not
  recreated;
- formatting and local validation completed without running `plan`, `apply`, or
  changing Azure.

Atomic change-sets #20 and #21 reviewed and applied the first local network
plan:

- the reviewed plan contained 5 resources to add, 0 to change, and 0 to
  destroy;
- local apply created `vnet-devopslab-dev-polandcentral`;
- it created the delegated `snet-container-apps` and `snet-postgres` subnets;
- it created `devopslab-dev.private.postgres.database.azure.com` and linked the
  private DNS zone to the VNet;
- Terraform outputs and local state were verified after apply;
- the state initially remained local pending its separately approved migration
  to Azure Blob Storage.

Atomic change-sets #23 and #24 completed the remote-state preflight and code:

- the private tenant, enabled subscription, `Owner` access, registered
  `Microsoft.Storage` provider, and Poland Central availability were confirmed;
- `stdevopslabtfstate190c1f` was available when checked;
- the reported Azure credit was EUR 171.72, expiring 2026-09-24;
- `infra/bootstrap/tfstate` is an independent root that retains local state;
- `infra/modules/storage` defines Standard LRS state storage, a private
  container, versioning, 14-day blob/container soft delete, and data-plane
  RBAC;
- plan/apply identities and the migration user receive `Storage Blob Data
  Contributor` at container scope;
- implementation and local validation did not plan, create, or migrate Azure
  resources.

Atomic change-sets #25 through #27 reviewed, hardened, and applied the
remote-state bootstrap:

- the saved plan created 6 resources and contained no changes or destroys;
- local-user authentication was explicitly disabled before the final plan;
- `rg-devopslab-tfstate-polandcentral`, Storage Account
  `stdevopslabtfstate190c1f`, and private container `tfstate` were created;
- Shared Key and anonymous blob access are disabled, while OAuth, HTTPS,
  minimum TLS 1.2, blob versioning, and 14-day blob/container soft delete are
  enabled;
- plan/apply identities and the migration user have `Storage Blob Data
  Contributor` at container scope;
- the bootstrap retains its independent local state.

Atomic change-sets #28 and #29 migrated and verified the main `dev` state:

- a hash-verified local pre-migration backup was preserved and remains ignored;
- `terraform init -migrate-state` copied the state to
  `tfstate/dev/terraform.tfstate`;
- the remote state retained lineage
  `1fa8166a-4e09-7c7f-4d79-40650979e62c` and all five network resources;
- blob versioning produced recoverable versions during migration;
- an Azure-normalized Container Apps subnet delegation action was added to the
  configuration;
- the final remote-backed Terraform plan reported no changes.

## Decisions already accepted

- Architecture: Option B from ADR-001.
- Initial environment: `dev` only.
- Terraform started with local state and has been migrated to the dedicated
  Azure Storage Account.
- GitHub authenticates to Azure through OIDC, without a long-lived client
  secret.
- Plan, apply, frontend deployment, and backend deployment use separated
  identities.
- Runtime frontend and backend identities are separate.
- Infrastructure uses meaningful capability modules; `container-app` is reused
  for frontend and backend.
- The first real application deployment occurs through CI/CD.

The completed network and remote-state work does not authorize additional Azure
resources, role assignments, Terraform modules, `plan`, or `apply`.

## Next work sequence

The next work remains inside Stage 4. An atomic gate is a unit of approval, not
a new project stage.

1. Select and design the next meaningful Azure foundation capability module;
   Log Analytics is the next dependency candidate for the future Container Apps
   environment.
2. Present a dedicated atomic gate before implementing the selected module.
3. Treat its Terraform plan and apply as separate reviewed actions.

Do not silently combine the identity/RBAC bootstrap, infrastructure code,
`plan`, and `apply` into one approval. If preflight reveals a new architectural
or paid-SKU choice, stop and request a new decision.

## Identity direction to preserve

ADR-001 and `PLATFORM_OPTIONS.md` define the intended identities:

- `id-gh-tf-plan-dev`;
- `id-gh-tf-apply-dev`;
- `id-gh-frontend-deploy-dev`;
- `id-gh-backend-deploy-dev`;
- `id-app-frontend-dev`;
- `id-app-backend-dev`.

The implemented design preserves least privilege and avoids subscription-wide
Contributor or Owner for GitHub. The apply identity has Contributor and
conditioned role-assignment administration only at the application
resource-group scope. The plan identity is read-only for infrastructure, and
both Terraform identities have state-container data-plane access.

The frontend and backend deployment identities can authenticate through GitHub
OIDC but currently have no ACR or Container Apps roles. Those target resources
do not exist yet. Future Terraform creates narrowly scoped assignments after
creating them. Runtime frontend and backend identities also do not exist yet
and remain Terraform-managed.

## Explicitly not authorized

- additional principals, managed identities, federated credentials, role
  assignments, or resource groups;
- paid or free Azure service resources beyond the completed network and state
  backend;
- Terraform resource/module implementation beyond the completed network and
  state backend;
- `terraform plan`, `apply`, import, state migration, or destroy;
- GitHub environments, variables, secrets, or workflow changes;
- DNS records, domain validation, or certificates;
- commit, push, pull-request creation, or merge.

Every item above requires the appropriate later atomic approval gate.
