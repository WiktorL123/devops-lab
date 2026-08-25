# AWS mapping skill

This is a future mapping reference, not an active implementation profile.

Preserve the same lab capabilities when adapting from Azure.

Likely mappings:
- Azure Container Apps -> ECS/Fargate or App Runner
- Azure PostgreSQL -> RDS for PostgreSQL
- ACR -> ECR
- Key Vault -> Secrets Manager
- Blob state -> S3-based Terraform backend

Do not implement AWS unless explicitly requested.
When adapting, preserve the learning scope rather than redesigning the lab.
