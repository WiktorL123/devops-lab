# Stage 4 Terraform handoff

## Purpose

This handoff lets a fresh Codex session continue `devops-lab` on another
computer without relying on conversation history.

It records repository state and approved decisions only. It does not authorize
repository changes, Azure mutations, role assignments, Terraform `plan` or
`apply`, commits, pushes, or merges.

## Repository handoff

- Expected branch for the next Stage 4 work: `terraform-network`.
- The branch was created from `main` after the Terraform and Azure identity
  bootstrap was reviewed and merged at commit `74fdde9`.
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

- Current stage: **Stage 4 — Initial Terraform with local state**.
- Stage 3 selected Option B, the balanced private-data-plane architecture, in
  `polandcentral`.
- The public application hostname will be `app.devopslab.com.pl`; DNS remains
  hosted at home.pl.
- Frontend is public and proxies `/api/*` to an internally exposed backend.
- PostgreSQL is private. ACR and Key Vault initially retain public service
  endpoints protected by identity and RBAC.
- GitHub Actions is the only active CI/CD provider.
- The Azure Portal balance reported on 2026-08-31 is EUR 175.72 and expires on
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

## Decisions already accepted

- Architecture: Option B from ADR-001.
- Initial environment: `dev` only.
- Terraform starts with local state.
- A later learning stage migrates state to a dedicated Azure Storage Account.
- GitHub authenticates to Azure through OIDC, without a long-lived client
  secret.
- Plan, apply, frontend deployment, and backend deployment use separated
  identities.
- Runtime frontend and backend identities are separate.
- Infrastructure uses meaningful capability modules; `container-app` is reused
  for frontend and backend.
- The first real application deployment occurs through CI/CD.

The completed bootstrap authorization does not authorize additional Azure
resources, role assignments, Terraform modules, `plan`, or `apply`.

## Next work sequence

The next work remains inside Stage 4. An atomic gate is a unit of approval, not
a new project stage.

1. Review the first local Terraform plan for the network module through a
   dedicated atomic gate.
2. Treat `terraform plan` as a separate reviewed action. A plan must not be
   interpreted as approval for apply.
3. Request a separate explicit gate before the first `terraform apply`, stating
   every resource and paid SKU expected to be created.

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
resource-group scope. The plan identity is read-only for infrastructure and
later receives only the state-container data-plane access it needs.

The frontend and backend deployment identities can authenticate through GitHub
OIDC but currently have no ACR or Container Apps roles. Those target resources
do not exist yet. Future Terraform creates narrowly scoped assignments after
creating them. Runtime frontend and backend identities also do not exist yet
and remain Terraform-managed.

## Explicitly not authorized

- additional principals, managed identities, federated credentials, role
  assignments, or resource groups;
- paid or free Azure service resources beyond the completed bootstrap;
- Terraform resource/module implementation beyond the completed bootstrap;
- `terraform plan`, `apply`, import, state migration, or destroy;
- GitHub environments, variables, secrets, or workflow changes;
- DNS records, domain validation, or certificates;
- commit, push, pull-request creation, or merge.

Every item above requires the appropriate later atomic approval gate.
