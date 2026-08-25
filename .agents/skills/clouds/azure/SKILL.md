# Azure cloud profile skill

Azure is the active cloud profile.

Default capability mapping:
- container runtime -> Azure Container Apps
- managed PostgreSQL -> Azure Database for PostgreSQL Flexible Server
- registry -> Azure Container Registry
- runtime secrets -> Azure Key Vault
- Terraform remote state -> Azure Blob Storage
- public ingress -> Container Apps ingress/default DNS

Initial environment:
- dev only

Optional:
- custom domain,
- Azure DNS,
- production environment,
- AKS,
- monitoring/observability.

Do not introduce optional resources without explicit user intent.

Respect cost-first policy.
