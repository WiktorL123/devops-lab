# Stage 4 Terraform handoff

## Purpose

This handoff lets a fresh Codex session continue `devops-lab` on another
computer without relying on conversation history.

It records repository state and approved decisions only. It does not authorize
repository changes, Azure mutations, role assignments, Terraform `plan` or
`apply`, commits, pushes, or merges.

## Repository handoff

- Expected branch: `terraform-init`.
- Before moving to another computer, the repository owner must review, commit,
  and push the current branch.
- On the other computer, fetch the remote branch and verify both the checked-out
  branch and worktree before continuing.
- Agents never commit, push, or merge unless the user explicitly authorizes the
  specific operation. Agents never merge pull requests.

Suggested read-only checks on the new computer:

```bash
git fetch
git switch terraform-init
git pull --ff-only
git branch --show-current
git status --short
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
- The most recently reported Azure promotional-credit balance is USD 175. This
  is dynamic account state and must be rechecked before a cost-sensitive
  decision or provisioning.

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

Architecture approval is not approval to create resources or role assignments.

## Next work sequence

The next work remains inside Stage 4. An atomic gate is a unit of approval, not
a new project stage.

1. Perform read-only local-tool and Azure subscription preflight. Confirm Azure
   CLI availability, authenticated tenant/subscription context, current credit,
   required resource-provider registrations, regional availability, quota, and
   the human operator's existing RBAC. Do not register providers or mutate the
   subscription during this check.
2. Design the exact identity bootstrap. Explain which action is performed once
   by the human administrator and which identities, federated credentials,
   roles, conditions, and scopes will later be managed by Terraform.
3. Present a dedicated atomic gate before creating principals, federated
   credentials, role assignments, resource groups, or any other Azure object.
4. After the identity bootstrap is separately approved and completed, present a
   new atomic gate for the first meaningful Terraform capability module and
   Azure resource definitions.
5. Treat `terraform plan` as a separate reviewed action. A plan must not be
   interpreted as approval for apply.
6. Request a separate explicit gate before the first `terraform apply`, stating
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

The design must preserve least privilege and avoid subscription-wide
Contributor or Owner for GitHub. The apply identity may need Contributor at the
application resource-group scope and constrained role-assignment administration,
but exact bootstrap commands, conditions, and scopes have not yet been approved.
The plan identity is read-only for infrastructure and later receives only the
state-container data-plane access it needs.

## Explicitly not authorized

- Azure CLI login or mutation on the user's behalf;
- resource-provider registration;
- principals, managed identities, app registrations, or federated credentials;
- Azure role assignments or custom/conditioned delegations;
- resource groups or paid/free Azure resources;
- Terraform resource/module implementation beyond the completed bootstrap;
- `terraform plan`, `apply`, import, state migration, or destroy;
- GitHub environments, variables, secrets, or workflow changes;
- DNS records, domain validation, or certificates;
- commit, push, pull-request creation, or merge.

Every item above requires the appropriate later atomic approval gate.
