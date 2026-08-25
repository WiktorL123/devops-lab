# Terraform skill

Use Terraform as the infrastructure source of truth for lab-managed Azure resources.

Principles:
- infrastructure code is committed,
- state is not committed,
- modules from the beginning,
- capability-oriented modules,
- local state first,
- deliberate remote-state migration later,
- PR plan,
- post-merge saved-plan apply.

Prefer clear explicit dependencies over clever abstractions.

Never destroy the state backend before Terraform-managed resources have been destroyed.
