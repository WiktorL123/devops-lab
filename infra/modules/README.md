# Terraform module boundaries

Modules are introduced only when their corresponding resource change-set is
approved. Empty wrapper modules are not created merely to mirror individual
Azure resources.

Planned capability boundaries for the accepted platform architecture:

- `network`: VNet, delegated subnets, PostgreSQL private DNS, and VNet links
  (implemented for the `dev` root in change-set #19);
- `log-analytics`: the baseline workspace and ingestion safeguards;
- `identity`: user-assigned managed identities and federated credentials;
- `acr`: Azure Container Registry and registry-specific configuration;
- `key-vault`: the runtime secret store and its security configuration;
- `postgres`: PostgreSQL Flexible Server and database configuration;
- `container-app-environment`: the VNet-integrated Container Apps environment;
- `container-app`: one reusable workload module instantiated for frontend and
  backend;
- `storage`: the later, separately bootstrapped Terraform-state storage
  capability.

The `dev` root composes these modules and owns cross-capability wiring. Role
assignments are placed with the capability whose access they grant unless a
later approved implementation reveals a clearer lifecycle boundary.
