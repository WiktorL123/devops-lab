# Terraform module boundaries

Modules are introduced only when their corresponding resource change-set is
approved. Empty wrapper modules are not created merely to mirror individual
Azure resources.

Planned capability boundaries for the accepted platform architecture:

- `network`: VNet, delegated subnets, PostgreSQL private DNS, and VNet links
  (implemented for the `dev` root in change-set #19);
- `log-analytics`: the baseline workspace and ingestion safeguards
  (implemented for the `dev` root in change-set #35);
- `identity`: user-assigned managed identities and federated credentials;
- `acr`: Azure Container Registry and repository-scoped deployment access
  (implemented for the `dev` root in change-set #36);
- `key-vault`: the runtime secret store and its security configuration;
- `postgres`: PostgreSQL Flexible Server and database configuration;
- `container-app-environment`: the VNet-integrated Container Apps environment;
- `container-app`: one reusable workload module instantiated for frontend and
  backend;
- `storage`: the separately bootstrapped Terraform-state Storage Account,
  private container, retention controls, and data-plane RBAC (implemented in
  change-set #24).

The `dev` root composes these modules and owns cross-capability wiring. Role
assignments are placed with the capability whose access they grant unless a
later approved implementation reveals a clearer lifecycle boundary.
