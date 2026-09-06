# Terraform infrastructure

This directory contains the Azure infrastructure for `devops-lab`.

## Layout

```text
infra/
├── bootstrap/
│   └── tfstate/   # independent root for the remote-state infrastructure
├── environments/
│   └── dev/       # root module for the selected dev platform
└── modules/       # reusable capability modules added incrementally
```

`environments/dev` is the composition root. It owns environment-level inputs,
provider and backend configuration, and calls to capability modules as those
modules are approved and implemented. Its state is stored remotely in the
dedicated Azure Blob backend.

The remote-state bootstrap is deliberately separate from this root. The
`bootstrap/tfstate` root retains its own local state and defines the dedicated
state resource group, Storage Account, blob container, and data-plane RBAC. The
state backend must not be managed by the application state that depends on it.

## Remote-state bootstrap

Create an untracked variables file and replace the subscription and principal
ID placeholders with the values confirmed during the read-only preflight:

```bash
cd infra/bootstrap/tfstate
cp terraform.tfvars.example terraform.tfvars
```

Initialize and validate the bootstrap without configuring a remote backend:

```bash
terraform init -backend=false
terraform fmt -check -recursive ../..
terraform validate
```

The bootstrap was applied before the `dev` state was migrated. Preserve the
bootstrap's local state until final cleanup, when the application infrastructure
and its remote state have already been handled. Do not configure this bootstrap
to depend on the backend that it owns.

## Dev environment root

Create an untracked variables file from the committed example and replace the
placeholder subscription ID:

```bash
cd infra/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Initialize the committed Azure Blob backend configuration and validate:

```bash
terraform init -backend-config=backend.tfbackend
terraform fmt -check -recursive ../..
terraform validate
```

The initial local state was migrated with `terraform init -migrate-state` after
the backend was provisioned and its data-plane RBAC was verified. Do not use
`-backend=false` for normal `dev` plans or applies after this migration.

Do not commit `terraform.tfvars`, local state, saved plans, `.terraform/`, or
credentials. The provider dependency lock file is committed intentionally.

The first approved capability module defines the deployed `dev` network: a
VNet, dedicated delegated subnets for Container Apps and PostgreSQL Flexible
Server, and PostgreSQL private DNS linked to the VNet. Further infrastructure
implementation requires an atomic approval gate. Its pull request runs plan;
the repository owner's reviewed merge authorizes the automated saved-plan
apply.

## GitHub Actions workflow

`.github/workflows/infra.yml` is path-scoped to `infra/**` and the workflow
file. Pull requests run formatting checks, initialize the committed Azure Blob
backend, validate the configuration, and create a plan using the dedicated
Terraform plan identity.

After the repository owner reviews and merges a pull request to `main`, the
workflow creates a fresh plan, retains it as a one-day artifact, and applies
that exact artifact using the separate Terraform apply identity. Applies for
the `dev` environment are serialized and are never cancelled in progress.

Both identities authenticate without a client secret through the GitHub
Environment `dev` and immutable GitHub OIDC federation. The environment defines
these non-secret variables:

```text
AZURE_CLIENT_ID_TF_PLAN
AZURE_CLIENT_ID_TF_APPLY
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

The first pull-request plan and post-merge saved-plan apply completed
successfully with no Terraform changes. A successful no-change run verifies the
authentication, remote-state, artifact, and execution paths, but does not prove
resource-mutation permissions until a later approved plan contains a real
Azure change.
