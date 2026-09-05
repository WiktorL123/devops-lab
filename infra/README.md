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
provider configuration, local state during Stage 4, and calls to capability
modules as those modules are approved and implemented.

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

The bootstrap code does not migrate `environments/dev/terraform.tfstate`.
Backend planning, apply, RBAC propagation checks, and `init -migrate-state` are
separate approval gates. Preserve the bootstrap's local state until the final
cleanup, when the application infrastructure and its remote state have already
been handled.

## Local bootstrap

Create an untracked variables file from the committed example and replace the
placeholder subscription ID:

```bash
cd infra/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Initialize and validate without contacting Azure:

```bash
terraform init -backend=false
terraform fmt -check -recursive ../..
terraform validate
```

Do not commit `terraform.tfvars`, local state, saved plans, `.terraform/`, or
credentials. The provider dependency lock file is committed intentionally.

The first approved capability module defines the `dev` network: a VNet,
dedicated delegated subnets for Container Apps and PostgreSQL Flexible Server,
and PostgreSQL private DNS linked to the VNet. Running `plan` and `apply`
remains subject to separate atomic approval gates.
