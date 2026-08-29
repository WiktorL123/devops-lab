# Cloud Capability Mapping

Azure is the active profile.

This document exists so future AWS/GCP variants preserve the same lab intent rather than becoming unrelated tutorials.

| Capability | Azure | AWS candidate | GCP candidate |
|---|---|---|---|
| Container runtime | Azure Container Apps | ECS/Fargate or App Runner | Cloud Run |
| Managed PostgreSQL | Azure Database for PostgreSQL Flexible Server | RDS for PostgreSQL | Cloud SQL for PostgreSQL |
| Container registry | Azure Container Registry | ECR | Artifact Registry |
| Runtime secrets | Azure Key Vault | Secrets Manager | Secret Manager |
| Terraform remote state | Azure Blob Storage | S3-based backend | Cloud Storage backend |
| Private database networking | delegated subnet and private DNS for PostgreSQL Flexible Server | private RDS subnets and DNS | private IP for Cloud SQL |
| Public frontend ingress | Container Apps ingress with a custom domain | custom domain over service/ALB/App Runner endpoint | custom domain over Cloud Run ingress |
| Public TLS certificate | free Container Apps managed certificate | provider-managed certificate candidate | provider-managed certificate candidate |
| Inter-service routing | internal Container Apps communication | private service routing candidate | private service routing candidate |
| Platform logs | Log Analytics workspace | CloudWatch Logs | Cloud Logging |
| Default CI/CD | GitHub Actions | GitHub Actions | GitHub Actions |
| Alternative CI/CD | Azure Pipelines | provider-specific alternative if requested | provider-specific alternative if requested |

## Rules

- Azure-specific implementation details belong in Azure-focused skills/docs.
- Core learning rules should avoid unnecessary Azure terminology.
- Future AWS/GCP profiles should preserve:
  - two independent containerized apps,
  - managed PostgreSQL,
  - registry,
  - runtime secret manager,
  - Terraform,
  - remote state migration,
  - CI/CD gates,
  - semver + SHA image tags,
  - cost-first lab behavior,
  - a custom public frontend domain with managed TLS,
  - a backend without a separate public custom domain,
  - Tutor/Builder/Reviewer/Troubleshooter operating rules.

Domain registration and DNS hosting are separate capabilities. The active Azure
profile may use an existing external DNS provider; Azure DNS is optional and
must not be introduced solely because the runtime is hosted in Azure.

The selected Azure implementation uses the balanced private-data-plane profile:
a VNet-integrated Container Apps environment, a public frontend, an internal
backend, private PostgreSQL, and no additional paid edge proxy. The equivalent
future-cloud profiles should preserve those trust boundaries without copying
Azure-specific subnet or DNS mechanics unnecessarily.
