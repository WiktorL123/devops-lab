# devops-lab

Azure-first DevOps learning lab focused on CI/CD, Terraform, container delivery, secrets, managed PostgreSQL, troubleshooting, and cost-aware infrastructure.

The application itself is intentionally simple. Its job is to provide a realistic frontend/backend workload for DevOps exercises.

## Planned workload

- separate frontend and backend
- Node.js + TypeScript backend
- Prisma + PostgreSQL
- frontend selected during bootstrap
- multi-stage Dockerfiles for both applications
- local PostgreSQL with Docker Compose
- GitHub Actions CI/CD
- Terraform
- Azure Container Apps
- Azure Database for PostgreSQL Flexible Server
- Azure Container Registry
- Azure Key Vault
- Azure Blob Storage for remote Terraform state

## Agent roles

- **Implementator** - bootstraps and maintains the frontend/backend application workload.
- **DevOps Tutor** - teaches one DevOps step at a time.
- **DevOps Builder** - implements Terraform, CI/CD, and Azure deployment configuration.
- **DevOps Reviewer** - reviews DevOps/infrastructure changes using structured findings.
- **Azure Troubleshooter** - diagnoses Azure, Terraform, deployment, and pipeline failures.
- **Platform Architect** - planned for a later platform-design phase; not active yet.

After agent initialization, the first active stage is application bootstrap handled by the **Implementator**.

## Agent workflow

See:

- `AGENTS.md`
- `docs/AGENT_INDEX.md`
- `docs/LAB_SPEC.md`
- `docs/PROGRESS.md`

Repository changes use atomic approval gates.
The user owns review, approval, and merge decisions.
Agents may prepare changes and pull requests, but must not merge them.
