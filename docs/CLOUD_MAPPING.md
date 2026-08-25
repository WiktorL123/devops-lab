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
| Public service ingress | Container Apps ingress | service/ALB/App Runner endpoint | Cloud Run ingress |
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
  - Tutor/Builder/Reviewer/Troubleshooter operating rules.
