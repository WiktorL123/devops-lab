# Terraform infrastructure

This directory contains the Azure infrastructure for `devops-lab`.

## Layout

```text
infra/
├── environments/
│   └── dev/       # root module for the selected dev platform
└── modules/       # reusable capability modules added incrementally
```

`environments/dev` is the composition root. It owns environment-level inputs,
provider configuration, local state during Stage 4, and calls to capability
modules as those modules are approved and implemented.

The future remote-state bootstrap is deliberately separate from this root. A
later stage will create the dedicated state resource group, Storage Account, and
blob container before migrating this root to the `azurerm` backend. The state
backend must not be managed by the state that depends on it.

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

No Azure resource is defined by the initial bootstrap. `plan` and `apply` begin
only in later atomic change-sets.
